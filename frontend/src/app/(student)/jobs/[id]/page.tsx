'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import Link from 'next/link';
import Image from 'next/image';
import {
  ArrowLeft, MapPin, Briefcase, Clock, Users, CheckCircle,
  Building2, ExternalLink, Send, Loader2, AlertCircle, X,
  Calendar, GraduationCap, TrendingUp,
} from 'lucide-react';
import { isValidName, NAME_FORMAT_MESSAGE, sanitizeNameInput } from '@/lib/name-format';
import { isValidEmail, EMAIL_FORMAT_MESSAGE } from '@/lib/email-format';
import { isIndianMobile, INDIAN_MOBILE_MESSAGE, sanitizeMobileInput } from '@/lib/phone';

interface Job {
  _id: string;
  jobTitle: string;
  category: string;
  description: string;
  responsibilities: string[];
  requiredSkills: string[];
  educationRequirement: string;
  experienceLevel: string;
  openings: number;
  employmentType: string;
  workMode: string;
  location: string;
  salaryOrStipend: string;
  deadline: string;
  companyName: string;
  companyEmail: string;
  companyLogoUrl: string;
  companyWebsite: string;
  companyCity: string;
  companyVerified: boolean;
  applicantsCount: number;
  createdAt: string;
}

const TYPE_COLORS: Record<string, string> = {
  'full-time':      'bg-blue-100 text-blue-700',
  'part-time':      'bg-purple-100 text-purple-700',
  'internship':     'bg-orange-100 text-orange-700',
  'freelance':      'bg-teal-100 text-teal-700',
  'project-based':  'bg-yellow-100 text-yellow-700',
  'work-from-home': 'bg-green-100 text-green-700',
};

