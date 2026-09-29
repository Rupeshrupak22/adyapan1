/**
 * Client-side Indian mobile helpers (mirror of the server checks in security.ts).
 */

/** Keep only digits and clamp to a sane length while typing. */
export function sanitizeMobileInput(value: string): string {
  return value.replace(/\D/g, '').slice(0, 10);
}

/** Extract the 10-digit core, stripping +91 / 0091 / leading 0. */
export function normalizeIndianMobile(value: string): string {
  let digits = value.replace(/\D/g, '');
  if (digits.length === 12 && digits.startsWith('91')) digits = digits.slice(2);
  else if (digits.length === 11 && digits.startsWith('0')) digits = digits.slice(1);
  return digits;
}

/** Valid Indian mobile: exactly 10 digits starting with 6-9. */
export function isIndianMobile(value: string): boolean {
  return /^[6-9]\d{9}$/.test(normalizeIndianMobile(value));
}

export const INDIAN_MOBILE_MESSAGE =
  'Enter a valid 10-digit Indian mobile number starting with 6, 7, 8 or 9.';
