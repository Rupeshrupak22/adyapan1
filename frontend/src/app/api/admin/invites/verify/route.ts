/**
 * POST /api/admin/invites/verify
 *
 * Verify an invite token and return invite details (PUBLIC endpoint).
 * Called by /admin/signup?token=... page on load to validate before showing form.
 *
 * Security:
 *  - Rate limited: 10 attempts per IP per 15 minutes
 *  - Logs failed attempts on the invite record
 *  - Never exposes full mobile number (masked: ****7890)
 *  - Never exposes raw token in response
 */

import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { connectToDatabase } from '@/lib/mongodb';
import AdminInvite from '@/models/AdminInvite';

/* â"€â"€ Rate limiter (in-memory, per IP) â"€â"€ */
const verifyAttempts = new Map<string, { count: number; resetAt: number }>();
const MAX_VERIFY = 10;
const VERIFY_WINDOW_MS = 15 * 60 * 1000;

function checkVerifyRateLimit(ip: string): boolean {
  const now = Date.now();
  const entry = verifyAttempts.get(ip);
  if (!entry || now > entry.resetAt) {
    verifyAttempts.set(ip, { count: 1, resetAt: now + VERIFY_WINDOW_MS });
    return false;
  }
  entry.count++;
  return entry.count > MAX_VERIFY;
}

const VerifySchema = z.object({
  token: z.string().min(1, 'Token is required'),
});

export async function POST(request: NextRequest) {
  const ip = request.headers.get('x-forwarded-for')?.split(',')[0]?.trim()
          || request.headers.get('x-real-ip')
          || 'unknown';

  if (checkVerifyRateLimit(ip)) {
    console.warn(`[InviteVerify] ï¸ Rate limited: ${ip}`);
    return NextResponse.json(
      { error: 'Too many verification attempts. Please try again later.' },
      { status: 429 }
    );
  }

  try {
    await connectToDatabase();

    const body = await request.json();
    const parsed = VerifySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: parsed.error.errors[0].message }, { status: 400 });
    }
    const { token } = parsed.data;

    const invite = await AdminInvite.findOne({ token }).lean();

    if (!invite) {
      console.warn(`[InviteVerify]  Invalid token from IP: ${ip}`);
      return NextResponse.json(
        { error: 'Invalid invite link. Please contact your administrator.' },
        { status: 404 }
      );
    }

    const now = new Date();

    if (invite.used) {
      console.warn(`[InviteVerify] Already used invite ${invite._id} | IP: ${ip}`);
      // Log failed attempt
      await AdminInvite.updateOne(
        { _id: invite._id },
        { $inc: { failedAttempts: 1 }, $set: { lastFailedAt: now } }
      );
      return NextResponse.json(
        { error: 'This invite has already been used.' },
        { status: 403 }
      );
    }

    if (invite.expiresAt < now) {
      console.warn(`[InviteVerify] Expired invite ${invite._id} | IP: ${ip}`);
      await AdminInvite.updateOne(
        { _id: invite._id },
        { $inc: { failedAttempts: 1 }, $set: { lastFailedAt: now } }
      );
      return NextResponse.json(
        { error: 'This invite has expired. Please request a new one.' },
        { status: 403 }
      );
    }

    if (invite.revokedAt) {
      console.warn(`[InviteVerify] Revoked invite ${invite._id} | IP: ${ip}`);
      await AdminInvite.updateOne(
        { _id: invite._id },
        { $inc: { failedAttempts: 1 }, $set: { lastFailedAt: now } }
      );
      return NextResponse.json(
        { error: 'This invite has been revoked. Please contact your administrator.' },
        { status: 403 }
      );
    }

    console.log(`[InviteVerify]  Valid token for ${invite.email} | IP: ${ip}`);

    return NextResponse.json({
      success: true,
      invite: {
        email:        invite.email,
        mobileHint:   maskMobile(invite.mobileNumber),
        role:         invite.role,
        expiresAt:    invite.expiresAt,
        invitedBy:    invite.invitedByEmail,
      },
    });

  } catch (err: any) {
    console.error('[InviteVerify]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

function maskMobile(mobile: string): string {
  if (mobile.length <= 4) return '****';
  return mobile.slice(0, -4).replace(/./g, '*') + mobile.slice(-4);
}
