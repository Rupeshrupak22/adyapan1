import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import mongoose, { Schema, model, models } from 'mongoose';

// Same schema as in upload-file route
const certFileSchema = new Schema({
  name:     { type: String, default: '' },
  mimeType: { type: String, required: true },
  data:     { type: String, required: true },
  size:     { type: Number },
  createdAt: { type: Date, default: Date.now, expires: 60 * 60 * 24 * 90 },
});
const CertFileStore = models.CertFileStore || model('CertFileStore', certFileSchema);

/**
 * GET /api/certificate-file/:id
 * Public — serves a stored certificate file (PDF or image) by ID.
 * The browser will render PDFs inline or prompt download.
 */
export async function GET(
  _request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return NextResponse.json({ error: 'Invalid file ID' }, { status: 400 });
  }

  try {
    await connectToDatabase();

    const doc = await CertFileStore.findById(id).lean() as any;
    if (!doc) {
      return NextResponse.json({ error: 'File not found' }, { status: 404 });
    }

    const buffer = Buffer.from(doc.data, 'base64');

    const isPdf = doc.mimeType === 'application/pdf';
    const ext   = isPdf ? 'pdf' : doc.mimeType.split('/')[1] || 'bin';
    const filename = `${(doc.name || 'certificate').replace(/[^a-z0-9_\- ]/gi, '_')}.${ext}`;

    return new NextResponse(buffer, {
      status: 200,
      headers: {
        'Content-Type':        doc.mimeType,
        'Content-Length':      String(buffer.length),
        // inline = open in browser; attachment = force download
        'Content-Disposition': `inline; filename="${filename}"`,
        'Cache-Control':       'public, max-age=86400',
      },
    });
  } catch (err: any) {
    console.error('[Certificate File Serve]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
