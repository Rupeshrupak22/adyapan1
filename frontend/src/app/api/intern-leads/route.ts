import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { connectToDatabase } from '@/lib/mongodb';
import InternLead from '@/models/InternLead';
import { sendLeadNotificationEmails } from '@/lib/resend';
import { isIndianMobile, indianMobileMessage } from '@/lib/security';

const InternLeadSchema = z.object({
  name: z.string().min(2, 'Name is required').max(100).transform(v => v.trim()),
  courseName: z.string().min(2, 'Course name is required').max(200).transform(v => v.trim()),
  email: z.string().email('Invalid email address').transform(v => v.toLowerCase().trim()),
  mobile: z
    .string()
    .refine(isIndianMobile, indianMobileMessage()),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const data = InternLeadSchema.parse(body);

    await connectToDatabase();

    // Duplicate check — same email within 24 hours
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const duplicate = await InternLead.findOne({
      email: data.email,
      createdAt: { $gte: since },
    }).lean();

    if (duplicate) {
      return NextResponse.json(
        { error: 'You have already applied recently. Our team will contact you soon.' },
        { status: 409 }
      );
    }

    const lead = await InternLead.create({
      name: data.name,
      courseName: data.courseName,
      email: data.email,
      mobile: data.mobile,
    });

    // Send notification emails (non-blocking)
    sendLeadNotificationEmails({
      sourcePage: 'Internship Apply Modal',
      name: lead.name,
      email: lead.email,
      phone: lead.mobile,
      course: lead.courseName,
      submittedAt: lead.createdAt,
    }).catch(() => {});

    return NextResponse.json(
      { success: true, id: lead._id.toString() },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: error.errors[0]?.message || 'Invalid data' },
        { status: 400 }
      );
    }
    console.error('[InternLeads POST]', error);
    return NextResponse.json(
      { error: 'Something went wrong. Please try again.' },
      { status: 500 }
    );
  }
}
