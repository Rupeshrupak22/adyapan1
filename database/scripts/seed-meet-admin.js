/**
 * Seed script: Create "meet" ADMIN account
 *
 * Run from the database/ folder:
 *   node scripts/seed-meet-admin.js
 *
 * What it does:
 *  1. Creates (or upgrades) the admin user in MongoDB
 *  2. Prints the env vars you need to add to Vercel / Render
 */

require('dotenv').config({ path: '../frontend/.env' });
require('dotenv').config({ path: '../backend/.env' });
require('dotenv').config({ path: '.env' });

const mongoose = require('mongoose');
const bcrypt   = require('bcrypt');
const crypto   = require('crypto');

// ── Config for "meet" admin ───────────────────────────────────
// Credentials are read from the environment so NO secrets live in this file.
// Pass them inline when running, e.g.:
//   SEED_ADMIN_EMAIL=meet@adyapan.com SEED_ADMIN_PASSWORD='YourPass!' SEED_ADMIN_ACCESS_KEY='YourKey!' node scripts/seed-meet-admin.js
const ADMIN_NAME     = process.env.SEED_ADMIN_NAME       || 'Meet';
const ADMIN_EMAIL    = process.env.SEED_ADMIN_EMAIL      || '';
const ADMIN_PASSWORD = process.env.SEED_ADMIN_PASSWORD   || '';
const ACCESS_KEY_RAW = process.env.SEED_ADMIN_ACCESS_KEY || '';

const MONGODB_URI = process.env.MONGODB_URI || process.env.MONGO_URI;

if (!MONGODB_URI) {
  console.error('❌ MONGODB_URI not found in .env files');
  process.exit(1);
}

if (!ADMIN_EMAIL || !ADMIN_PASSWORD || !ACCESS_KEY_RAW) {
  console.error('❌ Missing required env vars. Run with:');
  console.error("   SEED_ADMIN_EMAIL=you@adyapan.com SEED_ADMIN_PASSWORD='YourPass!' SEED_ADMIN_ACCESS_KEY='YourKey!' node scripts/seed-meet-admin.js");
  process.exit(1);
}

// ── Derived values (auto-computed) ────────────────────────────
const ACCESS_KEY_HASH = crypto.createHash('sha256').update(ACCESS_KEY_RAW).digest('hex');

const userSchema = new mongoose.Schema({
  name:                String,
  email:               { type: String, unique: true, lowercase: true },
  passwordHash:        String,
  role:                { type: String, default: 'ADMIN' },
  accountStatus:       { type: String, default: 'approved' },
  phone:               { type: String, default: '' },
  isActive:            { type: Boolean, default: true },
  isEmailVerified:     { type: Boolean, default: true },
  loginCount:          { type: Number, default: 0 },
  failedLoginAttempts: { type: Number, default: 0 },
  signupAt:            { type: Date, default: Date.now },
}, { timestamps: true });

async function main() {
  console.log('\n🔗 Connecting to MongoDB Atlas...');
  await mongoose.connect(MONGODB_URI, { dbName: 'adyapan' });
  console.log('✅ Connected\n');

  const AuthUser = mongoose.models.AuthUser || mongoose.model('AuthUser', userSchema);

  // Hash password using bcrypt (compatible with the frontend's verifyPassword which falls back to bcrypt)
  const passwordHash = await bcrypt.hash(ADMIN_PASSWORD, 12);

  const existing = await AuthUser.findOne({ email: ADMIN_EMAIL.toLowerCase() });

  if (existing) {
    existing.name         = ADMIN_NAME;
    existing.passwordHash = passwordHash;
    existing.role         = existing.role === 'SUPERADMIN' ? 'SUPERADMIN' : 'ADMIN';
    existing.accountStatus = 'approved';
    existing.isActive     = true;
    await existing.save();
    console.log(`✅ Updated existing user → ${existing.role}: ${ADMIN_EMAIL}`);
  } else {
    await AuthUser.create({
      name:            ADMIN_NAME,
      email:           ADMIN_EMAIL.toLowerCase(),
      passwordHash,
      role:            'ADMIN',
      accountStatus:   'approved',
      isActive:        true,
      isEmailVerified: true,
    });
    console.log(`✅ Created ADMIN: ${ADMIN_EMAIL}`);
  }

  await mongoose.disconnect();

  // ── Print everything needed ───────────────────────────────
  console.log('\n' + '═'.repeat(60));
  console.log('  ADMIN CREDENTIALS (save these securely)');
  console.log('═'.repeat(60));
  console.log(`  Name       : ${ADMIN_NAME}`);
  console.log(`  Email      : ${ADMIN_EMAIL}`);
  console.log(`  Password   : ${ADMIN_PASSWORD}`);
  console.log(`  Access Key : ${ACCESS_KEY_RAW}`);
  console.log('═'.repeat(60));

  console.log('\n' + '─'.repeat(60));
  console.log('  ENV VARS — Add these to Vercel AND Render');
  console.log('─'.repeat(60));
  console.log(`  ADMIN_LOGIN_EMAIL=${ADMIN_EMAIL}`);
  console.log(`  ADMIN_EMAIL=${ADMIN_EMAIL}`);
  console.log(`  ADMIN_ACCESS_KEY_HASH=${ACCESS_KEY_HASH}`);
  console.log('─'.repeat(60));

  console.log('\n📋 Steps:');
  console.log('  1. Go to Vercel → Project → Settings → Environment Variables');
  console.log(`     Add: ADMIN_LOGIN_EMAIL  = ${ADMIN_EMAIL}`);
  console.log(`     Add: ADMIN_EMAIL        = ${ADMIN_EMAIL}`);
  console.log(`     Add: ADMIN_ACCESS_KEY_HASH = ${ACCESS_KEY_HASH}`);
  console.log('  2. Redeploy on Vercel (or it auto-deploys)');
  console.log('  3. Login at: https://adyapan.com/admin/login');
  console.log(`     Email    : ${ADMIN_EMAIL}`);
  console.log(`     Password : ${ADMIN_PASSWORD}`);
  console.log(`     Key      : ${ACCESS_KEY_RAW}`);
  console.log('\n✅ Done!\n');
}

main().catch(err => {
  console.error('❌ Failed:', err.message);
  process.exit(1);
});
