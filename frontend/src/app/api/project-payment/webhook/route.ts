/**
 * POST /api/project-payment/webhook
 *
 * Razorpay webhook handler for project payments.
 * Acts as a backup source of truth - handles payment.captured and payment.failed.
 *
 * SECURITY:
 *  - Webhook signature verified using RAZORPAY_WEBHOOK_SECRET
 *  - Idempotent - duplicate events are safely ignored
 */

import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';
import { connectToDatabase } from '@/lib/mongodb';
import mongoose from 'mongoose';

/* â"€â"€ Disable body parsing - we need raw bytes for signature verification â"€â"€ */
export const dynamic = 'force-dynamic';

function getModel(name: string, schema: mongoose.Schema) {
  return mongoose.models[name] || mongoose.model(name, schema);
}

const projectPaymentSchema = new mongoose.Schema(
  {
    projectRequestId:  mongoose.Schema.Types.ObjectId,
    contactName: String, contactEmail: String, contactPhone: String,
    razorpayOrderId:   String, razorpayPaymentId: String, razorpaySignature: String,
    amount: Number, currency: String,
    status:            { type: String, enum: ['pending','success','failed'], default: 'pending' },
    signatureVerified: Boolean, isTestMode: Boolean,
    paidAt: Date, failureReason: String,
  },
  { timestamps: true }
);

const projectRequestSchema = new mongoose.Schema(
  {
    paymentId: String, orderId: String,
    paymentStatus: { type: String, enum: ['pending','success','failed'], default: 'pending' },
    paidAmount: Number, projectStatus: String, budget: Number, emailSent: Boolean,
  },
  { timestamps: true }
);

function verifyWebhookSignature(rawBody: string, signature: string): boolean {
  const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
  // Always reject when the secret is missing/placeholder (never fail-open),
  // regardless of environment — a webhook is only ever called by Razorpay.
  if (!secret || secret.includes('your_webhook')) {
    console.error('[Webhook] RAZORPAY_WEBHOOK_SECRET is not configured - rejecting webhook');
    return false;
  }
  const expected = crypto.createHmac('sha256', secret).update(rawBody).digest('hex');
  const a = Buffer.from(expected);
  const b = Buffer.from(String(signature || ''));
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

export async function POST(req: NextRequest) {
  try {
    const rawBody  = await req.text();
    const signature = req.headers.get('x-razorpay-signature') || '';

    /* â"€â"€ 1. Verify webhook signature â"€â"€ */
    if (!verifyWebhookSignature(rawBody, signature)) {
      console.warn('[Webhook]  Invalid webhook signature');
      return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
    }

    const event = JSON.parse(rawBody);
    const eventType = event?.event;
    const payment   = event?.payload?.payment?.entity;

    if (!payment) {
      return NextResponse.json({ received: true });
    }

    await connectToDatabase();
    const ProjectPayment = getModel('ProjectPayment', projectPaymentSchema);
    const ProjectRequest = getModel('ProjectRequest', projectRequestSchema);

    const orderId   = payment.order_id;
    const paymentId = payment.id;

    /* â"€â"€ 2. Find the payment record â"€â"€ */
    const paymentRecord = await ProjectPayment.findOne({ razorpayOrderId: orderId });
    if (!paymentRecord) {
      // Not a project payment - ignore
      return NextResponse.json({ received: true });
    }

    /* â"€â"€ 3. Handle events â"€â"€ */
    if (eventType === 'payment.captured') {
      // Idempotency check
      if (paymentRecord.status === 'success') {
        return NextResponse.json({ received: true, note: 'already processed' });
      }

      await ProjectPayment.findByIdAndUpdate(paymentRecord._id, {
        razorpayPaymentId: paymentId,
        status:            'success',
        signatureVerified: true,
        paidAt:            new Date(payment.created_at * 1000),
      });

      await ProjectRequest.findByIdAndUpdate(paymentRecord.projectRequestId, {
        paymentId,
        paymentStatus: 'success',
        paidAmount:    payment.amount / 100,
        projectStatus: 'submitted',
      });

      console.log(`[Webhook]  payment.captured - Order: ${orderId} | Payment: ${paymentId}`);

    } else if (eventType === 'payment.failed') {
      if (paymentRecord.status === 'failed') {
        return NextResponse.json({ received: true, note: 'already processed' });
      }

      const reason = payment.error_description || payment.error_code || 'Payment failed';

      await ProjectPayment.findByIdAndUpdate(paymentRecord._id, {
        razorpayPaymentId: paymentId,
        status:            'failed',
        failureReason:     reason,
      });

      await ProjectRequest.findByIdAndUpdate(paymentRecord.projectRequestId, {
        paymentStatus: 'failed',
      });

      console.log(`[Webhook]  payment.failed - Order: ${orderId} | Reason: ${reason}`);
    }

    return NextResponse.json({ received: true });

  } catch (err: any) {
    console.error('[Webhook] Error:', err?.message);
    // Always return 200 to Razorpay so it doesn't retry
    return NextResponse.json({ received: true });
  }
}
