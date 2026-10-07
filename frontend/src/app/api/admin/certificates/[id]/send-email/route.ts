/**
 * POST /api/admin/certificates/:id/send-email
 *
 * Sends the official certificate email to the student with the
 * uploaded certificate file(s) attached, then marks the certificate
 * as emailSent and logs the attempt in EmailLog.
 *
 * Access: ADMIN or SUPERADMIN
 */

import { NextRequest, NextResponse } from 'next/server';
import mongoose, { Schema, model, models } from 'mongoose';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRouteByRole } from '@/lib/auth';
import { sendAdminCertificateEmail, AdminCertificateEmailAttachment } from '@/lib/email';
import Certificate from '@/models/Certificate';
import AuthUser from '@/models/AuthUser';
import EmailLog from '@/models/EmailLog';

// Same CertFileStore schema used by upload-file / certificate-file routes
const certFileSchema = new Schema({
  name:      { type: String, default: '' },
  mimeType:  { type: String, required: true },
  data:      { type: String, required: true },
  size:      { type: Number },
  createdAt: { type: Date, default: Date.now },
});
const CertFileStore = models.CertFileStore || model('CertFileStore', certFileSchema);

type RouteContext = { params: Promise<{ id: string }> };

function extFromMime(mime: string): string {
  if (mime === 'application/pdf') return 'pdf';
  if (mime === 'image/jpeg') return 'jpg';
  if (mime === 'image/png') return 'png';
  if (mime === 'image/webp') return 'webp';
  return 'bin';
}

function sanitizeFilename(name: string): string {
  return (name || 'certificate').replace(/[^a-z0-9_\- ]/gi, '_').trim() || 'certificate';
}

export async function POST(request: NextRequest, { params }: RouteContext) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const { id } = await params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return NextResponse.json({ error: 'Invalid certificate ID' }, { status: 400 });
    }

    const cert = (await Certificate.findById(id).lean()) as any;
    if (!cert) {
      return NextResponse.json({ error: 'Certificate not found' }, { status: 404 });
    }

    // Resolve recipient email: stored studentEmail first, else linked AuthUser
    let email: string = (cert.studentEmail || '').toLowerCase().trim();
    if (!email && mongoose.Types.ObjectId.isValid(cert.userId)) {
      const user = (await AuthUser.findById(cert.userId).select('email').lean()) as any;
      email = (user?.email || '').toLowerCase().trim();
    }

    if (!email) {
      return NextResponse.json(
        { error: 'No email on file for this certificate. Edit the certificate to add a student email first.' },
        { status: 400 }
      );
    }

    // Build attachments from uploaded certificate files
    const files: Array<{ name: string; url: string }> = cert.certificateFiles || [];
    const attachments: AdminCertificateEmailAttachment[] = [];

    for (const f of files) {
      // url format: /api/certificate-file/<objectId>
      const match = f.url?.match(/certificate-file\/([a-f0-9]{24})/i);
      if (!match) continue;
      const fileId = match[1];
      const stored = (await CertFileStore.findById(fileId).lean()) as any;
      if (!stored?.data) continue;
      const buffer = Buffer.from(stored.data, 'base64');
      const base = sanitizeFilename(f.name || stored.name || cert.certificateId);
      attachments.push({ filename: `${base}.${extFromMime(stored.mimeType)}`, content: buffer });
    }

    const verifyUrl = `${process.env.NEXT_PUBLIC_APP_URL || 'https://adyapan.com'}/verify-certificate?id=${encodeURIComponent(cert.certificateId)}`;

    const sent = await sendAdminCertificateEmail({
      name:          cert.studentName,
      email,
      courseName:    cert.courseName,
      certificateId: cert.certificateId,
      issuedAt:      cert.issuedAt,
      verifyUrl,
      attachments,
    });

    // Log the attempt
    try {
      await EmailLog.create({
        userId:        cert.userId || '',
        email,
        emailType:     'certificate_ready',
        subject:       `Your Certificate - ${cert.courseName} | Adyapan Edutech`,
        status:        sent ? 'sent' : 'failed',
        provider:      'resend',
        courseSlug:    cert.courseSlug || '',
        courseName:    cert.courseName || '',
        certificateId: cert.certificateId || '',
      });
    } catch (logErr: any) {
      console.warn('[Certificate SendEmail] EmailLog failed:', logErr.message);
    }

    if (!sent) {
      return NextResponse.json(
        { error: 'Email service is not configured or the send failed. Please try again later.' },
        { status: 502 }
      );
    }

    // Mark as emailed
    await Certificate.findByIdAndUpdate(id, {
      $set: { emailSent: true, emailSentAt: new Date() },
    });

    return NextResponse.json({
      success: true,
      message: `Certificate email sent to ${email}`,
      attachmentCount: attachments.length,
    });
  } catch (err: any) {
    console.error('[Certificate SendEmail]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
