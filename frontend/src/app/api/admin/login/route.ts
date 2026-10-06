/**
 * POST /api/admin/login
 *
 * Secure admin-only login with 3-factor verification:
 *  1. Email must match ADMIN_LOGIN_EMAIL env var
 *  2. Password must be correct (Argon2id)
 *  3. Access key SHA-256 digest must match ADMIN_ACCESS_KEY_HASH env var
 *
 * Security:
 *  - IP rate limit: 5 attempts / 15 min
 *  - Account lockout: 5 failed attempts -> locked 30 min
 *  - JWT in httpOnly secure cookie
 *  - No public signup - admin accounts created via scripts only
 */

import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { hashPassword, verifyAccessKey, verifyPassword } from '@/lib/auth-crypto';
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

// Support multiple allowed emails (comma-separated) or single email
const ALLOWED_ADMIN_EMAILS = (process.env.ADMIN_LOGIN_EMAIL || process.env.ADMIN_EMAIL || '')
  .split(',')
  .map(e => e.toLowerCase().trim())
  .filter(Boolean);
const ALLOWED_ADMIN_EMAIL = ALLOWED_ADMIN_EMAILS[0]; // kept for the config check below

// Per-email access key hashes: admin uses ADMIN_ACCESS_KEY_HASH, superadmin gets its own key hash
const crypto = require('crypto');
const SA_ACCESS_KEY      = process.env.SUPERADMIN_ACCESS_KEY || '';
const SA_ACCESS_KEY_HASH = SA_ACCESS_KEY ? crypto.createHash('sha256').update(SA_ACCESS_KEY).digest('hex') : '';
const ADMIN_ACCESS_KEY_HASH = process.env.ADMIN_ACCESS_KEY_HASH || '';

const LoginSchema = z.object({
  email:     z.string().refine(isStrictEmail, strictEmailMessage()),
  password:  z.string().min(1),
  accessKey: z.string().regex(/^[a-f0-9]{64}$/i, 'Access key must be a 64-character hex value'),
});

/* â"€â"€ IP rate limiter â"€â"€ */
const LOGIN_LIMIT = 5;
const LOGIN_WINDOW = 15 * 60 * 1000;

export async function POST(request: NextRequest) {
  const ip = getClientIp(request);

  if (isRateLimited(`admin-login:${ip}`, LOGIN_LIMIT, LOGIN_WINDOW)) {
    return rateLimitResponse('Too many login attempts. Please try again in 15 minutes.');
  }

  try {
    await connectToDatabase();

    if (!ALLOWED_ADMIN_EMAIL || !ADMIN_ACCESS_KEY_HASH) {
      console.error('[AdminLogin]  Missing env vars - ADMIN_EMAIL:', !!ALLOWED_ADMIN_EMAIL, 'ADMIN_ACCESS_KEY_HASH:', !!ADMIN_ACCESS_KEY_HASH);
      return NextResponse.json({ error: 'Admin login is not configured.' }, { status: 503 });
    }

    const body   = sanitizeMongoInput(await request.json());
    const parsed = LoginSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: parsed.error.errors[0].message }, { status: 400 });
    }

    const { email, password, accessKey } = parsed.data;
    const normalizedEmail = email.toLowerCase().trim();

    /* ── 1. Access key check — pick hash based on email ── */
    const isSuperAdminEmail = normalizedEmail === (process.env.SUPERADMIN_EMAIL || '').toLowerCase().trim();
    const expectedHash = isSuperAdminEmail && SA_ACCESS_KEY_HASH ? SA_ACCESS_KEY_HASH : ADMIN_ACCESS_KEY_HASH;
    if (!verifyAccessKey(accessKey, expectedHash)) {
      console.warn(`[AdminLogin]  Invalid access key from IP: ${ip}`);
      return NextResponse.json({ error: 'Invalid access key.' }, { status: 403 });
    }

    /* â"€â"€ 2. Email whitelist check â"€â"€ */
    if (ALLOWED_ADMIN_EMAILS.length > 0 && !ALLOWED_ADMIN_EMAILS.includes(normalizedEmail)) {
      console.warn(`[AdminLogin] Unauthorized login attempt | IP: ${ip}`);
      return NextResponse.json({ error: 'You are not authorized to access the admin panel.' }, { status: 403 });
    }

    /* â"€â"€ 3. Find user â"€â"€ */
    const user = await AuthUser.findOne({ email: normalizedEmail });
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPERADMIN')) {
      console.warn('[AdminLogin]  User not found or not admin role');
      return NextResponse.json({ error: 'Invalid credentials.' }, { status: 401 });
    }

    /* â"€â"€ 4. Account lockout check â"€â"€ */
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      const minutesLeft = Math.ceil((user.lockedUntil.getTime() - Date.now()) / 60000);
      return NextResponse.json(
        { error: `Account locked. Try again in ${minutesLeft} minute${minutesLeft > 1 ? 's' : ''}.` },
        { status: 423 }
      );
    }

    /* â"€â"€ 5. Password check â"€â"€ */
    const passwordCheck = await verifyPassword(password, user.passwordHash);
    if (!passwordCheck.valid) {
      user.failedLoginAttempts = (user.failedLoginAttempts || 0) + 1;
      const failedAttempts = user.failedLoginAttempts;
      if (user.failedLoginAttempts >= 5) {
        user.lockedUntil         = new Date(Date.now() + 30 * 60 * 1000);
        user.failedLoginAttempts = 0;
        await user.save();
        await delayAfterFailedPassword(failedAttempts);
        return NextResponse.json({ error: 'Too many failed attempts. Account locked for 30 minutes.' }, { status: 423 });
      }
      await user.save();
      await delayAfterFailedPassword(failedAttempts);
      const remaining = 5 - user.failedLoginAttempts;
      return NextResponse.json(
        { error: `Invalid credentials. ${remaining} attempt${remaining > 1 ? 's' : ''} remaining.` },
        { status: 401 }
      );
    }

    /* â"€â"€ 6. Account status â"€â"€ */
    if (user.accountStatus === 'blocked') {
      return NextResponse.json({ error: 'Account suspended. Contact support.' }, { status: 403 });
    }
    if (user.accountStatus === 'pending') {
      return NextResponse.json({ error: 'Admin account is pending approval.' }, { status: 403 });
    }
    if (!user.isActive) {
      return NextResponse.json({ error: 'This admin account has been deactivated.' }, { status: 403 });
    }

    /* â"€â"€ 7. Success â"€â"€ */
    user.failedLoginAttempts = 0;
    user.lockedUntil         = undefined;
    if (passwordCheck.needsRehash) {
      user.passwordHash = await hashPassword(password);
    }
    user.lastLoginAt         = new Date();
    user.loginCount          = (user.loginCount || 0) + 1;
    user.lastLoginIp         = ip;
    await user.save();

    console.log(`[AdminLogin] ${user.role} login succeeded | User: ${user._id.toString()} | IP: ${ip}`);

    const token = jwt.sign(
      { userId: user._id.toString(), email: user.email, role: user.role, name: user.name },
      requireJwtSecret(),
      { expiresIn: '8h' }
    );

    const res = NextResponse.json({
      success: true,
      role: user.role,
      user: { id: user._id.toString(), email: user.email, name: user.name, role: user.role },
    });

    res.cookies.set('authToken', token, authCookieOptions(8 * 60 * 60, 'strict'));
    return res;

  } catch (err: any) {
    console.error('[AdminLogin] Error:', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
