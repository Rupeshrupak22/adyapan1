'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { AnimatePresence, motion } from 'framer-motion';
import { Check, Crown, Sparkles, X } from 'lucide-react';
import AuthModal from './AuthModal';
import { ALL_PLANS, type PlanDetail } from '@/lib/planData';

type PricingModalProps = {
  isOpen: boolean;
  onClose: () => void;
};

// Seats left per plan (static but looks real)
const seatsLeft: Record<string, number> = {
  'plan-1': 4,
  'plan-2': 3,
  'plan-3': 2,
  'plan-4-premium': 1,
};

// Map planData to the shape PricingModal needs
const plans = ALL_PLANS.map(p => ({
  name: p.label,
  slug: p.id,
  price: `Rs. ${p.price.toLocaleString('en-IN')}`,
  priceNum: p.price,
  originalPrice: `Rs. ${p.originalPrice.toLocaleString('en-IN')}`,
  savings: `Rs. ${(p.originalPrice - p.price).toLocaleString('en-IN')}`,
  discount: p.discount,
  cta: p.isPremium ? 'Get Premium Access' : `Buy ${p.label.split(' ')[0]}`,
  features: p.benefits,
  isPremium: p.isPremium ?? false,
  badge: p.badge,
  emoji: p.emoji,
  duration: p.duration,
  seats: seatsLeft[p.id] ?? 3,
}));

