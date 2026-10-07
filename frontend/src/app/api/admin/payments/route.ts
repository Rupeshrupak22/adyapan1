import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRouteByRole } from '@/lib/auth';
import Payment from '@/models/Payment';

export async function GET(request: NextRequest) {
  const auth = protectRouteByRole(request, ['ADMIN', 'COMPANY']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const { searchParams } = new URL(request.url);
    const search = searchParams.get('search') || '';
    const status = searchParams.get('status') || '';
    const course = searchParams.get('course') || '';
    const plan = searchParams.get('plan') || '';
    const dateFrom = searchParams.get('dateFrom') || '';
    const dateTo = searchParams.get('dateTo') || '';
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '20');
    const skip = (page - 1) * limit;

    const query: any = {};

    if (search) {
      query.$or = [
        { userName: { $regex: search, $options: 'i' } },
        { userEmail: { $regex: search, $options: 'i' } },
        { paymentId: { $regex: search, $options: 'i' } },
        { orderId: { $regex: search, $options: 'i' } },
      ];
    }
    if (status) query.status = status;
    if (course) query.courseName = { $regex: course, $options: 'i' };
    if (plan) query.planLabel = { $regex: plan, $options: 'i' };
    if (dateFrom || dateTo) {
      query.paidAt = {};
      if (dateFrom) query.paidAt.$gte = new Date(dateFrom);
      if (dateTo) query.paidAt.$lte = new Date(dateTo);
    }

    const revenueQuery = { ...query, status: 'success' };
    const [payments, total, revenueAgg] = await Promise.all([
      Payment.find(query).sort({ paidAt: -1 }).skip(skip).limit(limit).lean(),
      Payment.countDocuments(query),
      Payment.aggregate([
        { $match: revenueQuery },
        { $group: { _id: null, total: { $sum: '$totalAmount' } } },
      ]),
    ]);
    const totalRevenue = revenueAgg[0]?.total || 0;

    return NextResponse.json({
      success: true,
      totalRevenue,
      payments: payments.map(p => ({
        id: p._id.toString(),
        paymentId: p.paymentId,
        orderId: p.orderId,
        studentName: p.userName,
        studentEmail: p.userEmail,
        studentPhone: p.userPhone,
        courseName: p.courseName,
        courseSlug: p.courseSlug,
        planLabel: p.planLabel,
        baseAmount: p.baseAmount,
        gstAmount: p.gstAmount,
        totalAmount: p.totalAmount,
        currency: p.currency,
        status: p.status,
        paymentMethod: p.paymentMethod,
        isTestMode: p.isTestMode,
        paidAt: p.paidAt,
        userId: p.userId,
      })),
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (err: any) {
    console.error('[Admin Payments]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
