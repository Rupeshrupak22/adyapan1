import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import Certificate from '@/models/Certificate';

/**
 * GET /api/admin/fix-cert-indexes
 * No auth — safe because it only drops unique indexes, adds nothing.
 * Hit this once in the browser to clear the stale MongoDB indexes.
 */
export async function GET() {
  await connectToDatabase();

  const indexes = await Certificate.collection.indexes();
  const dropped: string[] = [];
  const kept:    string[] = [];

  for (const idx of indexes) {
    const name = idx.name as string;
    if (name === '_id_') { kept.push(name); continue; }
    if (idx.unique) {
      try {
        await Certificate.collection.dropIndex(name);
        dropped.push(name);
      } catch (e: any) {
        dropped.push(`${name} — ERROR: ${e.message}`);
      }
    } else {
      kept.push(name);
    }
  }

  return NextResponse.json({
    message: dropped.length > 0
      ? `✅ Dropped ${dropped.length} unique index(es). You can now add certificates freely.`
      : '⚠️ No unique indexes found — already clean or not yet connected.',
    dropped,
    kept,
    allIndexes: indexes.map((i: any) => ({ name: i.name, unique: !!i.unique, key: i.key })),
  });
}
