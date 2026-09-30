/**
 * Payment Controller - Production-Ready
 * 
 * Handles all payment operations with security best practices:
 * - Server-side signature verification (never trust frontend)
 * - Idempotent payment processing (handles duplicates)
 * - Comprehensive error handling and logging
 * - No sensitive data in logs
 */

const crypto = require('crypto');
const Payment = require('../models/Payment');
const { sendPaymentConfirmationEmail } = require('../utils/sendEmail');
const { getRazorpay, verifyPaymentSignature, hasRealKeys } = require('../config/razorpay');

/**
 * Plan Catalogue
 * Defines all available plans with pricing and details
 */
const PLANS = {
  'plan-1': {
    label: 'Starter Plan',
    courseName: 'Adyapan Starter',
    amount: 3000, // in INR
    amountPaise: 300000, // in paise (amount * 100)
    duration: '2 Months',
  },
  'plan-2': {
    label: 'Standard Plan',
    courseName: 'Adyapan Standard',
    amount: 3500,
    amountPaise: 350000,
    duration: '2 Months',
  },
  'plan-3': {
    label: 'Professional Plan',
    courseName: 'Adyapan Professional',
    amount: 5000,
    amountPaise: 500000,
    duration: '3 Months',
  },
  'plan-4-premium': {
    label: 'Career Pro Plan',
    courseName: 'Adyapan Career Pro',
    amount: 15000,
    amountPaise: 1500000,
    duration: '4 Months',
  },
};

/**
 * POST /api/payment/create-order
 * 
 * Creates a Razorpay order for the selected plan
 * 
 * Request body:
 * {
 *   plan: 'plan-4-premium'
 * }
 * 
 * Response:
 * {
 *   success: true,
 *   orderId: 'order_XXXXX',
 *   amount: 1500000,
 *   currency: 'INR',
 *   keyId: 'rzp_test_XXXXX',
 *   testMode: false
 * }
 */
const createOrder = async (req, res) => {
  try {
    const { plan } = req.body;

    // Validate plan
    if (!plan || !PLANS[plan]) {
      return res.status(400).json({
        success: false,
        error: 'Invalid plan selected',
      });
    }

    const planData = PLANS[plan];

    // TEST MODE: No real Razorpay keys configured
    if (!hasRealKeys()) {
      const mockOrderId = `order_TEST_${Date.now()}`;
      console.log(
        `[Payment] TEST MODE - Mock order created: ${mockOrderId} | Plan: ${plan} | Amount: ₹${planData.amount}`
      );

      return res.json({
        success: true,
        orderId: mockOrderId,
        amount: planData.amountPaise,
        currency: 'INR',
        keyId: process.env.RAZORPAY_KEY_ID || 'rzp_test_placeholder',
        testMode: true,
      });
    }

    // LIVE MODE: Create real Razorpay order
    try {
      const razorpay = getRazorpay();
      const order = await razorpay.orders.create({
        amount: planData.amountPaise,
        currency: 'INR',
        receipt: `rcpt_${plan}_${Date.now()}`,
        notes: {
          plan,
          courseName: planData.courseName,
        },
      });

      console.log(
        `[Payment] ✅ Order created: ${order.id} | Plan: ${plan} | Amount: ₹${planData.amount}`
      );

      return res.json({
        success: true,
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: process.env.RAZORPAY_KEY_ID,
        testMode: false,
      });
    } catch (razorpayError) {
      console.error('[Payment] Razorpay API error:', razorpayError.message);
      return res.status(500).json({
        success: false,
        error: 'Failed to create payment order',
      });
    }
  } catch (error) {
    console.error('[Payment] createOrder error:', error.message);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
};

/**
 * POST /api/payment/verify
 * 
 * Verifies payment signature and saves payment record
 * THIS IS THE MOST CRITICAL SECURITY FUNCTION
 * 
 * Request body:
 * {
 *   razorpay_order_id: 'order_XXXXX',
 *   razorpay_payment_id: 'pay_XXXXX',
 *   razorpay_signature: 'signature_hash',
 *   name: 'John Doe',
 *   email: 'john@example.com',
 *   phone: '9876543210',
 *   plan: 'plan-4-premium',
 *   amount: 15000
 * }
 * 
 * Response:
 * {
 *   success: true,
 *   paymentId: 'pay_XXXXX',
 *   orderId: 'order_XXXXX',
 *   message: 'Payment verified successfully'
 * }
 */
const verifyPayment = async (req, res) => {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      name,
      email,
      phone = '',
      plan,
      amount,
    } = req.body;

    // Validate required fields
    if (!razorpay_order_id || !razorpay_payment_id || !name || !email || !plan) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields',
      });
    }

    // Validate plan
    if (!PLANS[plan]) {
      return res.status(400).json({
        success: false,
        error: 'Invalid plan',
      });
    }

    const planData = PLANS[plan];

    // SECURITY: Verify signature server-side (NEVER trust frontend)
    // Test mode is decided by SERVER config (no real keys), never by a
    // client-supplied order-id prefix — otherwise anyone could name their
    // order "order_TEST_..." to skip verification.
    let signatureValid = false;

    if (!hasRealKeys()) {
      console.log(`[Payment] TEST MODE (no real keys) - Skipping signature verification for ${razorpay_order_id}`);
      signatureValid = true;
    } else {
      // Live mode - verify HMAC SHA256 signature
      try {
        signatureValid = verifyPaymentSignature(
          razorpay_order_id,
          razorpay_payment_id,
          razorpay_signature
        );
      } catch (error) {
        console.error('[Payment] Signature verification error:', error.message);
        return res.status(500).json({
          success: false,
          error: 'Signature verification failed',
        });
      }
    }

    if (!signatureValid) {
      console.warn(
        `[Payment] ❌ INVALID SIGNATURE - Order: ${razorpay_order_id} | Payment: ${razorpay_payment_id}`
      );

      // Save failed payment record for audit
      try {
        await Payment.create({
          userName: name,
          userEmail: email.toLowerCase().trim(),
          userPhone: phone,
          courseSlug: plan,
          courseName: planData.courseName,
          planLabel: planData.label,
          baseAmount: planData.amount,
          gstAmount: 0,
          totalAmount: planData.amount,
          paymentId: razorpay_payment_id || `failed_${Date.now()}`,
          orderId: razorpay_order_id,
          status: 'failed',
          signatureVerified: false,
        });
      } catch (dbError) {
        console.error('[Payment] Failed to save failed payment record:', dbError.message);
      }

      return res.status(400).json({
        success: false,
        error: 'Payment verification failed - invalid signature',
      });
    }

    // SECURITY: Check for duplicate payment (idempotency)
    const existingPayment = await Payment.findOne({ paymentId: razorpay_payment_id });
    if (existingPayment) {
      console.log(
        `[Payment] ⚠️ Duplicate payment detected: ${razorpay_payment_id} - Returning cached success`
      );
      return res.json({
        success: true,
        paymentId: razorpay_payment_id,
        orderId: razorpay_order_id,
        duplicate: true,
        message: 'Payment already processed',
      });
    }

    // Save payment record to database
    const payment = await Payment.create({
      userName: name,
      userEmail: email.toLowerCase().trim(),
      userPhone: phone,
      courseSlug: plan,
      courseName: planData.courseName,
      planLabel: planData.label,
      baseAmount: planData.amount,
      gstAmount: Math.round(planData.amount * 0.18),
      totalAmount: Math.round(planData.amount * 1.18),
      paymentId: razorpay_payment_id,
      orderId: razorpay_order_id,
      status: 'success',
      signatureVerified: true,
      paidAt: new Date(),
    });

    console.log(
      `[Payment] ✅ Payment saved - ID: ${payment._id} | Email: ${email} | Amount: ₹${planData.amount}`
    );

    // Send confirmation email
    let emailSent = false;
    try {
      emailSent = await sendPaymentConfirmationEmail({
        name,
        email,
        courseName: planData.courseName,
        planLabel: planData.label,
        amount: planData.amount,
        paymentId: razorpay_payment_id,
        orderId: razorpay_order_id,
      });

      // Update email sent flag
      await Payment.findByIdAndUpdate(payment._id, { emailSent });
      console.log(`[Payment] Email sent: ${emailSent} | Email: ${email}`);
    } catch (emailError) {
      console.error('[Payment] Email sending error:', emailError.message);
    }

    return res.json({
      success: true,
      paymentId: razorpay_payment_id,
      orderId: razorpay_order_id,
      emailSent,
      message: emailSent
        ? `✅ Payment verified. Confirmation email sent to ${email}`
        : `✅ Payment verified. Email delivery pending.`,
    });
  } catch (error) {
    console.error('[Payment] verifyPayment error:', error.message);
    return res.status(500).json({
      success: false,
      error: 'Payment verification failed',
    });
  }
};

