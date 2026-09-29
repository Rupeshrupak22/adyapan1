import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { connectToDatabase } from '@/lib/mongodb';
import { sendLeadNotificationEmails } from '@/lib/resend';
import {
  cleanText,
  getClientIp,
  isStrictEmail,
  isRateLimited,
  isSpamSubmission,
  isIndianMobile,
  indianMobileMessage,
  normalizeEmail,
  normalizeIndianMobile,
  rateLimitResponse,
  sanitizeMongoInput,
  strictEmailMessage,
  verifyTurnstileToken,
} from '@/lib/security';
import ContactMessage from '@/models/ContactMessage';

const ContactSchema = z.object({
  name: z.string().min(2).max(100).transform((v) => cleanText(v, 100)),
  email: z.string().refine(isStrictEmail, strictEmailMessage()).transform(normalizeEmail),
  phone: z.string().refine(isIndianMobile, indianMobileMessage()).transform((v) => normalizeIndianMobile(v)),
  subject: z.string().min(1).max(150).transform((v) => cleanText(v, 150)),
  message: z.string().min(1).max(2000).transform((v) => cleanText(v, 2000)),
  cfTurnstileToken: z.string().optional(),
});

export async function POST(req: NextRequest) {
  const ip = getClientIp(req);
  if (isRateLimited(`contact:${ip}`, 5, 15 * 60 * 1000)) {
    return rateLimitResponse('Too many contact submissions. Please try again later.');
  }

  try {
    const body = sanitizeMongoInput(await req.json());
    if (isSpamSubmission(body as Record<string, unknown>)) {
      return NextResponse.json({ success: true });
    }

    const data = ContactSchema.parse(body);

    const turnstileOk = await verifyTurnstileToken(data.cfTurnstileToken, ip);
    if (!turnstileOk) {
      return NextResponse.json({ error: 'Security check failed. Please try again.' }, { status: 400 });
    }

    await connectToDatabase();
    const msg = await ContactMessage.create({
      name: data.name,
      email: data.email,
      phone: data.phone || '',
      subject: data.subject,
      message: data.message,
      status: 'new',
      ip,
    });

    console.log(`[Contact] Saved message ${msg._id.toString()} from ${data.name} <${data.email}> | Subject: ${data.subject}`);

    await sendLeadNotificationEmails({
      sourcePage: 'Contact / Get In Touch form',
      name: data.name,
      phone: data.phone || '',
      email: data.email,
      service: data.subject,
      message: data.message,
      submittedAt: msg.createdAt,
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ error: error.errors[0].message }, { status: 400 });
    }
    console.error('[Contact] Error:', error);
    return NextResponse.json({ error: 'Failed to send message' }, { status: 500 });
  }
}
