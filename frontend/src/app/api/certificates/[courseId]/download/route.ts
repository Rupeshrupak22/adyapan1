/**
 * GET /api/certificates/:courseId/download
 * Streams a PDF certificate to the authenticated user.
 * Only accessible by the certificate owner.
 */
import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRoute } from '@/lib/auth';
import Certificate from '@/models/Certificate';
import Progress from '@/models/Progress';
import AuthUser from '@/models/AuthUser';
// @ts-ignore - pdfkit has no default ESM export
import PDFDocument from 'pdfkit';

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ courseId: string }> }
) {
  const auth = protectRoute(req);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();
    const { courseId: courseSlug } = await params;

    /* -- Verify course is complete -- */
    const progress = await Progress.findOne({
      userId: auth.userId,
      courseSlug,
    }).lean();

    if (!progress || (progress as any).progressPercent < 100) {
      return NextResponse.json(
        { error: 'Course not completed. Complete all lessons to download your certificate.' },
        { status: 403 }
      );
    }

    /* -- Fetch certificate (match by userId or stored email) -- */
    const user = await AuthUser.findById(auth.userId).select('email').lean();
    const email = (user as any)?.email?.toLowerCase().trim();
    const orConditions: Record<string, unknown>[] = [{ userId: auth.userId }];
    if (email) orConditions.push({ studentEmail: email });

    const cert = await Certificate.findOne({
      courseSlug,
      $or: orConditions,
    }).lean();

    if (!cert) {
      return NextResponse.json(
        { error: 'Certificate not found. Please contact support.' },
        { status: 404 }
      );
    }

    const c = cert as any;

    /* -- If admin uploaded a certificate file, redirect to it instead of
          generating a PDF (the uploaded file is the real certificate). -- */
    const uploadedUrl: string | undefined = (c.certificateFiles?.[0]?.url) || c.certificateUrl;
    if (uploadedUrl) {
      const absolute = uploadedUrl.startsWith('http')
        ? uploadedUrl
        : new URL(uploadedUrl, req.nextUrl.origin).toString();
      return NextResponse.redirect(absolute);
    }

    /* -- Fallback: generate a PDF certificate on the fly -- */
    const pdfBuffer = await generateCertificatePDF({
      certificateId: c.certificateId,
      studentName:   c.studentName,
      courseName:    c.courseName,
      issuedAt:      new Date(c.issuedAt),
    });

    const filename = `Adyapan-Certificate-${c.certificateId}.pdf`;

    return new NextResponse(pdfBuffer as unknown as BodyInit, {
      status: 200,
      headers: {
        'Content-Type':        'application/pdf',
        'Content-Disposition': `attachment; filename="${filename}"`,
        'Content-Length':      String(pdfBuffer.length),
        'Cache-Control':       'no-store',
      },
    });
  } catch (err: any) {
    console.error('[Certificate Download]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

/* -------------------------------------------------------------
   PDF Generation
   ------------------------------------------------------------- */
interface CertData {
  certificateId: string;
  studentName:   string;
  courseName:    string;
  issuedAt:      Date;
}

function generateCertificatePDF(data: CertData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      size:    'A4',
      layout:  'landscape',
      margins: { top: 0, bottom: 0, left: 0, right: 0 },
    });

    const chunks: Buffer[] = [];
    doc.on('data',  (chunk: Buffer) => chunks.push(chunk));
    doc.on('end',   () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    const W = doc.page.width;   // 841.89
    const H = doc.page.height;  // 595.28

    /* -- Background -- */
    doc.rect(0, 0, W, H).fill('#fffbf0');

    /* -- Outer border -- */
    doc
      .rect(20, 20, W - 40, H - 40)
      .lineWidth(3)
      .stroke('#ffa800');

    /* -- Inner border -- */
    doc
      .rect(28, 28, W - 56, H - 56)
      .lineWidth(1)
      .stroke('#ffd580');

    /* -- Corner decorations -- */
    const corners = [
      [30, 30], [W - 30, 30], [30, H - 30], [W - 30, H - 30],
    ] as [number, number][];
    corners.forEach(([cx, cy]) => {
      doc.circle(cx, cy, 6).fill('#ffa800');
    });

    /* -- Header band -- */
    doc.rect(0, 0, W, 90).fill('#ffa800');

    /* -- Brand name -- */
    doc
      .fillColor('#ffffff')
      .fontSize(28)
      .font('Helvetica-Bold')
      .text('ADYAPAN SKILLS', 0, 22, { align: 'center', width: W });

    /* -- Tagline -- */
    doc
      .fillColor('#fff3cc')
      .fontSize(11)
      .font('Helvetica')
      .text('Empowering Careers Through Quality Education', 0, 58, {
        align: 'center',
        width: W,
      });

    /* -- Certificate title -- */
    doc
      .fillColor('#7c3a00')
      .fontSize(22)
      .font('Helvetica-Bold')
      .text('CERTIFICATE OF COMPLETION', 0, 108, { align: 'center', width: W });

    /* -- Decorative line -- */
    doc
      .moveTo(W / 2 - 160, 140)
      .lineTo(W / 2 + 160, 140)
      .lineWidth(1.5)
      .stroke('#ffa800');

    /* -- "This is to certify that" -- */
    doc
      .fillColor('#555555')
      .fontSize(13)
      .font('Helvetica')
      .text('This is to certify that', 0, 158, { align: 'center', width: W });

    /* -- Student name -- */
    doc
      .fillColor('#1a1a1a')
      .fontSize(34)
      .font('Helvetica-Bold')
      .text(data.studentName, 0, 182, { align: 'center', width: W });

    /* -- Underline for name -- */
    const nameWidth = Math.min(data.studentName.length * 18, 400);
    doc
      .moveTo(W / 2 - nameWidth / 2, 226)
      .lineTo(W / 2 + nameWidth / 2, 226)
      .lineWidth(1)
      .stroke('#ffa800');

    /* -- "has successfully completed" -- */
    doc
      .fillColor('#555555')
      .fontSize(13)
      .font('Helvetica')
      .text('has successfully completed the course', 0, 238, {
        align: 'center',
        width: W,
      });

    /* -- Course name -- */
    doc
      .fillColor('#cc5500')
      .fontSize(20)
      .font('Helvetica-Bold')
      .text(data.courseName, 60, 262, { align: 'center', width: W - 120 });

    /* -- Offered by -- */
    doc
      .fillColor('#555555')
      .fontSize(12)
      .font('Helvetica')
      .text('offered by Adyapan Skills', 0, 296, { align: 'center', width: W });

    /* -- Divider -- */
    doc
      .moveTo(60, 330)
      .lineTo(W - 60, 330)
      .lineWidth(0.5)
      .stroke('#e0c080');

    /* -- Footer section -- */
    const issuedStr = data.issuedAt.toLocaleDateString('en-IN', {
      day:   '2-digit',
      month: 'long',
      year:  'numeric',
    });

    // Left: Issue date
    doc
      .fillColor('#888888')
      .fontSize(10)
      .font('Helvetica')
      .text('DATE OF ISSUE', 80, 348);
    doc
      .fillColor('#333333')
      .fontSize(13)
      .font('Helvetica-Bold')
      .text(issuedStr, 80, 364);

    // Center: Certificate ID
    doc
      .fillColor('#888888')
      .fontSize(10)
      .font('Helvetica')
      .text('CERTIFICATE ID', 0, 348, { align: 'center', width: W });
    doc
      .fillColor('#333333')
      .fontSize(13)
      .font('Helvetica-Bold')
      .text(data.certificateId, 0, 364, { align: 'center', width: W });

    // Right: Signature placeholder
    doc
      .fillColor('#888888')
      .fontSize(10)
      .font('Helvetica')
      .text('AUTHORIZED SIGNATURE', W - 240, 348);

    // Signature line
    doc
      .moveTo(W - 240, 390)
      .lineTo(W - 80, 390)
      .lineWidth(1)
      .stroke('#333333');

    doc
      .fillColor('#555555')
      .fontSize(10)
      .font('Helvetica')
      .text('Director, Adyapan Skills', W - 240, 396);

    /* -- Seal / badge -- */
    doc.circle(W / 2, 390, 32).fill('#ffa800');
    doc.circle(W / 2, 390, 28).fill('#fff3cc');
    doc
      .fillColor('#7c3a00')
      .fontSize(7)
      .font('Helvetica-Bold')
      .text('ADYAPAN', W / 2 - 20, 381);
    doc
      .fillColor('#7c3a00')
      .fontSize(6)
      .font('Helvetica')
      .text('CERTIFIED', W / 2 - 16, 391);

    /* -- Footer note -- */
    doc
      .fillColor('#aaaaaa')
      .fontSize(8)
      .font('Helvetica')
      .text(
        'This certificate is issued by Adyapan Skills and can be verified at adyapan.com',
        0,
        H - 38,
        { align: 'center', width: W }
      );

    doc.end();
  });
}
