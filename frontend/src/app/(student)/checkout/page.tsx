'use client';

import { Suspense } from 'react';
import Link from 'next/link';
import { useSearchParams, useRouter } from 'next/navigation';
import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { getPlan } from '@/lib/planData';

/* â"€â"€ helpers â"€â"€ */
const fmt = (n: number) => 'Rs. ' + n.toLocaleString('en-IN', { minimumFractionDigits: 2 });

/* â"€â"€ plan data - loaded from centralized planData.ts â"€â"€ */

/* â"€â"€ coupons â"€â"€ */
const COUPONS: Record<string, { type: 'percent' | 'flat'; value: number; label: string }> = {
  'ADYAPAN5':  { type: 'percent', value: 5,    label: 'Extra 5% Off' },
  'STUDENT10': { type: 'flat',    value: 1000,  label: 'Rs. 1,000 Off' },
  'CAREER20':  { type: 'percent', value: 20,    label: '20% Off Premium' },
};

const STATES = ['Andhra Pradesh','Arunachal Pradesh','Assam','Bihar','Chhattisgarh','Goa','Gujarat','Haryana','Himachal Pradesh','Jharkhand','Karnataka','Kerala','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram','Nagaland','Odisha','Punjab','Rajasthan','Sikkim','Tamil Nadu','Telangana','Tripura','Uttar Pradesh','Uttarakhand','West Bengal','Delhi','Jammu & Kashmir','Ladakh'];
type Step = 'details' | 'success';

declare global { interface Window { Razorpay: any } }

