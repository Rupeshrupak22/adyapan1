import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import Certificate from '@/models/Certificate';

/**
 * GET /api/verify-certificate?id=ADYP-2026-XXXXXXXX
 * Public endpoint — no authentication required.
 * Returns just enough info to verify + display the certificate.
 */
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const certId = (searchParams.get('id') || '').trim().toUpperCase();

  if (!certId) {
    return NextResponse.json({ error: 'Certificate ID is required' }, { status: 400 });
  }

  try {
    await connectToDatabase();

    const cert = await Certificate.findOne({
      certificateId: { $regex: `^${certId}$`, $options: 'i' },
    }).lean();

    if (!cert) {
      return NextResponse.json({ valid: false, error: 'No certificate found with this ID' }, { status: 404 });
    }

    const PRESET_LABELS: Record<string, string> = {
      course_completion:    'Course Completion',
      internship_completion:'Internship Completion',
      project_completion:   'Project Completion',
      best_performance:     'Best Performance',
    };

    const rawTypes: string[] = ((cert as any).certificateTypes?.length
      ? (cert as any).certificateTypes
      : [cert.certificateType]
    ).filter((t: unknown): t is string => typeof t === 'string' && t.trim().length > 0);

    const types: string[] = rawTypes.map((t: string) =>
      PRESET_LABELS[t] ?? t.replace(/_/g, ' ').replace(/\b\w/g, (c: string) => c.toUpperCase())
    );

    return NextResponse.json({
      valid:          true,
      certificateId:  cert.certificateId,
      studentName:    cert.studentName,
      courseName:     cert.courseName,
      courseSlug:     cert.courseSlug,
      types,
      issuedAt:       cert.issuedAt,
      status:         cert.status,
      certificateUrl: cert.certificateUrl || null,
      certificateFiles: ((cert as any).certificateFiles || []) as Array<{ name: string; url: string }>,
    });
  } catch (err: any) {
    console.error('[Verify Certificate]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
