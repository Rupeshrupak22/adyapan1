/**
 * POST /api/organization/login
 *
 * Dedicated login for organization accounts.
 * Checks ONLY the "organizationusers" collection - completely separate from
 * student/admin auth.
 *
 * Security:
 *  - IP rate limit: 5 attempts / 15 min
 *  - Account lockout: 5 failed attempts -> locked 30 min
 *  - Argon2id password verification
 *  - JWT in httpOnly secure cookie (orgToken - separate from authToken)
 *  - Only isApproved + active accounts can login
 */

import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { hashPassword, verifyPassword } from '@/lib/auth-crypto';
import { connectToDatabase } from '@/lib/mongodb';
import {
  authCookieOptions,
  delayAfterFailedPassword,
  getClientIp,
  isStrictEmail,
  isRateLimited,
  rateLimitResponse,
  requireJwtSecret,
  sanitizeMongoInput,
  strictEmailMessage,
} from '@/lib/security';
import OrganizationUser from '@/models/OrganizationUser';

const LoginSchema = z.object({
  email:    z.string().refine(isStrictEmail, strictEmailMessage()),
  password: z.string().min(1, 'Password is required'),
});

/* â"€â"€ IP rate limiter â"€â"€ */
const IP_MAX    = 5;
const IP_WINDOW = 15 * 60 * 1000;

const LOCK_AFTER   = 5;
const LOCK_MINUTES = 30;

export async function POST(request: NextRequest) {
  const ip = getClientIp(request);

  if (isRateLimited(`org-login:${ip}`, IP_MAX, IP_WINDOW)) {
    return rateLimitResponse('Too many login attempts. Please try again in 15 minutes.');
  }

  try {
    await connectToDatabase();

    const body   = sanitizeMongoInput(await request.json());
    const parsed = LoginSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: parsed.error.errors[0].message }, { status: 400 });
    }
    const { email, password } = parsed.data;
    const normalizedEmail = email.toLowerCase().trim();

    /* â"€â"€ Look up ONLY in organizationusers collection â"€â"€ */
    const user = await OrganizationUser.findOne({ email: normalizedEmail });

    if (!user) {
      console.warn(`[OrgLogin] Unknown organization login attempt | IP: ${ip}`);
      return NextResponse.json(
        { error: 'You are not authorized to access the organization portal.' },
        { status: 403 }
      );
    }

    /* â"€â"€ Approval check â"€â"€ */
    if (!user.isApproved) {
      return NextResponse.json(
        { error: 'Your organization account is not approved. Contact support@adyapan.com.' },
        { status: 403 }
      );
    }

    /* â"€â"€ Status check â"€â"€ */
    if (user.accountStatus === 'suspended') {
      return NextResponse.json(
        { error: 'Your organization account has been suspended. Contact support@adyapan.com.' },
        { status: 403 }
      );
    }

    /* â"€â"€ Account lockout check â"€â"€ */
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      const minutesLeft = Math.ceil((user.lockedUntil.getTime() - Date.now()) / 60000);
      return NextResponse.json(
        { error: `Account locked. Try again in ${minutesLeft} minute${minutesLeft > 1 ? 's' : ''}.` },
        { status: 423 }
      );
    }

    /* â"€â"€ Password check â"€â"€ */
    const passwordCheck = await verifyPassword(password, user.passwordHash);
    if (!passwordCheck.valid) {
      user.failedLoginAttempts = (user.failedLoginAttempts || 0) + 1;
      const failedAttempts = user.failedLoginAttempts;
      if (user.failedLoginAttempts >= LOCK_AFTER) {
        user.lockedUntil         = new Date(Date.now() + LOCK_MINUTES * 60 * 1000);
        user.failedLoginAttempts = 0;
        await user.save();
        await delayAfterFailedPassword(failedAttempts);
        return NextResponse.json(
          { error: `Too many failed attempts. Account locked for ${LOCK_MINUTES} minutes.` },
          { status: 423 }
        );
      }
      await user.save();
      await delayAfterFailedPassword(failedAttempts);
      const remaining = LOCK_AFTER - user.failedLoginAttempts;
      return NextResponse.json(
        { error: `Invalid email or password. ${remaining} attempt${remaining > 1 ? 's' : ''} remaining before lockout.` },
        { status: 401 }
      );
    }

    /* â"€â"€ Success â"€â"€ */
    const now = new Date();
    user.failedLoginAttempts = 0;
    user.lockedUntil         = undefined;
    if (passwordCheck.needsRehash) {
      user.passwordHash = await hashPassword(password);
    }
    user.lastLoginAt         = now;
    user.loginCount          = (user.loginCount || 0) + 1;
    user.lastLoginIp         = ip;
    await user.save();

    console.log(`[OrgLogin] Organization login succeeded | User: ${user._id.toString()} | IP: ${ip}`);

    /* â"€â"€ Issue JWT with role=COMPANY so existing middleware works â"€â"€ */
    const token = jwt.sign(
      { userId: user._id.toString(), email: user.email, role: 'COMPANY', source: 'organization' },
      requireJwtSecret(),
      { expiresIn: '7d' }
    );

    const res = NextResponse.json({
      success: true,
      user: {
        id:        user._id.toString(),
        email:     user.email,
        name:      user.name,
        role:      'COMPANY',
        loginCount: user.loginCount,
      },
    }, { status: 200 });

    /* Use same authToken cookie so existing middleware/me route works */
    res.cookies.set('authToken', token, authCookieOptions(7 * 24 * 60 * 60, 'strict'));

    return res;

  } catch (err: any) {
    console.error('[OrgLogin] Error:', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
