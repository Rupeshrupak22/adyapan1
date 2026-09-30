/**
 * Client-side password policy (mirrors the server zod schema: min 8).
 * Requires: min 8 chars, at least one letter and one number.
 */
export function isValidPassword(value: string): boolean {
  if (typeof value !== 'string' || value.length < 8 || value.length > 128) return false;
  return /[A-Za-z]/.test(value) && /\d/.test(value);
}

export const PASSWORD_POLICY_MESSAGE =
  'Password must be at least 8 characters and include a letter and a number.';

/** 0-4 rough strength score for a UI meter. */
export function passwordStrength(value: string): number {
  let score = 0;
  if (value.length >= 8) score++;
  if (value.length >= 12) score++;
  if (/[A-Z]/.test(value) && /[a-z]/.test(value)) score++;
  if (/\d/.test(value)) score++;
  if (/[^A-Za-z0-9]/.test(value)) score++;
  return Math.min(4, score);
}
