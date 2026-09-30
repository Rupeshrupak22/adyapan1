/**
 * POST /api/payment/webhook
 *
 * Razorpay Webhook - authoritative source for payment events.
 * Uses db-service for all persistence.
 *
 * Events: payment.captured -> success flow | payment.failed -> failure flow
 *
 * Setup: Webhook URL: https://yourdomain.com/api/payment/webhook
 *        Secret: RAZORPAY_WEBHOOK_SECRET in .env
 */

import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';
import { connectToDatabase } from '@/lib/mongodb';
import {
  savePayment,
  createEnrollmentWithProgress,
  logEmail,
  wasEmailSent,
} from '@/lib/db-service';
import { sendPaymentSuccessEmail, sendPaymentFailureEmail } from '@/lib/email';
import AuthUser from '@/models/AuthUser';
import Payment from '@/models/Payment';

const PLAN_SLUGS: Record<string, string> = {
  'plan-1':         'Adyapan Starter',
  'plan-2':         'Adyapan Standard',
  'plan-3':         'Adyapan Professional',
  'plan-4-premium': 'Adyapan Career Pro',
};

function verifyWebhookSignature(body: string, signature: string): boolean {
  const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
  // A webhook is only ever called by Razorpay, so a missing/placeholder secret
  // must ALWAYS reject (never fail-open) — otherwise staging/preview deployments
  // would accept forged payment events.
  if (!secret || secret.includes('your_webhook')) {
    console.error('[Webhook] RAZORPAY_WEBHOOK_SECRET is not configured - rejecting webhook');
    return false;
  }
  const expected = crypto.createHmac('sha256', secret).update(body).digest('hex');
  const a = Buffer.from(expected);
  const b = Buffer.from(String(signature || ''));
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

export async function POST(req: NextRequest) {
  const rawBody  = await req.text();
  const signature = req.headers.get('x-razorpay-signature') || '';

  if (!verifyWebhookSignature(rawBody, signature)) {
    console.warn('[Webhook]  Invalid signature - rejected');
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  let event: any;
  try { event = JSON.parse(rawBody); }
  catch { return NextResponse.json({ error: 'Invalid JSON' }, { status: 400 }); }

  const eventType     = event.event as string;
  const paymentEntity = event.payload?.payment?.entity;
  if (!paymentEntity) return NextResponse.json({ received: true });

  await connectToDatabase();

  const paymentId  = paymentEntity.id as string;
  const orderId    = paymentEntity.order_id as string;
  const amount     = (paymentEntity.amount || 0) / 100;
  const email      = (paymentEntity.email || '') as string;
  const contact    = (paymentEntity.contact || '') as string;
  const notes      = paymentEntity.notes || {};
  const courseSlug = (notes.plan || notes.courseSlug || 'plan-4-premium') as string;
  const courseName = PLAN_SLUGS[courseSlug] || 'Adyapan Course';
  const planLabel  = (notes.planLabel || courseName) as string;

  console.log(`[Webhook] ${eventType} | ${paymentId} | ${orderId}`);

  /* â"€â"€ PAYMENT CAPTURED â"€â"€ */
  if (eventType === 'payment.captured') {
    // Idempotency
    const existing = await Payment.findOne({ paymentId });
    if (existing) {
      console.log(`[Webhook] Duplicate captured: ${paymentId} - skip`);
      return NextResponse.json({ received: true });
    }

    const base = parseFloat(amount.toFixed(2));
    const gst  = 0;

    const dbUser   = await AuthUser.findOne({ email: email.toLowerCase() }).lean();
    const userId   = (dbUser as any)?._id?.toString() || '';
    const userName = (dbUser as any)?.name || paymentEntity.name || 'Student';

    // Critical: save payment
    await savePayment({
      userId, userName, userEmail: email.toLowerCase(), userPhone: contact,
      paymentId, orderId, courseSlug, courseName, planLabel,
      baseAmount: base, gstAmount: gst, totalAmount: amount,
      status: 'success', paymentMethod: paymentEntity.method || 'upi',
      signatureVerified: true, isTestMode: false, paidAt: new Date(),
    });

    // Critical: enroll
    if (userId) {
      await createEnrollmentWithProgress({
        userId, courseSlug, courseName,
        planId: courseSlug, planLabel, amountPaid: amount, paymentId,
      }).catch(e => console.warn('[Webhook] Enrollment error:', e?.message));
    }

    // Email
    const alreadySent = await wasEmailSent('paymentId', paymentId, 'payment_success');
    if (!alreadySent && email) {
      let emailStatus: 'sent' | 'failed' = 'failed';
      let errorMessage = '';
      try {
        const sent = await sendPaymentSuccessEmail({
          name: userName, email, courseName, courseSlug,
          planLabel, amount, paymentId, orderId,
        });
        emailStatus = sent ? 'sent' : 'failed';
        if (!sent) errorMessage = 'SendGrid non-202';
      } catch (e: any) { errorMessage = e?.message || 'Unknown'; }

      await logEmail({
        userId, email, emailType: 'payment_success',
        subject: `Payment Confirmed - ${courseName}`,
        status: emailStatus, errorMessage,
        paymentId, orderId, courseSlug, courseName, amount,
      });
    }

    return NextResponse.json({ received: true, status: 'success' });
  }

  /* â"€â"€ PAYMENT FAILED â"€â"€ */
  if (eventType === 'payment.failed') {
    const failureReason = paymentEntity.error_description || paymentEntity.error_reason || 'Payment declined';

    const existing = await Payment.findOne({ paymentId, status: 'failed' });
    if (!existing) {
      await savePayment({
        userId: '', userName: '', userEmail: email.toLowerCase(), userPhone: contact,
        paymentId: paymentId || `failed_${Date.now()}`, orderId,
        courseSlug, courseName, planLabel,
        baseAmount: amount, gstAmount: 0, totalAmount: amount,
        status: 'failed', paymentMethod: paymentEntity.method || 'upi',
        failureReason, signatureVerified: false, isTestMode: false,
      }).catch(e => console.warn('[Webhook] Failed payment save error:', e?.message));
    }

    // Failure email
    const alreadySent = await wasEmailSent('paymentId', orderId, 'payment_failed');
    if (!alreadySent && email) {
      const dbUser   = await AuthUser.findOne({ email: email.toLowerCase() }).lean();
      const userName = (dbUser as any)?.name || 'Student';
      const userId   = (dbUser as any)?._id?.toString() || '';

      let emailStatus: 'sent' | 'failed' = 'failed';
      let errorMessage = '';
      try {
        const sent = await sendPaymentFailureEmail({
          name: userName, email, courseName, courseSlug,
          planLabel, amount, orderId, failureReason,
        });
        emailStatus = sent ? 'sent' : 'failed';
        if (!sent) errorMessage = 'SendGrid non-202';
      } catch (e: any) { errorMessage = e?.message || 'Unknown'; }

      await logEmail({
        userId, email, emailType: 'payment_failed',
        subject: `Payment Failed - ${courseName}`,
        status: emailStatus, errorMessage,
        paymentId: paymentId || '', orderId, courseSlug, courseName, amount,
      });
    }

    return NextResponse.json({ received: true, status: 'failed' });
  }

  return NextResponse.json({ received: true });
}
