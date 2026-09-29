import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { connectToDatabase } from '@/lib/mongodb';
import { sendLeadNotificationEmails } from '@/lib/resend';
import { isStrictEmail, strictEmailMessage, isIndianMobile, indianMobileMessage } from '@/lib/security';
import CertificationEnrollment from '@/models/CertificationEnrollment';

const EnrollSchema = z.object({
  name: z.string().min(2, 'Name is required').max(100).transform((v) => v.trim()),
  phone: z.string().refine(isIndianMobile, indianMobileMessage()),
  email: z.string().refine(isStrictEmail, strictEmailMessage()).transform((v) => v.toLowerCase().trim()),
  college: z.string().max(200).optional().default('').transform((v) => v?.trim() ?? ''),
  city: z.string().max(100).optional().default('').transform((v) => v?.trim() ?? ''),
  examDate: z.string().min(1, 'Exam date is required'),
  certificationName: z.string().min(2, 'Certification name is required').max(300).transform((v) => v.trim()),
  companyName: z.string().min(1, 'Company name is required').max(200).transform((v) => v.trim()),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const data = EnrollSchema.parse(body);

    await connectToDatabase();

    const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const duplicate = await CertificationEnrollment.findOne({
      certificationName: data.certificationName,
      createdAt: { $gte: since },
      $or: [
        { email: data.email },
        { phone: data.phone },
      ],
    }).lean();

    if (duplicate) {
      return NextResponse.json(
        { error: 'You have already submitted this certification enrollment recently.' },
        { status: 409 }
      );
    }

    const enrollment = await CertificationEnrollment.create({
      certificationName: data.certificationName,
      companyName: data.companyName,
      name: data.name,
      phone: data.phone,
      email: data.email,
      college: data.college,
      city: data.city,
      examDate: new Date(data.examDate),
      source: 'certification-modal',
      status: 'new',
    });

    await sendLeadNotificationEmails({
      sourcePage: 'Certification enrollment modal',
      name: enrollment.name,
      phone: enrollment.phone,
      email: enrollment.email,
      college: enrollment.college,
      city: enrollment.city,
      certification: enrollment.certificationName,
      service: enrollment.companyName,
      notes: `Exam date: ${enrollment.examDate?.toLocaleDateString('en-IN') || data.examDate}`,
      submittedAt: enrollment.createdAt,
    });

    return NextResponse.json(
      { success: true, id: enrollment._id.toString() },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: error.errors[0]?.message || 'Invalid enrollment data' },
        { status: 400 }
      );
    }

    console.error('[CertificationEnrollments POST]', error);
    return NextResponse.json(
      { error: 'Something went wrong. Please try again.' },
      { status: 500 }
    );
  }
}
