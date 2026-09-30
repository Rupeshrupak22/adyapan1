/**
 * POST /api/auth/signup
 *
 * PUBLIC:  role=student      - no invite needed
 * PUBLIC:  role=organization - no invite needed (invite system removed)
 *
 * Admin accounts are created ONLY via the seed script.
 * No admin signup is allowed here.
 */

import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { hashPassword } from '@/lib/auth-crypto';
import { connectToDatabase } from '@/lib/mongodb';
import {
  getClientIp,
  isStrictEmail,
  isRateLimited,
  normalizePhone,
  rateLimitResponse,
  sanitizeMongoInput,
  strictEmailMessage,
  verifyTurnstileToken,
  isValidName,
  nameFormatMessage,
  isIndianMobile,
  indianMobileMessage,
} from '@/lib/security';
import {
  findExistingAccountByEmail,
  isDuplicateEmailError,
  isDuplicatePhoneError,
  normalizeAccountEmail,
} from '@/lib/account-uniqueness';
import {
  createEmailVerificationToken,
  getEmailVerificationUrl,
  sendEmailVerificationEmail,
} from '@/lib/email-verification';
import AuthUser, { ensureAuthUserIndexes } from '@/models/AuthUser';

const SIGNUP_LIMIT = 5;
const SIGNUP_WINDOW = 15 * 60 * 1000;

async function resendPendingVerification(user: any, request: NextRequest) {
  const verification = createEmailVerificationToken();
  user.emailVerificationToken = verification.tokenHash;
  user.emailVerificationExpires = verification.expiresAt;
  await user.save();

  const sent = await sendEmailVerificationEmail({
    name: user.name,
    email: user.email,
    verificationUrl: getEmailVerificationUrl(verification.token, new URL(request.url).origin),
  });

  if (!sent) {
    return NextResponse.json(
      { error: 'Email verification is not configured or the email could not be sent. Please try again later.' },
      { status: 503 }
    );
  }

  return NextResponse.json(
    { success: true, message: 'Verification email sent. Please verify your email before signing in.' },
    { status: 200 }
  );
}

/* â"€â"€ Validation schemas â"€â"€ */
const optionalIndianPhone = z
  .string()
  .optional()
  .refine((v) => !v || isIndianMobile(v), indianMobileMessage());

const StudentSchema = z
  .object({
    firstName:       z.string().refine(isValidName, nameFormatMessage()),
    lastName:        z.string().refine(isValidName, nameFormatMessage()),
    email:           z.string().refine(isStrictEmail, strictEmailMessage()),
    password:        z.string().min(8, 'Password must be at least 8 characters'),
    confirmPassword: z.string(),
    phone:           optionalIndianPhone,
    selectedProgram: z.string().optional(),
    selectedAmount:  z.number().positive().optional(),
  })
  .refine(d => d.password === d.confirmPassword, {
    message: "Passwords don't match",
    path: ['confirmPassword'],
  });

const OrgSchema = z
  .object({
    fullName:        z.string().min(2, 'Full name must be at least 2 characters').max(100),
    companyName:     z.string().min(2, 'Company name must be at least 2 characters').max(150),
    email:           z.string().refine(isStrictEmail, strictEmailMessage()),
    password:        z.string().min(8, 'Password must be at least 8 characters'),
    confirmPassword: z.string(),
    phone:           optionalIndianPhone,
  })
  .refine(d => d.password === d.confirmPassword, {
    message: "Passwords don't match",
    path: ['confirmPassword'],
  });

