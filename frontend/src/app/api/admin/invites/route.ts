/**
 * GET  /api/admin/invites  - list all admin invites
 * POST /api/admin/invites  - create a new admin invite
 *
 * Access:
 *  GET  -> ADMIN or SUPERADMIN (admins can see invites on their dashboard)
 *  POST -> SUPERADMIN only (only superadmin can generate new invites)
 *
 * Security:
 *  - Token generated with crypto.randomBytes(64) - 128 hex chars
 *  - Token never returned in list responses (only full invite link)
 *  - Rate limited: 20 invites per hour per superadmin
 */

import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';
import { z } from 'zod';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRouteByRole, requireSuperAdmin } from '@/lib/auth';
import { isStrictEmail, strictEmailMessage } from '@/lib/security';
import { findExistingAccountByEmail, normalizeAccountEmail } from '@/lib/account-uniqueness';
import AdminInvite from '@/models/AdminInvite';
import AuthUser from '@/models/AuthUser';

/* â"€â"€ Rate limiter (in-memory, per superadmin) â"€â"€ */
const createAttempts = new Map<string, { count: number; resetAt: number }>();
const MAX_CREATES    = 20;
const CREATE_WINDOW  = 60 * 60 * 1000; // 1 hour

function checkCreateRateLimit(userId: string): boolean {
  const now   = Date.now();
  const entry = createAttempts.get(userId);
  if (!entry || now > entry.resetAt) {
    createAttempts.set(userId, { count: 1, resetAt: now + CREATE_WINDOW });
    return false;
  }
  entry.count++;
  return entry.count > MAX_CREATES;
}

/* â"€â"€ Validation schema â"€â"€ */
const CreateInviteSchema = z.object({
  email:         z.string().refine(isStrictEmail, strictEmailMessage()),
  mobileNumber:  z.string()
    .min(10, 'Mobile number must be at least 10 digits')
    .max(15, 'Mobile number too long')
    .regex(/^\+?[0-9\s\-()]+$/, 'Invalid mobile number format'),
  role:          z.enum(['ADMIN', 'ORGANIZATION'], {
    errorMap: () => ({ message: 'Role must be ADMIN or ORGANIZATION' }),
  }),
  note:          z.string().max(200).optional(),
  expiresInDays: z.number().int().min(1).max(30).default(1),
});

/* â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
   GET - list invites (ADMIN or SUPERADMIN)
â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
export async function GET(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const { searchParams } = new URL(request.url);
    const filter = searchParams.get('filter') || 'all';
    const now    = new Date();

    let query: Record<string, unknown> = {};
    if (filter === 'active')  query = { used: false, revokedAt: { $exists: false }, expiresAt: { $gt: now } };
    if (filter === 'used')    query = { used: true };
    if (filter === 'expired') query = { used: false, revokedAt: { $exists: false }, expiresAt: { $lte: now } };
    if (filter === 'revoked') query = { revokedAt: { $exists: true, $ne: null } };

    const invites = await AdminInvite.find(query)
      .sort({ createdAt: -1 })
      .limit(200)
      .lean();

    const baseUrl = process.env.NEXT_PUBLIC_APP_URL
      || `https://${request.headers.get('host')}`;

    return NextResponse.json({
      success: true,
      invites: invites.map(inv => ({
        id:             inv._id.toString(),
        email:          inv.email,
        mobileNumber:   maskMobile(inv.mobileNumber),
        role:           inv.role,
        used:           inv.used,
        usedBy:         inv.usedBy   || null,
        usedAt:         inv.usedAt   || null,
        expiresAt:      inv.expiresAt,
        invitedBy:      inv.invitedBy,
        invitedByEmail: inv.invitedByEmail,
        note:           inv.note     || '',
        revokedAt:      inv.revokedAt || null,
        revokedBy:      inv.revokedBy || null,
        failedAttempts: inv.failedAttempts,
        isExpired:      inv.expiresAt < now,
        isRevoked:      !!inv.revokedAt,
        isActive:       !inv.used && !inv.revokedAt && inv.expiresAt > now,
        // Full invite link - token embedded in URL, raw token never exposed
        inviteLink:     `${baseUrl}/admin/invite/${inv.token}`,
        createdAt:      inv.createdAt,
      })),
      total: invites.length,
    });
  } catch (err: any) {
    console.error('[AdminInvites GET]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

/* â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
   POST - create invite (SUPERADMIN only)
â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
export async function POST(request: NextRequest) {
  // Only SUPERADMIN can generate invites
  const auth = requireSuperAdmin(request);
  if (auth instanceof NextResponse) return auth;

  if (checkCreateRateLimit(auth.userId)) {
    console.warn(`[AdminInvites] ï¸ Rate limited: superadmin ${auth.userId}`);
    return NextResponse.json(
      { error: 'Too many invites created. Please wait before creating more.' },
      { status: 429 }
    );
  }

  try {
    await connectToDatabase();

    const body   = await request.json();
    const parsed = CreateInviteSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: parsed.error.errors[0].message }, { status: 400 });
    }
    const { email, mobileNumber, role, note, expiresInDays } = parsed.data;
    const normalizedEmail = normalizeAccountEmail(email);

    // Verify superadmin still exists
    const superadmin = await AuthUser.findById(auth.userId).lean();
    if (!superadmin) {
      return NextResponse.json({ error: 'Superadmin account not found' }, { status: 404 });
    }

    // Block if active invite already exists for this email
    const existingActive = await AdminInvite.findOne({
      email:     normalizedEmail,
      used:      false,
      revokedAt: { $exists: false },
      expiresAt: { $gt: new Date() },
    });
    if (existingActive) {
      return NextResponse.json(
        { error: 'An active invite already exists for this email. Revoke it first or wait for it to expire.' },
        { status: 409 }
      );
    }

    // Block if email is already a registered user
    const existingUser = await findExistingAccountByEmail(normalizedEmail);
    if (existingUser) {
      return NextResponse.json(
        { error: 'This email is already registered in the system.' },
        { status: 409 }
      );
    }

    // Generate 64-byte crypto-secure token (128 hex chars)
    const token = crypto.randomBytes(64).toString('hex');

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + expiresInDays);

    const normalizedMobile = normalizeMobile(mobileNumber);

    const invite = await AdminInvite.create({
      email:          normalizedEmail,
      mobileNumber:   normalizedMobile,
      token,
      role,
      expiresAt,
      invitedBy:      auth.userId,
      invitedByEmail: (superadmin as any).email,
      note:           note?.trim() || '',
    });

    const baseUrl   = process.env.NEXT_PUBLIC_APP_URL || `https://${request.headers.get('host')}`;
    const inviteLink = `${baseUrl}/admin/invite/${token}`;

    console.log(`[AdminInvites] Created invite ${invite._id.toString()} | Role: ${role} | By: ${auth.userId}`);

    return NextResponse.json({
      success: true,
      invite: {
        id:           invite._id.toString(),
        email:        invite.email,
        mobileNumber: maskMobile(invite.mobileNumber),
        role:         invite.role,
        expiresAt:    invite.expiresAt,
        note:         invite.note,
        inviteLink,
        createdAt:    invite.createdAt,
      },
    }, { status: 201 });

  } catch (err: any) {
    console.error('[AdminInvites POST]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

/* â"€â"€ Helpers â"€â"€ */
function normalizeMobile(mobile: string): string {
  return mobile.replace(/[\s\-()]/g, '');
}

function maskMobile(mobile: string): string {
  if (mobile.length <= 4) return '****';
  return mobile.slice(0, -4).replace(/./g, '*') + mobile.slice(-4);
}
