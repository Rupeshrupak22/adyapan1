/**
 * POST /api/project-payment/create-order
 *
 * Creates a Razorpay order for a "Build My Project" submission.
 * Saves a ProjectRequest (status: draft) and a ProjectPayment (status: pending)
 * so we have a DB record before the user even pays.
 *
 * SECURITY:
 *  - Amount is validated server-side (min Rs. 3000) - never trust the frontend
 *  - Razorpay keys are read from env only
 *  - No secrets returned to the client
 */

import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { sendLeadNotificationEmails } from '@/lib/resend';
import ProjectRequest from '@/models/ProjectRequest';
import ProjectPayment from '@/models/ProjectPayment';
import {
  getClientIp, isRateLimited, rateLimitResponse, sanitizeMongoInput, isSpamSubmission,
  isValidName, nameFormatMessage, normalizeName,
  isStrictEmail, strictEmailMessage, normalizeEmail,
  isIndianMobile, indianMobileMessage, normalizeIndianMobile,
} from '@/lib/security';

const MIN_AMOUNT = 3000; // INR

export async function POST(req: NextRequest) {
  const ip = getClientIp(req);
  if (isRateLimited(`project-order:${ip}`, 10, 15 * 60 * 1000)) {
    return rateLimitResponse('Too many attempts. Please try again later.');
  }

  try {
    await connectToDatabase();

    const body = sanitizeMongoInput(await req.json()) as Record<string, any>;
    if (isSpamSubmission(body)) {
      return NextResponse.json({ success: true });
    }
    const {
      projectTitle, category, description, features,
      techPreference, deadline, budget, contactName,
      contactEmail, contactPhone, additionalNotes,
      imageUrls, pdfUrls, referenceFiles, userId,
    } = body;

    /* â"€â"€ 1. Validate required fields â"€â"€ */
    if (!projectTitle?.trim() || !category || !description?.trim() || !deadline) {
      return NextResponse.json(
        { success: false, error: 'Missing required fields' },
        { status: 400 }
      );
    }
    if (!isValidName(contactName)) {
      return NextResponse.json({ success: false, error: nameFormatMessage() }, { status: 400 });
    }
    if (!isStrictEmail(contactEmail)) {
      return NextResponse.json({ success: false, error: strictEmailMessage() }, { status: 400 });
    }
    if (!isIndianMobile(contactPhone)) {
      return NextResponse.json({ success: false, error: indianMobileMessage() }, { status: 400 });
    }

    /* â"€â"€ 2. Validate amount server-side â"€â"€ */
    const amount = Number(budget);
    if (!amount || amount < MIN_AMOUNT) {
      return NextResponse.json(
        { success: false, error: `Minimum project submission amount is Rs. ${MIN_AMOUNT}` },
        { status: 400 }
      );
    }

    /* â"€â"€ 3. Create Razorpay order â"€â"€ */
    const keyId     = process.env.RAZORPAY_KEY_ID;
    const keySecret = process.env.RAZORPAY_KEY_SECRET;

    if (!keyId || !keySecret) {
      console.error('[ProjectPayment] Razorpay keys not configured');
      return NextResponse.json(
        { success: false, error: 'Payment gateway not configured. Please contact support.' },
        { status: 500 }
      );
    }

    const isTestMode = keyId.startsWith('rzp_test_');
    let razorpayOrderId: string;
    let orderAmount: number;

    try {
      const Razorpay = (await import('razorpay')).default;
      const razorpay = new Razorpay({ key_id: keyId, key_secret: keySecret });

      const order = await razorpay.orders.create({
        amount:   Math.round(amount * 100), // paise
        currency: 'INR',
        receipt:  `proj_${Date.now()}`,
        notes:    { projectTitle, contactEmail, type: 'project_build' },
      });

      razorpayOrderId = order.id;
      orderAmount     = order.amount as number;
      console.log(`[ProjectPayment]  Order created: ${razorpayOrderId} | Rs. ${amount}`);
    } catch (rzpErr: any) {
      console.error('[ProjectPayment] Razorpay error:', rzpErr?.message);
      return NextResponse.json(
        { success: false, error: 'Failed to create payment order. Please try again.' },
        { status: 502 }
      );
    }

    const cleanName  = normalizeName(contactName);
    const cleanEmail = normalizeEmail(contactEmail);
    const cleanPhone = normalizeIndianMobile(contactPhone);

    /* â"€â"€ 4. Save ProjectRequest (draft) â"€â"€ */
    const projectRequest = await ProjectRequest.create({
      projectTitle:    projectTitle.trim(),
      category,
      description:     description.trim(),
      features:        Array.isArray(features) ? features.filter(Boolean) : [],
      techPreference:  techPreference || '',
      deadline:        new Date(deadline),
      budget:          amount,
      contactName:     cleanName,
      contactEmail:    cleanEmail,
      contactPhone:    cleanPhone,
      imageUrls:       imageUrls   || [],
      pdfUrls:         pdfUrls     || [],
      referenceFiles:  referenceFiles || [],
      additionalNotes: additionalNotes || '',
      userId:          userId || null,
      orderId:         razorpayOrderId,
      paymentStatus:   'pending',
      paidAmount:      0,
      projectStatus:   'draft',
    });

    /* â"€â"€ 5. Save ProjectPayment (pending) â"€â"€ */
    await ProjectPayment.create({
      projectRequestId:  projectRequest._id,
      contactName:       cleanName,
      contactEmail:      cleanEmail,
      contactPhone:      cleanPhone,
      razorpayOrderId,
      amount,
      currency:          'INR',
      status:            'pending',
      isTestMode,
    });

    /* â"€â"€ 6. Return order details to frontend â"€â"€ */
    await sendLeadNotificationEmails({
      sourcePage: 'Project request form',
      name: projectRequest.contactName,
      phone: projectRequest.contactPhone,
      email: projectRequest.contactEmail,
      course: projectRequest.projectTitle,
      service: projectRequest.category,
      message: projectRequest.description,
      notes: [
        `Budget: INR ${projectRequest.budget}`,
        `Deadline: ${projectRequest.deadline?.toLocaleDateString('en-IN') || deadline}`,
        `Tech preference: ${projectRequest.techPreference || 'Not specified'}`,
        `Additional notes: ${projectRequest.additionalNotes || 'Not specified'}`,
      ].join('\n'),
      submittedAt: projectRequest.createdAt,
    });

    return NextResponse.json({
      success:          true,
      orderId:          razorpayOrderId,
      amount:           orderAmount,
      currency:         'INR',
      keyId,
      projectRequestId: projectRequest._id.toString(),
      isTestMode,
    });

  } catch (err: any) {
    console.error('[ProjectPayment] create-order error:', err?.message);
    return NextResponse.json(
      { success: false, error: 'Internal server error. Please try again.' },
      { status: 500 }
    );
  }
}
