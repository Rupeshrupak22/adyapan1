import { NextRequest, NextResponse } from 'next/server';

type RateLimitEntry = {
  count: number;
  resetAt: number;
};

// NOTE: This is an in-memory rate limiter. It is per-instance and does NOT
// hold across serverless/Vercel lambda instances or after a cold start. It
// provides basic abuse resistance but is not a substitute for an edge/WAF rate
// limit (e.g. Cloudflare) or a shared store (Redis/Upstash) for strong limits.
const buckets = new Map<string, RateLimitEntry>();
const STRICT_EMAIL_REGEX = /^[A-Za-z0-9]+@[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)+$/;

/**
 * Best-effort client IP.
 *
 * NOTE: x-forwarded-for / x-real-ip are client-controllable unless a trusted
 * proxy (Cloudflare / Vercel) overwrites them. We PREFER cf-connecting-ip
 * (set by Cloudflare and not forgeable by the client) and, when reading
 * x-forwarded-for, take the LAST hop that the trusted proxy appended is not
 * reliably knowable, so we still fall back to the first entry but keep this
 * ordering so a spoofed header is less useful than a real edge-provided one.
 */
export function getClientIp(request: NextRequest): string {
  const cf = request.headers.get('cf-connecting-ip');
  if (cf) return cf.trim();
  const real = request.headers.get('x-real-ip');
  if (real) return real.trim();
  const xff = request.headers.get('x-forwarded-for');
  if (xff) return xff.split(',')[0]?.trim() || 'unknown';
  return 'unknown';
}

export function isRateLimited(key: string, limit: number, windowMs: number): boolean {
  const now = Date.now();
  const entry = buckets.get(key);

  if (!entry || now > entry.resetAt) {
    buckets.set(key, { count: 1, resetAt: now + windowMs });
    return false;
  }

  entry.count += 1;
  return entry.count > limit;
}

export function rateLimitResponse(message = 'Too many requests. Please try again later.') {
  return NextResponse.json({ error: message }, { status: 429 });
}

/**
 * Cookie options for auth-related cookies.
 * Defaults to sameSite='lax' because the OAuth flow (Google) relies on the
 * state cookie surviving the cross-site redirect back from accounts.google.com,
 * and 'strict' would drop it and break login. 'lax' already blocks the
 * dangerous cross-site POST/CSRF vectors for cookie-based auth.
 */
export function authCookieOptions(maxAge: number, sameSite: 'lax' | 'strict' = 'lax') {
  return {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite,
    maxAge,
    path: '/',
  };
}

export function requireJwtSecret(): string {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.length < 32 || secret.includes('fallback') || secret.includes('your_')) {
    throw new Error('JWT_SECRET must be configured with at least 32 characters.');
  }
  return secret;
}

export function sanitizeMongoInput<T>(value: T): T {
  if (Array.isArray(value)) {
    return value.map((item) => sanitizeMongoInput(item)) as T;
  }

  if (value && typeof value === 'object') {
    const output: Record<string, unknown> = {};
    for (const [key, nestedValue] of Object.entries(value as Record<string, unknown>)) {
      if (key.startsWith('$') || key.includes('.')) continue;
      output[key] = sanitizeMongoInput(nestedValue);
    }
    return output as T;
  }

  return value;
}

export function cleanText(value: unknown, max = 500): string {
  return String(value ?? '').trim().replace(/\s+/g, ' ').slice(0, max);
}

export function normalizeEmail(value: unknown): string {
  return cleanText(value, 254).toLowerCase();
}

export function isStrictEmail(value: unknown): boolean {
  const email = normalizeEmail(value);
  return email.length <= 254 && STRICT_EMAIL_REGEX.test(email);
}

export function strictEmailMessage() {
  return 'Email may contain only letters and numbers, with one @ and domain dots.';
}

export function progressiveLoginDelayMs(failedAttempts: number): number {
  if (failedAttempts <= 1) return 1000;
  if (failedAttempts === 2) return 3500;
  return 10000;
}

export async function delayAfterFailedPassword(failedAttempts: number): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, progressiveLoginDelayMs(failedAttempts)));
}

export function normalizePhone(value: unknown): string {
  return cleanText(value, 20).replace(/[^\d+]/g, '');
}

/**
 * Extracts the 10-digit Indian mobile number from any input.
 * Strips spaces, dashes, +91 / 0091 / leading 0 prefixes.
 * Returns the 10 digit core (or whatever digits remain, for validation to reject).
 */
export function normalizeIndianMobile(value: unknown): string {
  let digits = String(value ?? '').replace(/\D/g, '');
  // Strip common India prefixes: 91 (country code) or leading 0
  if (digits.length === 12 && digits.startsWith('91')) digits = digits.slice(2);
  else if (digits.length === 11 && digits.startsWith('0')) digits = digits.slice(1);
  return digits;
}

/**
 * Valid Indian mobile: exactly 10 digits, first digit between 6 and 9.
 */
export function isIndianMobile(value: unknown): boolean {
  const digits = normalizeIndianMobile(value);
  return /^[6-9]\d{9}$/.test(digits);
}

export function indianMobileMessage() {
  return 'Enter a valid 10-digit Indian mobile number starting with 6, 7, 8 or 9.';
}

/** Strip non-letters, collapse spaces, trim. */
export function normalizeName(value: unknown): string {
  return String(value ?? '').replace(/[^A-Za-z\s]/g, '').replace(/\s+/g, ' ').trim();
}

/** Valid full name: capitalised words, letters only, 2-50 chars. */
export function isValidName(value: unknown): boolean {
  const name = normalizeName(value);
  if (name.length < 2 || name.length > 50) return false;
  return /^[A-Z][a-z]*(?:\s[A-Z][a-z]*)*$/.test(name);
}

export function nameFormatMessage() {
  return 'Name must contain only letters and start with a capital letter.';
}

export function escapeRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export function isSpamSubmission(body: Record<string, unknown>): boolean {
  const honeypot = cleanText(body.website || body.companyWebsite || body.url || body._gotcha, 200);
  return honeypot.length > 0;
}

export async function verifyTurnstileToken(token: string | undefined, ip: string): Promise<boolean> {
  const secret = process.env.TURNSTILE_SECRET_KEY;
  // If no secret configured, skip verification entirely (no Turnstile widget on form)
  if (!secret || secret.includes('placeholder') || secret.includes('your_')) return true;
  // Secret is configured but no token sent — fail
  if (!token) return false;

  try {
    const response = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        secret,
        response: token,
        remoteip: ip,
      }),
    });
    const result = await response.json() as { success?: boolean };
    return Boolean(result.success);
  } catch {
    return false;
  }
}
