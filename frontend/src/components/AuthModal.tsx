'use client';

import api from '@/lib/api';
import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Image from 'next/image';
import { Eye, EyeOff, X, CheckCircle, AlertCircle } from 'lucide-react';
import { isValidName, NAME_FORMAT_MESSAGE, sanitizeNameInput } from '@/lib/name-format';
import { isValidEmail, EMAIL_FORMAT_MESSAGE } from '@/lib/email-format';
import { isIndianMobile, INDIAN_MOBILE_MESSAGE, sanitizeMobileInput } from '@/lib/phone';
import { isValidPassword, PASSWORD_POLICY_MESSAGE } from '@/lib/password';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  /** After successful auth, called with the user object */
  onSuccess: (user: { name: string; email: string; role: string }) => void;
  /** Pre-selected plan to show in the modal */
  planLabel?: string;
  planPrice?: string;
  /** Default tab */
  defaultTab?: 'login' | 'signup';
}

export default function AuthModal({ isOpen, onClose, onSuccess, planLabel, planPrice, defaultTab = 'login' }: Props) {
  const [tab, setTab]               = useState<'login' | 'signup'>(defaultTab);
  const [loading, setLoading]       = useState(false);
  const [error, setError]           = useState('');
  const [success, setSuccess]       = useState('');
  const [showPwd, setShowPwd]       = useState(false);
  const [showCPwd, setShowCPwd]     = useState(false);

  /* login fields */
  const [lEmail, setLEmail]   = useState('');
  const [lPwd,   setLPwd]     = useState('');

  /* signup fields */
  const [sFirst, setSFirst]   = useState('');
  const [sLast,  setSLast]    = useState('');
  const [sEmail, setSEmail]   = useState('');
  const [sPhone, setSPhone]   = useState('');
  const [sPwd,   setSPwd]     = useState('');
  const [sCPwd,  setSCPwd]    = useState('');
  const [agreed, setAgreed]   = useState(false);

  /* reset on open */
  useEffect(() => {
    if (isOpen) {
      setTab(defaultTab);
      setError(''); setSuccess('');
      setLEmail(''); setLPwd('');
      setSFirst(''); setSLast(''); setSEmail(''); setSPhone(''); setSPwd(''); setSCPwd('');
      setAgreed(false);
    }
  }, [isOpen, defaultTab]);

  /* lock body scroll */
  useEffect(() => {
    document.body.style.overflow = isOpen ? 'hidden' : '';
    return () => { document.body.style.overflow = ''; };
  }, [isOpen]);

  /*  Login  */
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(''); setLoading(true);
    try {
      const res = await api.post('/api/auth/login', { email: lEmail, password: lPwd });
      setSuccess('Welcome back! Redirecting to checkout...');
      window.dispatchEvent(new Event('auth-change'));
      setTimeout(() => { onSuccess(res.data.user); }, 800);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Login failed. Please try again.');
    } finally { setLoading(false); }
  };

  /*  Signup  */
  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    if (!isValidName(sFirst)) { setError(`First name: ${NAME_FORMAT_MESSAGE}`); return; }
    if (!isValidName(sLast))  { setError(`Last name: ${NAME_FORMAT_MESSAGE}`); return; }
    if (!isValidEmail(sEmail)) { setError(EMAIL_FORMAT_MESSAGE); return; }
    if (sPhone && !isIndianMobile(sPhone)) { setError(INDIAN_MOBILE_MESSAGE); return; }
    if (!isValidPassword(sPwd)) { setError(PASSWORD_POLICY_MESSAGE); return; }
    if (sPwd !== sCPwd) { setError('Passwords do not match.'); return; }
    if (!agreed) { setError('Please accept the Terms & Conditions.'); return; }
    setLoading(true);
    try {
      const res = await api.post('/api/auth/signup', {
        role: 'student',
        firstName: sFirst,
        lastName: sLast,
        email: sEmail,
        phone: sPhone,
        password: sPwd,
        confirmPassword: sCPwd,
      });
      setSuccess('Account created! Redirecting to checkout...');
      window.dispatchEvent(new Event('auth-change'));
      setTimeout(() => { onSuccess(res.data.user); }, 800);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Signup failed. Please try again.');
    } finally { setLoading(false); }
  };

  const inp = 'w-full rounded-xl border border-gray-200 px-4 py-3 text-sm text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all bg-white';

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center p-4 overflow-y-auto">
          {/* backdrop */}
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            onClick={onClose}
          />

          {/* card */}
          <motion.div
            initial={{ opacity: 0, scale: 0.93, y: 24 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.93, y: 24 }}
            transition={{ type: 'spring', stiffness: 280, damping: 26 }}
            className="relative w-full max-w-md rounded-3xl bg-white shadow-2xl overflow-y-auto my-auto max-h-[90vh]"
            onClick={e => e.stopPropagation()}
          >
            {/* saffron top bar */}
            <div className="h-1.5 w-full" style={{ background: 'linear-gradient(90deg, #f97316, #fbbf24, #f97316)' }} />

            {/* close */}
            <button onClick={onClose} className="absolute top-4 right-4 w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors z-10">
              <X className="w-4 h-4 text-gray-600" />
            </button>

            {/* plan reminder banner */}
            {planLabel && (
              <div className="mx-5 mt-5 rounded-2xl bg-orange-50 border border-orange-100 px-4 py-3 flex items-center gap-3">
                <CheckCircle className="h-5 w-5 shrink-0 text-orange-500" />
                <div>
                  <p className="text-xs text-orange-600 font-semibold uppercase tracking-wide">Selected Plan</p>
                  <p className="text-sm font-bold text-gray-800">{planLabel} {planPrice && <span className="text-orange-600">- {planPrice}</span>}</p>
                </div>
              </div>
            )}

            {/* header */}
            <div className="px-6 pt-5 pb-2 text-center">
              <Image src="/newadylogo.png" alt="Adyapan" width={80} height={32} className="h-8 w-auto mx-auto mb-3" />
              <h2 className="text-xl font-black text-gray-900">
                {tab === 'login' ? 'Welcome Back' : 'Create Your Account'}
              </h2>
              <p className="text-xs text-gray-500 mt-1">
                {tab === 'login' ? 'Sign in to continue your enrollment' : 'Join 20,000+ students on Adyapan'}
              </p>
            </div>

            {/* tabs */}
            <div className="mx-6 mt-4 flex rounded-xl bg-gray-100 p-1">
              {(['login', 'signup'] as const).map(t => (
                <button key={t} onClick={() => { setTab(t); setError(''); setSuccess(''); }}
                  className={`flex-1 py-2 rounded-lg text-sm font-semibold transition-all ${tab === t ? 'bg-white text-orange-600 shadow-sm' : 'text-gray-500 hover:text-gray-700'}`}>
                  {t === 'login' ? 'Login' : 'Sign Up'}
                </button>
              ))}
            </div>

            {/* alerts */}
            <div className="px-6 mt-3">
              <AnimatePresence>
                {error && (
                  <motion.div initial={{ opacity: 0, y: -6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
                    className="flex items-start gap-2 rounded-xl bg-red-50 border border-red-200 px-3 py-2.5 text-sm text-red-700">
                    <AlertCircle className="w-4 h-4 shrink-0 mt-0.5" />{error}
                  </motion.div>
                )}
                {success && (
                  <motion.div initial={{ opacity: 0, y: -6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
                    className="flex items-start gap-2 rounded-xl bg-green-50 border border-green-200 px-3 py-2.5 text-sm text-green-700">
                    <CheckCircle className="w-4 h-4 shrink-0 mt-0.5" />{success}
                  </motion.div>
                )}
              </AnimatePresence>
            </div>

            {/* forms */}
            <div className="px-6 pb-6 pt-3">
              <AnimatePresence mode="wait">
                {tab === 'login' ? (
                  <motion.form key="login" initial={{ opacity: 0, x: -12 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 12 }}
                    transition={{ duration: 0.18 }} onSubmit={handleLogin} className="space-y-3">
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">Email Address</label>
                      <input type="email" required value={lEmail} onChange={e => setLEmail(e.target.value)} placeholder="you@email.com" className={inp} />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">Password</label>
                      <div className="relative">
                        <input type={showPwd ? 'text' : 'password'} required value={lPwd} onChange={e => setLPwd(e.target.value)} placeholder="Your password" className={`${inp} pr-11`} />
                        <button type="button" onClick={() => setShowPwd(v => !v)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                          {showPwd ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                        </button>
                      </div>
                    </div>
                    <div className="flex justify-end">
                      <a href="/auth/forgot-password" className="text-xs text-orange-600 hover:underline">Forgot password?</a>
                    </div>
                    <motion.button type="submit" disabled={loading} whileHover={{ scale: loading ? 1 : 1.02 }} whileTap={{ scale: 0.98 }}
                      className="w-full py-3.5 rounded-xl font-bold text-white text-sm shadow-lg disabled:opacity-60 flex items-center justify-center gap-2"
                      style={{ background: 'linear-gradient(135deg, #f97316, #ea580c)' }}>
                      {loading ? <><svg className="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/></svg>Signing in...</> : 'Login & Continue to Checkout'}
                    </motion.button>
                    {/* Divider */}
                    <div className="flex items-center gap-3 my-1">
                      <div className="flex-1 h-px bg-gray-200" />
                      <span className="text-xs text-gray-400 font-medium">or continue with</span>
                      <div className="flex-1 h-px bg-gray-200" />
                    </div>
                    {/* Google login button */}
                    <button type="button" onClick={() => { window.location.href = `/api/auth/google/start?mode=login&role=student&redirect=${encodeURIComponent(window.location.pathname)}`; }}
                      className="w-full py-3 rounded-xl border-2 border-gray-200 bg-white text-gray-700 text-sm font-semibold flex items-center justify-center gap-2.5 transition-all duration-200 hover:border-gray-300 hover:bg-gray-50 hover:shadow-sm">
                      <svg className="w-4 h-4" viewBox="0 0 24 24">
                        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
                      </svg>
                      Continue with Google
                    </button>
                    <p className="text-center text-xs text-gray-500">
                      Don't have an account?{' '}
                      <button type="button" onClick={() => { setTab('signup'); setError(''); }} className="text-orange-600 font-semibold hover:underline">Sign Up Free</button>
                    </p>
                  </motion.form>
                ) : (
                  <motion.form key="signup" initial={{ opacity: 0, x: 12 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -12 }}
                    transition={{ duration: 0.18 }} onSubmit={handleSignup} className="space-y-3">
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-xs font-semibold text-gray-600 mb-1.5">First Name</label>
                        <input required value={sFirst} onChange={e => setSFirst(sanitizeNameInput(e.target.value))} placeholder="Rupesh" className={inp} autoComplete="given-name" />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-gray-600 mb-1.5">Last Name</label>
                        <input required value={sLast} onChange={e => setSLast(sanitizeNameInput(e.target.value))} placeholder="Kumar" className={inp} autoComplete="family-name" />
                      </div>
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">Email Address</label>
                      <input type="email" required value={sEmail} onChange={e => setSEmail(e.target.value)} placeholder="you@email.com" className={inp} />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">Phone Number</label>
                      <div className="flex gap-2">
                        <span className="rounded-xl border border-gray-200 px-3 py-3 text-sm bg-gray-50 text-gray-600 shrink-0">+91</span>
                        <input value={sPhone} onChange={e => setSPhone(sanitizeMobileInput(e.target.value))} placeholder="9876543210" className={inp} inputMode="numeric" maxLength={10} />
                      </div>
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">Password</label>
                      <div className="relative">
                        <input type={showPwd ? 'text' : 'password'} required value={sPwd} onChange={e => setSPwd(e.target.value)} placeholder="Min 8 chars, 1 letter & 1 number" className={`${inp} pr-11`} />
                        <button type="button" aria-label={showPwd ? 'Hide password' : 'Show password'} onClick={() => setShowPwd(v => !v)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                          {showPwd ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                        </button>
                      </div>
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">Confirm Password</label>
                      <div className="relative">
                        <input type={showCPwd ? 'text' : 'password'} required value={sCPwd} onChange={e => setSCPwd(e.target.value)} placeholder="Repeat password" className={`${inp} pr-11`} />
                        <button type="button" aria-label={showCPwd ? 'Hide password' : 'Show password'} onClick={() => setShowCPwd(v => !v)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                          {showCPwd ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                        </button>
                      </div>
                    </div>
                    <label className="flex items-start gap-2 text-xs text-gray-600 cursor-pointer">
                      <input type="checkbox" checked={agreed} onChange={e => setAgreed(e.target.checked)} className="accent-orange-500 mt-0.5 shrink-0" />
                      I agree to Adyapan's <a href="/terms" target="_blank" rel="noopener noreferrer" className="text-orange-600 hover:underline">Terms</a> & <a href="/privacy" target="_blank" rel="noopener noreferrer" className="text-orange-600 hover:underline">Privacy Policy</a>
                    </label>
                    <motion.button type="submit" disabled={loading} whileHover={{ scale: loading ? 1 : 1.02 }} whileTap={{ scale: 0.98 }}
                      className="w-full py-3.5 rounded-xl font-bold text-white text-sm shadow-lg disabled:opacity-60 flex items-center justify-center gap-2"
                      style={{ background: 'linear-gradient(135deg, #f97316, #ea580c)' }}>
                      {loading ? <><svg className="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/></svg>Creating account...</> : 'Create Account & Enroll'}
                    </motion.button>
                    {/* Divider */}
                    <div className="flex items-center gap-3 my-1">
                      <div className="flex-1 h-px bg-gray-200" />
                      <span className="text-xs text-gray-400 font-medium">or continue with</span>
                      <div className="flex-1 h-px bg-gray-200" />
                    </div>
                    {/* Google signup button */}
                    <button type="button" onClick={() => { window.location.href = `/api/auth/google/start?mode=signup&role=student&redirect=${encodeURIComponent(window.location.pathname)}`; }}
                      className="w-full py-3 rounded-xl border-2 border-gray-200 bg-white text-gray-700 text-sm font-semibold flex items-center justify-center gap-2.5 transition-all duration-200 hover:border-gray-300 hover:bg-gray-50 hover:shadow-sm">
                      <svg className="w-4 h-4" viewBox="0 0 24 24">
                        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
                      </svg>
                      Sign up with Google
                    </button>
                    <p className="text-center text-xs text-gray-500">
                      Already have an account?{' '}
                      <button type="button" onClick={() => { setTab('login'); setError(''); }} className="text-orange-600 font-semibold hover:underline">Login</button>
                    </p>
                  </motion.form>
                )}
              </AnimatePresence>
            </div>

            {/* footer trust */}
            <div className="px-6 pb-5 flex items-center justify-center gap-4 text-xs text-gray-400 border-t border-gray-100 pt-3">
              <span>SSL Secured</span>
              <span>|</span>
              <span>20,000+ Students</span>
              <span>|</span>
              <span>4.9 Rating</span>
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
