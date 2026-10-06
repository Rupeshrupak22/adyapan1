'use client';

import api from '@/lib/api';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { motion, AnimatePresence } from 'framer-motion';
import { Eye, EyeOff, Shield, AlertCircle, Lock, Mail, ArrowRight, CheckCircle, Key, Loader2 } from 'lucide-react';

const STRICT_EMAIL_REGEX = /^[A-Za-z0-9]+@[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)+$/;
const ACCESS_KEY_REGEX = /^[a-f0-9]{64}$/i;

export default function AdminLoginPage() {
  const router = useRouter();

  const [email, setEmail]         = useState('');
  const [password, setPassword]   = useState('');
  const [accessKey, setAccessKey] = useState('');
  const [showPw, setShowPw]       = useState(false);
  const [showKey, setShowKey]     = useState(false);
  const [loading, setLoading]     = useState(false);
  const [checking, setChecking]   = useState(true);
  const [error, setError]         = useState<string | null>(null);
  const [success, setSuccess]     = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);

  /* Redirect if already logged in as ADMIN */
  useEffect(() => {
    api.get('/api/auth/me')
      .then(r => {
        const role = r.data?.user?.role;
        if (role === 'ADMIN' || role === 'SUPERADMIN') {
          router.replace('/admin/dashboard');
        } else {
          setChecking(false);
        }
      })
      .catch(() => setChecking(false));
  }, [router]);

  /* Email validation */
  const validateEmail = (email: string): boolean => {
    if (!email) {
      setEmailError('Email is required');
      return false;
    }
    if (!STRICT_EMAIL_REGEX.test(email.trim())) {
      setEmailError('Email may contain only letters and numbers, with one @ and domain dots.');
      return false;
    }
    setEmailError(null);
    return true;
  };

  /* Password validation */
  const validatePassword = (password: string): boolean => {
    if (!password) {
      setPasswordError('Password is required');
      return false;
    }
    if (password.length < 6) {
      setPasswordError('Password must be at least 6 characters');
      return false;
    }
    setPasswordError(null);
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    // Validate inputs
    const isEmailValid = validateEmail(email);
    const isPasswordValid = validatePassword(password);

    if (!isEmailValid || !isPasswordValid) {
      return;
    }

    setLoading(true);

    try {
      if (!ACCESS_KEY_REGEX.test(accessKey.trim())) {
        setError('Access key must be a 64-character hex value');
        setLoading(false);
        return;
      }

      const res = await api.post('/api/admin/login', { email: email.trim(), password, accessKey: accessKey.trim() });
      const role = res.data?.user?.role;

      if (role !== 'ADMIN' && role !== 'SUPERADMIN') {
        await api.post('/api/auth/logout');
        setError('You are not authorized to access the admin panel.');
        setLoading(false);
        return;
      }

      setSuccess('Login successful! Redirecting to admin dashboard...');

      setTimeout(() => {
        router.push('/admin/dashboard');
        router.refresh();
      }, 900);
    } catch (err) {
      const errorMsg = (err as any)?.response?.data?.error || 'Login failed. Please check your credentials.';
      setError(errorMsg);
      setLoading(false);
    }
  };

  if (checking) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 to-amber-50">
        <div className="flex flex-col items-center gap-3">
          <Loader2 className="w-10 h-10 text-[#ffa800] animate-spin" />
          <p className="text-sm text-gray-500 font-medium">Checking authentication...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 via-amber-50 to-white flex items-center justify-center px-4 py-8 relative overflow-hidden">

      {/* Background orbs */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <motion.div
          animate={{ x: [0, 50, 0], y: [0, -30, 0], scale: [1, 1.1, 1] }}
          transition={{ duration: 16, repeat: Infinity, ease: 'easeInOut' }}
          className="absolute -top-40 -left-40 w-[500px] h-[500px] rounded-full bg-[#ffa800]/15 blur-3xl"
        />
        <motion.div
          animate={{ x: [0, -40, 0], y: [0, 50, 0], scale: [1.1, 1, 1.1] }}
          transition={{ duration: 20, repeat: Infinity, ease: 'easeInOut', delay: 3 }}
          className="absolute -bottom-40 -right-40 w-[600px] h-[600px] rounded-full bg-orange-400/10 blur-3xl"
        />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 24 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
        className="relative z-10 w-full max-w-md"
      >
        {/* Logo */}
        <Link href="/" className="inline-flex items-center gap-2 mb-6 group">
          <Image src="/newadylogo.png" alt="Adyapan" width={120} height={40} className="h-9 w-auto group-hover:scale-105 transition-transform" />
        </Link>

        {/* Card */}
        <div className="bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
          {/* Top gradient bar */}
          <div className="h-1.5 w-full" style={{ background: 'linear-gradient(90deg, #ffa800, #ff6b00, #ffa800)' }} />

          <div className="p-6 sm:p-8">
            {/* Header */}
            <div className="flex items-center gap-3 mb-6">
              <div
                className="w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0"
                style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
              >
                <Shield className="w-5 h-5 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-extrabold text-gray-900 leading-tight">
                  Admin Login
                </h1>
                <p className="text-xs text-gray-500 mt-0.5">
                  Adyapan Admin Portal - Authorized access only
                </p>
              </div>
            </div>

            {/* Alerts */}
            <AnimatePresence mode="wait">
              {error && (
                <motion.div
                  key="error"
                  initial={{ opacity: 0, y: -8, height: 0 }}
                  animate={{ opacity: 1, y: 0, height: 'auto' }}
                  exit={{ opacity: 0, y: -8, height: 0 }}
                  className="mb-5 p-3.5 rounded-xl bg-red-50 border border-red-200 flex items-start gap-2.5"
                >
                  <AlertCircle className="w-4 h-4 text-red-500 flex-shrink-0 mt-0.5" />
                  <p className="text-sm text-red-700">{error}</p>
                </motion.div>
              )}
              {success && (
                <motion.div
                  key="success"
                  initial={{ opacity: 0, y: -8, height: 0 }}
                  animate={{ opacity: 1, y: 0, height: 'auto' }}
                  exit={{ opacity: 0, y: -8, height: 0 }}
                  className="mb-5 p-3.5 rounded-xl bg-green-50 border border-green-200 flex items-start gap-2.5"
                >
                  <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
                  <p className="text-sm text-green-700">{success}</p>
                </motion.div>
              )}
            </AnimatePresence>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-4">

              {/* Email */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-1.5">Email Address</label>
                <div className="relative">
                  <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none z-10" />
                  <input
                    type="email"
                    value={email}
                    onChange={e => { 
                      setEmail(e.target.value); 
                      setError(null); 
                      setEmailError(null);
                    }}
                    onBlur={() => validateEmail(email)}
                    required
                    autoComplete="email"
                    placeholder="admin@adyapan.com"
                    className={`w-full pl-10 pr-4 py-3 border-2 rounded-xl text-sm text-gray-900 focus:outline-none transition-all ${
                      emailError 
                        ? 'border-red-300 focus:border-red-500 focus:shadow-[0_0_0_4px_rgba(239,68,68,0.1)]'
                        : 'border-gray-200 focus:border-[#ffa800] focus:shadow-[0_0_0_4px_rgba(255,168,0,0.1)]'
                    }`}
                  />
                </div>
                {emailError && (
                  <motion.p
                    initial={{ opacity: 0, y: -4 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-xs text-red-600 mt-1.5 flex items-center gap-1"
                  >
                    <AlertCircle className="w-3 h-3" />
                    {emailError}
                  </motion.p>
                )}
              </div>

              {/* Password */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-1.5">Password</label>
                <div className="relative">
                  <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none z-10" />
                  <input
                    type={showPw ? 'text' : 'password'}
                    value={password}
                    onChange={e => { 
                      setPassword(e.target.value); 
                      setError(null); 
                      setPasswordError(null);
                    }}
                    onBlur={() => validatePassword(password)}
                    required
                    autoComplete="current-password"
                    placeholder="Enter your password"
                    className={`w-full pl-10 pr-12 py-3 border-2 rounded-xl text-sm text-gray-900 focus:outline-none transition-all ${
                      passwordError
                        ? 'border-red-300 focus:border-red-500 focus:shadow-[0_0_0_4px_rgba(239,68,68,0.1)]'
                        : 'border-gray-200 focus:border-[#ffa800] focus:shadow-[0_0_0_4px_rgba(255,168,0,0.1)]'
                    }`}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPw(v => !v)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors p-1 z-10"
                    aria-label={showPw ? 'Hide password' : 'Show password'}
                  >
                    {showPw ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
                {passwordError && (
                  <motion.p
                    initial={{ opacity: 0, y: -4 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-xs text-red-600 mt-1.5 flex items-center gap-1"
                  >
                    <AlertCircle className="w-3 h-3" />
                    {passwordError}
                  </motion.p>
                )}
              </div>

              {/* Access Key */}
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-1.5">
                  Access Key
                  <span className="ml-1.5 text-xs font-normal text-gray-400">(required for admin access)</span>
                </label>
                <div className="relative">
                  <Key className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none z-10" />
                  <input
                    type={showKey ? 'text' : 'password'}
                    value={accessKey}
                    onChange={e => { setAccessKey(e.target.value); setError(null); }}
                    required
                    autoComplete="off"
                    placeholder="Enter your admin access key"
                    className="w-full pl-10 pr-12 py-3 border-2 border-gray-200 rounded-xl text-sm text-gray-900 focus:border-[#ffa800] focus:outline-none focus:shadow-[0_0_0_4px_rgba(255,168,0,0.1)] transition-all"
                  />
                  <button
                    type="button"
                    onClick={() => setShowKey(v => !v)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors p-1 z-10"
                    aria-label={showKey ? 'Hide access key' : 'Show access key'}
                  >
                    {showKey ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              {/* Submit */}
              <motion.button
                type="submit"
                disabled={loading}
                whileHover={loading ? {} : { scale: 1.02, boxShadow: '0 8px 30px rgba(255,168,0,0.35)' }}
                whileTap={loading ? {} : { scale: 0.98 }}
                className="w-full py-3.5 rounded-xl font-bold text-white text-sm flex items-center justify-center gap-2 transition-all disabled:opacity-60 disabled:cursor-not-allowed mt-6"
                style={{ background: 'linear-gradient(135deg, #ffa800 0%, #ff6b00 100%)' }}
              >
                {loading ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    <span>Signing in...</span>
                  </>
                ) : (
                  <>
                    <span>Sign In to Admin</span>
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </motion.button>
            </form>
          </div>
        </div>

        {/* Security note */}
        <p className="text-center text-xs text-gray-400 mt-5">
           All login attempts are logged and monitored
        </p>

        {/* Back to site */}
        <div className="text-center mt-3">
          <Link href="/" className="text-xs text-gray-400 hover:text-[#ffa800] transition-colors">
            Back to Adyapan
          </Link>
        </div>
      </motion.div>
    </div>
  );
}
