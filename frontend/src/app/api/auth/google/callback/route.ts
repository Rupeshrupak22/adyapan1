import { randomBytes } from 'crypto';
import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import { hashPassword } from '@/lib/auth-crypto';
import { connectToDatabase } from '@/lib/mongodb';
import { normalizeAccountEmail } from '@/lib/account-uniqueness';
import { authCookieOptions, getClientIp, requireJwtSecret } from '@/lib/security';
import AuthUser, { ensureAuthUserIndexes } from '@/models/AuthUser';

const STATE_COOKIE = 'googleOAuthState';
const GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token';
const GOOGLE_USERINFO_URL = 'https://openidconnect.googleapis.com/v1/userinfo';

type GoogleState = {
  nonce?: string;
  role?: 'student' | 'organization';
  mode?: 'login' | 'signup';
  redirect?: string;
};

type GoogleProfile = {
  sub: string;
  email: string;
  email_verified?: boolean;
  name?: string;
  given_name?: string;
  family_name?: string;
  picture?: string;
};

function getAppUrl(request: NextRequest) {
  return (
    process.env.NEXT_PUBLIC_APP_URL ||
    process.env.NEXTAUTH_URL ||
    request.nextUrl.origin
  ).replace(/\/$/, '');
}

function decodeState(rawState: string | null): GoogleState | null {
  if (!rawState) return null;
  try {
    return JSON.parse(Buffer.from(rawState, 'base64url').toString('utf8'));
  } catch {
    return null;
  }
}

function redirectWithError(request: NextRequest, message: string) {
  const url = new URL('/login', request.url);
  url.searchParams.set('error', message);
  return NextResponse.redirect(url);
}

async function fetchGoogleProfile(request: NextRequest, code: string): Promise<GoogleProfile> {
  const clientId = process.env.GOOGLE_CLIENT_ID;
  const clientSecret = process.env.GOOGLE_CLIENT_SECRET;
  if (!clientId || !clientSecret) {
    throw new Error('Google OAuth is not configured.');
  }

  const tokenResponse = await fetch(GOOGLE_TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      code,
      client_id: clientId,
      client_secret: clientSecret,
      redirect_uri: `${getAppUrl(request)}/api/auth/google/callback`,
      grant_type: 'authorization_code',
    }),
  });

  if (!tokenResponse.ok) {
    throw new Error('Google token exchange failed.');
  }

  const tokenData = await tokenResponse.json() as { access_token?: string };
  if (!tokenData.access_token) {
    throw new Error('Google did not return an access token.');
  }

  const profileResponse = await fetch(GOOGLE_USERINFO_URL, {
    headers: { Authorization: `Bearer ${tokenData.access_token}` },
  });

  if (!profileResponse.ok) {
    throw new Error('Google profile fetch failed.');
  }

  return profileResponse.json() as Promise<GoogleProfile>;
}

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get('code');
  const state = decodeState(request.nextUrl.searchParams.get('state'));
  const savedNonce = request.cookies.get(STATE_COOKIE)?.value;

  if (!code || !state?.nonce || !savedNonce || state.nonce !== savedNonce) {
    return redirectWithError(request, 'google_state_invalid');
  }

  try {
    await connectToDatabase();
    await ensureAuthUserIndexes();

    const profile = await fetchGoogleProfile(request, code);
    if (!profile.email || !profile.sub) {
      return redirectWithError(request, 'google_profile_missing');
    }
    if (profile.email_verified === false) {
      return redirectWithError(request, 'google_email_unverified');
    }

    const ip = getClientIp(request);
    const userAgent = request.headers.get('user-agent') || 'unknown';
    const normalizedEmail = normalizeAccountEmail(profile.email);
    const now = new Date();

    let user = await AuthUser.findOne({ email: normalizedEmail });

    if (user?.role === 'ADMIN' || user?.role === 'SUPERADMIN') {
      return redirectWithError(request, 'admin_google_login_disabled');
    }

    if (user) {
      if (user.accountStatus === 'blocked' || !user.isActive) {
        return redirectWithError(request, 'account_suspended');
      }

      user.googleId = profile.sub;
      user.authProvider = user.authProvider === 'local' ? 'local,google' : user.authProvider || 'google';
      user.avatar = user.avatar || profile.picture || '';
      user.isEmailVerified = true;
      user.failedLoginAttempts = 0;
      user.lockedUntil = undefined;
      user.lastLoginAt = now;
      user.loginCount = (user.loginCount || 0) + 1;
      user.lastLoginIp = ip;
      user.lastUserAgent = userAgent;
      await user.save();
    } else {
      const role = state.role === 'organization' ? 'COMPANY' : 'STUDENT';
      const name = (profile.name || [profile.given_name, profile.family_name].filter(Boolean).join(' ') || normalizedEmail.split('@')[0]).trim();
      const passwordHash = await hashPassword(`google:${profile.sub}:${randomBytes(24).toString('hex')}`);

      user = await AuthUser.create({
        email: normalizedEmail,
        name,
        passwordHash,
        role,
        accountStatus: 'approved',
        authProvider: 'google',
        googleId: profile.sub,
        avatar: profile.picture || '',
        companyName: role === 'COMPANY' ? '' : undefined,
        purchasedCourses: [],
        enrolledCourses: [],
        wishlist: [],
        isEmailVerified: true,
        loginCount: 1,
        lastLoginAt: now,
        lastLoginIp: ip,
        lastUserAgent: userAgent,
        signupIp: ip,
        userAgent,
        signupAt: now,
      });
    }

    const token = jwt.sign(
      { userId: user._id.toString(), email: user.email, role: user.role },
      requireJwtSecret(),
      { expiresIn: '7d' }
    );

    const redirectTo = state.redirect ||
      (user.role === 'COMPANY' ? '/organization' : '/dashboard/student');
    const response = NextResponse.redirect(new URL(redirectTo, request.url));
    response.cookies.set('authToken', token, authCookieOptions(7 * 24 * 60 * 60, 'strict'));
    response.cookies.set(STATE_COOKIE, '', { ...authCookieOptions(0), maxAge: 0 });
    return response;
  } catch (error) {
    console.error('[Google OAuth]', error);
    return redirectWithError(request, 'google_login_failed');
  }
}
