import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { connectToDatabase } from '@/lib/mongodb';
import { sendLeadNotificationEmails } from '@/lib/resend';
import CampusAmbassadorLead from '@/models/CampusAmbassadorLead';
import {
  getClientIp,
  isRateLimited,
  isSpamSubmission,
  rateLimitResponse,
  sanitizeMongoInput,
  isValidName,
  nameFormatMessage,
  normalizeName,
  isStrictEmail,
  strictEmailMessage,
  normalizeEmail,
  isIndianMobile,
  indianMobileMessage,
  normalizeIndianMobile,
  cleanText,
} from '@/lib/security';

const YEARS = ['1st Year', '2nd Year', '3rd Year', '4th Year', 'PG'] as const;

const Schema = z.object({
  name: z.string().refine(isValidName, nameFormatMessage()).transform(normalizeName),
  email: z.string().refine(isStrictEmail, strictEmailMessage()).transform(normalizeEmail),
  phone: z.string().refine(isIndianMobile, indianMobileMessage()).transform(normalizeIndianMobile),
  college: z.string().min(2, 'College is required').max(200).transform((v) => cleanText(v, 200)),
  city: z.string().min(2, 'City is required').max(100).transform((v) => cleanText(v, 100)),
  branch: z.string().min(1, 'Branch is required').max(100).transform((v) => cleanText(v, 100)),
  year: z.enum(YEARS, { errorMap: () => ({ message: 'Please select your year of study.' }) }),
  linkedin: z.string().max(300).optional().default('').transform((v) => cleanText(v ?? '', 300)),
  why: z.string().min(10, 'Please tell us a bit more (min 10 characters).').max(2000).transform((v) => cleanText(v, 2000)),
});

export async function POST(req: NextRequest) {
  const ip = getClientIp(req);
  if (isRateLimited(`campus-ambassador:${ip}`, 5, 15 * 60 * 1000)) {
    return rateLimitResponse('Too many applications. Please try again later.');
  }

  try {
    const body = sanitizeMongoInput(await req.json()) as Record<string, unknown>;
    if (isSpamSubmission(body)) {
      return NextResponse.json({ success: true });
    }

    const data = Schema.parse(body);

    await connectToDatabase();

    // Duplicate check — same email in the last 24h
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const duplicate = await CampusAmbassadorLead.findOne({
      email: data.email,
      createdAt: { $gte: since },
    }).lean();
    if (duplicate) {
      return NextResponse.json(
        { error: 'You have already applied recently. Our team will contact you soon.' },
        { status: 409 }
      );
    }

    const lead = await CampusAmbassadorLead.create({ ...data, status: 'new', ip });

    sendLeadNotificationEmails({
      sourcePage: 'Campus Ambassador application',
      name: lead.name,
      email: lead.email,
      phone: lead.phone,
      college: lead.college,
      city: lead.city,
      service: 'Campus Ambassador',
      notes: [
        `Branch: ${lead.branch}`,
        `Year: ${lead.year}`,
        `LinkedIn: ${lead.linkedin || 'Not provided'}`,
        `Why: ${lead.why}`,
      ].join('\n'),
      submittedAt: lead.createdAt,
    }).catch(() => {});

    return NextResponse.json({ success: true, id: lead._id.toString() }, { status: 201 });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ error: error.errors[0]?.message || 'Invalid data' }, { status: 400 });
    }
    console.error('[CampusAmbassador] Error:', error);
    return NextResponse.json({ error: 'Something went wrong. Please try again.' }, { status: 500 });
  }
}
