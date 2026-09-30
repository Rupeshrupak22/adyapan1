/**
 * Client-side name helpers.
 *
 * Rules:
 * - letters and single spaces only (no digits, no symbols)
 * - each word starts with a capital letter (title case)
 * - 2-50 characters
 */

/**
 * Keep only letters and spaces while typing, collapse repeated spaces,
 * and auto-capitalise the first letter of each word.
 */
export function sanitizeNameInput(value: string): string {
  const lettersAndSpaces = value
    .replace(/[^A-Za-z\s]/g, '')   // drop digits & symbols
    .replace(/\s{2,}/g, ' ')        // collapse multiple spaces
    .replace(/^\s+/, '');           // no leading space

  // Capitalise first letter of each word
  return lettersAndSpaces.replace(/\b([a-z])/g, (m) => m.toUpperCase());
}

/** Trim + collapse spaces (used before submitting / on the server). */
export function normalizeName(value: string): string {
  return value.replace(/[^A-Za-z\s]/g, '').replace(/\s+/g, ' ').trim();
}

/** Valid full name: capitalised words, letters only, 2-50 chars. */
export function isValidName(value: string): boolean {
  const name = normalizeName(value);
  if (name.length < 2 || name.length > 50) return false;
  return /^[A-Z][a-z]*(?:\s[A-Z][a-z]*)*$/.test(name);
}

export const NAME_FORMAT_MESSAGE =
  'Name must contain only letters and start with a capital letter.';
