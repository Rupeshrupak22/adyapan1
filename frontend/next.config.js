/** @type {import('next').NextConfig} */
const securityHeaders = [
  { key: 'X-Frame-Options', value: 'SAMEORIGIN' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'X-XSS-Protection', value: '1; mode=block' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
  {
    key: 'Content-Security-Policy',
    value: [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://checkout.razorpay.com https://challenges.cloudflare.com",
      "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
      "img-src 'self' data: blob: https:",
      "font-src 'self' data: https://fonts.gstatic.com",
      "media-src 'self' data: blob: https: https://*.amazonaws.com https://adyapan-website-storage.s3.ap-south-1.amazonaws.com",
      "connect-src 'self' https://api.razorpay.com https://*.mongodb.net https://challenges.cloudflare.com https://*.amazonaws.com https://adyapan-website-storage.s3.ap-south-1.amazonaws.com",
      "frame-src https://api.razorpay.com https://checkout.razorpay.com https://challenges.cloudflare.com https://www.youtube.com https://www.youtube-nocookie.com https://player.vimeo.com",
      "object-src 'none'",
      "base-uri 'self'",
      "form-action 'self'",
      "frame-ancestors 'self'",
    ].join('; '),
  },
  ...(process.env.NODE_ENV === 'production' ? [
    { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
  ] : []),
];

// Polyfill localStorage on server to prevent crashes.
// Newer Node versions ship an experimental built-in `localStorage` that
// requires `--localstorage-file`; without it, its methods throw. So we
// override whenever a working `getItem` is not present.
if (typeof global !== 'undefined' &&
    (typeof global.localStorage === 'undefined' ||
     typeof global.localStorage.getItem !== 'function')) {
  const noopStorage = {
    getItem: () => null,
    setItem: () => {},
    removeItem: () => {},
    clear: () => {},
    key: () => null,
    length: 0,
  };
  try {
    Object.defineProperty(global, 'localStorage', {
      value: noopStorage,
      writable: true,
      configurable: true,
    });
  } catch {
    global.localStorage = noopStorage;
  }
}

const nextConfig = {
  // ─── Core ────────────────────────────────────────────────────────────────
  reactStrictMode: true,
  devIndicators:   false,
  transpilePackages: ['axios'],

  // ─── Server external packages ─────────────────────────────────────────────
  // These packages are excluded from edge runtime bundling
  // Prevents middleware.js.nft.json generation failure on Vercel
  serverExternalPackages: [
    'argon2',
    'bcrypt',
    '@aws-sdk/client-s3',
    '@aws-sdk/s3-request-presigner',
    'pdfkit',
    'mongoose',
    'nodemailer',
  ],

  // ─── Image optimisation ──────────────────────────────────────────────────
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'images.unsplash.com',    pathname: '/**' },
      { protocol: 'https', hostname: 'api.qrserver.com',       pathname: '/**' },
      { protocol: 'https', hostname: 'chart.googleapis.com',   pathname: '/**' },
      { protocol: 'https', hostname: 'res.cloudinary.com',     pathname: '/**' },
      { protocol: 'https', hostname: 'upload.wikimedia.org',   pathname: '/**' },
      { protocol: 'https', hostname: 'logo.clearbit.com',      pathname: '/**' },
      { protocol: 'https', hostname: 'videos.pexels.com',      pathname: '/**' },
      { protocol: 'https', hostname: 'static.vecteezy.com',    pathname: '/**' },
      { protocol: 'https', hostname: 'adyapan-website-storage.s3.ap-south-1.amazonaws.com', pathname: '/**' },
    ],
    formats:          ['image/avif', 'image/webp'],
    minimumCacheTTL:  31536000,   // 1 year cache TTL to prevent Vercel re-optimization bandwidth spikes
    deviceSizes:      [640, 750, 828, 1080, 1200, 1920],
    imageSizes:       [16, 32, 48, 64, 96, 128, 256, 384],
    dangerouslyAllowSVG: false,
  },

  // ─── Bundle optimisation ─────────────────────────────────────────────────
  modularizeImports: {
    'date-fns': { transform: 'date-fns/{{member}}' },
  },

  // ─── Compiler optimisations ──────────────────────────────────────────────
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production'
      ? { exclude: ['error', 'warn'] }
      : false,
  },

  // ─── TypeScript ──────────────────────────────────────────────────────────
  typescript: {
    ignoreBuildErrors: true,
  },

  // ─── Security & Caching Headers ──────────────────────────────────────────
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: securityHeaders,
      },
      // Aggressively cache static assets at Vercel Edge CDN
      {
        source: '/course-thumbnails/(.*)',
        headers: [
          { key: 'Cache-Control', value: 'public, max-age=31536000, immutable' },
        ],
      },
      {
        source: '/images/(.*)',
        headers: [
          { key: 'Cache-Control', value: 'public, max-age=31536000, immutable' },
        ],
      },
    ];
  },

  // ─── Redirects ───────────────────────────────────────────────────────────
  async redirects() {
    return [
      {
        source:      '/offline-service',
        destination: '/offline-services',
        permanent:   true,
      },
      ...(process.env.NODE_ENV === 'production' ? [
        {
          source:      '/:path*',
          has:         [{ type: 'host', value: 'www.adyapan.com' }],
          destination: 'https://adyapan.com/:path*',
          permanent:   true,
        },
      ] : []),
    ];
  },
};

module.exports = nextConfig;