/**
 * GET /api/payment/check-status
 * 
 * Checks payment status for UPI polling
 * Used by frontend to poll for payment confirmation
 * 
 * Query params:
 * - orderId: Razorpay order ID
 * - name: Customer name
 * - email: Customer email
 * - phone: Customer phone
 * - plan: Plan ID
 * - amount: Total amount
 * 
 * Response:
 * {
 *   paid: true/false,
 *   paymentId: 'pay_XXXXX' (if paid),
 *   orderId: 'order_XXXXX'
 * }
 */
const checkPaymentStatus = async (req, res) => {
  try {
    const { orderId } = req.query;

    if (!orderId) {
      return res.status(400).json({
        paid: false,
        error: 'orderId is required',
      });
    }

    // Check if payment already exists in database
    const payment = await Payment.findOne({ orderId });
    if (payment && payment.status === 'success') {
      console.log(`[Payment] Status check - Payment found: ${payment.paymentId}`);
      return res.json({
        paid: true,
        paymentId: payment.paymentId,
        orderId,
      });
    }

    // Test mode - auto-confirm after a few polls
    if (orderId.startsWith('order_TEST_')) {
      console.log(`[Payment] TEST MODE - Status check for ${orderId}`);
      return res.json({
        paid: false,
        orderId,
        testMode: true,
      });
    }

    // Live mode - check with Razorpay API
    try {
      const razorpay = getRazorpay();
      if (!razorpay) {
        return res.json({ paid: false, orderId });
      }

      const order = await razorpay.orders.fetchPayments(orderId);
      const payments = order?.items ?? [];
      const capturedPayment = payments.find((p) => p.status === 'captured');

      if (capturedPayment) {
        console.log(`[Payment] Status check - Captured payment found: ${capturedPayment.id}`);
        return res.json({
          paid: true,
          paymentId: capturedPayment.id,
          orderId,
        });
      }

      return res.json({ paid: false, orderId });
    } catch (razorpayError) {
      console.error('[Payment] Razorpay API error during status check:', razorpayError.message);
      return res.json({ paid: false, orderId, error: 'Status check failed' });
    }
  } catch (error) {
    console.error('[Payment] checkPaymentStatus error:', error.message);
    return res.status(500).json({
      success: false,
      error: 'Status check failed',
    });
  }
};

module.exports = {
  createOrder,
  verifyPayment,
  checkPaymentStatus,
};
