/**
 * POST /api/jobs/[id]/apply - student applies for a job
 * Requires: STUDENT role (or any authenticated user)
 */
import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRoute } from '@/lib/auth';
import JobPost from '@/models/JobPost';
import JobApplication from '@/models/JobApplication';
import {
  isValidName, nameFormatMessage, normalizeName,
  isStrictEmail, strictEmailMessage, normalizeEmail,
  isIndianMobile, indianMobileMessage, normalizeIndianMobile,
} from '@/lib/security';

export async function POST(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const auth = protectRoute(req);
  if (auth instanceof NextResponse) return auth;
  if (auth.role === 'COMPANY') {
    return NextResponse.json({ error: 'Companies cannot apply for jobs' }, { status: 403 });
  }
  try {
    await connectToDatabase();
    const { id } = await params;
    const job = await JobPost.findOne({ _id: id, status: 'active' });
    if (!job) return NextResponse.json({ error: 'Job not found or no longer active' }, { status: 404 });
    const existing = await JobApplication.findOne({ jobId: id, studentId: auth.userId });
    if (existing) {
      return NextResponse.json({ error: 'You have already applied for this job' }, { status: 409 });
    }
    const body = await req.json();
    const { studentName, studentEmail, studentPhone, cvUrl, portfolioUrl, message } = body;

    if (!isValidName(studentName)) {
      return NextResponse.json({ error: nameFormatMessage() }, { status: 400 });
    }
    if (!isStrictEmail(studentEmail)) {
      return NextResponse.json({ error: strictEmailMessage() }, { status: 400 });
    }
    const phone = normalizeIndianMobile(studentPhone || '');
    if (phone && !isIndianMobile(phone)) {
      return NextResponse.json({ error: indianMobileMessage() }, { status: 400 });
    }

    const application = await JobApplication.create({
      jobId: id, companyId: job.companyId, studentId: auth.userId,
      studentName: normalizeName(studentName), studentEmail: normalizeEmail(studentEmail),
      studentPhone: phone, cvUrl: cvUrl || '',
      portfolioUrl: portfolioUrl || '', message: message || '',
      status: 'applied', appliedAt: new Date(),
    });
    await JobPost.findByIdAndUpdate(id, { $inc: { applicantsCount: 1 } });
    return NextResponse.json({ success: true, application, message: 'Application submitted successfully' }, { status: 201 });
  } catch (err: any) {
    if (err.code === 11000) return NextResponse.json({ error: 'You have already applied for this job' }, { status: 409 });
    console.error('[JobApply POST]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
