import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRouteByRole } from '@/lib/auth';
import { sendLeadNotificationEmails } from '@/lib/resend';
import {
  getClientIp,
  isRateLimited,
  isSpamSubmission,
  isIndianMobile,
  indianMobileMessage,
  normalizeEmail,
  normalizeIndianMobile,
  rateLimitResponse,
  sanitizeMongoInput,
  verifyTurnstileToken,
} from '@/lib/security';
import OfflineInternshipLead from '@/models/OfflineInternshipLead';

const clean = (value: unknown) => String(value || '').trim();

export async function POST(req: NextRequest) {
  const ip = getClientIp(req);

  if (isRateLimited(`offline-leads:${ip}`, 5, 15 * 60 * 1000)) {
    return rateLimitResponse('Too many enrollment submissions. Please try again later.');
  }

  try {
    await connectToDatabase();
  } catch {
    return NextResponse.json(
      { error: 'Database connection failed. Please try again later.' },
      { status: 503 }
    );
  }

  try {
    const body = sanitizeMongoInput(await req.json()) as Record<string, unknown>;
    if (isSpamSubmission(body)) {
      return NextResponse.json({ success: true });
    }

    const turnstileOk = await verifyTurnstileToken(
      typeof body.cfTurnstileToken === 'string' ? body.cfTurnstileToken : undefined,
      ip
    );
    if (!turnstileOk) {
      return NextResponse.json({ error: 'Security check failed. Please try again.' }, { status: 400 });
    }

    const name = clean(body.name);
    const phone = normalizeIndianMobile(body.phone);
    const email = normalizeEmail(body.email);
    const college = clean(body.college);
    const city = clean(body.city);
    const courseInterest = clean(body.courseInterest || body.course);
    const preferredBatch = clean(body.preferredBatch || body.batch);

    const missing: string[] = [];
    if (!name) missing.push('Name');
    if (!phone) missing.push('Phone');
    if (!email) missing.push('Email');
    if (!courseInterest) missing.push('Course Interest');
    if (!preferredBatch) missing.push('Preferred Batch');

    if (missing.length) {
      return NextResponse.json(
        { error: `Please fill in: ${missing.join(', ')}` },
        { status: 400 }
      );
    }

    if (!isIndianMobile(phone)) {
      return NextResponse.json(
        { error: indianMobileMessage() },
        { status: 400 }
      );
    }

    if (!/^\S+@\S+\.\S+$/.test(email)) {
      return NextResponse.json(
        { error: 'Please enter a valid email address.' },
        { status: 400 }
      );
    }

    const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const duplicate = await OfflineInternshipLead.findOne({
      $or: [
        { phone, createdAt: { $gte: since } },
        { email, createdAt: { $gte: since } },
      ],
    }).lean();

    if (duplicate) {
      return NextResponse.json(
        {
          error: 'You have already submitted an enquiry in the last 24 hours.',
          duplicate: true,
        },
        { status: 409 }
      );
    }

    const lead = await OfflineInternshipLead.create({
      name,
      phone,
      email,
      college,
      city,
      courseInterest,
      preferredBatch,
      status: 'new',
      source: 'offline_services_page',
    });

    console.log(`[OfflineLead] Saved lead ${lead._id.toString()} | Course: ${courseInterest}`);

    await sendLeadNotificationEmails({
      sourcePage: 'Offline internship form',
      name: lead.name,
      phone: lead.phone,
      email: lead.email,
      college: lead.college,
      city: lead.city,
      course: lead.courseInterest,
      service: 'Offline Internship',
      notes: `Preferred batch: ${lead.preferredBatch || 'Not specified'}`,
      submittedAt: lead.createdAt,
    });

    return NextResponse.json(
      {
        success: true,
        message: 'Enrollment submitted successfully. Our counselor will contact you soon.',
        id: lead._id.toString(),
      },
      { status: 201 }
    );
  } catch (err: any) {
    console.error('[OfflineLead POST]', err.message);
    return NextResponse.json(
      { error: 'Something went wrong. Please try again later.' },
      { status: 500 }
    );
  }
}

export async function GET(req: NextRequest) {
  const auth = protectRouteByRole(req, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();
  } catch {
    return NextResponse.json({ error: 'Database connection failed.' }, { status: 503 });
  }

  try {
    const { searchParams } = new URL(req.url);
    const status = searchParams.get('status');
    const limit = Math.min(Number(searchParams.get('limit') || 100), 500);
    const page = Math.max(Number(searchParams.get('page') || 1), 1);

    const filter: Record<string, unknown> = {};
    if (status) filter.status = status;

    const [leads, total] = await Promise.all([
      OfflineInternshipLead.find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      OfflineInternshipLead.countDocuments(filter),
    ]);

    return NextResponse.json({ success: true, leads, total, page, limit });
  } catch (err: any) {
    console.error('[OfflineLead GET]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
