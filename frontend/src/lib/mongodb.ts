/**
 * MongoDB Atlas Connection - Next.js Frontend
 *
 * Singleton pattern for Next.js - reuses connection across hot reloads.
 * Uses MONGODB_URI from environment variables (never hardcoded).
 * Works on localhost, Vercel, Render, Railway.
 */

import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI;

// Don't throw at module evaluation time " this breaks the build.
// The check happens at connection time instead.

type MongooseCache = {
  conn: typeof mongoose | null;
  promise: Promise<typeof mongoose> | null;
};

// Preserve connection across Next.js hot reloads in development
const globalForMongoose = global as typeof globalThis & {
  mongoose?: MongooseCache;
};

const cached: MongooseCache = globalForMongoose.mongoose ?? {
  conn: null,
  promise: null,
};

export async function connectToDatabase(): Promise<typeof mongoose> {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    throw new Error(
      '[MongoDB] MONGODB_URI is not defined. Add it to your .env file.'
    );
  }

  // Return existing connection if available
  if (cached.conn) {
    return cached.conn;
  }

  // Create new connection promise if none exists
  if (!cached.promise) {
    cached.promise = mongoose
      .connect(uri, {
        dbName: process.env.DB_NAME || 'adyapan',
        serverSelectionTimeoutMS: 15000,
        socketTimeoutMS: 45000,
        bufferCommands: false,
      })
      .then((m) => {
        console.log('[MongoDB]  Connected to Atlas:', m.connection.host);
        return m;
      })
      .catch((err) => {
        cached.promise = null; // Reset so next call retries
        console.error('[MongoDB]  Connection failed:', err.message);
        throw err;
      });
  }

  cached.conn = await cached.promise;
  globalForMongoose.mongoose = cached;

  // ── One-time migration: drop legacy unique indexes on certificates ──
  // These cause false 409s when adding multiple certs for the same student.
  try {
    const db = mongoose.connection.db;
    if (db) {
      const col = db.collection('certificates');
      const indexes = await col.indexes();
      const toDrop = ['certificateId_1', 'userId_1_courseSlug_1'];
      for (const name of toDrop) {
        if (indexes.some((i: any) => i.name === name && i.unique)) {
          await col.dropIndex(name);
          console.log(`[MongoDB] Dropped unique index: ${name}`);
        }
      }
    }
  } catch {
    // Migration is best-effort — never block the app
  }

  return cached.conn;
}
