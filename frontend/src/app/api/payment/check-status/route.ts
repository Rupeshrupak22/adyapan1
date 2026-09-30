/**
 * GET /api/payment/check-status
 * 
 * Checks payment status for UPI polling
 * Used by frontend to poll for payment confirmation
 * 
 * SECURITY:
 * - Checks database first (fast path)
 * - Falls back to Razorpay API for live mode
 * - Handles test mode gracefully
 * 
 * Query params:
 * - orderId: Razorpay order ID
 * - name: Customer name
 * - email: Customer email
 * - phone: Customer phone
 * - planName: Plan name
 * - planLabel: Plan label
 * - planKey: Plan key
 * - grandTotal: Total amount
 */

import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import { connectToDatabase } from '@/lib/mongodb';
import { requireJwtSecret, getClientIp, isRateLimited, rateLimitResponse, normalizeName, normalizeEmail, normalizeIndianMobile } from '@/lib/security';
import { sendPaymentSuccessEmail } from '@/lib/email';
import Payment from '@/models/Payment';
import Enrollment from '@/models/Enrollment';
import Progress from '@/models/Progress';
import Course from '@/models/Course';
import AuthUser from '@/models/AuthUser';
import { COURSE_CATALOGUE, withTotalLessons } from '@/lib/courseData';

const PLAN_SLUGS: Record<string, string> = {
  'plan-1': 'Adyapan Starter',
  'plan-2': 'Adyapan Standard',
  'plan-3': 'Adyapan Professional',
  'plan-4-premium': 'Adyapan Career Pro',
};

const PLAN_BASE_PRICES: Record<string, number> = {
  'plan-1': 3000,
  'plan-2': 3500,
  'plan-3': 5000,
  'plan-4-premium': 15000,
};

const COUPONS: Record<string, { type: 'percent' | 'flat'; value: number; plans: string[] | null }> = {
  ADYAPAN5: { type: 'percent', value: 5, plans: null },
  STUDENT10: { type: 'flat', value: 1000, plans: null },
  CAREER20: { type: 'percent', value: 20, plans: ['plan-4-premium'] },
};

function calculatePricing(plan: string, couponCode?: unknown) {
  const basePrice = PLAN_BASE_PRICES[plan];
  if (!basePrice) return null;

  const code = String(couponCode || '').trim().toUpperCase();
  let coupon = code ? COUPONS[code] : null;
  // Ignore a coupon that isn't valid for this plan (keeps amount check honest).
  if (coupon && coupon.plans && !coupon.plans.includes(plan)) coupon = null;
  const couponDiscount = coupon
    ? coupon.type === 'percent'
      ? Math.round((basePrice * coupon.value) / 100)
      : coupon.value
    : 0;
  const totalAmount = Math.max(0, basePrice - couponDiscount);

  return {
    totalAmount,
    amountPaise: Math.round(totalAmount * 100),
  };
}

/**
 * Helper function to save payment and enroll user
 */
async function savePaymentAndEnroll(
  req: NextRequest,
  paymentId: string,
  orderId: string,
  planKey: string,
  planName: string,
  planLabel: string,
  verifiedTotal: number,
  testMode: boolean,
  customerName: string,
  customerEmail: string,
  customerPhone: string
) {
  const token = req.cookies.get('authToken')?.value;
  let userId = '';
  let userName = customerName;
  let userEmail = customerEmail;
  let userPhone = customerPhone;

  if (token) {
    try {
      const decoded = jwt.verify(token, requireJwtSecret()) as {
        userId: string;
      };
      userId = decoded.userId;

      const dbUser = await AuthUser.findById(userId).lean();
      if (dbUser) {
        userName = (dbUser as any).name || userName;
        userEmail = (dbUser as any).email || userEmail;
        userPhone = (dbUser as any).phone || userPhone;
      }
    } catch {
      // Continue without userId
    }
  }

  const courseSlug =
    planKey ||
    Object.keys(PLAN_SLUGS).find((k) => PLAN_SLUGS[k] === planName) ||
    'plan-4-premium';
  const courseName = PLAN_SLUGS[courseSlug] || planName || 'Adyapan Course';

  const total = Number(verifiedTotal) || 0;
  const base = parseFloat(total.toFixed(2));
  const gst = 0;
  const now = new Date();

  // Save Payment record
  const existingPayment = await Payment.findOne({ paymentId });
  if (!existingPayment) {
    await Payment.create({
      userId,
      userName,
      userEmail: userEmail.toLowerCase().trim(),
      userPhone,
      paymentId,
      orderId,
      courseSlug,
      courseName,
      planLabel: planLabel || '',
      baseAmount: base,
      gstAmount: gst,
      totalAmount: total,
      currency: 'INR',
      status: 'success',
      paymentMethod: 'upi',
      signatureVerified: !testMode,
      isTestMode: testMode,
      paidAt: now,
    });

    console.log(
      `[Payment]  Payment saved via polling - ID: ${paymentId} | Email: ${userEmail} | Amount: Rs. ${total}`
    );
  }

  // Enroll user
  if (userId) {
    const existingEnrollment = await Enrollment.findOne({ paymentId });
    if (!existingEnrollment) {
      await Enrollment.create({
        userId,
        courseSlug,
        courseName,
        planLabel: planLabel || '',
        amountPaid: total,
        paymentId,
        enrolledAt: now,
      });

      let course = await Course.findOne({ slug: courseSlug }).lean();
      if (!course) {
        const raw = COURSE_CATALOGUE.find((c) => c.slug === courseSlug);
        if (raw) {
          const data = withTotalLessons(raw);
          course = await Course.findOneAndUpdate(
            { slug: data.slug },
            { $set: data },
            { upsert: true, new: true }
          ).lean();
        }
      }

      await Progress.findOneAndUpdate(
        { userId, courseSlug },
        {
          $setOnInsert: {
            completedLessons: [],
            progressPercent: 0,
            totalLessons: (course as any)?.totalLessons || 0,
          },
        },
        { upsert: true }
      );

      await AuthUser.findByIdAndUpdate(userId, { $addToSet: { purchasedCourses: courseName } });

      console.log(`[Enrollment]  ${userName} enrolled in ${courseSlug} via polling`);
    }
  }
}

