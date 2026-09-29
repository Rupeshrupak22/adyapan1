/**
 * S3 Media URL Utility (compatibility shim)
 * -----------------------------------------
 * Historically this resolved media to a hard S3 URL. It now delegates to the
 * centralized, provider-switchable helper in `src/lib/media.ts` so that all
 * media resolution (S3 today, R2/Cloudinary/CDN tomorrow) is controlled from a
 * single place via environment variables.
 *
 * Behaviour is preserved: with the default env (S3 bucket configured), this
 * returns the same S3 URLs as before. Absolute URLs still pass through.
 *
 * Existing usage remains valid:
 *   s3Url('/images/team.jpg')
 */

import { getMediaUrl, getMediaBaseUrl } from './media';

/**
 * Convert a local media path to a full media URL.
 * Absolute URLs (http/https/data/blob) pass through unchanged.
 */
export function s3Url(path: string): string {
  return getMediaUrl(path);
}

/**
 * Get the media base URL (S3 origin by default, or NEXT_PUBLIC_MEDIA_BASE_URL).
 */
export function getS3BaseUrl(): string {
  return getMediaBaseUrl();
}

export default s3Url;
