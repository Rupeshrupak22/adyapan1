/**
 * Centralized Media URL Abstraction
 * ---------------------------------
 * Single source of truth for resolving image / video / generic media URLs.
 *
 * Goal: keep heavy media OFF Vercel (Fast Data Transfer) by serving it from an
 * external object store / CDN, while letting the provider be swapped purely via
 * environment variables — no component code changes required.
 *
 * Resolution order for a local path like '/videos/hero.mp4':
 *   1. If it's already an absolute URL (http/https) or a data URI -> return unchanged.
 *   2. If NEXT_PUBLIC_MEDIA_BASE_URL is set (e.g. an R2 / Cloudinary / CDN origin)
 *      -> `${NEXT_PUBLIC_MEDIA_BASE_URL}/videos/hero.mp4`.
 *   3. Else if NEXT_PUBLIC_S3_BUCKET is configured -> S3 virtual-hosted URL
 *      (this preserves the existing behaviour of src/lib/s3Url.ts).
 *   4. Else -> return the local path as-is (served from Vercel /public as a
 *      safe fallback so nothing breaks before assets are uploaded).
 *
 * Switching providers later (S3 -> Cloudflare R2 -> Cloudinary -> any CDN) is a
 * one-line env change: set NEXT_PUBLIC_MEDIA_BASE_URL to the new public origin.
 */

const MEDIA_BASE_URL = (process.env.NEXT_PUBLIC_MEDIA_BASE_URL || '').replace(/\/+$/, '');

const S3_BUCKET = process.env.NEXT_PUBLIC_S3_BUCKET || 'adyapan-website-storage';
const S3_REGION = process.env.NEXT_PUBLIC_S3_REGION || 'ap-south-1';
const S3_BASE_URL = S3_BUCKET ? `https://${S3_BUCKET}.s3.${S3_REGION}.amazonaws.com` : '';

/** True for values that must never be rewritten (already absolute or inline). */
function isAbsolute(path: string): boolean {
  return (
    path.startsWith('http://') ||
    path.startsWith('https://') ||
    path.startsWith('//') ||
    path.startsWith('data:') ||
    path.startsWith('blob:')
  );
}

/** The resolved public origin used for local media paths (may be empty). */
export function getMediaBaseUrl(): string {
  return MEDIA_BASE_URL || S3_BASE_URL || '';
}

/**
 * Resolve any media path to a full URL.
 * Absolute URLs and data/blob URIs pass through unchanged.
 */
export function getMediaUrl(path: string | null | undefined): string {
  if (!path) return '';
  if (isAbsolute(path)) return path;

  const base = getMediaBaseUrl();
  if (!base) return path; // fallback: serve from /public (Vercel)

  const key = path.startsWith('/') ? path.slice(1) : path;
  return `${base}/${key}`;
}

/** Semantic alias for images. Identical resolution to getMediaUrl. */
export function getImageUrl(path: string | null | undefined): string {
  return getMediaUrl(path);
}

/** Semantic alias for videos. Identical resolution to getMediaUrl. */
export function getVideoUrl(path: string | null | undefined): string {
  return getMediaUrl(path);
}

export default getMediaUrl;
