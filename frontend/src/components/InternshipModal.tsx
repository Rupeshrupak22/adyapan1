'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, CheckCircle, Loader2 } from 'lucide-react';
import EmailField from '@/components/forms/EmailField';
import PhoneField from '@/components/forms/PhoneField';
import { isIndianMobile, INDIAN_MOBILE_MESSAGE } from '@/lib/phone';
import { isValidEmail, EMAIL_FORMAT_MESSAGE } from '@/lib/email-format';

interface Props {
  isOpen: boolean;
  onClose: () => void;
}

const COURSES = [
  'Artificial Intelligence', 'Machine Learning', 'Data Science', 'Web Development',
  'App Development', 'Python Full Stack', 'Java Full Stack', 'DevOps Engineering',
  'Cloud Computing', 'Cyber Security', 'UI/UX Design', 'Digital Marketing',
  'Finance', 'Business Analytics', 'Embedded Systems', 'Other',
];

export default function InternshipModal({ isOpen, onClose }: Props) {
  const [form, setForm] = useState({ name: '', courseName: '', email: '', mobile: '' });
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [errorMsg, setErrorMsg] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setForm(prev => ({ ...prev, [name]: value }));
    setErrorMsg('');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isValidEmail(form.email)) {
      setErrorMsg(EMAIL_FORMAT_MESSAGE);
      return;
    }
    if (!isIndianMobile(form.mobile)) {
      setErrorMsg(INDIAN_MOBILE_MESSAGE);
      return;
    }
    setStatus('loading');
    setErrorMsg('');
    try {
      const res = await fetch('/api/intern-leads', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (!res.ok) {
        setErrorMsg(data.error || 'Something went wrong. Please try again.');
        setStatus('error');
        return;
      }
      setStatus('success');
    } catch {
      setErrorMsg('Something went wrong. Please try again.');
      setStatus('error');
    }
  };

  const handleClose = () => {
    if (status === 'loading') return;
    onClose();
    setTimeout(() => {
      setStatus('idle');
      setErrorMsg('');
      setForm({ name: '', courseName: '', email: '', mobile: '' });
    }, 300);
  };

  const inp = 'w-full px-4 py-3 rounded-xl border border-gray-200 bg-white text-sm text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all';

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            key="backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={handleClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[200]"
          />

          {/* Modal */}
          <motion.div
            key="modal"
            initial={{ opacity: 0, scale: 0.93, y: 40 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.93, y: 40 }}
            transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }}
            className="fixed inset-0 z-[201] flex items-center justify-center p-4"
            onClick={e => e.stopPropagation()}
          >
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden">

              {/* Top bar */}
              <div className="h-1.5 w-full" style={{ background: 'linear-gradient(90deg, #f97316, #fbbf24, #f97316)' }} />

              {/* Success screen */}
              {status === 'success' ? (
                <div className="flex flex-col items-center justify-center py-14 px-8 text-center">
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 260, damping: 20 }}
                    className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mb-5"
                  >
                    <CheckCircle className="w-10 h-10 text-green-500" />
                  </motion.div>
                  <h3 className="text-2xl font-black text-gray-900 mb-2">Application Submitted!</h3>
                  <p className="text-gray-500 text-sm leading-relaxed mb-6">
                    Thank you for applying! Our team will connect with you as soon as possible.
                  </p>
                  <button
                    onClick={handleClose}
                    className="px-8 py-3 rounded-xl font-bold text-white text-sm"
                    style={{ background: 'linear-gradient(135deg, #f97316, #ea580c)' }}
                  >
                    Close
                  </button>
                </div>
              ) : (
                <>
                  {/* Header */}
                  <div className="flex items-center justify-between px-6 pt-5 pb-1">
                    <div>
                      <h2 className="text-xl font-black text-gray-900">Apply for Internship</h2>
                      <p className="text-xs text-gray-500 mt-0.5">Fill in your details and we'll get back to you</p>
                    </div>
                    <button
                      onClick={handleClose}
                      className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
                    >
                      <X className="w-4 h-4 text-gray-600" />
                    </button>
                  </div>

                  {/* Form */}
                  <form onSubmit={handleSubmit} className="px-6 pb-6 pt-4 space-y-4">
                    {/* Error */}
                    {errorMsg && (
                      <div className="rounded-xl bg-red-50 border border-red-200 px-3 py-2.5 text-sm text-red-600">
                        {errorMsg}
                      </div>
                    )}

                    {/* Name */}
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">
                        Full Name <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="text"
                        name="name"
                        required
                        value={form.name}
                        onChange={handleChange}
                        placeholder="Enter your full name"
                        className={inp}
                      />
                    </div>

                    {/* Course Name */}
                    <div>
                      <label className="block text-xs font-semibold text-gray-600 mb-1.5">
                        Course Name <span className="text-red-500">*</span>
                      </label>
                      <select
                        name="courseName"
                        required
                        value={form.courseName}
                        onChange={handleChange}
                        className={inp}
                      >
                        <option value="">Select a course</option>
                        {COURSES.map(c => (
                          <option key={c} value={c}>{c}</option>
                        ))}
                      </select>
                    </div>

                    {/* Email */}
                    <EmailField
                      label="Email Address"
                      email={form.email}
                      onEmailChange={(v) => setForm(prev => ({ ...prev, email: v }))}
                      placeholder="you@email.com"
                      inputClassName={inp}
                      labelClassName="block text-xs font-semibold text-gray-600 mb-1.5"
                    />

                    {/* Mobile */}
                    <PhoneField
                      label="Mobile Number"
                      name="mobile"
                      value={form.mobile}
                      onChange={(digits) => setForm(prev => ({ ...prev, mobile: digits }))}
                      placeholder="10-digit mobile number"
                      inputClassName={inp}
                      labelClassName="block text-xs font-semibold text-gray-600 mb-1.5"
                    />

                    {/* Submit */}
                    <motion.button
                      type="submit"
                      disabled={status === 'loading'}
                      whileHover={{ scale: status === 'loading' ? 1 : 1.02 }}
                      whileTap={{ scale: 0.98 }}
                      className="w-full py-3.5 rounded-xl font-bold text-white text-sm shadow-lg disabled:opacity-60 flex items-center justify-center gap-2 mt-2"
                      style={{ background: 'linear-gradient(135deg, #f97316, #ea580c)' }}
                    >
                      {status === 'loading' ? (
                        <><Loader2 className="w-4 h-4 animate-spin" /> Submitting...</>
                      ) : (
                        'Submit Application'
                      )}
                    </motion.button>
                  </form>
                </>
              )}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
