'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Save, Loader2, AlertCircle, CheckCircle, Building2, Shield, Clock } from 'lucide-react';
import { isIndianMobile, INDIAN_MOBILE_MESSAGE, sanitizeMobileInput } from '@/lib/phone';

const inputCls = 'w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-100 text-sm text-gray-800 bg-white transition-all';
const labelCls = 'block text-sm font-semibold text-gray-700 mb-1.5';

const INDUSTRIES = ['Technology','Finance','Healthcare','Education','E-commerce','Manufacturing','Media','Consulting','Real Estate','Other'];
const COMPANY_SIZES = ['1"10','11"50','51"200','201"500','500+'];

export default function CompanyProfilePage() {
  const [loading, setSaving]  = useState(false);
  const [fetching, setFetching] = useState(true);
  const [error,   setError]   = useState('');
  const [success, setSuccess] = useState('');
  const [verificationStatus, setVerificationStatus] = useState<'pending'|'verified'|'rejected'|null>(null);
  const [rejectionReason, setRejectionReason] = useState('');

  const [form, setForm] = useState({
    companyName: '', companyEmail: '', mobileNumber: '',
    website: '', logoUrl: '', industry: '', companySize: '',
    gstOrCin: '', address: '', city: '', state: '', country: 'India',
  });

  useEffect(() => {
    fetch('/api/company/profile', { credentials: 'include' })
      .then(r => r.json())
      .then(data => {
        if (data.profile) {
          const p = data.profile;
          setForm({
            companyName:  p.companyName  || '',
            companyEmail: p.companyEmail || '',
            mobileNumber: p.mobileNumber || '',
            website:      p.website      || '',
            logoUrl:      p.logoUrl      || '',
            industry:     p.industry     || '',
            companySize:  p.companySize  || '',
            gstOrCin:     p.gstOrCin     || '',
            address:      p.address      || '',
            city:         p.city         || '',
            state:        p.state        || '',
            country:      p.country      || 'India',
          });
          setVerificationStatus(p.verificationStatus || 'pending');
          setRejectionReason(p.rejectionReason || '');
        }
      })
      .catch(() => setError('Could not load your profile. Please refresh the page.'))
      .finally(() => setFetching(false));
  }, []);

  const set = (k: string, v: string) => setForm(prev => ({ ...prev, [k]: v }));

  const handleSave = async () => {
    setError(''); setSuccess('');
    if (form.mobileNumber && !isIndianMobile(form.mobileNumber)) {
      setError(INDIAN_MOBILE_MESSAGE);
      return;
    }
    setSaving(true);
    try {
      const res = await fetch('/api/company/profile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (data.success) {
        setSuccess(data.message || 'Profile saved successfully!');
        setVerificationStatus(data.profile?.verificationStatus || verificationStatus);
      } else {
        setError(data.error || 'Failed to save profile');
      }
    } catch {
      setError('Could not reach the server. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const VerificationBanner = () => {
    if (!verificationStatus) return null;
    const cfg = {
      verified: { icon: CheckCircle, cls: 'bg-green-50 border-green-200 text-green-700', msg: 'Your company is verified. You can post jobs.' },
      pending:  { icon: Clock,       cls: 'bg-yellow-50 border-yellow-200 text-yellow-700', msg: 'Your profile is under review. You can save drafts but cannot publish jobs until verified.' },
      rejected: { icon: AlertCircle, cls: 'bg-red-50 border-red-200 text-red-600', msg: `Your profile was rejected. ${rejectionReason ? `Reason: ${rejectionReason}` : ''} Please update and resubmit.` },
    }[verificationStatus];
    const Icon = cfg.icon;
    return (
      <div className={`flex items-start gap-3 p-4 rounded-xl border ${cfg.cls}`}>
        <Icon className="w-5 h-5 flex-shrink-0 mt-0.5" />
        <p className="text-sm font-medium">{cfg.msg}</p>
      </div>
    );
  };

  if (fetching) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-orange-500 animate-spin" />
      </div>
    );
  }

  return (
    <div className="p-4 sm:p-6 lg:p-8 max-w-3xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl bg-orange-100 flex items-center justify-center">
          <Building2 className="w-5 h-5 text-orange-500" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Company Profile</h1>
          <p className="text-gray-500 text-sm">Complete your profile to start posting jobs</p>
        </div>
      </div>

      {/* Verification status */}
      <VerificationBanner />

      {/* Alerts */}
      {error && (
        <div className="flex items-center gap-2 p-4 bg-red-50 border border-red-200 rounded-xl text-sm text-red-600">
          <AlertCircle className="w-4 h-4 flex-shrink-0" /> {error}
        </div>
      )}
      {success && (
        <motion.div initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }}
          className="flex items-center gap-2 p-4 bg-green-50 border border-green-200 rounded-xl text-sm text-green-700">
          <CheckCircle className="w-4 h-4 flex-shrink-0" /> {success}
        </motion.div>
      )}

      {/* Form */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-5">
        <p className="text-sm font-bold text-gray-700 pb-2 border-b border-gray-100">Basic Information</p>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className={labelCls}>Company Name <span className="text-red-500">*</span></label>
            <input type="text" value={form.companyName} onChange={e => set('companyName', e.target.value)} className={inputCls} placeholder="Acme Corp" />
          </div>
          <div>
            <label className={labelCls}>Company Email <span className="text-red-500">*</span></label>
            <input type="email" value={form.companyEmail} onChange={e => set('companyEmail', e.target.value)} className={inputCls} placeholder="hr@company.com" />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className={labelCls}>Mobile Number</label>
            <input type="tel" inputMode="numeric" maxLength={10} value={form.mobileNumber} onChange={e => set('mobileNumber', sanitizeMobileInput(e.target.value))} className={inputCls} placeholder="10-digit mobile number" />
          </div>
          <div>
            <label className={labelCls}>Website</label>
            <input type="url" value={form.website} onChange={e => set('website', e.target.value)} className={inputCls} placeholder="https://company.com" />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className={labelCls}>Industry</label>
            <select value={form.industry} onChange={e => set('industry', e.target.value)} className={inputCls}>
              <option value="">Select industry</option>
              {INDUSTRIES.map(i => <option key={i} value={i}>{i}</option>)}
            </select>
          </div>
          <div>
            <label className={labelCls}>Company Size</label>
            <select value={form.companySize} onChange={e => set('companySize', e.target.value)} className={inputCls}>
              <option value="">Select size</option>
              {COMPANY_SIZES.map(s => <option key={s} value={s}>{s} employees</option>)}
            </select>
          </div>
        </div>

        <div>
          <label className={labelCls}>GST / CIN (optional)</label>
          <input type="text" value={form.gstOrCin} onChange={e => set('gstOrCin', e.target.value)} className={inputCls} placeholder="GST or CIN number" />
        </div>

        <p className="text-sm font-bold text-gray-700 pb-2 border-b border-gray-100 pt-2">Address</p>

        <div>
          <label className={labelCls}>Street Address</label>
          <textarea rows={2} value={form.address} onChange={e => set('address', e.target.value)} className={inputCls + ' resize-none'} placeholder="Office address" />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div>
            <label className={labelCls}>City</label>
            <input type="text" value={form.city} onChange={e => set('city', e.target.value)} className={inputCls} placeholder="Mumbai" />
          </div>
          <div>
            <label className={labelCls}>State</label>
            <input type="text" value={form.state} onChange={e => set('state', e.target.value)} className={inputCls} placeholder="Maharashtra" />
          </div>
          <div>
            <label className={labelCls}>Country</label>
            <input type="text" value={form.country} onChange={e => set('country', e.target.value)} className={inputCls} />
          </div>
        </div>

        {/* Verification note */}
        <div className="flex items-start gap-2 p-3 bg-blue-50 border border-blue-100 rounded-xl text-xs text-blue-700">
          <Shield className="w-4 h-4 flex-shrink-0 mt-0.5" />
          <span>After saving, your profile will be reviewed by the Adyapan admin team. Verified companies can publish jobs immediately.</span>
        </div>
      </div>

      {/* Save */}
      <div className="flex justify-end">
        <button
          onClick={handleSave}
          disabled={loading}
          className="inline-flex items-center gap-2 px-6 py-3 rounded-xl font-bold text-white disabled:opacity-70 transition-all shadow-md shadow-orange-200"
          style={{ background: 'linear-gradient(135deg,#f97316,#ea580c)' }}
        >
          {loading ? <><Loader2 className="w-4 h-4 animate-spin" /> Saving...</> : <><Save className="w-4 h-4" /> Save Profile</>}
        </button>
      </div>
    </div>
  );
}