export async function GET(req: NextRequest) {
  const ip = getClientIp(req);
  // UPI polling can be frequent, so allow a generous but bounded rate.
  if (isRateLimited(`payment-status:${ip}`, 60, 60 * 1000)) {
    return rateLimitResponse('Too many status checks. Please wait a moment.');
  }

  const { searchParams } = new URL(req.url);
  const orderId = searchParams.get('orderId') || '';
  const name = searchParams.get('name') || '';
  const email = searchParams.get('email') || '';
  const phone = searchParams.get('phone') || '';
  const planName = searchParams.get('planName') || '';
  const planLabel = searchParams.get('planLabel') || '';
  const planKey = searchParams.get('planKey') || '';
  const grandTotal = parseFloat(searchParams.get('grandTotal') || '0');

  if (!orderId) {
    return NextResponse.json(
      { paid: false, error: 'orderId is required' },
      { status: 400 }
    );
  }

  try {
    await connectToDatabase();

    // Check if payment already exists in database (fast path)
    const existingPayment = await Payment.findOne({ orderId });
    if (existingPayment && existingPayment.status === 'success') {
      console.log(`[Payment] Status check - Payment found: ${existingPayment.paymentId}`);
      return NextResponse.json({
        paid: true,
        paymentId: existingPayment.paymentId,
        orderId,
      });
    }

    // LIVE MODE: Check with Razorpay API
    try {
      const Razorpay = (await import('razorpay')).default;
      if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
        console.error('[Payment] Razorpay keys not configured during status check');
        return NextResponse.json(
          { paid: false, orderId, error: 'Payment gateway not configured' },
          { status: 500 }
        );
      }

      const rzp = new Razorpay({
        key_id: process.env.RAZORPAY_KEY_ID,
        key_secret: process.env.RAZORPAY_KEY_SECRET,
      });

      const orderDetails = await (rzp.orders as any).fetch(orderId);
      const orderPayments = await (rzp.orders as any).fetchPayments(orderId);
      const payments: any[] = orderPayments?.items || [];
      const capturedPayment = payments.find((p) => p.status === 'captured');

      if (capturedPayment) {
        const orderNotes = orderDetails?.notes || {};
        const securePlanKey = String(orderNotes.plan || planKey || '').trim();
        const secureCouponCode = String(orderNotes.couponCode || '').trim();
        const pricing = calculatePricing(securePlanKey, secureCouponCode);

        if (!pricing) {
          console.warn(`[Payment] Status check rejected - invalid order plan: ${securePlanKey}`);
          return NextResponse.json(
            { paid: false, orderId, error: 'Invalid payment order' },
            { status: 400 }
          );
        }

        const orderAmount = Number(orderDetails?.amount || 0);
        const paymentAmount = Number(capturedPayment.amount || 0);
        if (orderAmount !== pricing.amountPaise || paymentAmount !== pricing.amountPaise) {
          console.warn(`[Payment] Status check rejected - amount mismatch for ${orderId}`);
          return NextResponse.json(
            { paid: false, orderId, error: 'Payment amount mismatch' },
            { status: 400 }
          );
        }

        await savePaymentAndEnroll(
          req,
          capturedPayment.id,
          orderId,
          securePlanKey,
          PLAN_SLUGS[securePlanKey] || planName,
          planLabel,
          pricing.totalAmount,
          false,
          normalizeName(name),
          normalizeEmail(email),
          normalizeIndianMobile(phone)
        );

        if (email && name) {
          sendPaymentSuccessEmail({
            name,
            email,
            courseName: PLAN_SLUGS[securePlanKey] || planName,
            courseSlug: securePlanKey,
            planLabel,
            amount: pricing.totalAmount,
            paymentId: capturedPayment.id,
            orderId,
          }).catch((err) => console.error('[Payment] Receipt email failed:', err?.message));
        }

        console.log(`[Payment] Status check - Captured payment found: ${capturedPayment.id}`);
        return NextResponse.json({
          paid: true,
          paymentId: capturedPayment.id,
          orderId,
        });
      }

      return NextResponse.json({ paid: false, orderId });
    } catch (razorpayError: any) {
      console.error('[Payment] Razorpay API error during status check:', razorpayError?.message);
      return NextResponse.json(
        { paid: false, orderId, error: 'Status check failed' },
        { status: 500 }
      );
    }
  } catch (error: any) {
    console.error('[Payment] checkPaymentStatus error:', error?.message);
    return NextResponse.json(
      { success: false, error: 'Status check failed' },
      { status: 500 }
    );
  }
}
