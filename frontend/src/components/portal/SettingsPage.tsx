'use client';

import api from '@/lib/api';
import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { User, Mail, Phone, Building2, Shield, Save, CheckCircle } from 'lucide-react';
import { isValidName, NAME_FORMAT_MESSAGE, sanitizeNameInput } from '@/lib/name-format';
import { isIndianMobile, INDIAN_MOBILE_MESSAGE, sanitizeMobileInput } from '@/lib/phone';

export default function SettingsPage() {
  const [user, setUser]       = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving]   = useState(false);
  const [saved, setSaved]     = useState(false);
  const [error, setError]     = useState('');
  const [form, setForm]       = useState({ name: '', email: '', phone: '', companyName: '' });

  useEffect(() => {
    api.get('/api/auth/me')
      .then(res => {
        const u = res.data.user;
        setUser(u);
        setForm({
          name:        u.name || '',
          email:       u.email || '',
          phone:       u.phone || '',
          companyName: u.companyProfile?.companyName || u.companyName || '',
        });
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    if (!isValidName(form.name)) { setError(NAME_FORMAT_MESSAGE); return; }
    if (form.phone && !isIndianMobile(form.phone)) { setError(INDIAN_MOBILE_MESSAGE); return; }
    setSaving(true);
    try {
      await api.post('/api/auth/update-profile', { name: form.name, phone: form.phone });
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    } catch (err: any) {
      setError(err?.response?.data?.error || 'Could not save changes. Please try again.');
    }
    finally { setSaving(false); }
  };

  if (loading) {
    return (
      <div className="p-8">
        <div className="max-w-2xl mx-auto space-y-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-white rounded-2xl h-20 animate-pulse border border-gray-100" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 sm:p-6 lg:p-8">
      <div className="max-w-2xl mx-auto space-y-6">
        {/* Header */}
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
          <p className="text-gray-500 text-sm mt-1">Manage your portal account settings</p>
        </div>

        {/* Profile card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100"
        >
          <div className="flex items-center gap-4 mb-6">
            <div
              className="w-16 h-16 rounded-2xl flex items-center justify-center text-white text-2xl font-bold"
              style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
            >
              {user?.name?.[0]?.toUpperCase() || 'A'}
            </div>
            <div>
              <h2 className="font-bold text-gray-900 text-lg">{user?.name}</h2>
              <p className="text-gray-500 text-sm">{user?.email}</p>
              <span
                className="inline-flex items-center mt-1 px-2.5 py-0.5 rounded-full text-xs font-bold text-white"
                style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
              >
                {user?.role}
              </span>
            </div>
          </div>

          <form onSubmit={handleSave} className="space-y-4">
            {[
              { icon: User,      label: 'Full Name',     key: 'name',        type: 'text',  disabled: false },
              { icon: Mail,      label: 'Email Address', key: 'email',       type: 'email', disabled: true },
              { icon: Phone,     label: 'Phone Number',  key: 'phone',       type: 'tel',   disabled: false },
              { icon: Building2, label: 'Company Name',  key: 'companyName', type: 'text',  disabled: true },
            ].map(({ icon: Icon, label, key, type, disabled }) => (
              <div key={key}>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">{label}</label>
                <div className="relative">
                  <Icon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input
                    type={type}
                    value={(form as any)[key]}
                    onChange={e => {
                      const raw = e.target.value;
                      const val = key === 'name' ? sanitizeNameInput(raw)
                        : key === 'phone' ? sanitizeMobileInput(raw)
                        : raw;
                      setForm(p => ({ ...p, [key]: val }));
                      setError('');
                    }}
                    disabled={disabled}
                    {...(key === 'phone' ? { inputMode: 'numeric' as const, maxLength: 10 } : {})}
                    className={`w-full pl-10 pr-4 py-2.5 rounded-xl border text-sm transition-all
                      ${disabled
                        ? 'border-gray-100 bg-gray-50 text-gray-400 cursor-not-allowed'
                        : 'border-gray-200 bg-white text-gray-900 focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10'
                      }`}
                  />
                </div>
                {disabled && <p className="text-xs text-gray-400 mt-1">This field cannot be changed</p>}
              </div>
            ))}

            {error && (
              <p className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-4 py-2.5">{error}</p>
            )}

            <div className="flex items-center gap-3 pt-2">
              <motion.button
                type="submit"
                disabled={saving}
                whileHover={saving ? {} : { scale: 1.02 }}
                whileTap={saving ? {} : { scale: 0.98 }}
                className="flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold text-white transition-all disabled:opacity-60"
                style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
              >
                {saving ? (
                  <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /> Saving...</>
                ) : (
                  <><Save className="w-4 h-4" /> Save Changes</>
                )}
              </motion.button>
              {saved && (
                <motion.span
                  initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}
                  className="flex items-center gap-1.5 text-sm text-green-600 font-medium"
                >
                  <CheckCircle className="w-4 h-4" /> Saved!
                </motion.span>
              )}
            </div>
          </form>
        </motion.div>

        {/* Security info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-8 h-8 rounded-xl bg-blue-50 flex items-center justify-center">
              <Shield className="w-4 h-4 text-blue-600" />
            </div>
            <h3 className="font-semibold text-gray-900">Security</h3>
          </div>
          <div className="space-y-3">
            <div className="flex items-center justify-between py-2 border-b border-gray-50">
              <div>
                <p className="text-sm font-medium text-gray-900">Password</p>
                <p className="text-xs text-gray-400">Last changed: unknown</p>
              </div>
              <a href="/auth/forgot-password" className="text-xs text-[#ffa800] font-semibold hover:underline">
                Change Password
              </a>
            </div>
            <div className="flex items-center justify-between py-2">
              <div>
                <p className="text-sm font-medium text-gray-900">Two-Factor Authentication</p>
                <p className="text-xs text-gray-400">Not configured</p>
              </div>
              <span className="text-xs text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full">Coming soon</span>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
