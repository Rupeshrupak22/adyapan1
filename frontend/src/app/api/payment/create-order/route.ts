/**
 * POST /api/payment/create-order
 * 
 * Creates a Razorpay order for the selected plan
 * This endpoint is called by the frontend checkout page
 * 
 * SECURITY:
 * - Validates plan against hardcoded catalogue
 * - Returns only necessary data (no secrets)
 * - Always uses real Razorpay (no test mode)
 */

import { NextRequest, NextResponse } from 'next/server';
import { getClientIp, isRateLimited, rateLimitResponse } from '@/lib/security';

const PLAN_BASE_PRICES: Record<string, number> = {
  'plan-1': 3000,
  'plan-2': 3500,
  'plan-3': 5000,
  'plan-4-premium': 15000,
};

/**
 * Coupons + which plans they may apply to.
 * `plans: null` = any plan. CAREER20 (a premium discount) is restricted to the
 * premium plan so it can't be stacked onto the cheapest plan.
 */
const COUPONS: Record<string, { type: 'percent' | 'flat'; value: number; label: string; plans: string[] | null }> = {
  ADYAPAN5:  { type: 'percent', value: 5,    label: 'Extra 5% Off',    plans: null },
  STUDENT10: { type: 'flat',    value: 1000, label: 'Rs. 1,000 Off',   plans: null },
  CAREER20:  { type: 'percent', value: 20,   label: '20% Off Premium', plans: ['plan-4-premium'] },
};

function calculatePricing(plan: string, couponCode?: string) {
  const basePrice = PLAN_BASE_PRICES[plan];
  if (!basePrice) return null;

  const code = String(couponCode || '').trim().toUpperCase();
  const coupon = code ? COUPONS[code] : null;
  if (code && !coupon) return { error: 'Invalid coupon code' as const };
  if (coupon && coupon.plans && !coupon.plans.includes(plan)) {
    return { error: 'This coupon is not valid for the selected plan' as const };
  }

  const couponDiscount = coupon
    ? coupon.type === 'percent'
      ? Math.round((basePrice * coupon.value) / 100)
      : coupon.value
    : 0;
  const discountedBase = Math.max(0, basePrice - couponDiscount);
  const totalAmount = parseFloat(discountedBase.toFixed(2));

  return {
    basePrice,
    couponCode: coupon ? code : '',
    couponLabel: coupon?.label || '',
    couponDiscount,
    discountedBase,
    gstAmount: 0,
    totalAmount,
    amountPaise: Math.round(totalAmount * 100),
  };
}

export async function POST(req: NextRequest) {
  const ip = getClientIp(req);
  if (isRateLimited(`create-order:${ip}`, 15, 15 * 60 * 1000)) {
    return rateLimitResponse('Too many attempts. Please try again later.');
  }

  try {
    const { plan, couponCode } = await req.json();

    // Validate plan
    const pricing = calculatePricing(plan, couponCode);
    if (!pricing) {
      return NextResponse.json(
        { success: false, error: 'Invalid plan selected' },
        { status: 400 }
      );
    }
    if ('error' in pricing) {
      return NextResponse.json(
        { success: false, error: pricing.error },
        { status: 400 }
      );
    }

    // Create real Razorpay order
    try {
      const Razorpay = (await import('razorpay')).default;
      const razorpay = new Razorpay({
        key_id: process.env.RAZORPAY_KEY_ID!,
        key_secret: process.env.RAZORPAY_KEY_SECRET!,
      });

      const order = await razorpay.orders.create({
        amount: pricing.amountPaise,
        currency: 'INR',
        receipt: `rcpt_${plan}_${Date.now()}`,
        notes: {
          plan,
          couponCode: pricing.couponCode,
          couponDiscount: String(pricing.couponDiscount),
          taxableAmount: String(pricing.discountedBase),
          gstAmount: '0',
        },
      });

      console.log(
        `[Payment]  Order created: ${order.id} | Plan: ${plan} | Amount: Rs. ${pricing.totalAmount}`
      );

      return NextResponse.json({
        success: true,
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: process.env.RAZORPAY_KEY_ID,
        pricing: {
          basePrice: pricing.basePrice,
          couponCode: pricing.couponCode,
          couponLabel: pricing.couponLabel,
          couponDiscount: pricing.couponDiscount,
          gstAmount: pricing.gstAmount,
          totalAmount: pricing.totalAmount,
        },
      });
    } catch (razorpayError: any) {
      console.error('[Payment] Razorpay API error:', razorpayError?.message);
      return NextResponse.json(
        { success: false, error: 'Failed to create payment order' },
        { status: 500 }
      );
    }
  } catch (error: any) {
    console.error('[Payment] Order creation error:', error?.message);
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    );
  }
}
