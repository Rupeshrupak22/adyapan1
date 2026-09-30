'use client';

import api from '@/lib/api';
import { useState, useEffect, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { Eye, EyeOff, CheckCircle, AlertCircle, ArrowRight, Sparkles, Users, BookOpen, Shield, TrendingUp } from 'lucide-react';
import { isValidName, NAME_FORMAT_MESSAGE } from '@/lib/name-format';
import { isValidEmail, EMAIL_FORMAT_MESSAGE } from '@/lib/email-format';
import { isValidPassword, PASSWORD_POLICY_MESSAGE } from '@/lib/password';

/*  Floating orb background  */
function Orbs() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      <div
        className="absolute -top-32 -left-32 w-96 h-96 rounded-full bg-gradient-to-br from-[#ffa800]/30 to-orange-300/10 blur-3xl"
      />
      <div
        className="absolute -bottom-32 -right-32 w-[500px] h-[500px] rounded-full bg-gradient-to-tl from-orange-400/20 to-amber-200/10 blur-3xl"
      />
      <div
        className="absolute top-1/2 left-1/4 w-64 h-64 rounded-full bg-gradient-to-r from-yellow-300/15 to-orange-200/10 blur-3xl"
      />
    </div>
  );
}

/*  Floating stat card  */
function StatCard({ value, label, icon, delay }: { value: string; label: string; icon: string; delay: number }) {
  return (
    <div
      className="bg-white/80 backdrop-blur-sm rounded-2xl px-5 py-4 shadow-lg border border-white/60 flex items-center gap-3"
    >
      <span className="text-2xl">{icon}</span>
      <div>
        <div className="text-xl font-extrabold text-gray-900 leading-none">{value}</div>
        <div className="text-xs text-gray-500 mt-0.5">{label}</div>
      </div>
    </div>
  );
}

/*  Floating input field  */
function FloatInput({
  label, name, type = 'text', value, onChange, placeholder, required, autoComplete,
  rightEl,
}: {
  label: string; name: string; type?: string; value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string; required?: boolean; autoComplete?: string;
  rightEl?: React.ReactNode;
}) {
  const [focused, setFocused] = useState(false);
  const active = focused || value.length > 0;
  return (
    <div className="relative group">
      <input
        type={type}
        name={name}
        value={value}
        onChange={onChange}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        placeholder={active ? placeholder : ''}
        required={required}
        autoComplete={autoComplete}
        suppressHydrationWarning
        className={`w-full px-4 pt-6 pb-2 rounded-xl border-2 bg-white text-gray-900 text-sm outline-none transition-all duration-200 peer
          ${focused ? 'border-[#ffa800] shadow-[0_0_0_4px_rgba(255,168,0,0.12)]' : 'border-gray-200 hover:border-gray-300'}
          ${rightEl ? 'pr-12' : ''}`}
      />
      <label
        className={`absolute left-4 transition-all duration-200 pointer-events-none font-medium
          ${active ? 'top-2 text-[10px] text-[#ffa800] uppercase tracking-wider' : 'top-1/2 -translate-y-1/2 text-sm text-gray-400'}`}
      >
        {label}
      </label>
      {rightEl && (
        <div className="absolute right-3 top-1/2 -translate-y-1/2">{rightEl}</div>
      )}
    </div>
  );
}

