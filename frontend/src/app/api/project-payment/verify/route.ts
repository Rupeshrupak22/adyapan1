/**
 * POST /api/project-payment/verify
 *
 * Verifies Razorpay payment signature (HMAC SHA256) and finalises the
 * ProjectRequest + ProjectPayment records.
 *
 * SECURITY:
 *  - Signature is verified server-side using RAZORPAY_KEY_SECRET
 *  - Amount is never re-read from the frontend - we use the DB record
 *  - Idempotent: duplicate payment IDs are detected and short-circuited
 */

import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';
import { connectToDatabase } from '@/lib/mongodb';
import mongoose from 'mongoose';
import ProjectRequest from '@/models/ProjectRequest';
import ProjectPayment from '@/models/ProjectPayment';
import { sanitizeMongoInput } from '@/lib/security';

/**
 * Test mode is decided ONLY by a server-side env flag, never by a
 * client-supplied order-id prefix. This prevents a caller from skipping
 * signature verification by naming their order "order_..._TEST_".
 */
function isServerTestMode(): boolean {
  const keyId = process.env.RAZORPAY_KEY_ID || '';
  return keyId.startsWith('rzp_test_');
}

function verifySignature(orderId: string, paymentId: string, signature: string): boolean {
  const secret = process.env.RAZORPAY_KEY_SECRET;
  if (!secret) throw new Error('RAZORPAY_KEY_SECRET not set');
  const body     = `${orderId}|${paymentId}`;
  const expected = crypto.createHmac('sha256', secret).update(body).digest('hex');
  // constant-time comparison to avoid timing leaks
  const a = Buffer.from(expected);
  const b = Buffer.from(String(signature || ''));
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

export async function POST(req: NextRequest) {
  try {
    await connectToDatabase();

    const body = sanitizeMongoInput(await req.json()) as Record<string, string>;
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      projectRequestId,
    } = body;

    /* â"€â"€ 1. Validate inputs â"€â"€ */
    if (!razorpay_order_id || !razorpay_payment_id || !projectRequestId) {
      return NextResponse.json(
        { success: false, error: 'Missing required payment fields' },
        { status: 400 }
      );
    }

    /* â"€â"€ 2. Idempotency: already processed? â"€â"€ */
    const existingPayment = await ProjectPayment.findOne({
      razorpayPaymentId: razorpay_payment_id,
      status: 'success',
    });
    if (existingPayment) {
      console.log(`[ProjectPayment] Duplicate payment: ${razorpay_payment_id}`);
      return NextResponse.json({
        success: true,
        projectRequestId,
        duplicate: true,
        message: 'Payment already processed',
      });
    }

    /* â"€â"€ 3. Verify signature (server-side decides test mode, not the client) â"€â"€ */
    let signatureValid = false;
    if (isServerTestMode() && !process.env.RAZORPAY_KEY_SECRET) {
      // Only skip when this deployment is explicitly a Razorpay TEST deployment
      // AND no secret is configured to verify against.
      console.warn('[ProjectPayment] TEST deployment without secret - skipping signature verification');
      signatureValid = true;
    } else {
      try {
        signatureValid = verifySignature(
          razorpay_order_id,
          razorpay_payment_id,
          razorpay_signature
        );
      } catch (err: any) {
        console.error('[ProjectPayment] Signature error:', err?.message);
        return NextResponse.json(
          { success: false, error: 'Payment verification failed' },
          { status: 500 }
        );
      }
    }

    if (!signatureValid) {
      console.warn(`[ProjectPayment]  Invalid signature - Order: ${razorpay_order_id}`);

      // Mark payment as failed
      await ProjectPayment.findOneAndUpdate(
        { razorpayOrderId: razorpay_order_id },
        { status: 'failed', failureReason: 'Invalid signature', razorpayPaymentId: razorpay_payment_id }
      );
      await ProjectRequest.findByIdAndUpdate(projectRequestId, { paymentStatus: 'failed' });

      return NextResponse.json(
        { success: false, error: 'Payment verification failed - invalid signature' },
        { status: 400 }
      );
    }

    /* â"€â"€ 4. Load the ProjectRequest to get amount â"€â"€ */
    const projectRequest = await ProjectRequest.findById(projectRequestId);
    if (!projectRequest) {
      return NextResponse.json(
        { success: false, error: 'Project request not found' },
        { status: 404 }
      );
    }

    /* â"€â"€ 5. Update ProjectPayment â"€â"€ */
    await ProjectPayment.findOneAndUpdate(
      { razorpayOrderId: razorpay_order_id },
      {
        razorpayPaymentId: razorpay_payment_id,
        razorpaySignature: razorpay_signature,
        status:            'success',
        signatureVerified: true,
        paidAt:            new Date(),
      }
    );

    /* â"€â"€ 6. Update ProjectRequest â"€â"€ */
    await ProjectRequest.findByIdAndUpdate(projectRequestId, {
      paymentId:     razorpay_payment_id,
      orderId:       razorpay_order_id,
      paymentStatus: 'success',
      paidAmount:    projectRequest.budget,
      projectStatus: 'submitted',
    });

    console.log(`[ProjectPayment]  Payment verified - Project: ${projectRequestId} | Payment: ${razorpay_payment_id}`);

    /* â"€â"€ 7. Send confirmation emails (non-blocking) â"€â"€ */
    sendConfirmationEmails(projectRequest, razorpay_payment_id).catch((e) =>
      console.error('[ProjectPayment] Email error:', e.message)
    );

    return NextResponse.json({
      success:          true,
      projectRequestId: projectRequestId,
      paymentId:        razorpay_payment_id,
      message:          'Payment verified and project submitted successfully',
    });

  } catch (err: any) {
    console.error('[ProjectPayment] verify error:', err?.message);
    return NextResponse.json(
      { success: false, error: 'Internal server error. Please contact support.' },
      { status: 500 }
    );
  }
}