function CheckoutPageInner() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const planKey = searchParams.get('plan') || 'plan-4-premium';
  const plan = getPlan(planKey);

  /* â"€â"€ Auth guard: redirect to auth if not logged in â"€â"€ */
  const [authChecked, setAuthChecked] = useState(false);
  const [loggedInUser, setLoggedInUser] = useState<{ name: string; email: string; phone?: string; state?: string } | null>(null);

  useEffect(() => {
    fetch('/api/auth/me')
      .then(r => r.ok ? r.json() : null)
      .then(data => {
        if (!data?.user) {
          // Save plan and redirect to auth
          sessionStorage.setItem('selectedPlan', JSON.stringify({ id: planKey }));
          router.replace(`/auth?redirect=/checkout?plan=${encodeURIComponent(planKey)}`);
        } else {
          setLoggedInUser({ name: data.user.name || '', email: data.user.email || '', phone: data.user.phone || '', state: '' });
          setAuthChecked(true);
        }
      })
      .catch(() => {
        sessionStorage.setItem('selectedPlan', JSON.stringify({ id: planKey }));
        router.replace(`/auth?redirect=/checkout?plan=${encodeURIComponent(planKey)}`);
      });
  }, [planKey, router]);

  /* â"€â"€ state â"€â"€ */
  const [step, setStep] = useState<Step>('details');
  const [paying, setPaying] = useState(false);
  const [error, setError] = useState('');
  const [summaryOpen, setSummaryOpen] = useState(false); // mobile accordion

  /* details form - autofill from logged-in user */
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  /* autofill when user data arrives */
  useEffect(() => {
    if (loggedInUser) {
      setName(loggedInUser.name || '');
      setEmail(loggedInUser.email || '');
      setPhone(loggedInUser.phone || '');
    }
  }, [loggedInUser]);
  const [phone, setPhone] = useState('');
  const [state, setState] = useState('');
  const [city, setCity] = useState('');
  const [college, setCollege] = useState('');
  const [referral, setReferral] = useState('');
  const [agreed, setAgreed] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  /* coupon */
  const [couponInput, setCouponInput] = useState('');
  const [couponApplied, setCouponApplied] = useState<null | { code: string; label: string; discount: number }>(null);
  const [couponError, setCouponError] = useState('');
  const [couponSuccess, setCouponSuccess] = useState('');

  /* card */
  /* pricing */
  const basePrice = plan.price;
  const couponDiscount = couponApplied ? couponApplied.discount : 0;
  const afterCoupon = Math.max(0, basePrice - couponDiscount);
  const grandTotal = afterCoupon;
  const savings = plan.originalPrice - afterCoupon;

  /* validate step 1 */
  const validate = () => {
    const e: Record<string, string> = {};
    if (!name.trim()) e.name = 'Full name is required';
    if (!email.trim() || !/\S+@\S+\.\S+/.test(email)) e.email = 'Valid email is required';
    if (!phone.trim() || phone.length < 10) e.phone = 'Valid 10-digit phone required';
    if (!state) e.state = 'Please select your state';
    if (!agreed) e.agreed = 'Please accept terms & conditions';
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleProceed = async (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) await handlePay();
  };

  /* â"€â"€ apply coupon â"€â"€ */
  const applyCoupon = (forcedCode?: string) => {
    setCouponError('');
    setCouponSuccess('');
    const code = (forcedCode || couponInput).trim().toUpperCase();
    if (!code) { setCouponError('Enter a coupon code'); return; }
    const c = COUPONS[code];
    if (!c) { setCouponError('Invalid coupon code'); return; }
    const disc = c.type === 'percent' ? Math.round(basePrice * c.value / 100) : c.value;
    setCouponApplied({ code, label: c.label, discount: disc });
    setCouponInput(code);
    setCouponSuccess(` "${code}" applied - ${c.label}`);
  };

  const removeCoupon = () => {
    setCouponApplied(null);
    setCouponInput('');
    setCouponSuccess('');
  };

  /* â"€â"€ Razorpay payment â"€â"€ */
  const loadRazorpay = () => new Promise<boolean>(res => {
    if (window.Razorpay) return res(true);
    const s = document.createElement('script');
    s.src = 'https://checkout.razorpay.com/v1/checkout.js';
    s.onload = () => res(true);
    s.onerror = () => res(false);
    document.body.appendChild(s);
  });

  const handlePay = async () => {
    setError('');
    setPaying(true);
    try {
      /* â"€â"€ 1. Create order via Next.js API route â"€â"€ */
      const res = await fetch('/api/payment/create-order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan: planKey, couponCode: couponApplied?.code || '' }),
      });
      if (!res.ok) {
        const d = await res.json();
        setError(d.error || 'Order creation failed.');
        setPaying(false);
        return;
      }
      const { orderId, amount, currency, keyId } = await res.json();

      /* â"€â"€ 2. LIVE MODE (card/netbanking/etc) - open Razorpay checkout â"€â"€ */
      const loaded = await loadRazorpay();
      if (!loaded) { setError('Payment gateway failed to load.'); setPaying(false); return; }

      const rzp = new window.Razorpay({
        key: keyId, amount, currency, order_id: orderId,
        name: 'ADYAPAN SCHOOL', description: plan.name,
        prefill: { name, email, contact: phone },
        theme: { color: '#f97316' },
        handler: async (response: any) => {
          const vRes = await fetch('/api/payment/verify', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              razorpay_order_id:   response.razorpay_order_id,
              razorpay_payment_id: response.razorpay_payment_id,
              razorpay_signature:  response.razorpay_signature,
              customerName:  name,
              customerEmail: email,
              customerPhone: phone,
              planName:      plan.name,
              planLabel:     plan.label,
              planKey,
              couponCode:     couponApplied?.code || '',
              grandTotal,
            }),
          });
          const vData = await vRes.json();
          if (vData.success) {
            setStep('success');
            setTimeout(() => router.push('/dashboard/student'), 2500);
          }
          else { setError('Payment verification failed.'); setPaying(false); }
        },
        modal: { ondismiss: () => setPaying(false) },
      });
      rzp.on('payment.failed', (r: any) => { setError(r.error.description); setPaying(false); });
      rzp.open();
    } catch (err: any) {
      setError(err?.message || 'Something went wrong.');
      setPaying(false);
    }
  };

  /* â"€â"€ input class helper â"€â"€ */
  const inp = (err?: string) => `w-full rounded-xl border ${err ? 'border-red-400 bg-red-50' : 'border-gray-200 bg-white'} px-4 py-3 text-sm text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all`;

  /* â"€â"€ ORDER SUMMARY â"€â"€ */
  const OrderSummary = ({ compact = false }: { compact?: boolean }) => (
    <div className={`rounded-2xl border border-orange-100 bg-gradient-to-b from-amber-50 to-orange-50 shadow-lg ${compact ? '' : 'sticky top-24'}`}>
      {/* header */}
      <div className="px-5 py-4 border-b border-orange-100 flex items-center justify-between">
        <div className="flex items-center gap-2 font-bold text-gray-800">
          <svg className="w-4 h-4 text-orange-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" /></svg>
          Order Summary
        </div>
      </div>

      <div className="p-5 space-y-4">
        {/* plan badge */}
        <div className="flex items-center gap-2 flex-wrap">
          <span className="inline-block rounded-full bg-orange-100 border border-orange-200 px-3 py-1 text-xs font-semibold text-orange-700">
            {plan.label}
          </span>
          {plan.badge && (
            <span
              className="inline-block rounded-full bg-black text-white px-3 py-1 text-xs font-bold"
            >
               {plan.badge}
            </span>
          )}
        </div>

        {/* plan name + meta - fully dynamic */}
        <div className="rounded-xl bg-white border border-orange-100 p-4 space-y-2.5">
          <p className="font-black text-gray-900 text-base">{plan.name}</p>
          <p className="text-xs text-gray-400 italic">{plan.tagline}</p>
          <div className="space-y-1.5 text-xs text-gray-600 pt-1">
            <div className="flex items-center gap-2">
              <span className="text-base"></span>
              <span><strong>{plan.startDate}</strong> " <strong>{plan.endDate}</strong></span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-base"></span>
              <span>{plan.classTime}</span>
            </div>
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-base"></span>
              <span>Valid till <strong>{plan.validTill}</strong></span>
              <span
                className="rounded-full bg-blue-100 text-blue-700 px-2 py-0.5 font-bold text-[10px]"
              >
                {plan.totalDays} Days
              </span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-base">Time</span>
              <span>Duration: <strong>{plan.duration}</strong></span>
            </div>
          </div>
        </div>

        {/* benefits */}
        <div className="space-y-1.5">
          <p className="text-xs font-bold text-gray-700 uppercase tracking-wide">What's Included</p>
          {plan.benefits.map(f => (
            <div
              key={f}
              className="flex items-center gap-2 text-xs text-gray-700"
            >
              <span className="w-4 h-4 rounded-full bg-green-100 flex items-center justify-center text-green-600 shrink-0 font-bold text-[10px]"></span>
              {f}
            </div>
          ))}
        </div>

        {/* pricing */}
        <div className="rounded-xl bg-white border border-orange-100 p-3 space-y-1.5">
          <div className="flex items-center justify-between text-sm">
            <span className="text-gray-600">Program Fees</span>
            <div className="flex items-center gap-2">
              <span className="rounded bg-green-100 text-green-700 text-xs font-bold px-1.5 py-0.5">{plan.discount}% Off</span>
              <span className="line-through text-gray-400 text-xs">{fmt(plan.originalPrice)}</span>
              <span className="font-bold text-gray-900">{fmt(basePrice)}</span>
            </div>
          </div>
          {couponApplied && (
            <div className="flex items-center justify-between text-sm text-green-700">
              <span>Coupon ({couponApplied.code})</span>
              <span className="font-semibold">âˆ' {fmt(couponApplied.discount)}</span>
            </div>
          )}
        </div>

        {/* coupon input */}
        <div>
          <p className="text-xs font-semibold text-gray-600 mb-2 flex items-center gap-1"> Promo Code</p>
          {couponApplied ? (
            <div className="flex items-center justify-between rounded-xl bg-green-50 border border-green-200 px-3 py-2">
              <span className="text-xs font-semibold text-green-700">{couponSuccess}</span>
              <button type="button" onClick={removeCoupon} className="text-xs text-red-500 hover:underline ml-2">Remove</button>
            </div>
          ) : (
            <>
              <div className="flex gap-2">
                <input value={couponInput} onChange={e => setCouponInput(e.target.value.toUpperCase())}
                  placeholder="Enter code here"
                  className="flex-1 rounded-xl border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-orange-400" />
                <button type="button" onClick={() => applyCoupon()}
                  className="rounded-xl bg-orange-500 text-white px-4 py-2 text-xs font-bold hover:bg-orange-600 transition-colors">
                  APPLY
                </button>
              </div>
              {couponError && <p className="text-xs text-red-500 mt-1">{couponError}</p>}
              <button
                type="button"
                onClick={() => applyCoupon('ADYAPAN5')}
                className="mt-2 w-full text-left rounded-xl border border-green-200 bg-green-50 px-3 py-2 text-xs text-green-700 flex items-center gap-2 hover:border-green-300 hover:bg-green-100 transition-colors"
              >
                <span className="w-4 h-4 rounded-full border-2 border-green-500 flex items-center justify-center text-green-600 shrink-0" />
                <div>
                  <p className="font-bold">APPLY COUPON</p>
                  <p>Grab an Extra 5% off - use <strong>ADYAPAN5</strong></p>
                  <p className="text-gray-400">Expires on: 30-May-2026</p>
                </div>
              </button>
            </>
          )}
        </div>

        {/* billing */}
        <div className="border-t border-orange-100 pt-3 space-y-2 text-sm">
          <p className="font-bold text-gray-700 text-xs uppercase tracking-wide">Billing Details</p>
          <div className="flex justify-between text-gray-600"><span>Total Price</span><span>{fmt(afterCoupon)}</span></div>
          <div className="flex justify-between text-gray-500 text-xs"><span>GST</span><span>Included</span></div>
          <div className="flex justify-between font-bold text-gray-900 text-base pt-2 border-t border-orange-100">
            <span>Grand Total</span><span className="text-orange-600">{fmt(grandTotal)}</span>
          </div>
        </div>

        {/* savings */}
        <div className="rounded-xl bg-green-50 border border-green-200 px-3 py-2 text-xs text-green-700 flex items-center gap-2">
           You are saving <strong>{fmt(savings)}</strong> on this purchase!
        </div>

        {/* trust */}
        <div className="flex items-center gap-3 text-xs text-gray-400 pt-1">
          <span> SSL Secured</span>
          <span>|</span>
          <span> PCI-DSS</span>
        </div>
      </div>
    </div>
  );

  /* â"€â"€ Loading / auth check screen â"€â"€ */
  if (!authChecked) {
    return (
      <main className="min-h-screen flex items-center justify-center" style={{ background: 'linear-gradient(135deg, #fff7ed, #fef3c7)' }}>
        <div className="text-center">
          <div className="w-12 h-12 rounded-full border-4 border-orange-200 border-t-orange-500 animate-spin mx-auto mb-4" />
          <p className="text-gray-500 text-sm">Verifying your session...</p>
        </div>
      </main>
    );
  }

  /* â"€â"€ SUCCESS SCREEN â"€â"€ */
  if (step === 'success') {
    return (
      <main className="min-h-screen bg-gradient-to-br from-orange-50 via-amber-50 to-white flex items-center justify-center px-4 py-16">
        <div
          className="max-w-md w-full text-center bg-white rounded-3xl shadow-2xl p-10 border border-orange-100">
          <div
            className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mx-auto mb-6">
            <svg className="w-10 h-10 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h1 className="text-2xl font-black text-gray-900 mb-2">Payment Successful! </h1>
          <p className="text-gray-500 mb-1">Welcome to <span className="text-orange-600 font-bold">ADYAPAN SCHOOL</span></p>
          <p className="text-sm text-gray-400 mb-2">A confirmation has been sent to <strong>{email}</strong></p>
          <p className="text-xs text-orange-500 font-semibold mb-6 animate-pulse">Redirecting to your dashboard...</p>
          <div className="rounded-2xl bg-orange-50 border border-orange-100 p-4 mb-6 text-left space-y-2 text-sm">
            <div className="flex justify-between"><span className="text-gray-500">Plan</span><span className="font-semibold text-gray-800">{plan.name}</span></div>
            <div className="flex justify-between"><span className="text-gray-500">Amount Paid</span><span className="font-bold text-orange-600">{fmt(grandTotal)}</span></div>
            <div className="flex justify-between"><span className="text-gray-500">Duration</span><span className="font-semibold text-gray-800">{plan.duration}</span></div>
          </div>
          <Link href="/dashboard/student"
            className="block w-full py-3 rounded-xl font-bold text-white text-sm"
            style={{ background: 'linear-gradient(135deg, #f97316, #ea580c)' }}>
            Go to Dashboard &rarr;
          </Link>
          <Link href="/programs" className="block mt-3 text-sm text-gray-400 hover:text-gray-600">Browse more courses</Link>
        </div>
      </main>
    );
  }

  /* â"€â"€ MAIN RENDER â"€â"€ */
  return (
    <main className="min-h-screen px-3 sm:px-4 py-6 sm:py-8" style={{ background: 'linear-gradient(135deg, #fff7ed 0%, #fef3c7 50%, #fff 100%)' }}>
      <div className="max-w-6xl mx-auto">

        {/* â"€â"€ Page header â"€â"€ */}
        <div className="mb-6 flex items-center justify-between">
          <Link href="/programs" className="flex items-center gap-1.5 text-sm text-gray-500 hover:text-orange-600 transition-colors">
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" /></svg>
            Back to Programs
          </Link>
          <div className="flex items-center gap-2 text-xs text-gray-500">
            <span className="text-green-600 font-semibold"> Secure Checkout</span>
          </div>
        </div>

        {/* â"€â"€ Logged-in banner â"€â"€ */}
        {loggedInUser && (
          <div
            className="mb-4 rounded-2xl bg-white border border-green-100 shadow-sm px-5 py-3 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center text-white text-xs font-bold shrink-0">
                {loggedInUser.name?.[0]?.toUpperCase() || '?'}
              </div>
              <div>
                <p className="text-xs text-gray-500">Logged in as</p>
                <p className="text-sm font-semibold text-gray-800">{loggedInUser.name} <span className="text-gray-400 font-normal">({loggedInUser.email})</span></p>
              </div>
            </div>
            <span className="text-xs text-green-600 font-semibold flex items-center gap-1"> Verified</span>
          </div>
        )}

        {/* â"€â"€ Urgency bar â"€â"€ */}
        <div
          className="mb-6 rounded-2xl overflow-hidden"
          style={{ background: 'linear-gradient(135deg, #f97316, #dc2626)' }}>
          <div className="px-4 sm:px-5 py-3 flex flex-wrap items-center justify-between gap-2 sm:gap-3">
            <div className="flex flex-wrap items-center gap-2 sm:gap-4 text-white text-xs font-semibold">
              <span> Only 12 Seats Left</span>
              <span className="hidden sm:block">|</span>
              <span className="hidden sm:inline">20,000+ Students Joined</span>
              <span className="hidden sm:block">|</span>
              <span className="hidden sm:inline"> 4.9 Rating</span>
            </div>
          </div>
        </div>

        {/* â"€â"€ Mobile summary accordion â"€â"€ */}
        <div className="lg:hidden mb-4">
          <button onClick={() => setSummaryOpen(v => !v)}
            className="w-full flex items-center justify-between rounded-2xl bg-white border border-orange-100 shadow-sm px-5 py-4">
            <div className="flex items-center gap-3">
              <span className="text-orange-500 font-bold text-sm">Order Summary</span>
              <span className="text-xs text-gray-500">{plan.label}</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="font-bold text-orange-600 text-sm">{fmt(grandTotal)}</span>
              <svg className={`w-4 h-4 text-gray-400 transition-transform ${summaryOpen ? 'rotate-180' : ''}`} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" /></svg>
            </div>
          </button>
          
            {summaryOpen && (
              <div className="overflow-hidden">
                <div className="pt-3"><OrderSummary compact /></div>
              </div>
            )}
          
        </div>

        {/* â"€â"€ Main grid â"€â"€ */}
        <div className="flex flex-col lg:flex-row gap-6 items-start">

          {/* â"€â"€ LEFT: Steps â"€â"€ */}
          <div className="flex-1 space-y-4 min-w-0">

            {/* STEP 1 */}
            <div className="rounded-2xl bg-white shadow-sm border border-gray-100 overflow-hidden">
              {/* header */}
              <div className={`px-6 py-4 flex items-center gap-3 ${step === 'details' ? 'bg-gradient-to-r from-orange-500 to-orange-600' : 'bg-white border-b border-gray-100'}`}>
                <span className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-black shrink-0 ${step === 'details' ? 'bg-white text-orange-600' : 'bg-green-500 text-white'}`}>
                  {step !== 'details' ? '' : '1'}
                </span>
                <h2 className={`font-bold text-base ${step === 'details' ? 'text-white' : 'text-gray-700'}`}>Basic Details</h2>
              </div>

              
                {step === 'details' && (
                  <form
                    onSubmit={handleProceed} className="p-6 space-y-5">

                    {/* name + phone */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-semibold text-gray-600 mb-1.5">Full Name <span className="text-red-500">*</span></label>
                        <input value={name} onChange={e => setName(e.target.value)} placeholder="Rupesh Kumar" className={inp(errors.name)} />
                        {errors.name && <p className="text-xs text-red-500 mt-1">{errors.name}</p>}
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-gray-600 mb-1.5">Phone Number <span className="text-red-500">*</span></label>
                        <div className="flex gap-2">
                          <select className="rounded-xl border border-gray-200 px-2 py-3 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-orange-400 shrink-0">
                            <option> +91</option>
                          </select>
                          <input value={phone} onChange={e => setPhone(e.target.value.replace(/\D/,'').slice(0,10))} placeholder="9876543210" className={inp(errors.phone)} />
                        </div>
                        {errors.phone && <p className="text-xs text-red-500 mt-1">{errors.phone}</p>}
                      </div>
                    </div>

                    {/* email */}
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5 flex items-center gap-1.5">
                        Email ID <span className="text-red-500">*</span>
                        {email && loggedInUser?.email === email && (
                          <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-green-100 text-green-700 border border-green-200">Saved</span>
                        )}
                      </label>
                      <input 
                        type="email" 
                        value={email} 
                        onChange={e => setEmail(e.target.value)} 
                        placeholder="you@email.com" 
                        className={inp(errors.email)}
                        readOnly={loggedInUser?.email === email}
                      />
                      {errors.email && <p className="text-xs text-red-500 mt-1">{errors.email}</p>}
                      {email && loggedInUser?.email === email && (
                        <p className="text-[11px] text-green-600 mt-1">Using your registered email</p>
                      )}
                    </div>

                    {/* state + city */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-semibold text-gray-600 mb-1.5">State <span className="text-red-500">*</span></label>
                        <select value={state} onChange={e => setState(e.target.value)} className={inp(errors.state)}>
                          <option value="">Select State</option>
                          {STATES.map(s => <option key={s}>{s}</option>)}
                        </select>
                        {errors.state && <p className="text-xs text-red-500 mt-1">{errors.state}</p>}
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-gray-600 mb-1.5">City</label>
                        <input value={city} onChange={e => setCity(e.target.value)} placeholder="Your city" className={inp()} />
                      </div>
                    </div>

                    {/* college */}
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">College / Institution <span className="text-gray-400">(Optional)</span></label>
                      <input value={college} onChange={e => setCollege(e.target.value)} placeholder="e.g. IIT Delhi, VIT Vellore" className={inp()} />
                    </div>

                    {/* referral */}
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">Referral Code <span className="text-gray-400">(Optional)</span></label>
                      <input value={referral} onChange={e => setReferral(e.target.value.toUpperCase())} placeholder="e.g. REF123" className={inp()} />
                    </div>

                    {/* T&C */}
                    <div>
                      <label className="flex items-start gap-2 text-sm text-gray-600 cursor-pointer select-none">
                        <input type="checkbox" checked={agreed} onChange={e => setAgreed(e.target.checked)} className="accent-orange-500 w-4 h-4 mt-0.5 shrink-0" />
                        <span>I agree to the <a href="#" className="text-orange-600 hover:underline">Terms of Use</a> and <a href="#" className="text-orange-600 hover:underline">Privacy Policy</a> of ADYAPAN SCHOOL. <span className="text-red-500">*</span></span>
                      </label>
                      {errors.agreed && <p className="text-xs text-red-500 mt-1">{errors.agreed}</p>}
                    </div>

                    {error && (
                      <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>
                    )}

                    <button type="submit" disabled={paying}
                      className="w-full sm:w-auto px-10 py-3.5 rounded-xl font-bold text-white text-sm shadow-lg disabled:opacity-60"
                      style={{ background: paying ? '#9ca3af' : 'linear-gradient(135deg, #f97316, #ea580c)' }}>
                      {paying ? 'Opening Razorpay...' : 'Proceed to Payment'}
                    </button>
                  </form>
                )}
              
            </div>

            {/* bottom links */}
            <div className="flex items-center gap-4 text-sm text-gray-400 pb-4">
              <Link href="/programs" className="hover:text-orange-600 transition-colors">Rs. Go back to program</Link>
              <span>|</span>
              <a href="mailto:support@adyapan.com" className="hover:text-orange-600 transition-colors">Contact Support</a>
            </div>
          </div>

          {/* â"€â"€ RIGHT: Order Summary (desktop) â"€â"€ */}
          <div className="hidden lg:block w-80 shrink-0">
            <OrderSummary />
          </div>
        </div>
      </div>
    </main>
  );
}

export default function CheckoutPage() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center"><div className="w-10 h-10 border-4 border-orange-400 border-t-transparent rounded-full animate-spin" /></div>}>
      <CheckoutPageInner />
    </Suspense>
  );
}