/*  Email input with saved suggestions  */
function EmailInput({
  value, onChange,
}: {
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}) {
  const [focused, setFocused] = useState(false);
  const [showDropdown, setShowDropdown] = useState(false);
  const [savedEmails, setSavedEmails] = useState<string[]>([]);
  const active = focused || value.length > 0;

  // Load saved emails from localStorage on mount
  useEffect(() => {
    try {
      const stored = localStorage.getItem('adyapan_saved_emails');
      if (stored) setSavedEmails(JSON.parse(stored));
    } catch { /* ignore */ }
  }, []);

  // Filter suggestions based on current input
  const suggestions = value.length === 0
    ? savedEmails
    : savedEmails.filter(e => e.toLowerCase().includes(value.toLowerCase()) && e !== value);

  const handleSelect = (email: string) => {
    // Simulate input change event
    const nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value')?.set;
    const inputEl = document.querySelector('input[name="email"]') as HTMLInputElement;
    if (inputEl && nativeInputValueSetter) {
      nativeInputValueSetter.call(inputEl, email);
      inputEl.dispatchEvent(new Event('input', { bubbles: true }));
    }
    onChange({ target: { name: 'email', value: email } } as React.ChangeEvent<HTMLInputElement>);
    setShowDropdown(false);
  };

  return (
    <div className="relative group">
      <input
        type="email"
        name="email"
        value={value}
        onChange={onChange}
        onFocus={() => { setFocused(true); setShowDropdown(true); }}
        onBlur={() => { setFocused(false); setTimeout(() => setShowDropdown(false), 150); }}
        required
        autoComplete="off"
        suppressHydrationWarning
        className={`w-full px-4 pt-6 pb-2 rounded-xl border-2 bg-white text-gray-900 text-sm outline-none transition-all duration-200
          ${focused ? 'border-[#ffa800] shadow-[0_0_0_4px_rgba(255,168,0,0.12)]' : 'border-gray-200 hover:border-gray-300'}`}
      />
      <label
        className={`absolute left-4 transition-all duration-200 pointer-events-none font-medium
          ${active ? 'top-2 text-[10px] text-[#ffa800] uppercase tracking-wider' : 'top-1/2 -translate-y-1/2 text-sm text-gray-400'}`}
      >
        Email address
      </label>

      {/* Saved email dropdown */}
      {showDropdown && suggestions.length > 0 && (
        <div
          className="absolute z-50 top-full mt-1.5 w-full bg-white border border-gray-200 rounded-xl shadow-xl overflow-hidden"
        >
          <p className="text-[10px] text-gray-400 font-semibold uppercase tracking-wider px-3 pt-2.5 pb-1">
            Saved accounts
          </p>
          {suggestions.map((email) => (
            <button
              key={email}
              type="button"
              onMouseDown={() => handleSelect(email)}
              className="w-full flex items-center gap-3 px-3 py-2.5 hover:bg-orange-50 transition-colors text-left group"
            >
              {/* Avatar circle */}
              <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
                {email[0].toUpperCase()}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-gray-800 truncate group-hover:text-orange-700">{email}</p>
                <p className="text-[10px] text-gray-400">Adyapan account</p>
              </div>
              <svg className="w-4 h-4 text-gray-300 group-hover:text-orange-400 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

/*  Main auth content  */
function AuthPageContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const userTypeParam = searchParams?.get('type');
  const authModeParam = searchParams?.get('mode');

  const [isLogin, setIsLogin] = useState(authModeParam === 'login');
  const [checking, setChecking] = useState(true);
  const [userType, setUserType] = useState<'students' | 'organizations'>(
    userTypeParam === 'organization' ? 'organizations' : 'students'
  );
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    firstName: '', lastName: '', fullName: '', companyName: '',
    email: '', password: '', confirmPassword: '',
  });

  useEffect(() => {
    fetch('/api/auth/me')
      .then(r => r.ok ? r.json() : null)
      .then(data => {
        if (data?.user) {
          const role = data.user.role;
          if (role === 'ADMIN') router.replace('/admin');
          else if (role === 'COMPANY') router.replace('/organization');
          else router.replace('/');
        } else {
          setChecking(false);
        }
      })
      .catch(() => setChecking(false));
  }, [router]);

  useEffect(() => {
    if (userTypeParam === 'organization') router.replace('/admin/login');
    else if (userTypeParam === 'student') setUserType('students');
  }, [router, userTypeParam]);

  useEffect(() => {
    if (authModeParam === 'login') setIsLogin(true);
    else if (authModeParam === 'signup') setIsLogin(false);
  }, [authModeParam]);

  useEffect(() => {
    const googleError = searchParams?.get('error');
    if (googleError?.startsWith('google') || googleError === 'account_suspended') {
      setError('Google sign in failed. Please try again or use email and password.');
    }
    const emailVerification = searchParams?.get('emailVerification');
    if (emailVerification === 'verified') {
      setIsLogin(true);
      setSuccess('Email verified successfully. Please sign in.');
    } else if (emailVerification === 'expired') {
      setError('Email verification link has expired. Please create the account again or contact support.');
    } else if (emailVerification === 'invalid') {
      setError('Invalid email verification link. Please check the latest link in your inbox.');
    }
  }, [searchParams]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(p => ({ ...p, [name]: value }));
    setError(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null); setSuccess(null); setLoading(true);
    try {
      if (showAsLogin) {
        if (isOrg) {
          router.push('/admin/login');
          return;
        }

        await api.post('/api/auth/login', { email: formData.email, password: formData.password });
        // Save email to localStorage for future suggestions
        try {
          const stored = JSON.parse(localStorage.getItem('adyapan_saved_emails') || '[]') as string[];
          if (!stored.includes(formData.email)) {
            localStorage.setItem('adyapan_saved_emails', JSON.stringify([formData.email, ...stored].slice(0, 5)));
          }
        } catch { /* ignore */ }
        setSuccess('Login successful! Redirecting...');
        window.dispatchEvent(new Event('auth-change'));
        // Role-based redirect
        const loginRes = await api.get('/api/auth/me');
        const loginRole = loginRes.data?.user?.role;
        let redirectTo = searchParams?.get('redirect') || '/';
        if (loginRole === 'ADMIN') {
          redirectTo = '/admin';
        } else if (loginRole === 'COMPANY') {
          redirectTo = '/organization';
        } else if (loginRole === 'STUDENT') {
          redirectTo = searchParams?.get('redirect') || '/dashboard/student';
        }
        setTimeout(() => router.push(redirectTo), 900);
      } else {
        // Student signup only — validate client-side before hitting the API
        if (!isValidName(formData.firstName)) { setError(`First name: ${NAME_FORMAT_MESSAGE}`); setLoading(false); return; }
        if (!isValidName(formData.lastName))  { setError(`Last name: ${NAME_FORMAT_MESSAGE}`); setLoading(false); return; }
        if (!isValidEmail(formData.email)) { setError(EMAIL_FORMAT_MESSAGE); setLoading(false); return; }
        if (!isValidPassword(formData.password)) { setError(PASSWORD_POLICY_MESSAGE); setLoading(false); return; }
        if (formData.password !== formData.confirmPassword) { setError('Passwords do not match.'); setLoading(false); return; }

        const signupData = {
          role: 'student',
          email: formData.email,
          password: formData.password,
          confirmPassword: formData.confirmPassword,
          firstName: formData.firstName,
          lastName: formData.lastName,
        };
        await api.post('/api/auth/signup', signupData);
        setIsLogin(true);
        setSuccess('Account created. Please check your email and verify it before signing in.');
        setFormData(p => ({ ...p, password: '', confirmPassword: '' }));
      }
    } catch (err: any) {
      setError(err.response?.data?.error || 'Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const switchMode = () => {
    const nextIsLogin = !isLogin;
    setIsLogin(nextIsLogin); setError(null); setSuccess(null);
    setFormData({ firstName: '', lastName: '', fullName: '', companyName: '', email: '', password: '', confirmPassword: '' });
    const params = new URLSearchParams(searchParams?.toString());
    params.set('mode', nextIsLogin ? 'login' : 'signup');
    router.replace(`/auth?${params.toString()}`, { scroll: false });
  };

  const handleGoogleAuth = () => {
    if (isOrg) {
      router.push('/admin/login');
      return;
    }

    const p = new URLSearchParams({
      mode: showAsLogin ? 'login' : 'signup',
      role: 'student',
      redirect: searchParams?.get('redirect') || '/dashboard/student',
    });

    window.location.href = `/api/auth/google/start?${p.toString()}`;
  };

  if (checking) return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 to-amber-50">
      <div className="w-10 h-10 border-4 border-[#ffa800] border-t-transparent rounded-full animate-spin" />
    </div>
  );

  // Organization tab  login only, no public signup
  const isOrg        = userType === 'organizations';
  const showAsLogin  = isLogin || isOrg;   // org always shows login form

  const features = isOrg
    ? ['Manage student enrollments', 'Track payments & revenue', 'Handle project requests', 'View offline leads & analytics']
    : (isLogin
        ? ['Access your learning dashboard', 'Track your skill progress', 'View your credentials', 'Apply for opportunities']
        : ['Learn Industry-Relevant Skills', 'Earn While You Learn', 'Real Internship Experience', 'Placement Support']);

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-orange-50 via-amber-50 to-white relative overflow-hidden">
      <Orbs />

      {/*  LEFT PANEL  form  */}
      <div className="relative z-10 flex-1 flex items-center justify-center px-6 py-16 lg:px-12">
        <div
          className="w-full max-w-md"
        >
          {/* Logo */}
          <Link href="/" className="inline-flex items-center gap-2 mb-8 group">
            <Image src="/newadylogo.png" alt="Adyapan" width={120} height={40} className="h-9 w-auto group-hover:scale-105 transition-transform" />
          </Link>

          {/* Heading */}
          <div
            key={`${showAsLogin}-${userType}`}
            className="mb-7"
          >
            <h1 className="text-3xl font-extrabold text-gray-900 leading-tight">
              {showAsLogin ? (
                <span className="flex items-center gap-2">
                  Welcome back
                  <svg className="w-8 h-8 inline-block" viewBox="0 0 72 72" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M36 12c-2.2 0-4 1.8-4 4v16c0 2.2 1.8 4 4 4s4-1.8 4-4V16c0-2.2-1.8-4-4-4z" fill="#ffa800"/>
                    <path d="M24 20c-2.2 0-4 1.8-4 4v16c0 2.2 1.8 4 4 4s4-1.8 4-4V24c0-2.2-1.8-4-4-4z" fill="#ffa800"/>
                    <path d="M48 22c-2.2 0-4 1.8-4 4v14c0 2.2 1.8 4 4 4s4-1.8 4-4V26c0-2.2-1.8-4-4-4z" fill="#ffa800"/>
                    <path d="M56 32c-2.2 0-4 1.8-4 4v8c0 8.8-7.2 16-16 16S20 52.8 20 44v-8c0-2.2-1.8-4-4-4s-4 1.8-4 4v8c0 13.3 10.7 24 24 24s24-10.7 24-24v-8c0-2.2-1.8-4-4-4z" fill="#ff6b00"/>
                  </svg>
                </span>
              ) : 'Start your journey'}
            </h1>
            <p className="text-gray-500 text-sm mt-1.5">
              {showAsLogin
                ? (isOrg ? 'Sign in to access the Admin portal' : 'Sign in to continue learning')
                : 'Learn, earn & get placed with Adyapan'}
            </p>
          </div>

          {/* Alerts */}
          
            {error && (
              <div
                className="mb-4 p-3.5 rounded-xl bg-red-50 border border-red-200 flex items-start gap-2.5"
              >
                <AlertCircle className="w-4 h-4 text-red-500 flex-shrink-0 mt-0.5" />
                <p className="text-sm text-red-700">{error}</p>
              </div>
            )}
            {success && (
              <div
                className="mb-4 p-3.5 rounded-xl bg-green-50 border border-green-200 flex items-start gap-2.5"
              >
                <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
                <p className="text-sm text-green-700">{success}</p>
              </div>
            )}
          

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-3.5">
            
              {!showAsLogin && (
                <div
                  key={`names-${userType}`}
                  className="grid grid-cols-2 gap-3"
                >
                  <FloatInput
                    label="First Name"
                    name="firstName"
                    value={formData.firstName}
                    onChange={handleInputChange}
                    required
                  />
                  <FloatInput
                    label="Last Name"
                    name="lastName"
                    value={formData.lastName}
                    onChange={handleInputChange}
                    required
                  />
                </div>
              )}
            

            <EmailInput
              value={formData.email}
              onChange={handleInputChange}
            />

            <FloatInput
              label="Password"
              name="password"
              type={showPassword ? 'text' : 'password'}
              value={formData.password}
              onChange={handleInputChange}
              autoComplete={isLogin ? 'current-password' : 'new-password'}
              required
              rightEl={
                <button type="button" onClick={() => setShowPassword(v => !v)}
                  className="text-gray-400 hover:text-gray-600 transition-colors p-1">
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              }
            />

            
              {!showAsLogin && (
                <div
                >
                  <FloatInput
                    label="Confirm Password"
                    name="confirmPassword"
                    type={showConfirmPassword ? 'text' : 'password'}
                    value={formData.confirmPassword}
                    onChange={handleInputChange}
                    autoComplete="new-password"
                    required
                    rightEl={
                      <button type="button" onClick={() => setShowConfirmPassword(v => !v)}
                        className="text-gray-400 hover:text-gray-600 transition-colors p-1">
                        {showConfirmPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                    }
                  />
                </div>
              )}
            


            {showAsLogin && (
              <div className="text-right">
                <Link href="/auth/forgot-password"
                  className="text-xs text-[#ffa800] hover:text-orange-600 font-medium hover:underline transition-colors">
                  Forgot password?
                </Link>
              </div>
            )}

            {/* Submit */}
            <button
              type="submit"
              disabled={loading}
              className="w-full mt-2 py-3.5 rounded-xl font-bold text-white text-sm flex items-center justify-center gap-2 transition-all duration-300 disabled:opacity-60 disabled:cursor-not-allowed"
              style={{ background: 'linear-gradient(135deg, #ffa800 0%, #ff6b00 100%)' }}
            >
              {loading ? (
                <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /><span>Processing...</span></>
              ) : (
                <><span>{showAsLogin ? 'Sign In' : 'Create Account'}</span><ArrowRight className="w-4 h-4" /></>
              )}
            </button>

            {/* Divider */}
            <div className="flex items-center gap-3 my-1">
              <div className="flex-1 h-px bg-gray-200" />
              <span className="text-xs text-gray-400 font-medium">or continue with</span>
              <div className="flex-1 h-px bg-gray-200" />
            </div>

            {/* Google */}
            <button
              type="button"
              onClick={handleGoogleAuth}
              className="w-full py-3 rounded-xl border-2 border-gray-200 bg-white text-gray-700 text-sm font-semibold flex items-center justify-center gap-2.5 transition-all duration-200 hover:border-gray-300 hover:shadow-sm"
            >
              <svg className="w-4 h-4" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
              </svg>
              Continue with Google
            </button>
          </form>

          {/* Switch mode  students only, org is login-only */}
          {!isOrg && (
            <p className="text-center text-sm text-gray-500 mt-6">
              {isLogin ? "Don't have an account?" : 'Already have an account?'}{' '}
              <button onClick={switchMode}
                className="text-[#ffa800] font-bold hover:text-orange-600 transition-colors hover:underline">
                {isLogin ? 'Sign Up' : 'Sign In'}
              </button>
            </p>
          )}
        </div>
      </div>

      {/*  RIGHT PANEL  visual  */}
      <div className="hidden lg:flex flex-1 relative overflow-hidden items-center justify-center"
        style={{ background: 'linear-gradient(145deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)' }}>

        {/* Animated mesh */}
        <div className="absolute inset-0 overflow-hidden">
          {[...Array(6)].map((_, i) => (
            <div
              key={i}
              className="absolute rounded-full border border-white/5"
              style={{
                width: `${200 + i * 80}px`,
                height: `${200 + i * 80}px`,
                top: '50%', left: '50%',
                transform: 'translate(-50%, -50%)',
              }}
            />
          ))}
          <div
            className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 rounded-full bg-[#ffa800]/20 blur-3xl"
          />
        </div>

        <div className="relative z-10 px-12 max-w-md w-full">
          {/* Headline */}
          <div
            className="mb-10"
          >
            <div className="flex items-center gap-2 mb-4">
              <Sparkles className="w-5 h-5 text-[#ffa800]" />
              <span className="text-[#ffa800] text-sm font-semibold uppercase tracking-widest">
                {isOrg ? 'For Admin' : 'For Students'}
              </span>
            </div>
            <h2 className="text-4xl font-extrabold text-white leading-tight mb-4">
              {isOrg ? (
                <>Manage smarter,<br /><span className="text-[#ffa800]">grow faster</span></>
              ) : (
                <>Learn today,<br /><span className="text-[#ffa800]">lead tomorrow</span></>
              )}
            </h2>
            <p className="text-gray-400 text-sm leading-relaxed">
              {isOrg
                ? 'Secure admin portal for Adyapan. Manage students, enrollments, payments, and platform operations.'
                : 'Master industry skills, earn while you learn, and land your dream job with Adyapan\'s expert-led programs.'}
            </p>
          </div>

          {/* Feature list */}
          <div
            key={`features-${showAsLogin}-${userType}`}
            className="space-y-3 mb-10"
          >
            {features.map((f, i) => (
              <div
                key={f}
                className="flex items-center gap-3 group"
              >
                <div className="w-6 h-6 rounded-full bg-[#ffa800]/20 border border-[#ffa800]/40 flex items-center justify-center flex-shrink-0 group-hover:bg-[#ffa800]/30 transition-colors">
                  <CheckCircle className="w-3.5 h-3.5 text-[#ffa800]" />
                </div>
                <span className="text-gray-300 text-sm group-hover:text-white transition-colors">{f}</span>
              </div>
            ))}
          </div>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-3">
            {(isOrg
              ? [
                  { v: '10K+', l: 'Students',  Icon: Users },
                  { v: '67+',  l: 'Programs',  Icon: BookOpen },
                  { v: '100%', l: 'Secure',    Icon: Shield },
                ]
              : [
                  { v: '50+',  l: 'Courses',   Icon: BookOpen },
                  { v: '10K+', l: 'Students',  Icon: Users },
                  { v: '95%',  l: 'Placement', Icon: TrendingUp },
                ]
            ).map(({ v, l, Icon }, idx) => (
              <div
                key={v}
                className="bg-white/5 border border-white/10 rounded-xl p-3 text-center hover:bg-white/10 hover:border-[#ffa800]/30 transition-all cursor-default"
              >
                <div className="flex justify-center mb-1.5">
                  <Icon className="w-5 h-5 text-[#ffa800]" />
                </div>
                <div className="text-white font-extrabold text-lg leading-none">{v}</div>
                <div className="text-gray-500 text-[10px] mt-0.5">{l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

export default function AuthPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 to-amber-50">
        <div className="w-10 h-10 border-4 border-[#ffa800] border-t-transparent rounded-full animate-spin" />
      </div>
    }>
      <AuthPageContent />
    </Suspense>
  );
}