export async function POST(request: NextRequest) {
  const ip = getClientIp(request);

  if (isRateLimited(`auth-signup:${ip}`, SIGNUP_LIMIT, SIGNUP_WINDOW)) {
    return rateLimitResponse('Too many signup attempts. Please try again in 15 minutes.');
  }

  try {
    await connectToDatabase();
    await ensureAuthUserIndexes();

    const body = sanitizeMongoInput(await request.json());
    const { role, ...data } = body;

    const userAgent = request.headers.get('user-agent') || 'unknown';
    const now       = new Date();

    const turnstileOk = await verifyTurnstileToken(
      typeof body.cfTurnstileToken === 'string' ? body.cfTurnstileToken : undefined,
      ip
    );
    if (!turnstileOk) {
      return NextResponse.json({ error: 'Security check failed. Please try again.' }, { status: 400 });
    }

    /* â"€â"€ Block any attempt to self-register as admin â"€â"€ */
    if (role === 'admin' || role === 'ADMIN' || role === 'superadmin') {
      return NextResponse.json(
        { error: 'You are not authorized to create this account.' },
        { status: 403 }
      );
    }

    /* â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
       STUDENT SIGNUP
    â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â• */
    if (role === 'student') {
      const parsed = StudentSchema.safeParse(data);
      if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.errors[0].message }, { status: 400 });
      }
      const d = parsed.data;

      const normalizedEmail = normalizeAccountEmail(d.email);
      const phone = normalizePhone(d.phone) || undefined;
      const existingEmail = await findExistingAccountByEmail(normalizedEmail);
      const existingPhone = phone ? await AuthUser.findOne({ phone }).select('_id').lean() : null;
      if (existingEmail || existingPhone) {
        const pendingUser = await AuthUser.findOne({ email: normalizedEmail });
        if (
          pendingUser &&
          pendingUser.role === 'STUDENT' &&
          pendingUser.isEmailVerified !== true &&
          !existingPhone
        ) {
          return resendPendingVerification(pendingUser, request);
        }
        return NextResponse.json({ error: 'Email or phone already registered' }, { status: 409 });
      }

      const passwordHash = await hashPassword(d.password);
      const verification = createEmailVerificationToken();
      const user = await AuthUser.create({
        email:            normalizedEmail,
        name:             `${d.firstName.trim()} ${d.lastName.trim()}`,
        passwordHash,
        role:             'STUDENT',
        accountStatus:    'approved',
        ...(phone ? { phone } : {}),
        selectedProgram:  d.selectedProgram || null,
        selectedAmount:   d.selectedAmount  || null,
        purchasedCourses: [],
        enrolledCourses:  [],
        wishlist:         [],
        loginCount:       0,
        signupIp:         ip,
        userAgent,
        signupAt:         now,
        isEmailVerified:  false,
        emailVerificationToken: verification.tokenHash,
        emailVerificationExpires: verification.expiresAt,
      });

      console.log(`[Signup] STUDENT account created | User: ${user._id.toString()} | IP: ${ip}`);

      const sent = await sendEmailVerificationEmail({
        name: user.name,
        email: user.email,
        verificationUrl: getEmailVerificationUrl(verification.token, new URL(request.url).origin),
      });
      if (!sent) {
        await AuthUser.deleteOne({ _id: user._id });
        return NextResponse.json(
          { error: 'Email verification is not configured or the email could not be sent. Please try again later.' },
          { status: 503 }
        );
      }

      return NextResponse.json({
        success: true,
        message: 'Account created. Please verify your email before signing in.',
        user: { id: user._id.toString(), email: user.email, name: user.name, role: user.role, accountStatus: user.accountStatus },
      }, { status: 201 });
    }

    /* â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
       ORGANIZATION SIGNUP - no invite needed
    â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â• */
    if (role === 'organization') {
      const parsed = OrgSchema.safeParse(data);
      if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.errors[0].message }, { status: 400 });
      }
      const d = parsed.data;

      const normalizedEmail = normalizeAccountEmail(d.email);
      const phone = normalizePhone(d.phone) || undefined;
      const existingEmail = await findExistingAccountByEmail(normalizedEmail);
      const existingPhone = phone ? await AuthUser.findOne({ phone }).select('_id').lean() : null;
      if (existingEmail || existingPhone) {
        const pendingUser = await AuthUser.findOne({ email: normalizedEmail });
        if (
          pendingUser &&
          pendingUser.role === 'COMPANY' &&
          pendingUser.isEmailVerified !== true &&
          !existingPhone
        ) {
          return resendPendingVerification(pendingUser, request);
        }
        return NextResponse.json({ error: 'Email or phone already registered' }, { status: 409 });
      }

      const passwordHash = await hashPassword(d.password);
      const verification = createEmailVerificationToken();
      const user = await AuthUser.create({
        email:          normalizedEmail,
        name:           d.fullName.trim(),
        passwordHash,
        role:           'COMPANY',
        accountStatus:  'approved',
        ...(phone ? { phone } : {}),
        companyName:    d.companyName.trim(),
        purchasedCourses: [],
        enrolledCourses:  [],
        wishlist:         [],
        loginCount:       0,
        signupIp:         ip,
        userAgent,
        signupAt:         now,
        isEmailVerified:  false,
        emailVerificationToken: verification.tokenHash,
        emailVerificationExpires: verification.expiresAt,
      });

      console.log(`[Signup] COMPANY account created | User: ${user._id.toString()} | IP: ${ip}`);

      const sent = await sendEmailVerificationEmail({
        name: user.name,
        email: user.email,
        verificationUrl: getEmailVerificationUrl(verification.token, new URL(request.url).origin),
      });
      if (!sent) {
        await AuthUser.deleteOne({ _id: user._id });
        return NextResponse.json(
          { error: 'Email verification is not configured or the email could not be sent. Please try again later.' },
          { status: 503 }
        );
      }

      return NextResponse.json({
        success: true,
        message: 'Account created. Please verify your email before signing in.',
        user: { id: user._id.toString(), email: user.email, name: user.name, role: user.role, accountStatus: user.accountStatus },
      }, { status: 201 });
    }

    return NextResponse.json(
      { error: 'You are not authorized to create this account.' },
      { status: 403 }
    );

  } catch (error) {
    if (isDuplicateEmailError(error)) {
      return NextResponse.json({ error: 'Email already registered' }, { status: 409 });
    }
    if (isDuplicatePhoneError(error)) {
      return NextResponse.json({ error: 'Phone number already registered' }, { status: 409 });
    }
    if ((error as any)?.name === 'ZodError') {
      return NextResponse.json({ error: (error as any).errors[0].message }, { status: 400 });
    }
    console.error('[Signup] Error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