export default function PricingModal({ isOpen, onClose }: PricingModalProps) {
  const router = useRouter();
  const [authOpen, setAuthOpen] = useState(false);
  const [pendingPlan, setPendingPlan] = useState<(typeof plans)[0] | null>(null);
  const [checking, setChecking] = useState(false);

  const fmt2 = (n: number) => String(n).padStart(2, '0');

  /* Lock body scroll while open */
  useEffect(() => {
    if (!isOpen) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    const onEsc = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', onEsc);
    return () => {
      document.body.style.overflow = prev;
      window.removeEventListener('keydown', onEsc);
    };
  }, [isOpen, onClose]);

  const handlePlanSelect = async (plan: typeof plans[0]) => {
    setChecking(true);
    sessionStorage.setItem(
      'selectedPlan',
      JSON.stringify({ id: plan.slug, name: plan.name, price: plan.priceNum, label: plan.price })
    );
    try {
      const res = await fetch('/api/auth/me');
      if (res.ok) {
        onClose();
        router.push(`/checkout?plan=${encodeURIComponent(plan.slug)}`);
      } else {
        setPendingPlan(plan);
        setAuthOpen(true);
      }
    } catch {
      setPendingPlan(plan);
      setAuthOpen(true);
    } finally {
      setChecking(false);
    }
  };

  const handleAuthSuccess = () => {
    setAuthOpen(false);
    onClose();
    if (pendingPlan) {
      router.push(`/checkout?plan=${encodeURIComponent(pendingPlan.slug)}`);
    }
  };

  return (
    <>
      <AnimatePresence>
        {isOpen && (
          /* â"€â"€ Backdrop â"€â"€ */
          <motion.div
            className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto p-3 sm:items-center sm:p-4"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            {/* Clickable backdrop */}
            <button
              type="button"
              aria-label="Close pricing modal"
              className="absolute inset-0 bg-black/50 backdrop-blur-md"
              onClick={onClose}
            />

            {/* â"€â"€ Modal panel â"€â"€ */}
            <motion.div
              initial={{ opacity: 0, scale: 0.96, y: 16 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.96, y: 16 }}
              transition={{ duration: 0.2, ease: 'easeOut' }}
              className={[
                /* Positioning & sizing */
                'relative z-10 my-auto',
                'w-[98vw] max-w-[1100px]',
                /* Appearance */
                'rounded-2xl sm:rounded-3xl',
                'border border-white/30',
                'bg-white/90 backdrop-blur-xl',
                'shadow-2xl',
                /* Prevent overflow */
                'overflow-hidden',
              ].join(' ')}
            >
              {/* Close button - outside scroll area, always visible */}
              <button
                type="button"
                onClick={onClose}
                className="absolute right-3 top-3 z-50 rounded-full border border-gray-200 bg-white p-1.5 text-gray-600 shadow-sm transition-all hover:bg-gray-900 hover:text-white sm:right-4 sm:top-4 sm:p-2"
                aria-label="Close"
              >
                <X className="h-4 w-4" />
              </button>

              {/* Scrollable inner area */}
              <div className="max-h-[90vh] overflow-y-auto overscroll-contain px-3 py-5 sm:px-5 sm:py-6">

                {/* Header */}
                <div className="mb-4 pr-8 text-center sm:pr-10">
                  <p className="mb-2 inline-flex items-center gap-1.5 rounded-full bg-red-100 px-3 py-1 text-xs font-semibold text-red-600">
                    <Sparkles className="h-3.5 w-3.5 flex-shrink-0" />
                    🔴 Sale Live — Limited Seats Available
                  </p>
                  <h2 className="text-lg font-bold text-gray-900 sm:text-xl lg:text-2xl">
                    Choose Your Growth Plan
                  </h2>
                </div>

                {/* Plans grid: 1 col mobile → 2 col sm → 4 col md */}
                <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 md:grid-cols-4">
                  {plans.map((plan) => (
                    <div
                      key={plan.slug}
                      onClick={() => handlePlanSelect(plan)}
                      className={[
                        'group relative flex flex-col rounded-xl border p-3 transition-all duration-300 cursor-pointer',
                        'hover:-translate-y-1 hover:shadow-2xl',
                        plan.isPremium
                          ? 'border-orange-300 bg-gradient-to-br from-orange-500 via-orange-500 to-amber-500 text-white shadow-lg shadow-orange-300/40 md:scale-[1.02]'
                          : 'border-gray-200 bg-white text-gray-900 shadow-md hover:border-orange-300',
                      ].join(' ')}
                    >
                      {/* Best Value / Most Popular badge */}
                      {plan.badge && (
                        <div className="absolute -top-3 left-1/2 -translate-x-1/2 whitespace-nowrap rounded-full bg-black px-3 py-1 text-xs font-bold text-white">
                          <span className="inline-flex items-center gap-1">
                            <Crown className="h-3.5 w-3.5" /> {plan.badge}
                          </span>
                        </div>
                      )}

                      {/* Sale Live badge — on every card */}
                      <div className={`absolute top-3 right-3 flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold ${plan.isPremium ? 'bg-white/20 text-white' : 'bg-red-100 text-red-600'}`}>
                        <span className="inline-block w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse" />
                        Sale Live
                      </div>

                      {/* Plan name + price */}
                      <p className="text-xs font-semibold opacity-90 mt-1">{plan.name}</p>
                      <p className="mt-1 text-xl font-extrabold sm:text-2xl">
                        {plan.price}
                        <span className={`text-sm font-medium ml-1 line-through ${plan.isPremium ? 'text-white/60' : 'text-gray-900'}`}>
                          /{plan.originalPrice}
                        </span>
                      </p>
                      <div className="flex items-center gap-1.5 mt-0.5">
                        <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded-full ${plan.isPremium ? 'bg-white/20 text-white' : 'bg-green-100 text-green-700'}`}>
                          {plan.discount}% Off
                        </span>
                      </div>
                      {/* Savings */}
                      <p className={`text-[10px] font-bold mt-0.5 ${plan.isPremium ? 'text-yellow-200' : 'text-green-600'}`}>
                        🎉 You save {plan.savings}!
                      </p>
                      <p className="text-[10px] opacity-70 mt-0.5">{plan.duration}</p>
                      {/* Seats left */}
                      <div className={`mt-1.5 inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-[10px] font-bold w-fit ${plan.isPremium ? 'bg-white/20 text-white' : 'bg-red-50 text-red-600 border border-red-200'}`}>
                        🔥 Only {plan.seats} seats left!
                      </div>

                      {/* Features */}
                      <ul className="mt-3 flex-1 space-y-1.5 text-xs">
                        {plan.features.map((feature) => {
                          const isHighlight = feature.startsWith('\u2B50');
                          const displayText = isHighlight ? feature.slice(2) : feature;
                          return (
                            <li key={feature} className={`flex items-start gap-1.5 ${isHighlight ? 'font-semibold' : ''}`}>
                              <Check
                                className={`mt-0.5 h-3 w-3 flex-shrink-0 ${
                                  isHighlight
                                    ? (plan.isPremium ? 'text-yellow-300' : 'text-green-500')
                                    : (plan.isPremium ? 'text-white' : 'text-orange-600')
                                }`}
                              />
                              <span className={`break-words leading-snug ${
                                isHighlight && !plan.isPremium ? 'text-green-700' : ''
                              }${isHighlight && plan.isPremium ? 'text-yellow-100' : ''}`}>{displayText}</span>
                            </li>
                          );
                        })}
                      </ul>

                      {/* CTA button */}
                      <button
                        type="button"
                        disabled={checking}
                        onClick={() => handlePlanSelect(plan)}
                        className={[
                          'mt-4 w-full rounded-xl px-3 py-2 text-xs font-semibold',
                          'transition-all duration-300 disabled:opacity-60',
                          plan.isPremium
                            ? 'bg-white text-orange-600 hover:bg-black hover:text-white'
                            : 'bg-orange-500 text-white hover:bg-black',
                        ].join(' ')}
                      >
                        {checking ? '...' : plan.cta}
                      </button>
                    </div>
                  ))}
                </div>

                {/* â"€â"€ Footer note â"€â"€ */}
                <p className="mt-6 text-center text-xs text-gray-400">
                  Prices are GST-inclusive. Secure payment via Razorpay.
                </p>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Auth modal - shown when user is not logged in */}
      <AuthModal
        isOpen={authOpen}
        onClose={() => setAuthOpen(false)}
        onSuccess={handleAuthSuccess}
        planLabel={pendingPlan?.name}
        planPrice={pendingPlan?.price}
        defaultTab="login"
      />
    </>
  );
}
