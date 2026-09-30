'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Send, Phone, CheckCircle, Loader2, CalendarDays } from 'lucide-react';
import EmailField from '@/components/forms/EmailField';
import PhoneField from '@/components/forms/PhoneField';
import NameField from '@/components/forms/NameField';
import { isIndianMobile, INDIAN_MOBILE_MESSAGE } from '@/lib/phone';
import { isValidEmail, EMAIL_FORMAT_MESSAGE } from '@/lib/email-format';
import { isValidName, NAME_FORMAT_MESSAGE } from '@/lib/name-format';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  certificationName: string;
  companyName: string;
}

export default function CertificationEnrollModal({
  isOpen,
  onClose,
  certificationName,
  companyName,
}: Props) {
  const [form, setForm] = useState({
    name: '',
    phone: '',
    email: '',
    college: '',
    city: '',
    examDate: '',
  });
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [errorMsg, setErrorMsg] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
    setErrorMsg('');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isValidName(form.name)) {
      setErrorMsg(NAME_FORMAT_MESSAGE);
      setStatus('error');
      return;
    }
    if (!isValidEmail(form.email)) {
      setErrorMsg(EMAIL_FORMAT_MESSAGE);
      setStatus('error');
      return;
    }
    if (!isIndianMobile(form.phone)) {
      setErrorMsg(INDIAN_MOBILE_MESSAGE);
      setStatus('error');
      return;
    }
    setStatus('loading');
    setErrorMsg('');

    try {
      const res = await fetch('/api/certification-enrollments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...form,
          certificationName,
          companyName,
        }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
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
      setForm({ name: '', phone: '', email: '', college: '', city: '', examDate: '' });
    }, 300);
  };

  // Min date = today
  const today = new Date().toISOString().split('T')[0];

  const inp =
    'w-full px-4 py-3 rounded-xl border border-gray-200 bg-white text-sm text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all';

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
            initial={{ opacity: 0, scale: 0.92, y: 40 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.92, y: 40 }}
            transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }}
            className="fixed inset-0 z-[201] flex items-center justify-center p-4"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="bg-white rounded-3xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">

              {/* â"€â"€ Success screen â"€â"€ */}
              {status === 'success' ? (
                <div className="flex flex-col items-center justify-center py-16 px-8 text-center">
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 260, damping: 20 }}
                    className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mb-6"
                  >
                    <CheckCircle className="w-10 h-10 text-green-500" />
                  </motion.div>
                  <h2 className="text-2xl font-black text-gray-900 mb-2">Enrollment submitted successfully.</h2>
                  <p className="text-gray-500 text-sm mb-1">Our team will contact you soon.</p>
                  <p className="text-orange-600 font-bold text-base mb-1">{certificationName}</p>
                  {form.examDate && (
                    <p className="text-gray-500 text-sm mb-4 flex items-center justify-center gap-1.5">
                      <CalendarDays className="w-4 h-4 text-orange-400" />
                      Exam Date:{' '}
                      <span className="font-semibold text-gray-700">
                        {new Date(form.examDate).toLocaleDateString('en-IN', {
                          day: 'numeric', month: 'long', year: 'numeric',
                        })}
                      </span>
                    </p>
                  )}
                  <p className="text-gray-400 text-sm mb-8">
                    Enrollment submitted successfully. Our team will contact you soon.
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
                  {/* â"€â"€ Header â"€â"€ */}
                  <div className="flex items-start justify-between px-6 pt-6 pb-4 border-b border-gray-100">
                    <div>
                      <h2 className="text-xl font-black text-gray-900">
                        Start Your Certification Journey
                      </h2>
                      <p className="text-gray-500 text-sm mt-1">
                        Fill out the form below and we'll help you get started
                      </p>
                    </div>
                    <button
                      onClick={handleClose}
                      className="ml-4 flex-shrink-0 w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
                    >
                      <X className="w-4 h-4 text-gray-500" />
                    </button>
                  </div>

                  {/* â"€â"€ Cert badge â"€â"€ */}
                  {certificationName && (
                    <div className="px-6 py-3 bg-orange-50 border-b border-orange-100">
                      <p className="text-xs text-orange-600 font-semibold">
                         <span className="text-orange-800">{certificationName}</span>
                        {companyName && <> - <span className="text-orange-700">{companyName}</span></>}
                      </p>
                    </div>
                  )}

                  {/* â"€â"€ Form â"€â"€ */}
                  <form onSubmit={handleSubmit} className="px-6 py-6 space-y-4">

                    {/* Name + Phone */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <NameField
                        label="Name"
                        value={form.name}
                        onChange={(v) => setForm((prev) => ({ ...prev, name: v }))}
                        placeholder="Enter your full name"
                        inputClassName={inp}
                        labelClassName="block text-xs font-bold text-gray-600 mb-1.5"
                      />
                      <PhoneField
                        label="Phone"
                        name="phone"
                        value={form.phone}
                        onChange={(digits) => setForm((prev) => ({ ...prev, phone: digits }))}
                        placeholder="10-digit mobile number"
                        inputClassName={inp}
                        labelClassName="block text-xs font-bold text-gray-600 mb-1.5"
                      />
                    </div>

                    {/* Email + College */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <EmailField
                        label="Email"
                        email={form.email}
                        onEmailChange={(v) => setForm((prev) => ({ ...prev, email: v }))}
                        placeholder="Enter your email address"
                        inputClassName={inp}
                        labelClassName="block text-xs font-bold text-gray-600 mb-1.5"
                      />
                      <div>
                        <label className="block text-xs font-bold text-gray-600 mb-1.5">
                          College
                        </label>
                        <input
                          name="college" value={form.college} onChange={handleChange}
                          placeholder="Enter your college name" className={inp}
                        />
                      </div>
                    </div>

                    {/* City + Exam Date */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-bold text-gray-600 mb-1.5">
                          City
                        </label>
                        <input
                          name="city" value={form.city} onChange={handleChange}
                          placeholder="Enter your city" className={inp}
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-bold text-gray-600 mb-1.5 flex items-center gap-1.5">
                          <CalendarDays className="w-3.5 h-3.5 text-orange-500" />
                          Exam Date <span className="text-red-500">*</span>
                        </label>
                        <input
                          name="examDate"
                          type="date"
                          value={form.examDate}
                          onChange={handleChange}
                          min={today}
                          required
                          className={`${inp} cursor-pointer`}
                          style={{ colorScheme: 'light' }}
                        />
                      </div>
                    </div>

                    {/* Error */}
                    {status === 'error' && (
                      <p className="text-sm text-red-500 bg-red-50 border border-red-200 rounded-xl px-4 py-3">
                        {errorMsg}
                      </p>
                    )}

                    {/* Buttons */}
                    <div className="flex flex-col sm:flex-row gap-3 pt-2">
                      <motion.button
                        type="submit"
                        disabled={status === 'loading'}
                        whileHover={status !== 'loading' ? { scale: 1.02 } : {}}
                        whileTap={status !== 'loading' ? { scale: 0.98 } : {}}
                        className="flex-1 py-3.5 rounded-xl font-bold text-white text-sm flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed transition-all"
                        style={{ background: 'linear-gradient(135deg, #f97316, #ea580c)' }}
                      >
                        {status === 'loading' ? (
                          <><Loader2 className="w-4 h-4 animate-spin" /> Submitting...</>
                        ) : (
                          <><Send className="w-4 h-4" /> Enroll Now</>
                        )}
                      </motion.button>

                      <motion.a
                        href="tel:+918179124566"
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        className="flex-1 py-3.5 rounded-xl font-semibold text-gray-700 text-sm flex items-center justify-center gap-2 border-2 border-gray-200 hover:border-gray-300 bg-white transition-all"
                      >
                        <Phone className="w-4 h-4" /> Talk to Counselor
                      </motion.a>
                    </div>

                    {/* Disclaimer */}
                    <p className="text-xs text-gray-400 text-center pt-1">
                      By enrolling, you agree to our terms and conditions. We'll contact you within 24 hours to confirm your enrollment.
                    </p>
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
