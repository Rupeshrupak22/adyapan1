/**
 * Client-side email format validation (format only, no verification).
 *
 * Rules enforced:
 * - exactly one "@"
 * - a non-empty local part and domain
 * - domain has at least one dot with a 2+ letter TLD
 * - no spaces, no leading/trailing dots, no consecutive dots
 */
const EMAIL_RE = /^[A-Za-z0-9](?:[A-Za-z0-9._%+-]*[A-Za-z0-9])?@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}$/;

export function isValidEmail(value: string): boolean {
  const email = value.trim();
  if (!email || email.length > 254) return false;
  if (email.includes('..')) return false;
  return EMAIL_RE.test(email);
}

export const EMAIL_FORMAT_MESSAGE = 'Enter a valid email address (e.g. name@example.com).';