function ApplyModal({ job, user, onClose, onSuccess }: {
  job: Job;
  user: { name: string; email: string; phone?: string } | null;
  onClose: () => void;
  onSuccess: () => void;
}) {
  const [form, setForm] = useState({
    studentName:  user?.name  || '',
    studentEmail: user?.email || '',
    studentPhone: user?.phone || '',
    cvUrl:        '',
    portfolioUrl: '',
    message:      '',
  });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError]           = useState('');

  const set = (k: string, v: string) => setForm(prev => ({ ...prev, [k]: v }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isValidName(form.studentName)) {
      setError(NAME_FORMAT_MESSAGE); return;
    }
    if (!isValidEmail(form.studentEmail)) {
      setError(EMAIL_FORMAT_MESSAGE); return;
    }
    if (form.studentPhone.trim() && !isIndianMobile(form.studentPhone)) {
      setError(INDIAN_MOBILE_MESSAGE); return;
    }
    setError(''); setSubmitting(true);
    try {
      const res = await fetch(`/api/jobs/${job._id}/apply`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (data.success) {
        onSuccess();
      } else {
        setError(data.error || 'Failed to submit application');
      }
    } catch {
      setError('Could not reach the server. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  const inputCls = 'w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-100 text-sm text-gray-800 bg-white transition-all';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
      <div
        className="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden"
      >
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-100">
          <div>
            <h2 className="font-bold text-gray-900 text-lg">Apply for Job</h2>
            <p className="text-sm text-gray-500 mt-0.5">{job.jobTitle} - {job.companyName}</p>
          </div>
          <button onClick={onClose} className="p-2 rounded-xl text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-all">
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1.5">Full Name <span className="text-red-500">*</span></label>
              <input type="text" value={form.studentName} onChange={e => set('studentName', sanitizeNameInput(e.target.value))} className={inputCls} placeholder="Your full name" autoComplete="name" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1.5">Email <span className="text-red-500">*</span></label>
              <input type="email" value={form.studentEmail} onChange={e => set('studentEmail', e.target.value)} className={inputCls} placeholder="you@example.com" />
            </div>
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Phone</label>
            <input type="tel" inputMode="numeric" maxLength={10} value={form.studentPhone} onChange={e => set('studentPhone', sanitizeMobileInput(e.target.value))} className={inputCls} placeholder="10-digit mobile number" />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">CV / Resume URL</label>
            <input type="url" value={form.cvUrl} onChange={e => set('cvUrl', e.target.value)} className={inputCls} placeholder="https://drive.google.com/your-cv" />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Portfolio / GitHub URL</label>
            <input type="url" value={form.portfolioUrl} onChange={e => set('portfolioUrl', e.target.value)} className={inputCls} placeholder="https://github.com/username" />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Cover Message (optional)</label>
            <textarea rows={3} value={form.message} onChange={e => set('message', e.target.value)} className={inputCls + ' resize-none'} placeholder="Why are you a great fit for this role?" />
          </div>

          {error && (
            <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-600">
              <AlertCircle className="w-4 h-4 flex-shrink-0" /> {error}
            </div>
          )}

          <div className="flex gap-3 pt-2">
            <button type="button" onClick={onClose} className="flex-1 py-3 rounded-xl font-semibold text-gray-500 border-2 border-gray-200 hover:border-gray-300 transition-all">
              Cancel
            </button>
            <button type="submit" disabled={submitting}
              className="flex-1 py-3 rounded-xl font-bold text-white flex items-center justify-center gap-2 disabled:opacity-70 transition-all shadow-md shadow-orange-200"
              style={{ background: 'linear-gradient(135deg,#f97316,#ea580c)' }}>
              {submitting ? <><Loader2 className="w-4 h-4 animate-spin" /> Submitting...</> : <><Send className="w-4 h-4" /> Submit Application</>}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function JobDetailPage() {
  const params = useParams();
  const router = useRouter();
  const id = params.id as string;

  const [job,     setJob]     = useState<Job | null>(null);
  const [loading, setLoading] = useState(true);
  const [error,   setError]   = useState('');
  const [user,    setUser]    = useState<{ name: string; email: string; phone?: string } | null>(null);
  const [showApply,  setShowApply]  = useState(false);
  const [applied,    setApplied]    = useState(false);

  useEffect(() => {
    // Fetch job
    fetch(`/api/jobs/${id}`)
      .then(r => r.json())
      .then(data => {
        if (data.success) setJob(data.job);
        else setError('Job not found');
      })
      .catch(() => setError('Failed to load job'))
      .finally(() => setLoading(false));

    // Fetch user (optional)
    fetch('/api/auth/me', { credentials: 'include' })
      .then(r => r.json())
      .then(data => {
        if (data?.user) setUser({ name: data.user.name, email: data.user.email, phone: data.user.phone });
      })
      .catch(() => {});
  }, [id]);

  const handleApplyClick = () => {
    if (!user) {
      router.push(`/auth?redirect=/jobs/${id}`);
      return;
    }
    setShowApply(true);
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-orange-50">
        <Loader2 className="w-8 h-8 text-orange-500 animate-spin" />
      </div>
    );
  }

  if (error || !job) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-orange-50 px-4">
        <div className="text-center">
          <AlertCircle className="w-12 h-12 text-red-400 mx-auto mb-3" />
          <h2 className="text-xl font-bold text-gray-900 mb-2">Job Not Found</h2>
          <Link href="/jobs" className="text-orange-500 font-semibold hover:underline">Back to Jobs</Link>
        </div>
      </div>
    );
  }

  const daysLeft = Math.ceil((new Date(job.deadline).getTime() - Date.now()) / 86400000);
  const expired  = daysLeft <= 0;

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 via-white to-amber-50">
      {/* Back */}
      <div className="max-w-4xl mx-auto px-4 pt-6 pb-2">
        <Link href="/jobs" className="inline-flex items-center gap-2 text-sm font-medium text-gray-500 hover:text-orange-500 transition-colors">
          <ArrowLeft className="w-4 h-4" /> All Jobs
        </Link>
      </div>

      <div className="max-w-4xl mx-auto px-4 pb-16">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">

          {/* Main content */}
          <div className="lg:col-span-2 space-y-5">
            {/* Job header card */}
            <div
              className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <div className="flex items-start gap-4">
                <div className="w-16 h-16 rounded-2xl bg-orange-50 border border-orange-100 flex items-center justify-center flex-shrink-0 overflow-hidden relative">
                  {job.companyLogoUrl
                    ? <Image src={job.companyLogoUrl} alt={job.companyName} fill className="object-cover" />
                    : <Building2 className="w-8 h-8 text-orange-400" />}
                </div>
                <div className="flex-1 min-w-0">
                  <h1 className="text-xl font-extrabold text-gray-900 mb-1">{job.jobTitle}</h1>
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="font-semibold text-gray-700">{job.companyName}</span>
                    {job.companyVerified && (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 bg-blue-50 text-blue-600 text-xs font-semibold rounded-full">
                        <CheckCircle className="w-3 h-3" /> Verified
                      </span>
                    )}
                  </div>
                  <div className="flex flex-wrap gap-3 mt-2 text-sm text-gray-500">
                    {job.location && <span className="flex items-center gap-1"><MapPin className="w-3.5 h-3.5" />{job.location}</span>}
                    <span className="flex items-center gap-1"><Briefcase className="w-3.5 h-3.5" />{job.experienceLevel}</span>
                    <span className="flex items-center gap-1"><Users className="w-3.5 h-3.5" />{job.openings} opening{job.openings !== 1 ? 's' : ''}</span>
                  </div>
                </div>
              </div>

              <div className="flex flex-wrap gap-2 mt-4">
                <span className={`px-3 py-1 rounded-full text-xs font-semibold ${TYPE_COLORS[job.employmentType] || 'bg-gray-100 text-gray-600'}`}>
                  {job.employmentType}
                </span>
                <span className="px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-600">
                  {job.workMode}
                </span>
                {job.salaryOrStipend && (
                  <span className="px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700">
                    {job.salaryOrStipend}
                  </span>
                )}
              </div>
            </div>

            {/* Description */}
            <div
              className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <h2 className="font-bold text-gray-900 mb-3">Job Description</h2>
              <p className="text-sm text-gray-700 leading-relaxed whitespace-pre-line">{job.description}</p>
            </div>

            {/* Responsibilities */}
            {job.responsibilities?.length > 0 && (
              <div
                className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
                <h2 className="font-bold text-gray-900 mb-3">Responsibilities</h2>
                <ul className="space-y-2">
                  {job.responsibilities.map((r, i) => (
                    <li key={i} className="flex items-start gap-2 text-sm text-gray-700">
                      <CheckCircle className="w-4 h-4 text-orange-400 flex-shrink-0 mt-0.5" />
                      {r}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            {/* Skills */}
            {job.requiredSkills?.length > 0 && (
              <div
                className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
                <h2 className="font-bold text-gray-900 mb-3">Required Skills</h2>
                <div className="flex flex-wrap gap-2">
                  {job.requiredSkills.map((s, i) => (
                    <span key={i} className="px-3 py-1.5 bg-orange-50 border border-orange-200 text-orange-700 text-sm font-semibold rounded-xl">
                      {s}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-4">
            {/* Apply card */}
            <div
              className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 sticky top-6">
              {applied ? (
                <div className="text-center py-4">
                  <CheckCircle className="w-12 h-12 text-green-500 mx-auto mb-3" />
                  <p className="font-bold text-gray-900 mb-1">Application Submitted!</p>
                  <p className="text-sm text-gray-500">The company will review your application.</p>
                </div>
              ) : (
                <>
                  {expired ? (
                    <div className="text-center py-2">
                      <p className="text-sm font-semibold text-red-500 mb-3">This job has expired</p>
                      <Link href="/jobs" className="text-sm text-orange-500 font-semibold hover:underline">Browse other jobs &rarr;</Link>
                    </div>
                  ) : (
                    <>
                      <div className="flex items-center justify-between mb-4">
                        <span className="text-sm text-gray-500">{job.applicantsCount || 0} applied</span>
                        <span className={`text-xs font-semibold ${daysLeft <= 3 ? 'text-orange-500' : 'text-gray-500'}`}>
                          {daysLeft}d left
                        </span>
                      </div>
                      <button
                        onClick={handleApplyClick}
                        className="w-full py-3.5 rounded-2xl font-bold text-white text-base flex items-center justify-center gap-2 shadow-lg shadow-orange-200 transition-all hover:shadow-xl"
                        style={{ background: 'linear-gradient(135deg,#f97316,#ea580c)' }}
                      >
                        <Send className="w-4 h-4" /> Apply Now
                      </button>
                      {!user && (
                        <p className="text-xs text-gray-400 text-center mt-2">Login required to apply</p>
                      )}
                    </>
                  )}
                </>
              )}
            </div>

            {/* Job details card */}
            <div
              className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
              <h3 className="font-bold text-gray-900 mb-4 text-sm">Job Details</h3>
              <div className="space-y-3 text-sm">
                {[
                  { icon: GraduationCap, label: 'Education', value: job.educationRequirement },
                  { icon: TrendingUp,    label: 'Experience', value: job.experienceLevel },
                  { icon: Users,         label: 'Openings',   value: String(job.openings) },
                  { icon: Calendar,      label: 'Deadline',   value: new Date(job.deadline).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }) },
                  { icon: Clock,         label: 'Posted',     value: new Date(job.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }) },
                ].filter(r => r.value).map(({ icon: Icon, label, value }) => (
                  <div key={label} className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg bg-orange-50 flex items-center justify-center flex-shrink-0">
                      <Icon className="w-4 h-4 text-orange-500" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-400">{label}</p>
                      <p className="font-semibold text-gray-800">{value}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Company card */}
            <div
              className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
              <h3 className="font-bold text-gray-900 mb-3 text-sm">About Company</h3>
              <div className="flex items-center gap-3 mb-3">
                <div className="w-10 h-10 rounded-xl bg-orange-50 border border-orange-100 flex items-center justify-center overflow-hidden relative">
                  {job.companyLogoUrl
                    ? <Image src={job.companyLogoUrl} alt={job.companyName} fill className="object-cover" />
                    : <Building2 className="w-5 h-5 text-orange-400" />}
                </div>
                <div>
                  <p className="font-semibold text-gray-800 text-sm">{job.companyName}</p>
                  {job.companyCity && <p className="text-xs text-gray-400">{job.companyCity}</p>}
                </div>
              </div>
              {job.companyWebsite && (
                <a href={job.companyWebsite} target="_blank" rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-orange-500 hover:text-orange-600 transition-colors">
                  <ExternalLink className="w-3.5 h-3.5" /> Visit Website
                </a>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Apply modal */}
      
        {showApply && (
          <ApplyModal
            job={job}
            user={user}
            onClose={() => setShowApply(false)}
            onSuccess={() => { setShowApply(false); setApplied(true); }}
          />
        )}
      
    </div>
  );
}
