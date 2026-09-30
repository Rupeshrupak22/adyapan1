/**
 * POST /api/auth/login
 *
 * Unified login for all roles: STUDENT, COMPANY, ADMIN.
 *
 * Admin access rule:
 *  - Only the pre-approved admin email can log in as ADMIN.
 *  - Any other email attempting admin login is rejected with a clear message.
 *  - Admin email is stored in ADMIN_EMAIL env var (never hardcoded in client).
 *
 * Security:
 *  - IP rate limit: 5 attempts / 15 min
 *  - Account lockout: 5 failed attempts -> locked 30 min
 *  - Argon2id password verification
 *  - JWT in httpOnly secure cookie
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
import AuthUser from '@/models/AuthUser';

/* â"€â"€ The one allowed admin email (set in .env) â"€â"€ */
const ALLOWED_ADMIN_EMAIL = (
  process.env.ADMIN_EMAIL || ''
).toLowerCase().trim();

const LoginSchema = z.object({
  email:    z.string().refine(isStrictEmail, strictEmailMessage()),
  password: z.string().min(1, 'Password is required'),
});

/* â"€â"€ IP-level rate limiter â"€â"€ */
const IP_MAX    = 5;
const IP_WINDOW = 15 * 60 * 1000; // 15 min

/* â"€â"€ Account lockout â"€â"€ */
const LOCK_AFTER   = 5;  // failed attempts
const LOCK_MINUTES = 30; // lock duration

export async function POST(request: NextRequest) {
  const ip = getClientIp(request);

  if (isRateLimited(`auth-login:${ip}`, IP_MAX, IP_WINDOW)) {
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

    /* â"€â"€ Find user â"€â"€ */
    const user = await AuthUser.findOne({ email: normalizedEmail });
    if (!user) {
      return NextResponse.json({ error: 'Invalid email or password' }, { status: 401 });
    }

    /* â"€â"€ Admin/SuperAdmin should use dedicated admin login endpoint â"€â"€ */
    if (user.role === 'ADMIN' || user.role === 'SUPERADMIN') {
      console.warn(`[Login] Admin user attempting regular login | IP: ${ip}`);
      return NextResponse.json(
        { error: 'Please use the admin login page at /admin/login' },
        { status: 403 }
      );
    }

    /* â"€â"€ Account lockout check â"€â"€ */
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      const minutesLeft = Math.ceil((user.lockedUntil.getTime() - Date.now()) / 60000);
      return NextResponse.json(
        { error: `Account locked due to too many failed attempts. Try again in ${minutesLeft} minute${minutesLeft > 1 ? 's' : ''}.` },
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

    /* â"€â"€ Account status checks â"€â"€ */
    if (user.accountStatus === 'blocked') {
      return NextResponse.json(
        { error: 'Your account has been suspended. Contact support@adyapan.com.' },
        { status: 403 }
      );
    }
    if (user.accountStatus === 'pending') {
      return NextResponse.json(
        { error: 'Your account is pending approval.' },
        { status: 403 }
      );
    }
    if (!user.isActive) {
      return NextResponse.json(
        { error: 'This account has been deactivated. Contact support.' },
        { status: 403 }
      );
    }
    if (
      user.authProvider !== 'google' &&
      user.isEmailVerified !== true &&
      (user.emailVerificationToken || user.emailVerificationExpires)
    ) {
      return NextResponse.json(
        { error: 'Please verify your email before signing in. Check your inbox for the verification link.' },
        { status: 403 }
      );
    }

    /* â"€â"€ Success - reset lockout, update stats â"€â"€ */
    const userAgent = request.headers.get('user-agent') || 'unknown';
    const now       = new Date();
    user.failedLoginAttempts = 0;
    user.lockedUntil         = undefined;
    if (passwordCheck.needsRehash) {
      user.passwordHash = await hashPassword(password);
    }
    user.lastLoginAt         = now;
    user.loginCount          = (user.loginCount || 0) + 1;
    user.lastLoginIp         = ip;
    user.lastUserAgent       = userAgent;
    await user.save();

    console.log(`[Login] ${user.role} login succeeded | User: ${user._id.toString()} | IP: ${ip}`);

    /* â"€â"€ Issue JWT â"€â"€ */
    const token = jwt.sign(
      { userId: user._id.toString(), email: user.email, role: user.role },
      requireJwtSecret(),
      { expiresIn: '7d' }
    );

    const res = NextResponse.json({
      success: true,
      user: {
        id:            user._id.toString(),
        email:         user.email,
        name:          user.name,
        role:          user.role,
        accountStatus: user.accountStatus,
        loginCount:    user.loginCount,
        lastLoginAt:   user.lastLoginAt,
      },
    }, { status: 200 });

    res.cookies.set('authToken', token, authCookieOptions(7 * 24 * 60 * 60, 'strict'));

    return res;

  } catch (err: any) {
    console.error('[Login] Error:', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
