'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { Eye, EyeOff, ShieldCheck, AlertCircle } from 'lucide-react';

const STRICT_EMAIL_REGEX = /^[A-Za-z0-9]+@[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)+$/;
const ACCESS_KEY_REGEX = /^[a-f0-9]{64}$/i;

export default function SuperAdminLogin() {
  const router = useRouter();
  const [email, setEmail]       = useState('');
  const [password, setPassword] = useState('');
  const [accessKey, setAccessKey] = useState('');
  const [showPw, setShowPw]     = useState(false);
  const [showKey, setShowKey]   = useState(false);
  const [loading, setLoading]   = useState(false);
  const [error, setError]       = useState('');

  // If already logged in as admin/superadmin, skip the login page.
  useEffect(() => {
    let active = true;
    fetch('/api/auth/me', { credentials: 'include' })
      .then((r) => (r.ok ? r.json() : null))
      .then((data) => {
        if (!active) return;
        const role = data?.user?.role;
        if (role === 'SUPERADMIN' || role === 'ADMIN') router.replace('/admin/dashboard');
      })
      .catch(() => {});
    return () => { active = false; };
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!STRICT_EMAIL_REGEX.test(email.trim())) {
      setError('Email may contain only letters and numbers, with one @ and domain dots.');
      return;
    }
    if (!ACCESS_KEY_REGEX.test(accessKey.trim())) {
      setError('Access key must be a 64-character hex value');
      return;
    }

    setLoading(true);
    
    try {
      const res  = await fetch('/api/admin/login', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ email: email.trim(), password, accessKey: accessKey.trim() }),
      });
      const data = await res.json();
      
      if (!res.ok) { 
        setError(data.error || 'Login failed'); 
        setLoading(false);
        return; 
      }
      if (data.user?.role !== 'SUPERADMIN' && data.user?.role !== 'ADMIN') {
        setError('Access denied - admin/superadmin only.');
        await fetch('/api/auth/logout', { method: 'POST' });
        setLoading(false);
        return;
      }
      
      router.push('/admin/dashboard');
      router.refresh();
    } catch (err) {
      setError('Network error. Please try again.');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 to-slate-800 px-4">
      <motion.div
        initial={{ opacity: 0, y: 24 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md bg-white rounded-2xl shadow-2xl p-8"
      >
        <div className="flex flex-col items-center mb-8">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-purple-600 to-indigo-600 flex items-center justify-center mb-4 shadow-lg">
            <ShieldCheck className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-2xl font-extrabold text-gray-900">Superadmin Login</h1>
          <p className="text-sm text-gray-500 mt-1">Restricted access - authorised personnel only</p>
        </div>

        {error && (
          <div className="mb-4 p-3 rounded-xl bg-red-50 border border-red-200 flex items-center gap-2">
            <AlertCircle className="w-4 h-4 text-red-500 flex-shrink-0" />
            <p className="text-sm text-red-700">{error}</p>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1.5">Email</label>
            <input
              type="email" value={email} onChange={e => setEmail(e.target.value)}
              required placeholder="superadmin@adyapan.com"
              className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-purple-500 focus:outline-none text-sm transition-colors"
            />
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1.5">Password</label>
            <div className="relative">
              <input
                type={showPw ? 'text' : 'password'} value={password}
                onChange={e => setPassword(e.target.value)}
                required placeholder="||||||||"
                className="w-full px-4 py-3 pr-11 rounded-xl border-2 border-gray-200 focus:border-purple-500 focus:outline-none text-sm transition-colors"
              />
              <button type="button" aria-label={showPw ? 'Hide password' : 'Show password'} onClick={() => setShowPw(v => !v)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                {showPw ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1.5">Access Key</label>
            <div className="relative">
              <input
                type={showKey ? 'text' : 'password'} value={accessKey}
                onChange={e => setAccessKey(e.target.value)}
                required placeholder="Enter admin access key"
                className="w-full px-4 py-3 pr-11 rounded-xl border-2 border-gray-200 focus:border-purple-500 focus:outline-none text-sm transition-colors"
              />
              <button type="button" aria-label={showKey ? 'Hide access key' : 'Show access key'} onClick={() => setShowKey(v => !v)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                {showKey ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>
          <button
            type="submit" disabled={loading}
            className="w-full py-3 rounded-xl bg-gradient-to-r from-purple-600 to-indigo-600 text-white font-bold text-sm disabled:opacity-60 hover:shadow-lg transition-all"
          >
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>
      </motion.div>
    </div>
  );
}
