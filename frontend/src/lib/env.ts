/**
 * Environment Variable Validation
 *
 * Validates all required env vars at startup.
 * Throws in production if critical vars are missing.
 * Warns in development.
 *
 * Usage: import '@/lib/env' at the top of server-side files.
 */

const isProd = process.env.NODE_ENV === 'production';

interface EnvVar {
  key:      string;
  required: boolean;
  secret?:  boolean; // don't log value
}

const ENV_VARS: EnvVar[] = [
  // Critical - app won't work without these
  { key: 'MONGODB_URI',              required: true,  secret: true  },
  { key: 'JWT_SECRET',               required: true,  secret: true  },
  { key: 'RAZORPAY_KEY_ID',          required: true,  secret: false },
  { key: 'RAZORPAY_KEY_SECRET',      required: true,  secret: true  },
  // Important - degraded functionality without these
  { key: 'NEXT_PUBLIC_APP_URL',      required: false, secret: false },
  { key: 'RESEND_API_KEY',           required: false, secret: true  },
  { key: 'RAZORPAY_WEBHOOK_SECRET',  required: false, secret: true  },
  { key: 'ADMIN_EMAIL',              required: false, secret: false },
  { key: 'NEXT_PUBLIC_BACKEND_URL',  required: false, secret: false },
];

function validateEnv(): void {
  const missing: string[] = [];
  const warnings: string[] = [];

  for (const { key, required } of ENV_VARS) {
    const value = process.env[key];
    if (!value || value.includes('your_') || value.includes('placeholder')) {
      if (required) missing.push(key);
      else warnings.push(key);
    }
  }

  if (warnings.length > 0 && !isProd) {
    console.warn(`[Env] ?  Missing optional env vars: ${warnings.join(', ')}`);
  }

  if (missing.length > 0) {
    const msg = `[Env]  Missing required env vars: ${missing.join(', ')}`;
    if (isProd) {
      throw new Error(msg);
    } else {
      console.error(msg);
    }
  }
}

// Run validation once on import (server-side only)
if (typeof window === 'undefined') {
  validateEnv();
}

// Typed env accessors - use these instead of process.env directly
export const env = {
  mongoUri:           process.env.MONGODB_URI || process.env.MONGO_URI || '',
  jwtSecret:          process.env.JWT_SECRET  || '',
  razorpayKeyId:      process.env.RAZORPAY_KEY_ID || '',
  razorpayKeySecret:  process.env.RAZORPAY_KEY_SECRET || '',
  appUrl:             process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
  backendUrl:         process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:5000',
  resendApiKey:       process.env.RESEND_API_KEY || '',
  razorpayWebhookSecret: process.env.RAZORPAY_WEBHOOK_SECRET || '',
  adminEmail:         process.env.ADMIN_EMAIL || '',
  nodeEnv:            process.env.NODE_ENV || 'development',
  isProd:             process.env.NODE_ENV === 'production',
  cloudinaryCloud:    process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME || '',
} as const;
