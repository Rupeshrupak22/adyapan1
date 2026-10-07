/**
 * GET /api/certificates/:courseId
 * Returns certificate details for the authenticated user's course.
 */
import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRoute } from '@/lib/auth';
import Certificate from '@/models/Certificate';
import Progress from '@/models/Progress';
import AuthUser from '@/models/AuthUser';

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ courseId: string }> }
) {
  const auth = protectRoute(req);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();
    const { courseId: courseSlug } = await params;

    /* -- Check progress -- */
    const progress = await Progress.findOne({
      userId: auth.userId,
      courseSlug,
    }).lean();

    const progressPercent = (progress as any)?.progressPercent ?? 0;
    const isComplete = progressPercent === 100;

    if (!isComplete) {
      return NextResponse.json({
        success: true,
        isComplete: false,
        progressPercent,
        certificate: null,
        message: 'Complete all lessons to unlock your certificate.',
      });
    }

    /* -- Resolve this user's email so we can also match admin-created certs
          that were issued before the student registered (synthetic userId). -- */
    const user = await AuthUser.findById(auth.userId).select('email').lean();
    const email = (user as any)?.email?.toLowerCase().trim();

    const orConditions: Record<string, unknown>[] = [{ userId: auth.userId }];
    if (email) orConditions.push({ studentEmail: email });

    const cert = await Certificate.findOne({
      courseSlug,
      $or: orConditions,
    }).lean();

    if (!cert) {
      return NextResponse.json({
        success: true,
        isComplete: true,
        progressPercent,
        certificate: null,
        message: 'Certificate is being generated.',
      });
    }

    const c = cert as any;
    const uploadedFiles = (c.certificateFiles || []) as Array<{ name: string; url: string }>;

    return NextResponse.json({
      success: true,
      isComplete: true,
      progressPercent,
      certificate: {
        certificateId:  c.certificateId,
        studentName:    c.studentName,
        courseName:     c.courseName,
        issuedAt:       c.issuedAt,
        status:         c.status,
        // Prefer the admin-uploaded file; otherwise fall back to the generated PDF
        certificateFiles: uploadedFiles,
        certificateUrl:   c.certificateUrl || null,
        downloadUrl:    uploadedFiles[0]?.url || `/api/certificates/${courseSlug}/download`,
      },
    });
  } catch (err: any) {
    console.error('[Certificate GET]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