/* â"€â"€ Email helper using Resend - fire-and-forget â"€â"€ */
async function sendConfirmationEmails(projectRequest: any, paymentId: string) {
  try {
    const apiKey = String(process.env.RESEND_API_KEY || '').trim();
    const fromEmail = String(process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev').trim();
    const fromName = String(process.env.RESEND_FROM_NAME || 'Adyapan School').trim();

    if (!apiKey || apiKey === 'ADD_NEW_RESEND_API_KEY_HERE') {
      console.warn('[ProjectPayment] RESEND_API_KEY not set - skipping emails');
      return;
    }

    const { Resend } = await import('resend');
    const resend = new Resend(apiKey);
    const from = `${fromName} <${fromEmail}>`;

    const appUrl      = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';
    const fmt         = (n: number) => 'Rs. ' + Number(n).toLocaleString('en-IN');
    const date        = new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'long', year: 'numeric' });
    const deadlineStr = new Date(projectRequest.deadline).toLocaleDateString('en-IN', { day: '2-digit', month: 'long', year: 'numeric' });

    const clientHtml = `<!DOCTYPE html><html><body style="margin:0;padding:0;background:#f5f0eb;font-family:sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" style="padding:40px 16px;background:#f5f0eb;">
<tr><td align="center">
<table width="600" style="background:#fff;border-radius:24px;overflow:hidden;box-shadow:0 8px 40px rgba(0,0,0,.1);">
<tr><td style="background:linear-gradient(135deg,#ffa800,#ff6b00);padding:40px;text-align:center;">
  <h1 style="margin:0 0 8px;color:#fff;font-size:26px;font-weight:800;">Project Request Received!</h1>
  <p style="margin:0;color:rgba(255,255,255,.88);font-size:14px;">Payment confirmed - we'll review within 24 hours</p>
</td></tr>
<tr><td style="padding:36px 40px;">
  <p style="font-size:18px;font-weight:700;color:#111827;margin:0 0 6px;">Hi ${projectRequest.contactName},</p>
  <p style="font-size:14px;color:#6b7280;line-height:1.7;margin:0 0 24px;">
    We received your project <strong style="color:#ea580c;">${projectRequest.projectTitle}</strong>.
  </p>
  <table width="100%" style="background:#fff7ed;border:1.5px solid #fed7aa;border-radius:12px;margin-bottom:24px;">
  <tr><td style="padding:16px 20px;">
    <p style="margin:0 0 12px;font-size:11px;font-weight:700;color:#92400e;text-transform:uppercase;">Receipt</p>
    <p style="margin:4px 0;font-size:13px;color:#374151;"><b>Project:</b> ${projectRequest.projectTitle}</p>
    <p style="margin:4px 0;font-size:13px;color:#374151;"><b>Category:</b> ${projectRequest.category}</p>
    <p style="margin:4px 0;font-size:13px;color:#374151;"><b>Amount Paid:</b> ${fmt(projectRequest.budget)}</p>
    <p style="margin:4px 0;font-size:13px;color:#374151;"><b>Deadline:</b> ${deadlineStr}</p>
    <p style="margin:4px 0;font-size:13px;color:#374151;"><b>Payment ID:</b> ${paymentId}</p>
    <p style="margin:4px 0;font-size:13px;color:#374151;"><b>Date:</b> ${date}</p>
  </td></tr></table>
  <p style="text-align:center;margin:0 0 24px;">
    <a href="${appUrl}/company/my-projects" style="display:inline-block;padding:14px 36px;background:linear-gradient(135deg,#ffa800,#ff6b00);color:#fff;font-size:14px;font-weight:700;text-decoration:none;border-radius:12px;">Track Your Project -></a>
  </p>
  <p style="font-size:13px;color:#6b7280;margin:0;">Questions? <a href="mailto:support@adyapan.com" style="color:#ea580c;">support@adyapan.com</a></p>
</td></tr>
<tr><td style="background:#1a1a2e;padding:20px 40px;text-align:center;">
  <p style="margin:0;font-size:12px;font-weight:700;color:#ffa800;">Adyapan Skills</p>
  <p style="margin:4px 0 0;font-size:11px;color:#6b7280;">© ${new Date().getFullYear()} Adyapan Skills</p>
</td></tr>
</table></td></tr></table></body></html>`;

    // Send to client
    await resend.emails.send({
      from,
      to:      projectRequest.contactEmail,
      subject: ` Project Request Received - ${projectRequest.projectTitle} | Adyapan`,
      html:    clientHtml,
      text:    `Hi ${projectRequest.contactName}, your project "${projectRequest.projectTitle}" has been received. Amount: ${fmt(projectRequest.budget)}. Payment ID: ${paymentId}. Track at ${appUrl}/company/my-projects`,
    });

    // Send admin notification
    const adminEmail = process.env.ADMIN_EMAIL || '';
    if (!adminEmail) {
      console.warn('[project-payment] ADMIN_EMAIL not set - skipping admin notification');
    } else {
      await resend.emails.send({
        from,
        to:      adminEmail,
        subject: ` New Project Request - ${projectRequest.projectTitle}`,
        text:    `New project: ${projectRequest.projectTitle}\nCategory: ${projectRequest.category}\nBudget: ${fmt(projectRequest.budget)}\nClient: ${projectRequest.contactName} <${projectRequest.contactEmail}>\nPhone: ${projectRequest.contactPhone}\nPayment ID: ${paymentId}\nReview: ${appUrl}/admin/project-requests`,
      });
    }

    // Mark email sent
    const ProjectRequest = mongoose.models.ProjectRequest;
    if (ProjectRequest) {
      await ProjectRequest.findByIdAndUpdate(projectRequest._id, { emailSent: true });
    }

    console.log(`[ProjectPayment]  Emails sent to ${projectRequest.contactEmail} and admin`);
  } catch (err: any) {
    console.error('[ProjectPayment] Email send error:', err?.message);
  }
}
