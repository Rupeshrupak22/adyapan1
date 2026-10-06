'use client';

import api from '@/lib/api';
import { useEffect, useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import useDebounce from '@/hooks/useDebounce';
import {
  Search, Filter, Download, Eye, Mail, ChevronLeft, ChevronRight,
  X, User, Phone, BookOpen, CreditCard, Award, Calendar,
  CheckCircle, Clock, AlertCircle, TrendingUp, KeyRound, Save,
  ExternalLink, MessageCircle,
} from 'lucide-react';

interface Enrollment {
  courseSlug: string;
  courseName: string;
  planLabel: string;
  amountPaid: number;
  enrolledAt: string;
  progressPercent: number;
  certificateStatus: string;
}

interface Student {
  id: string;
  name: string;
  email: string;
  phone: string;
  createdAt: string;
  lastLoginAt: string | null;
  totalPaid: number;
  paymentStatus: string;
  enrollments: Enrollment[];
  totalEnrollments: number;
  totalCertificates: number;
  lmsAccess: LMSAccess | null;
}

interface LMSAccess {
  lmsProvider: 'moodle' | 'google_classroom' | 'teachable' | 'thinkific' | 'custom';
  lmsEmail: string;
  lmsPassword: string;
  lmsPortalLink: string;
  batchName: string;
  mentorName: string;
  counselorName: string;
  supportContact: string;
  whatsappNumber: string;
  certificationGuidance: string;
  emailSent?: boolean;
  whatsappSent?: boolean;
  assignedAt?: string;
}

function StatusBadge({ status }: { status: string }) {
  const map: Record<string, string> = {
    success: 'bg-green-100 text-green-700',
    pending: 'bg-amber-100 text-amber-700',
    failed: 'bg-red-100 text-red-700',
    none: 'bg-gray-100 text-gray-500',
    ready: 'bg-green-100 text-green-700',
    not_issued: 'bg-gray-100 text-gray-500',
  };
  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${map[status] || 'bg-gray-100 text-gray-500'}`}>
      {status === 'success' || status === 'ready' ? <CheckCircle className="w-3 h-3 mr-1" /> :
       status === 'pending' ? <Clock className="w-3 h-3 mr-1" /> :
       status === 'failed' ? <AlertCircle className="w-3 h-3 mr-1" /> : null}
      {status.replace('_', ' ')}
    </span>
  );
}

const emptyLmsForm: LMSAccess = {
  lmsProvider: 'custom',
  lmsEmail: '',
  lmsPassword: '',
  lmsPortalLink: '',
  batchName: '',
  mentorName: '',
  counselorName: '',
  supportContact: 'support@adyapan.com',
  whatsappNumber: '',
  certificationGuidance: '',
};

function StudentDetailModal({
  student,
  onClose,
  onSaveLms,
  savingLms,
}: {
  student: Student;
  onClose: () => void;
  onSaveLms: (student: Student, data: LMSAccess) => Promise<void>;
  savingLms: boolean;
}) {
  const [lmsForm, setLmsForm] = useState<LMSAccess>({
    ...emptyLmsForm,
    ...(student.lmsAccess || {}),
    lmsEmail: student.lmsAccess?.lmsEmail || student.email,
    whatsappNumber: student.lmsAccess?.whatsappNumber || student.phone || '',
  });

  const updateLms = (key: keyof LMSAccess, value: string) => {
    setLmsForm(prev => ({ ...prev, [key]: value }));
  };

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
        onClick={onClose}
      >
        <motion.div
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 20 }}
          onClick={e => e.stopPropagation()}
          className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto"
        >
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b border-gray-100">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg"
                style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
                {student.name[0]?.toUpperCase()}
              </div>
              <div>
                <h2 className="font-bold text-gray-900">{student.name}</h2>
                <p className="text-sm text-gray-500">{student.email}</p>
              </div>
            </div>
            <button onClick={onClose} className="text-gray-400 hover:text-gray-600 p-1">
              <X className="w-5 h-5" />
            </button>
          </div>

          <div className="p-6 space-y-6">
            {/* Info grid */}
            <div className="grid grid-cols-2 gap-4">
              {[
                { icon: Phone, label: 'Phone', value: student.phone || 'N/A' },
                { icon: Calendar, label: 'Joined', value: new Date(student.createdAt).toLocaleDateString('en-IN') },
                { icon: CreditCard, label: 'Total Paid', value: `Rs. ${student.totalPaid.toLocaleString('en-IN')}` },
                { icon: Award, label: 'Certificates', value: student.totalCertificates },
              ].map(({ icon: Icon, label, value }) => (
                <div key={label} className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
                  <Icon className="w-4 h-4 text-[#ffa800]" />
                  <div>
                    <p className="text-xs text-gray-400">{label}</p>
                    <p className="text-sm font-semibold text-gray-900">{value}</p>
                  </div>
                </div>
              ))}
            </div>

            {/* LMS Access Assignment */}
            <div className="border border-orange-100 rounded-2xl overflow-hidden">
              <div className="bg-orange-50 px-5 py-4 border-b border-orange-100 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                <div>
                  <h3 className="font-semibold text-gray-900 flex items-center gap-2">
                    <KeyRound className="w-4 h-4 text-[#ffa800]" />
                    LMS Access Assignment
                  </h3>
                  <p className="text-xs text-orange-900/60 mt-0.5">
                    Assign credentials for Moodle, Google Classroom, Teachable, Thinkific, or a custom LMS.
                  </p>
                </div>
                {student.lmsAccess?.assignedAt && (
                  <span className="text-xs font-semibold text-green-700 bg-green-100 px-2.5 py-1 rounded-full">
                    Assigned {new Date(student.lmsAccess.assignedAt).toLocaleDateString('en-IN')}
                  </span>
                )}
              </div>

              <div className="p-5 grid grid-cols-1 sm:grid-cols-2 gap-4">
                <label className="text-xs font-semibold text-gray-500">
                  LMS Provider
                  <select
                    value={lmsForm.lmsProvider}
                    onChange={e => updateLms('lmsProvider', e.target.value)}
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  >
                    <option value="custom">Custom LMS</option>
                    <option value="moodle">Moodle</option>
                    <option value="google_classroom">Google Classroom</option>
                    <option value="teachable">Teachable</option>
                    <option value="thinkific">Thinkific</option>
                  </select>
                </label>
                <label className="text-xs font-semibold text-gray-500">
                  Portal Link
                  <input
                    value={lmsForm.lmsPortalLink}
                    onChange={e => updateLms('lmsPortalLink', e.target.value)}
                    placeholder="https://lms.example.com"
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
                <label className="text-xs font-semibold text-gray-500">
                  LMS Email
                  <input
                    value={lmsForm.lmsEmail}
                    onChange={e => updateLms('lmsEmail', e.target.value)}
                    placeholder="student@lms.com"
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
                <label className="text-xs font-semibold text-gray-500">
                  LMS Password
                  <input
                    value={lmsForm.lmsPassword}
                    onChange={e => updateLms('lmsPassword', e.target.value)}
                    placeholder="Temporary password"
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
                <label className="text-xs font-semibold text-gray-500">
                  Batch Name
                  <input
                    value={lmsForm.batchName}
                    onChange={e => updateLms('batchName', e.target.value)}
                    placeholder="May 2026 - AI Batch"
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
                <label className="text-xs font-semibold text-gray-500">
                  Mentor Name
                  <input
                    value={lmsForm.mentorName}
                    onChange={e => updateLms('mentorName', e.target.value)}
                    placeholder="Mentor name"
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
                <label className="text-xs font-semibold text-gray-500">
                  Counselor Support
                  <input
                    value={lmsForm.counselorName}
                    onChange={e => updateLms('counselorName', e.target.value)}
                    placeholder="Counselor name"
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
                <label className="text-xs font-semibold text-gray-500">
                  WhatsApp Connect
                  <input
                    value={lmsForm.whatsappNumber}
                    onChange={e => updateLms('whatsappNumber', e.target.value)}
                    placeholder="10 digit phone"
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
                <label className="text-xs font-semibold text-gray-500 sm:col-span-2">
                  Support Contact
                  <input
                    value={lmsForm.supportContact}
                    onChange={e => updateLms('supportContact', e.target.value)}
                    placeholder="support@adyapan.com"
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
                <label className="text-xs font-semibold text-gray-500 sm:col-span-2">
                  Certification Guidance
                  <textarea
                    value={lmsForm.certificationGuidance}
                    onChange={e => updateLms('certificationGuidance', e.target.value)}
                    placeholder="Example: Mentor will guide certification milestones after batch orientation."
                    rows={3}
                    className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2.5 text-sm text-gray-900 focus:outline-none focus:border-[#ffa800]"
                  />
                </label>
              </div>

              <div className="px-5 pb-5 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div className="flex flex-wrap items-center gap-2 text-xs">
                  <span className={`px-2 py-1 rounded-full ${student.lmsAccess?.emailSent ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}>
                    Email {student.lmsAccess?.emailSent ? 'sent' : 'not sent'}
                  </span>
                  <span className={`px-2 py-1 rounded-full ${student.lmsAccess?.whatsappSent ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}>
                    WhatsApp {student.lmsAccess?.whatsappSent ? 'sent' : 'not configured'}
                  </span>
                </div>
                <button
                  onClick={() => onSaveLms(student, lmsForm)}
                  disabled={savingLms}
                  className="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl text-sm font-bold text-white disabled:opacity-60"
                  style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
                >
                  <Save className="w-4 h-4" />
                  {savingLms ? 'Saving...' : 'Save & Notify Student'}
                </button>
              </div>
            </div>

            {/* Enrollments */}
            <div>
              <h3 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <BookOpen className="w-4 h-4 text-[#ffa800]" />
                Enrolled Courses ({student.totalEnrollments})
              </h3>
              {student.enrollments.length === 0 ? (
                <p className="text-sm text-gray-400 text-center py-4">No enrollments yet</p>
              ) : (
                <div className="space-y-3">
                  {student.enrollments.map((enr, i) => (
                    <div key={i} className="border border-gray-100 rounded-xl p-4">
                      <div className="flex items-start justify-between mb-2">
                        <div>
                          <p className="font-medium text-gray-900 text-sm">{enr.courseName}</p>
                          <p className="text-xs text-gray-400 mt-0.5">{enr.planLabel} - Rs. {enr.amountPaid?.toLocaleString('en-IN')}</p>
                        </div>
                        <StatusBadge status={enr.certificateStatus} />
                      </div>
                      {/* Progress bar */}
                      <div className="mt-2">
                        <div className="flex justify-between text-xs text-gray-400 mb-1">
                          <span>Progress</span>
                          <span>{enr.progressPercent}%</span>
                        </div>
                        <div className="h-1.5 bg-gray-100 rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full transition-all"
                            style={{
                              width: `${enr.progressPercent}%`,
                              background: enr.progressPercent === 100 ? '#22c55e' : 'linear-gradient(90deg, #ffa800, #ff6b00)',
                            }}
                          />
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}

export default function AdminStudentsPage() {
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterPlan, setFilterPlan] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [page, setPage] = useState(1);
  const [pagination, setPagination] = useState({ total: 0, pages: 1 });
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [exporting, setExporting] = useState(false);
  const [savingLms, setSavingLms] = useState(false);

  // Debounce search - waits 500ms after user stops typing
  const debouncedSearch = useDebounce(search, 500);

  const fetchStudents = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({
        page: String(page),
        limit: '15',
        ...(debouncedSearch && { search: debouncedSearch }),
        ...(filterPlan && { plan: filterPlan }),
        ...(filterStatus && { paymentStatus: filterStatus }),
      });
      const res = await api.get(`/api/admin/students?${params}`);
      setStudents(res.data.students || []);
      setPagination(res.data.pagination || { total: 0, pages: 1 });
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, [page, debouncedSearch, filterPlan, filterStatus]);

  useEffect(() => { fetchStudents(); }, [fetchStudents]);

  // Reset to page 1 when debounced search changes
  useEffect(() => { setPage(1); }, [debouncedSearch]);

  const handleExport = async () => {
    setExporting(true);
    try {
      const res = await fetch('/api/admin/export/students', { credentials: 'include' });
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `students-${Date.now()}.csv`;
      a.click();
      URL.revokeObjectURL(url);
    } catch (err) {
      console.error(err);
    } finally {
      setExporting(false);
    }
  };

  const handleSaveLms = async (student: Student, data: LMSAccess) => {
    setSavingLms(true);
    try {
      const res = await api.put(`/api/admin/students/${student.id}/lms-access`, data);
      const nextAccess = res.data.access;
      const normalized: LMSAccess = {
        lmsProvider: nextAccess.lmsProvider,
        lmsEmail: nextAccess.lmsEmail,
        lmsPassword: nextAccess.lmsPassword,
        lmsPortalLink: nextAccess.lmsPortalLink,
        batchName: nextAccess.batchName,
        mentorName: nextAccess.mentorName,
        counselorName: nextAccess.counselorName,
        supportContact: nextAccess.supportContact,
        whatsappNumber: nextAccess.whatsappNumber,
        certificationGuidance: nextAccess.certificationGuidance,
        emailSent: nextAccess.emailSent,
        whatsappSent: nextAccess.whatsappSent,
        assignedAt: nextAccess.assignedAt,
      };
      setStudents(prev => prev.map(s => s.id === student.id ? { ...s, lmsAccess: normalized } : s));
      setSelectedStudent(prev => prev && prev.id === student.id ? { ...prev, lmsAccess: normalized } : prev);
      alert('LMS access saved. Notification was attempted based on configured email/WhatsApp settings.');
    } catch (err: any) {
      alert(err.response?.data?.error || 'Failed to save LMS access.');
    } finally {
      setSavingLms(false);
    }
  };

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Students</h1>
          <p className="text-gray-500 text-sm mt-0.5">{pagination.total} total students</p>
        </div>
        <button
          onClick={handleExport}
          disabled={exporting}
          className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium text-white transition-all disabled:opacity-60"
          style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
        >
          <Download className="w-4 h-4" />
          {exporting ? 'Exporting...' : 'Export CSV'}
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search by name or email..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 bg-white"
          />
        </div>
        <select
          value={filterPlan}
          onChange={e => { setFilterPlan(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700"
        >
          <option value="">All Plans</option>
          <option value="Plan 1">Plan 1</option>
          <option value="Plan 2">Plan 2</option>
          <option value="Plan 3">Plan 3</option>
          <option value="Plan 4">Plan 4</option>
        </select>
        <select
          value={filterStatus}
          onChange={e => { setFilterStatus(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700"
        >
          <option value="">All Statuses</option>
          <option value="success">Paid</option>
          <option value="pending">Pending</option>
          <option value="failed">Failed</option>
        </select>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/50">
                {['Student', 'Phone', 'Enrolled Course', 'Plan', 'Amount Paid', 'Payment', 'LMS', 'Certificate', 'Actions'].map(h => (
                  <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                [...Array(8)].map((_, i) => (
                  <tr key={i}>
                    {[...Array(9)].map((_, j) => (
                      <td key={j} className="px-4 py-3">
                        <div className="h-4 bg-gray-100 rounded animate-pulse" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : students.length === 0 ? (
                <tr>
                  <td colSpan={9} className="px-4 py-12 text-center text-gray-400">
                    <User className="w-8 h-8 mx-auto mb-2 text-gray-200" />
                    No students found
                  </td>
                </tr>
              ) : (
                students.map((student) => {
                  const primaryEnr = student.enrollments[0];
                  return (
                    <motion.tr
                      key={student.id}
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      className="hover:bg-orange-50/30 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-2.5">
                          <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                            style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
                            {student.name[0]?.toUpperCase()}
                          </div>
                          <div>
                            <p className="font-medium text-gray-900 whitespace-nowrap">{student.name}</p>
                            <p className="text-xs text-gray-400">{student.email}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-gray-600 whitespace-nowrap">{student.phone || '-'}</td>
                      <td className="px-4 py-3">
                        {primaryEnr ? (
                          <div>
                            <p className="text-gray-900 font-medium whitespace-nowrap max-w-[160px] truncate">{primaryEnr.courseName}</p>
                            {student.totalEnrollments > 1 && (
                              <p className="text-xs text-[#ffa800]">+{student.totalEnrollments - 1} more</p>
                            )}
                          </div>
                        ) : <span className="text-gray-400">-</span>}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap">
                        {primaryEnr?.planLabel ? (
                          <span className="px-2 py-0.5 bg-orange-50 text-[#ffa800] rounded-full text-xs font-medium">
                            {primaryEnr.planLabel}
                          </span>
                        ) : <span className="text-gray-400">-</span>}
                      </td>
                      <td className="px-4 py-3 font-semibold text-gray-900 whitespace-nowrap">
                        {student.totalPaid > 0 ? `Rs. ${student.totalPaid.toLocaleString('en-IN')}` : '-'}
                      </td>
                      <td className="px-4 py-3">
                        <StatusBadge status={student.paymentStatus} />
                      </td>
                      <td className="px-4 py-3">
                        {primaryEnr ? (
                          <StatusBadge status={student.lmsAccess ? 'ready' : 'pending'} />
                        ) : <span className="text-gray-400">-</span>}
                      </td>
                      <td className="px-4 py-3">
                        <StatusBadge status={primaryEnr?.certificateStatus || 'not_issued'} />
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1.5">
                          <button
                            onClick={() => setSelectedStudent(student)}
                            className="p-1.5 rounded-lg text-gray-400 hover:text-[#ffa800] hover:bg-orange-50 transition-all"
                            title="View Details / Assign LMS"
                          >
                            <Eye className="w-4 h-4" />
                          </button>
                          {student.lmsAccess?.lmsPortalLink && (
                            <a
                              href={student.lmsAccess.lmsPortalLink}
                              target="_blank"
                              rel="noreferrer"
                              className="p-1.5 rounded-lg text-gray-400 hover:text-green-600 hover:bg-green-50 transition-all"
                              title="Open LMS"
                            >
                              <ExternalLink className="w-4 h-4" />
                            </a>
                          )}
                          <a
                            href={`mailto:${student.email}`}
                            className="p-1.5 rounded-lg text-gray-400 hover:text-blue-500 hover:bg-blue-50 transition-all"
                            title="Send Email"
                          >
                            <Mail className="w-4 h-4" />
                          </a>
                        </div>
                      </td>
                    </motion.tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100">
            <p className="text-xs text-gray-400">
              Page {page} of {pagination.pages} - {pagination.total} students
            </p>
            <div className="flex items-center gap-1.5">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 disabled:opacity-40 transition-all"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button
                onClick={() => setPage(p => Math.min(pagination.pages, p + 1))}
                disabled={page === pagination.pages}
                className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 disabled:opacity-40 transition-all"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Student detail modal */}
      {selectedStudent && (
        <StudentDetailModal
          student={selectedStudent}
          onClose={() => setSelectedStudent(null)}
          onSaveLms={handleSaveLms}
          savingLms={savingLms}
        />
      )}
    </div>
  );
}
