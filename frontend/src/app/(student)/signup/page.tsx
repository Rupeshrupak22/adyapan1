'use client';

import api from '@/lib/api';
import { FormEvent, useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { Eye, EyeOff, ArrowRight, AlertCircle, CheckCircle, GraduationCap, Building2 } from 'lucide-react';
import { isValidName, NAME_FORMAT_MESSAGE } from '@/lib/name-format';
import { isValidEmail, EMAIL_FORMAT_MESSAGE } from '@/lib/email-format';
import { isValidPassword, PASSWORD_POLICY_MESSAGE } from '@/lib/password';

type Role = 'student' | 'organization';

/* -- Floating label input ---------------------------------------- */
function FloatInput({
  label, type = 'text', value, onChange, required, autoComplete, rightEl, half,
}: {
  label: string; type?: string; value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  required?: boolean; autoComplete?: string; rightEl?: React.ReactNode; half?: boolean;
}) {
  const [focused, setFocused] = useState(false);
  const active = focused || value.length > 0;
  return (
    <div className={`relative ${half ? '' : 'w-full'}`}>
      <input
        type={type}
        value={value}
        onChange={onChange}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        required={required}
        autoComplete={autoComplete}
        suppressHydrationWarning
        className={`w-full px-4 pt-6 pb-2 rounded-xl border-2 bg-white text-gray-900 text-sm outline-none transition-all duration-200
          ${focused ? 'border-[#ffa800] shadow-[0_0_0_4px_rgba(255,168,0,0.12)]' : 'border-gray-200 hover:border-gray-300'}
          ${rightEl ? 'pr-12' : ''}`}
      />
      <label className={`absolute left-4 transition-all duration-200 pointer-events-none font-medium
        ${active ? 'top-2 text-[10px] text-[#ffa800] uppercase tracking-wider' : 'top-1/2 -translate-y-1/2 text-sm text-gray-400'}`}>
        {label}
      </label>
      {rightEl && <div className="absolute right-3 top-1/2 -translate-y-1/2">{rightEl}</div>}
    </div>
  );
}

/* -- Role card --------------------------------------------------- */
function RoleCard({ role, selected, onClick }: { role: Role; selected: boolean; onClick: () => void }) {
  const isStudent = role === 'student';
  return (
    <button
      type="button"
      onClick={onClick}
      className={`flex-1 flex flex-col items-center gap-2 py-4 px-3 rounded-2xl border-2 transition-all duration-300 cursor-pointer ${
        selected
          ? 'border-[#ffa800] bg-[#ffa800]/8 shadow-md shadow-[#ffa800]/20'
          : 'border-gray-200 bg-white hover:border-gray-300 hover:bg-gray-50'
      }`}
    >
      <div className={`w-10 h-10 rounded-xl flex items-center justify-center transition-colors ${
        selected ? 'bg-[#ffa800] text-white' : 'bg-gray-100 text-gray-500'
      }`}>
        {isStudent ? <GraduationCap className="w-5 h-5" /> : <Building2 className="w-5 h-5" />}
      </div>
      <div className="text-center">
        <div className={`text-sm font-bold transition-colors ${selected ? 'text-[#ffa800]' : 'text-gray-700'}`}>
          {isStudent ? 'Student' : 'Organization'}
        </div>
        <div className="text-[11px] text-gray-400 mt-0.5">
          {isStudent ? 'Learn & get placed' : 'Hire top talent'}
        </div>
      </div>
      {selected && (
        <div
          className="w-5 h-5 rounded-full bg-[#ffa800] flex items-center justify-center">
          <CheckCircle className="w-3 h-3 text-white" />
        </div>
      )}
    </button>
  );
}

function SignupContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [checking, setChecking] = useState(true);
  const [role, setRole] = useState<Role>('student');
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [fullName, setFullName] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPw, setShowPw] = useState(false);
  const [showCPw, setShowCPw] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    fetch('/api/auth/me')
      .then(r => r.ok ? r.json() : null)
      .then(data => { if (data?.user) router.replace('/'); else setChecking(false); })
      .catch(() => setChecking(false));
  }, [router]);

  useEffect(() => {
    const googleError = searchParams.get('error');
    if (googleError?.startsWith('google') || googleError === 'account_suspended') {
      setError('Google sign up failed. Please try again or use email and password.');
    }
  }, [searchParams]);

  if (checking) return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 to-amber-50">
      <div className="w-10 h-10 border-4 border-[#ffa800] border-t-transparent rounded-full animate-spin" />
    </div>
  );

  const selectedProgram = searchParams.get('program');
  const selectedAmount = searchParams.get('amount');
  const normalizedAmount = selectedAmount ? Number(selectedAmount) : undefined;
  const formattedAmount = Number.isFinite(normalizedAmount)
    ? `Rs. ${normalizedAmount!.toLocaleString('en-IN')}` : null;

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(''); setSuccess('');

    // Client-side field checks first (fast feedback, no server round-trip)
    if (role === 'student') {
      if (!isValidName(firstName)) { setError(`First name: ${NAME_FORMAT_MESSAGE}`); return; }
      if (!isValidName(lastName))  { setError(`Last name: ${NAME_FORMAT_MESSAGE}`); return; }
    } else {
      if (!fullName.trim()) { setError('Please enter your full name.'); return; }
      if (!companyName.trim()) { setError('Please enter your company name.'); return; }
    }
    if (!isValidEmail(email)) { setError(EMAIL_FORMAT_MESSAGE); return; }
    if (!isValidPassword(password)) { setError(PASSWORD_POLICY_MESSAGE); return; }
    if (password !== confirmPassword) { setError('Passwords do not match.'); return; }

    setLoading(true);

    // Step 1: Best-effort deliverability check. If the service is reachable and
    // says the email is invalid, block; if it errors/times out, continue
    // (the control fails open by design, but we log so it isn't silent).
    try {
      const verifyRes = await fetch('/api/verify-email', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim() }),
      });
      const verifyData = await verifyRes.json();
      if (!verifyData.valid) {
        setError(verifyData.reason || 'This email address is not valid. Please enter a real email.');
        setLoading(false);
        return;
      }
    } catch (err) {
      console.warn('[Signup] Email verification service unreachable; continuing.', err);
    }

    // Step 2: Proceed with signup
    const payload = role === 'student'
      ? { role, firstName, lastName, email, password, confirmPassword,
          selectedProgram: selectedProgram || undefined,
          selectedAmount: Number.isFinite(normalizedAmount) ? normalizedAmount : undefined }
      : { role, fullName, companyName, email, password, confirmPassword,
          selectedProgram: selectedProgram || undefined,
          selectedAmount: Number.isFinite(normalizedAmount) ? normalizedAmount : undefined };

    try {
      const res = await api.post('/api/auth/signup', payload);
      setSuccess('Account created! Redirecting...');
      window.dispatchEvent(new Event('auth-change'));
      const userRole = res.data?.user?.role;
      setTimeout(() => router.push(userRole === 'COMPANY' ? '/dashboard/company' : '/dashboard/student'), 900);
    } catch (err: any) {
      setError(err?.response?.data?.error || 'Signup failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignUp = () => {
    const p = new URLSearchParams({
      mode: 'signup',
      role,
      redirect: role === 'organization' ? '/dashboard/company' : '/dashboard/student',
    });

    window.location.href = `/api/auth/google/start?${p.toString()}`;
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 via-amber-50 to-white px-4 py-16 relative overflow-hidden">
      {/* Background orbs */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div
          className="absolute -top-40 -right-40 w-96 h-96 rounded-full bg-[#ffa800]/20 blur-3xl" />
        <div
          className="absolute -bottom-40 -left-40 w-[500px] h-[500px] rounded-full bg-orange-300/15 blur-3xl" />
      </div>

      <div
        className="relative z-10 w-full max-w-md"
      >
        <div className="bg-white rounded-3xl shadow-2xl shadow-orange-100/50 border border-gray-100 overflow-hidden">
          {/* Top gradient bar */}
          <div className="h-1.5 w-full" style={{ background: 'linear-gradient(90deg, #ffa800, #ff6b00, #ffa800)' }} />

          <div className="px-8 py-8">
            {/* Logo + heading */}
            <div className="text-center mb-6">
              <Link href="/" className="inline-flex items-center justify-center gap-2 mb-4 group">
                <Image src="/newadylogo.png" alt="Adyapan" width={40} height={40} className="h-10 w-auto group-hover:scale-105 transition-transform" />
                <span className="text-2xl font-extrabold text-gray-900 tracking-tight">Adyapan</span>
              </Link>
              <h1 className="text-2xl font-extrabold text-gray-900">Create your account </h1>
              <p className="text-gray-500 text-sm mt-1">Join 10,000+ learners and companies</p>
            </div>

            {/* Program banner */}
            {(selectedProgram || selectedAmount) && (
              <div
                className="mb-5 p-3.5 rounded-xl bg-green-50 border border-green-200 flex items-start gap-2.5">
                <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
                <p className="text-sm text-green-700">
                  Enrolling in: <strong>{selectedProgram}</strong>
                  {formattedAmount && <> - <strong>{formattedAmount}</strong></>}
                </p>
              </div>
            )}

            {/* Role selector */}
            <div className="flex gap-3 mb-5">
              <RoleCard role="student" selected={role === 'student'} onClick={() => setRole('student')} />
              <RoleCard role="organization" selected={role === 'organization'} onClick={() => setRole('organization')} />
            </div>

            {/* Alerts */}
            
              {error && (
                <div
                  className="mb-4 p-3.5 rounded-xl bg-red-50 border border-red-200 flex items-start gap-2.5">
                  <AlertCircle className="w-4 h-4 text-red-500 flex-shrink-0 mt-0.5" />
                  <p className="text-sm text-red-700">{error}</p>
                </div>
              )}
              {success && (
                <div
                  className="mb-4 p-3.5 rounded-xl bg-green-50 border border-green-200 flex items-start gap-2.5">
                  <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
                  <p className="text-sm text-green-700">{success}</p>
                </div>
              )}
            

            <form onSubmit={handleSubmit} className="space-y-3.5">
              {/* Name fields - animate when role changes */}
              
                <div
                  key={role}
                  className="grid grid-cols-2 gap-3"
                >
                  {role === 'student' ? (
                    <>
                      <FloatInput label="First Name" value={firstName}
                        onChange={e => setFirstName(e.target.value)} required half />
                      <FloatInput label="Last Name" value={lastName}
                        onChange={e => setLastName(e.target.value)} required half />
                    </>
                  ) : (
                    <>
                      <FloatInput label="Full Name" value={fullName}
                        onChange={e => setFullName(e.target.value)} required half />
                      <FloatInput label="Company" value={companyName}
                        onChange={e => setCompanyName(e.target.value)} required half />
                    </>
                  )}
                </div>
              

              <FloatInput label="Email address" type="email" value={email}
                onChange={e => { setEmail(e.target.value); setError(''); }}
                autoComplete="email" required />

              <FloatInput label="Password" type={showPw ? 'text' : 'password'} value={password}
                onChange={e => { setPassword(e.target.value); setError(''); }}
                autoComplete="new-password" required
                rightEl={
                  <button type="button" onClick={() => setShowPw(v => !v)}
                    className="text-gray-400 hover:text-gray-600 transition-colors p-1">
                    {showPw ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                }
              />

              <FloatInput label="Confirm Password" type={showCPw ? 'text' : 'password'} value={confirmPassword}
                onChange={e => { setConfirmPassword(e.target.value); setError(''); }}
                autoComplete="new-password" required
                rightEl={
                  <button type="button" onClick={() => setShowCPw(v => !v)}
                    className="text-gray-400 hover:text-gray-600 transition-colors p-1">
                    {showCPw ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                }
              />

              {/* Terms */}
              <label className="flex items-start gap-2.5 cursor-pointer group">
                <input type="checkbox" required
                  className="mt-0.5 w-4 h-4 rounded border-gray-300 text-[#ffa800] focus:ring-[#ffa800] cursor-pointer" />
                <span className="text-xs text-gray-500 leading-relaxed">
                  I agree to the{' '}
                  <Link href="/terms" className="text-[#ffa800] font-semibold hover:underline">Terms of Service</Link>
                  {' '}and{' '}
                  <Link href="/privacy" className="text-[#ffa800] font-semibold hover:underline">Privacy Policy</Link>
                </span>
              </label>

              <button
                type="submit"
                disabled={loading}
                className="w-full py-3.5 rounded-xl font-bold text-white text-sm flex items-center justify-center gap-2 transition-all duration-300 disabled:opacity-60 disabled:cursor-not-allowed"
                style={{ background: 'linear-gradient(135deg, #ffa800 0%, #ff6b00 100%)' }}
              >
                {loading
                  ? <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /><span>Creating account...</span></>
                  : <><span>Create Account</span><ArrowRight className="w-4 h-4" /></>
                }
              </button>

              {/* Divider */}
              <div className="flex items-center gap-3">
                <div className="flex-1 h-px bg-gray-200" />
                <span className="text-xs text-gray-400 font-medium">or</span>
                <div className="flex-1 h-px bg-gray-200" />
              </div>

              {/* Google */}
              <button
                type="button"
                onClick={handleGoogleSignUp}
                className="w-full py-3 rounded-xl border-2 border-gray-200 bg-white text-gray-700 text-sm font-semibold flex items-center justify-center gap-2.5 transition-all duration-200 hover:border-gray-300 hover:shadow-sm"
              >
                <svg className="w-4 h-4" viewBox="0 0 24 24">
                  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
                </svg>
                Sign up with Google
              </button>
            </form>

            <p className="text-center text-sm text-gray-500 mt-5">
              Already have an account?{' '}
              <Link href="/login" className="text-[#ffa800] font-bold hover:text-orange-600 transition-colors hover:underline">
                Sign In
              </Link>
            </p>
          </div>
        </div>

        {/* Trust badges */}
        <div className="flex items-center justify-center gap-6 mt-5">
          {[' Secure signup', ' 10K+ students', ' Free to join'].map(t => (
            <span key={t} className="text-xs text-gray-400 font-medium">{t}</span>
          ))}
        </div>
      </div>
    </div>
  );
}

export default function SignupPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 to-amber-50">
        <div className="w-10 h-10 border-4 border-[#ffa800] border-t-transparent rounded-full animate-spin" />
      </div>
    }>
      <SignupContent />
    </Suspense>
  );
}
