/**
 * /api/admin/manual-leads
 *
 * GET    - list manual leads (search, enrollmentType filter, paymentStatus filter, pagination)
 * POST   - create a new manual lead (duplicate check by phone/email)
 * PATCH  - update an existing lead (edit)
 * DELETE - delete a lead (admin only)
 *
 * All routes require ADMIN or SUPERADMIN role.
 */

import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRouteByRole } from '@/lib/auth';
import { sendLeadNotificationEmails } from '@/lib/resend';
import {
  isStrictEmail, strictEmailMessage,
  isValidName, nameFormatMessage,
  isIndianMobile, indianMobileMessage, normalizeIndianMobile,
} from '@/lib/security';
import ManualLead from '@/models/ManualLead';

// â"€â"€ Validation schema â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
const CreateSchema = z.object({
  name:           z.string().refine(isValidName, nameFormatMessage()),
  phone:          z.string().refine(isIndianMobile, indianMobileMessage()).transform(normalizeIndianMobile),
  email:          z.string().refine(isStrictEmail, strictEmailMessage()),
  college:        z.string().max(200).optional().default(''),
  city:           z.string().max(100).optional().default(''),
  courseInterest: z.string().max(200).optional().default(''),
  preferredBatch: z.string().max(100).optional().default(''),
  enrollmentType: z.enum(['Online', 'Offline Form', 'Office Visit', 'Phone Call']),
  paymentStatus:  z.enum(['Paid', 'Pending', 'Failed', 'Partial']).optional().default('Pending'),
  amountPaid:     z.number().min(0).optional().default(0),
  notes:          z.string().max(2000).optional().default(''),
  addedByAdmin:   z.string().max(200).optional().default(''),
});

const UpdateSchema = CreateSchema.partial().extend({
  id: z.string().min(1, 'id is required'),
});

