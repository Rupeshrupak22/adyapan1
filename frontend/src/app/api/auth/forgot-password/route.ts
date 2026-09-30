import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';
import { z } from 'zod';
import { connectToDatabase } from '@/lib/mongodb';
import {
  getClientIp,
  isStrictEmail,
  isRateLimited,
  normalizeEmail,
  rateLimitResponse,
  sanitizeMongoInput,
  strictEmailMessage,
} from '@/lib/security';
import { getPasswordResetUrl, sendPasswordResetEmail } from '@/lib/password-reset-email';
import AuthUser from '@/models/AuthUser';

const ForgotPasswordSchema = z.object({
  email: z.string().refine(isStrictEmail, strictEmailMessage()).transform(normalizeEmail),
});

const SUCCESS_RESPONSE = {
  success: true,
  message: 'If an account exists with this email, a password reset link has been sent.',
};

function hashResetToken(token: string) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

export async function POST(request: NextRequest) {
  const ip = getClientIp(request);
  if (isRateLimited(`forgot-password:${ip}`, 5, 15 * 60 * 1000)) {
    return rateLimitResponse('Too many password reset requests. Please try again later.');
  }

  try {
    const body = sanitizeMongoInput(await request.json());
    const validatedData = ForgotPasswordSchema.parse(body);

    await connectToDatabase();

    // Find user by email
    const user = await AuthUser.findOne({ email: validatedData.email }).lean();

    if (!user) {
      // Don't reveal if email exists for security
      return NextResponse.json(SUCCESS_RESPONSE, { status: 200 });
    }

    // Generate one-time password reset token (valid for 15 minutes).
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetPasswordToken = hashResetToken(resetToken);
    const resetPasswordExpires = new Date(Date.now() + 15 * 60 * 1000);

    const resetUrl = getPasswordResetUrl(resetToken, new URL(request.url).origin);

    await AuthUser.updateOne(
      { _id: user._id },
      { $set: { resetPasswordToken, resetPasswordExpires } }
    );

    const sent = await sendPasswordResetEmail({
      name: user.name || 'Student',
      email: user.email,
      resetUrl,
    });

    if (!sent) {
      console.error(`[ForgotPassword] Reset email failed for user ${user._id}`);
    }

    return NextResponse.json(SUCCESS_RESPONSE, { status: 200 });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: error.errors[0].message },
        { status: 400 }
      );
    }

    console.error('Forgot password error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
