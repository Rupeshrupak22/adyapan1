import { NextRequest, NextResponse } from 'next/server';
import { protectRouteByRole } from '@/lib/auth';
import { connectToDatabase } from '@/lib/mongodb';
import mongoose, { Schema, model, models } from 'mongoose';

// ── Permanent file store (base64 in MongoDB — no TTL, certs never expire) ─
const certFileSchema = new Schema({
  name:      { type: String, default: '' },
  mimeType:  { type: String, required: true },
  data:      { type: String, required: true }, // base64 encoded file
  size:      { type: Number },
  createdAt: { type: Date, default: Date.now },
});
const CertFileStore = models.CertFileStore || model('CertFileStore', certFileSchema);

/**
 * POST /api/admin/certificates/upload-file
 * Stores certificate files (PDF/image) in MongoDB as base64.
 * Returns a served URL at /api/certificate-file/:id — no S3 needed.
 */
export async function POST(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    const formData    = await request.formData();
    const file        = formData.get('file') as File | null;
    const displayName = (formData.get('name') as string | null)?.trim() || '';

    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 });
    }

    const allowed = ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'];
    if (!allowed.includes(file.type)) {
      return NextResponse.json(
        { error: 'Only PDF, JPG, PNG or WEBP files are allowed' },
        { status: 400 }
      );
    }

    if (file.size > 20 * 1024 * 1024) {
      return NextResponse.json({ error: 'File must be under 20 MB' }, { status: 400 });
    }

    await connectToDatabase();

    const arrayBuffer = await file.arrayBuffer();
    const base64      = Buffer.from(arrayBuffer).toString('base64');
    const name        = displayName || file.name.replace(/\.[^/.]+$/, '');

    const stored = await CertFileStore.create({
      name,
      mimeType: file.type,
      data:     base64,
      size:     file.size,
    });

    const url = `/api/certificate-file/${stored._id.toString()}`;
    return NextResponse.json({ success: true, url, name });
  } catch (err: any) {
    console.error('[Certificate Upload]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