// â"€â"€ GET â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
export async function GET(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const { searchParams } = new URL(request.url);
    const search         = searchParams.get('search') || '';
    const enrollmentType = searchParams.get('enrollmentType') || '';
    const paymentStatus  = searchParams.get('paymentStatus') || '';
    const page           = Math.max(1, parseInt(searchParams.get('page') || '1'));
    const limit          = Math.min(50, parseInt(searchParams.get('limit') || '20'));
    const skip           = (page - 1) * limit;

    const filter: Record<string, unknown> = {};

    if (enrollmentType && enrollmentType !== 'all') {
      filter.enrollmentType = enrollmentType;
    }
    if (paymentStatus && paymentStatus !== 'all') {
      filter.paymentStatus = paymentStatus;
    }
    if (search.trim()) {
      filter.$or = [
        { name:           { $regex: search, $options: 'i' } },
        { email:          { $regex: search, $options: 'i' } },
        { phone:          { $regex: search, $options: 'i' } },
        { city:           { $regex: search, $options: 'i' } },
        { college:        { $regex: search, $options: 'i' } },
        { courseInterest: { $regex: search, $options: 'i' } },
      ];
    }

    const [leads, total, byType, paidCount] = await Promise.all([
      ManualLead.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      ManualLead.countDocuments(filter),
      // Aggregate counts across the WHOLE filtered dataset (not just this page)
      ManualLead.aggregate([
        { $match: filter },
        { $group: { _id: '$enrollmentType', count: { $sum: 1 } } },
      ]),
      ManualLead.countDocuments({ ...filter, paymentStatus: 'Paid' }),
    ]);

    const typeCounts: Record<string, number> = {};
    for (const row of byType as Array<{ _id: string; count: number }>) {
      if (row._id) typeCounts[row._id] = row.count;
    }
    const stats = {
      total,
      online:      typeCounts['Online'] || 0,
      offline:     typeCounts['Offline Form'] || 0,
      officeVisit: typeCounts['Office Visit'] || 0,
      phoneCall:   typeCounts['Phone Call'] || 0,
      paid:        paidCount,
    };

    return NextResponse.json({ success: true, leads, total, page, limit, stats });
  } catch (err: any) {
    console.error('[ManualLeads GET]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

// â"€â"€ POST â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
export async function POST(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const body   = await request.json();
    const parsed = CreateSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: parsed.error.errors[0].message },
        { status: 400 }
      );
    }

    const data = parsed.data;

    // â"€â"€ Duplicate check by phone OR email (label the field that actually collided) â"€â"€
    const normPhone = data.phone.trim();
    const normEmail = data.email.toLowerCase().trim();
    const [phoneDup, emailDup] = await Promise.all([
      ManualLead.findOne({ phone: normPhone }).lean(),
      ManualLead.findOne({ email: normEmail }).lean(),
    ]);
    if (phoneDup || emailDup) {
      const field = phoneDup ? 'phone' : 'email';
      return NextResponse.json(
        { error: `A student with this ${field} already exists in manual leads.`, duplicate: true },
        { status: 409 }
      );
    }

    const lead = await ManualLead.create({
      ...data,
      source: 'manual-admin-entry',
    });

    await sendLeadNotificationEmails({
      sourcePage: 'Manual admin student entry',
      name: lead.name,
      phone: lead.phone,
      email: lead.email,
      college: lead.college,
      city: lead.city,
      course: lead.courseInterest,
      service: lead.enrollmentType,
      notes: [
        lead.notes,
        `Preferred batch: ${lead.preferredBatch || 'Not specified'}`,
        `Payment status: ${lead.paymentStatus || 'Pending'}`,
        `Amount paid: ${lead.amountPaid || 0}`,
      ].filter(Boolean).join('\n'),
      submittedAt: lead.createdAt,
    });

    return NextResponse.json({ success: true, lead }, { status: 201 });
  } catch (err: any) {
    console.error('[ManualLeads POST]', err.message);
    if (err.code === 11000) {
      return NextResponse.json({ error: 'Duplicate entry detected.' }, { status: 409 });
    }
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

// â"€â"€ PATCH â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
export async function PATCH(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const body   = await request.json();
    const parsed = UpdateSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: parsed.error.errors[0].message },
        { status: 400 }
      );
    }

    const { id, ...updates } = parsed.data;

    // If phone/email is being changed, check for duplicates (excluding self).
    // Query each field separately so we report the field that actually collided.
    if (updates.phone) {
      const phoneDup = await ManualLead.findOne({ _id: { $ne: id }, phone: updates.phone.trim() }).lean();
      if (phoneDup) {
        return NextResponse.json(
          { error: 'Another student with this phone already exists.', duplicate: true },
          { status: 409 }
        );
      }
    }
    if (updates.email) {
      const emailDup = await ManualLead.findOne({ _id: { $ne: id }, email: updates.email.toLowerCase().trim() }).lean();
      if (emailDup) {
        return NextResponse.json(
          { error: 'Another student with this email already exists.', duplicate: true },
          { status: 409 }
        );
      }
    }

    const updated = await ManualLead.findByIdAndUpdate(
      id,
      { $set: updates },
      { new: true, runValidators: true }
    ).lean();

    if (!updated) {
      return NextResponse.json({ error: 'Lead not found' }, { status: 404 });
    }

    return NextResponse.json({ success: true, lead: updated });
  } catch (err: any) {
    console.error('[ManualLeads PATCH]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

// â"€â"€ DELETE â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
export async function DELETE(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');
    if (!id) {
      return NextResponse.json({ error: 'id is required' }, { status: 400 });
    }

    const deleted = await ManualLead.findByIdAndDelete(id).lean();
    if (!deleted) {
      return NextResponse.json({ error: 'Lead not found' }, { status: 404 });
    }

    return NextResponse.json({ success: true, message: 'Lead deleted successfully' });
  } catch (err: any) {
    console.error('[ManualLeads DELETE]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
