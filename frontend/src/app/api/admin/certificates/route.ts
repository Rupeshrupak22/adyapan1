import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRouteByRole } from '@/lib/auth';
import Certificate from '@/models/Certificate';
import AuthUser from '@/models/AuthUser';
import mongoose from 'mongoose';

// ── Helpers ───────────────────────────────────────────────────
function generateCertificateId(): string {
  const year  = new Date().getFullYear();
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let suffix  = '';
  for (let i = 0; i < 8; i++) suffix += chars[Math.floor(Math.random() * chars.length)];
  return `ADYP-${year}-${suffix}`;
}

async function uniqueCertificateId(): Promise<string> {
  for (let attempt = 0; attempt < 10; attempt++) {
    const id = generateCertificateId();
    if (!(await Certificate.exists({ certificateId: id }))) return id;
  }
  return `ADYP-${Date.now()}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;
}

async function dropLegacyIndexes() {
  for (const name of ['userId_1_courseSlug_1', 'certificateId_1']) {
    try { await Certificate.collection.dropIndex(name); } catch { /* already gone */ }
  }
}

// ── GET /api/admin/certificates ───────────────────────────────
export async function GET(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'COMPANY']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();
    await dropLegacyIndexes();

    const { searchParams } = new URL(request.url);
    const search = searchParams.get('search') || '';
    const status = searchParams.get('status') || '';
    const course = searchParams.get('course') || '';
    const page   = parseInt(searchParams.get('page')  || '1');
    const limit  = parseInt(searchParams.get('limit') || '20');
    const skip   = (page - 1) * limit;

    const query: any = {};
    if (status) query.status = status;
    if (course) query.courseSlug = { $regex: course, $options: 'i' };
    if (search) {
      query.$or = [
        { studentName:   { $regex: search, $options: 'i' } },
        { courseName:    { $regex: search, $options: 'i' } },
        { certificateId: { $regex: search, $options: 'i' } },
      ];
    }

    const [certificates, total] = await Promise.all([
      Certificate.find(query).sort({ issuedAt: -1 }).skip(skip).limit(limit).lean(),
      Certificate.countDocuments(query),
    ]);

    const enriched = await Promise.all(
      certificates.map(async (cert) => {
        let userEmail = '', userPhone = '';
        if (mongoose.Types.ObjectId.isValid(cert.userId)) {
          const user = await AuthUser.findById(cert.userId).select('email phone').lean();
          userEmail = (user as any)?.email || '';
          userPhone = (user as any)?.phone || '';
        }
        return {
          id:               cert._id.toString(),
          certificateId:    cert.certificateId,
          studentName:      cert.studentName,
          studentEmail:     userEmail,
          studentPhone:     userPhone,
          courseName:       cert.courseName,
          courseSlug:       cert.courseSlug,
          certificateType:  cert.certificateType,
          certificateTypes: (cert as any).certificateTypes || [],
          status:           cert.status,
          emailSent:        cert.emailSent,
          issuedAt:         cert.issuedAt,
          downloadUrl:      `/api/certificates/${cert.courseSlug}/download`,
          certificateUrl:   cert.certificateUrl || '',
          certificateFiles: (cert as any).certificateFiles || [],
          userId:           cert.userId,
        };
      })
    );

    const [totalReady, totalPending, totalEmailSent] = await Promise.all([
      Certificate.countDocuments({ status: 'ready' }),
      Certificate.countDocuments({ status: 'pending' }),
      Certificate.countDocuments({ emailSent: true }),
    ]);

    return NextResponse.json({
      success: true,
      certificates: enriched,
      summary: { totalReady, totalPending, totalEmailSent },
      pagination: { total, page, limit, pages: Math.ceil(total / limit) },
    });
  } catch (err: any) {
    console.error('[Admin Certificates GET]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

// ── POST /api/admin/certificates ─────────────────────────────
export async function POST(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();
    await dropLegacyIndexes();

    const body = await request.json();
    const {
      studentName, studentEmail, courseName, courseSlug,
      certificateType  = 'course_completion',
      certificateTypes = [] as string[],
      otherType        = '',
      issuedAt, status = 'pending',
      certificateFiles = [] as Array<{ name: string; url: string }>,
    } = body;

    if (!studentName?.trim())  return NextResponse.json({ error: 'Student name is required' },  { status: 400 });
    if (!studentEmail?.trim()) return NextResponse.json({ error: 'Student email is required' }, { status: 400 });
    if (!courseName?.trim())   return NextResponse.json({ error: 'Course name is required' },   { status: 400 });
    if (!courseSlug?.trim())   return NextResponse.json({ error: 'Course slug is required' },   { status: 400 });

    let finalTypes: string[] = Array.isArray(certificateTypes) ? [...certificateTypes] : [certificateType];
    if (finalTypes.includes('other')) {
      if (!otherType?.trim()) {
        return NextResponse.json({ error: 'Please enter a name for the custom certificate type' }, { status: 400 });
      }
      finalTypes = [...finalTypes.filter(t => t !== 'other'), otherType.trim()];
    }
    if (finalTypes.length === 0) finalTypes = ['course_completion'];

    const user = await AuthUser.findOne({ email: studentEmail.toLowerCase().trim() }).select('_id').lean();
    const userId = user ? (user as any)._id.toString() : new mongoose.Types.ObjectId().toString();

    const cleanedFiles = (certificateFiles as Array<{ name?: string; url: string }>)
      .filter(f => f?.url?.trim())
      .map(f => ({ name: f.name?.trim() || '', url: f.url.trim() }));

    const certData = {
      userId,
      courseSlug:       courseSlug.trim(),
      certificateType:  finalTypes[0],
      certificateTypes: finalTypes,
      certificateId:    await uniqueCertificateId(),
      studentName:      studentName.trim(),
      courseName:       courseName.trim(),
      issuedAt:         issuedAt ? new Date(issuedAt) : new Date(),
      status,
      emailSent:        false,
      certificateUrl:   cleanedFiles[0]?.url || '',
      certificateFiles: cleanedFiles,
    };

    let cert;
    try {
      cert = await Certificate.create(certData);
    } catch (insertErr: any) {
      if (insertErr.code === 11000) {
        // Self-heal: nuke all remaining unique indexes and retry with a fresh ID
        const indexes = await Certificate.collection.indexes();
        for (const idx of indexes) {
          if ((idx as any).name !== '_id_' && (idx as any).unique) {
            try { await Certificate.collection.dropIndex((idx as any).name); } catch { /* ignore */ }
          }
        }
        cert = await Certificate.create({ ...certData, certificateId: await uniqueCertificateId() });
      } else {
        throw insertErr;
      }
    }

    return NextResponse.json(
      { success: true, certificateId: cert.certificateId, id: cert._id.toString() },
      { status: 201 }
    );
  } catch (err: any) {
    console.error('[Admin Certificates POST]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
