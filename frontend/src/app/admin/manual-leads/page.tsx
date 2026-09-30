'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Plus, Search, Filter, X, Edit2, Trash2, AlertCircle,
  CheckCircle, Loader2, Users, Phone, Mail, GraduationCap,
  MapPin, Calendar, CreditCard, ChevronLeft, ChevronRight,
  BookOpen, StickyNote, UserCheck, ChevronDown,
} from 'lucide-react';
import { sanitizeNameInput } from '@/lib/name-format';
import { sanitizeMobileInput } from '@/lib/phone';

// â"€â"€ Types â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
type EnrollmentType = 'Online' | 'Offline Form' | 'Office Visit' | 'Phone Call';
type PaymentStatus  = 'Paid' | 'Pending' | 'Failed' | 'Partial';

interface ManualLead {
  _id: string;
  name: string;
  phone: string;
  email: string;
  college: string;
  city: string;
  courseInterest: string;
  preferredBatch: string;
  enrollmentType: EnrollmentType;
  paymentStatus: PaymentStatus;
  amountPaid: number;
  notes: string;
  addedByAdmin: string;
  source: string;
  createdAt: string;
  updatedAt: string;
}

interface FormData {
  name: string;
  phone: string;
  email: string;
  college: string;
  city: string;
  courseInterest: string;
  preferredBatch: string;
  enrollmentType: EnrollmentType;
  paymentStatus: PaymentStatus;
  amountPaid: string;
  notes: string;
  addedByAdmin: string;
}

const EMPTY_FORM: FormData = {
  name: '', phone: '', email: '', college: '', city: '',
  courseInterest: '', preferredBatch: '',
  enrollmentType: 'Online',
  paymentStatus: 'Pending',
  amountPaid: '',
  notes: '', addedByAdmin: '',
};

// â"€â"€ Color maps â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
const ENROLLMENT_COLORS: Record<EnrollmentType, string> = {
  'Online':       'bg-blue-100 text-blue-700',
  'Offline Form': 'bg-purple-100 text-purple-700',
  'Office Visit': 'bg-teal-100 text-teal-700',
  'Phone Call':   'bg-orange-100 text-orange-700',
};

const PAYMENT_COLORS: Record<PaymentStatus, string> = {
  'Paid':    'bg-green-100 text-green-700',
  'Pending': 'bg-amber-100 text-amber-700',
  'Failed':  'bg-red-100 text-red-700',
  'Partial': 'bg-indigo-100 text-indigo-700',
};

// â"€â"€ Input style â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
const inp = 'w-full rounded-xl border border-gray-200 px-3.5 py-2.5 text-sm text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#ffa800]/30 focus:border-[#ffa800] transition-all bg-white';
const sel = `${inp} appearance-none cursor-pointer`;

// â"€â"€ Confirm Delete Modal â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
function ConfirmModal({
  name, onConfirm, onCancel, loading,
}: { name: string; onConfirm: () => void; onCancel: () => void; loading: boolean }) {
  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={onCancel} />
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 12 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 12 }}
        className="relative bg-white rounded-2xl shadow-2xl p-6 w-full max-w-sm z-10"
        onClick={e => e.stopPropagation()}
      >
        <div className="flex items-center gap-3 mb-4">
          <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center flex-shrink-0">
            <Trash2 className="w-5 h-5 text-red-600" />
          </div>
          <div>
            <h3 className="font-bold text-gray-900">Delete Lead</h3>
            <p className="text-sm text-gray-500">This action cannot be undone.</p>
          </div>
        </div>
        <p className="text-sm text-gray-700 mb-5">
          Are you sure you want to delete <span className="font-semibold">{name}</span>?
        </p>
        <div className="flex gap-3">
          <button onClick={onCancel} disabled={loading}
            className="flex-1 py-2.5 rounded-xl border border-gray-200 text-sm font-medium text-gray-700 hover:bg-gray-50 transition-all disabled:opacity-50">
            Cancel
          </button>
          <button onClick={onConfirm} disabled={loading}
            className="flex-1 py-2.5 rounded-xl bg-red-600 text-white text-sm font-semibold hover:bg-red-700 transition-all disabled:opacity-50 flex items-center justify-center gap-2">
            {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 className="w-4 h-4" />}
            Delete
          </button>
        </div>
      </motion.div>
    </div>
  );
}

// â"€â"€ Add/Edit Modal â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
function LeadModal({
  mode, initial, onClose, onSaved,
}: {
  mode: 'add' | 'edit';
  initial?: ManualLead;
  onClose: () => void;
  onSaved: (lead: ManualLead) => void;
}) {
  const [form, setForm] = useState<FormData>(
    initial
      ? {
          name: initial.name, phone: initial.phone, email: initial.email,
          college: initial.college, city: initial.city,
          courseInterest: initial.courseInterest, preferredBatch: initial.preferredBatch,
          enrollmentType: initial.enrollmentType, paymentStatus: initial.paymentStatus,
          amountPaid: initial.amountPaid > 0 ? String(initial.amountPaid) : '',
          notes: initial.notes, addedByAdmin: initial.addedByAdmin,
        }
      : EMPTY_FORM
  );
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState('');

  const set = (k: keyof FormData, v: string) => setForm(f => ({ ...f, [k]: v }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const payload = {
        ...form,
        amountPaid: form.amountPaid ? parseFloat(form.amountPaid) : 0,
        ...(mode === 'edit' && initial ? { id: initial._id } : {}),
      };

      const res = await fetch('/api/admin/manual-leads', {
        method: mode === 'add' ? 'POST' : 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(payload),
      });
      const data = await res.json();

      if (!res.ok) {
        setError(data.error || 'Something went wrong');
        return;
      }
      onSaved(data.lead);
    } catch {
      setError('Network error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Lock body scroll
  useEffect(() => {
    document.body.style.overflow = 'hidden';
    return () => { document.body.style.overflow = ''; };
  }, []);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={onClose}
      />
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        transition={{ type: 'spring', stiffness: 300, damping: 28 }}
        className="relative bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[92vh] overflow-y-auto z-10"
        onClick={e => e.stopPropagation()}
      >
        {/* Header */}
        <div className="sticky top-0 bg-white z-10 flex items-center justify-between px-6 py-4 border-b border-gray-100 rounded-t-2xl">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl flex items-center justify-center"
              style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
              {mode === 'add' ? <Plus className="w-4 h-4 text-white" /> : <Edit2 className="w-4 h-4 text-white" />}
            </div>
            <div>
              <h2 className="font-bold text-gray-900 text-base">
                {mode === 'add' ? 'Add Student Manually' : 'Edit Student Lead'}
              </h2>
              <p className="text-xs text-gray-400">
                {mode === 'add' ? 'Saved with source: manual-admin-entry' : `Editing: ${initial?.name}`}
              </p>
            </div>
          </div>
          <button onClick={onClose}
            className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors">
            <X className="w-4 h-4 text-gray-600" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="px-6 py-5 space-y-5">
          {/* Error */}
          <AnimatePresence>
            {error && (
              <motion.div initial={{ opacity: 0, y: -6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
                className="flex items-start gap-2 rounded-xl bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
                <AlertCircle className="w-4 h-4 shrink-0 mt-0.5" />
                {error}
              </motion.div>
            )}
          </AnimatePresence>

          {/* Section: Student Info */}
          <div>
            <p className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Student Information</p>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">
                  Student Name <span className="text-red-500">*</span>
                </label>
                <input required value={form.name} onChange={e => set('name', sanitizeNameInput(e.target.value))}
                  placeholder="e.g. Rahul Sharma" className={inp} />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">
                  Phone <span className="text-red-500">*</span>
                </label>
                <input required value={form.phone} onChange={e => set('phone', sanitizeMobileInput(e.target.value))}
                  placeholder="e.g. 9876543210" className={inp} inputMode="numeric" maxLength={10} />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">
                  Email <span className="text-red-500">*</span>
                </label>
                <input required type="email" value={form.email} onChange={e => set('email', e.target.value)}
                  placeholder="student@email.com" className={inp} />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">College</label>
                <input value={form.college} onChange={e => set('college', e.target.value)}
                  placeholder="e.g. IIT Bombay" className={inp} />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">City</label>
                <input value={form.city} onChange={e => set('city', e.target.value)}
                  placeholder="e.g. Mumbai" className={inp} />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">Course Interested</label>
                <input value={form.courseInterest} onChange={e => set('courseInterest', e.target.value)}
                  placeholder="e.g. Full Stack Development" className={inp} />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">Preferred Batch</label>
                <input value={form.preferredBatch} onChange={e => set('preferredBatch', e.target.value)}
                  placeholder="e.g. June 2025 Batch" className={inp} />
              </div>
            </div>
          </div>

          {/* Section: Enrollment & Payment */}
          <div>
            <p className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Enrollment & Payment</p>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">
                  Enrollment Type <span className="text-red-500">*</span>
                </label>
                <div className="relative">
                  <select required value={form.enrollmentType}
                    onChange={e => set('enrollmentType', e.target.value as EnrollmentType)}
                    className={sel}>
                    <option value="Online">Online</option>
                    <option value="Offline Form">Offline Form</option>
                    <option value="Office Visit">Office Visit</option>
                    <option value="Phone Call">Phone Call</option>
                  </select>
                  <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
                </div>
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">Payment Status</label>
                <div className="relative">
                  <select value={form.paymentStatus}
                    onChange={e => set('paymentStatus', e.target.value as PaymentStatus)}
                    className={sel}>
                    <option value="Paid">Paid</option>
                    <option value="Pending">Pending</option>
                    <option value="Failed">Failed</option>
                    <option value="Partial">Partial</option>
                  </select>
                  <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
                </div>
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">Amount Paid (Rs. )</label>
                <input type="number" min="0" step="1" value={form.amountPaid}
                  onChange={e => set('amountPaid', e.target.value)}
                  placeholder="0" className={inp} />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1.5">Added By Admin</label>
                <input value={form.addedByAdmin} onChange={e => set('addedByAdmin', e.target.value)}
                  placeholder="Admin name or email" className={inp} />
              </div>
            </div>
          </div>

          {/* Notes */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Notes</label>
            <textarea value={form.notes} onChange={e => set('notes', e.target.value)}
              rows={3} placeholder="Any additional notes about this student..."
              className={`${inp} resize-none`} />
          </div>

          {/* Source badge */}
          <div className="flex items-center gap-2 px-3 py-2 bg-orange-50 border border-orange-100 rounded-xl">
            <CheckCircle className="w-4 h-4 text-orange-500 flex-shrink-0" />
            <p className="text-xs text-orange-700 font-medium">
              Source will be saved as: <span className="font-bold">manual-admin-entry</span>
            </p>
          </div>

          {/* Actions */}
          <div className="flex gap-3 pt-1">
            <button type="button" onClick={onClose} disabled={loading}
              className="flex-1 py-3 rounded-xl border border-gray-200 text-sm font-semibold text-gray-700 hover:bg-gray-50 transition-all disabled:opacity-50">
              Cancel
            </button>
            <button type="submit" disabled={loading}
              className="flex-1 py-3 rounded-xl text-white text-sm font-bold shadow-lg transition-all disabled:opacity-60 flex items-center justify-center gap-2"
              style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
              {loading
                ? <><Loader2 className="w-4 h-4 animate-spin" /> Saving...</>
                : mode === 'add'
                  ? <><Plus className="w-4 h-4" /> Add Student</>
                  : <><CheckCircle className="w-4 h-4" /> Save Changes</>
              }
            </button>
          </div>
        </form>
      </motion.div>
    </div>
  );
}

// â"€â"€ Main Page â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
export default function ManualLeadsPage() {
  const [leads,   setLeads]   = useState<ManualLead[]>([]);
  const [loading, setLoading] = useState(true);
  const [error,   setError]   = useState('');
  const [total,   setTotal]   = useState(0);
  const [stats,   setStats]   = useState({ total: 0, online: 0, offline: 0, officeVisit: 0, phoneCall: 0, paid: 0 });
  const [page,    setPage]    = useState(1);
  const LIMIT = 20;

  // Filters
  const [search,         setSearch]         = useState('');
  const [enrollFilter,   setEnrollFilter]   = useState('');
  const [paymentFilter,  setPaymentFilter]  = useState('');

  // Modals
  const [showAdd,    setShowAdd]    = useState(false);
  const [editLead,   setEditLead]   = useState<ManualLead | null>(null);
  const [deleteLead, setDeleteLead] = useState<ManualLead | null>(null);
  const [deleting,   setDeleting]   = useState(false);

  // Toast
  const [toast, setToast] = useState<{ msg: string; type: 'success' | 'error' } | null>(null);
  const toastTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const showToast = (msg: string, type: 'success' | 'error' = 'success') => {
    setToast({ msg, type });
    if (toastTimer.current) clearTimeout(toastTimer.current);
    toastTimer.current = setTimeout(() => setToast(null), 3500);
  };

  // Debounced search
  const searchTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const handleSearch = (v: string) => {
    setSearch(v);
    if (searchTimer.current) clearTimeout(searchTimer.current);
    searchTimer.current = setTimeout(() => setPage(1), 400);
  };

  const fetchLeads = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const params = new URLSearchParams({
        page: String(page),
        limit: String(LIMIT),
        ...(search.trim()   && { search }),
        ...(enrollFilter    && { enrollmentType: enrollFilter }),
        ...(paymentFilter   && { paymentStatus: paymentFilter }),
      });
      const res  = await fetch(`/api/admin/manual-leads?${params}`, { credentials: 'include' });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to load');
      setLeads(data.leads || []);
      setTotal(data.total || 0);
      if (data.stats) setStats(data.stats);
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, [page, search, enrollFilter, paymentFilter]);

  useEffect(() => { fetchLeads(); }, [fetchLeads]);

  // Reset page when filters change
  useEffect(() => { setPage(1); }, [enrollFilter, paymentFilter]);

  const handleSaved = (lead: ManualLead) => {
    if (editLead) {
      setLeads(prev => prev.map(l => l._id === lead._id ? lead : l));
      showToast('Student updated successfully');
      setEditLead(null);
    } else {
      setLeads(prev => [lead, ...prev]);
      setTotal(t => t + 1);
      showToast('Student added successfully');
      setShowAdd(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteLead) return;
    setDeleting(true);
    try {
      const res = await fetch(`/api/admin/manual-leads?id=${deleteLead._id}`, {
        method: 'DELETE',
        credentials: 'include',
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Delete failed');
      setLeads(prev => prev.filter(l => l._id !== deleteLead._id));
      setTotal(t => Math.max(0, t - 1));
      showToast('Lead deleted');
      setDeleteLead(null);
    } catch (e: any) {
      showToast(e.message, 'error');
    } finally {
      setDeleting(false);
    }
  };

  const pages = Math.ceil(total / LIMIT);

  // Stats come from the API (aggregated over the full filtered dataset),
  // so the breakdown numbers stay consistent with the Total.

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">

      {/* Toast */}
      <AnimatePresence>
        {toast && (
          <motion.div
            initial={{ opacity: 0, y: -20, x: '-50%' }}
            animate={{ opacity: 1, y: 0, x: '-50%' }}
            exit={{ opacity: 0, y: -20, x: '-50%' }}
            className={`fixed top-5 left-1/2 z-[100] flex items-center gap-2 px-5 py-3 rounded-2xl shadow-xl text-sm font-semibold ${
              toast.type === 'success'
                ? 'bg-green-600 text-white'
                : 'bg-red-600 text-white'
            }`}
          >
            {toast.type === 'success'
              ? <CheckCircle className="w-4 h-4" />
              : <AlertCircle className="w-4 h-4" />}
            {toast.msg}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Manual Leads</h1>
          <p className="text-gray-500 text-sm mt-0.5">
            Students added manually by admin - {total} total
          </p>
        </div>
        <button
          onClick={() => setShowAdd(true)}
          className="flex items-center gap-2 px-5 py-2.5 rounded-xl text-white text-sm font-bold shadow-lg hover:shadow-xl transition-all active:scale-95"
          style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
        >
          <Plus className="w-4 h-4" />
          + Add Student Manually
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        {[
          { label: 'Total',         value: total,           color: 'bg-orange-100 text-orange-600' },
          { label: 'Online',        value: stats.online,    color: 'bg-blue-100 text-blue-600' },
          { label: 'Offline Form',  value: stats.offline,   color: 'bg-purple-100 text-purple-600' },
          { label: 'Office Visit',  value: stats.officeVisit, color: 'bg-teal-100 text-teal-600' },
          { label: 'Phone Call',    value: stats.phoneCall, color: 'bg-amber-100 text-amber-600' },
          { label: 'Paid',          value: stats.paid,      color: 'bg-green-100 text-green-600' },
        ].map(s => (
          <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm">
            <div className={`w-8 h-8 rounded-lg flex items-center justify-center mb-2 ${s.color}`}>
              <Users className="w-4 h-4" />
            </div>
            <p className="text-xl font-extrabold text-gray-900">{s.value}</p>
            <p className="text-xs text-gray-500 mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        {/* Search */}
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search name, email, phone, city..."
            value={search}
            onChange={e => handleSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 bg-white"
          />
        </div>

        {/* Enrollment type filter */}
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <select
            value={enrollFilter}
            onChange={e => setEnrollFilter(e.target.value)}
            className="pl-9 pr-8 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700 appearance-none cursor-pointer"
          >
            <option value="">All Types</option>
            <option value="Online">Online</option>
            <option value="Offline Form">Offline Form</option>
            <option value="Office Visit">Office Visit</option>
            <option value="Phone Call">Phone Call</option>
          </select>
          <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
        </div>

        {/* Payment status filter */}
        <div className="relative">
          <CreditCard className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <select
            value={paymentFilter}
            onChange={e => setPaymentFilter(e.target.value)}
            className="pl-9 pr-8 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700 appearance-none cursor-pointer"
          >
            <option value="">All Payments</option>
            <option value="Paid">Paid</option>
            <option value="Pending">Pending</option>
            <option value="Failed">Failed</option>
            <option value="Partial">Partial</option>
          </select>
          <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
        </div>
      </div>

      {/* Table / Cards */}
      {loading ? (
        <div className="space-y-3">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-gray-100 p-5 animate-pulse">
              <div className="h-4 bg-gray-200 rounded w-1/4 mb-3" />
              <div className="grid grid-cols-4 gap-3">
                {[...Array(4)].map((_, j) => <div key={j} className="h-8 bg-gray-100 rounded-xl" />)}
              </div>
            </div>
          ))}
        </div>
      ) : error ? (
        <div className="flex items-center gap-3 p-5 bg-red-50 border border-red-200 rounded-2xl text-red-600">
          <AlertCircle className="w-5 h-5 flex-shrink-0" /> {error}
        </div>
      ) : leads.length === 0 ? (
        <div className="text-center py-20 bg-white rounded-2xl border border-gray-100">
          <div className="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4"
            style={{ background: 'linear-gradient(135deg, rgba(255,168,0,0.12), rgba(255,107,0,0.06))' }}>
            <Users className="w-8 h-8 text-[#ffa800]" />
          </div>
          <p className="text-gray-700 font-semibold text-lg">No manual leads yet</p>
          <p className="text-gray-400 text-sm mt-1 mb-5">Click "+ Add Student Manually" to get started</p>
          <button
            onClick={() => setShowAdd(true)}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-white text-sm font-bold"
            style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
          >
            <Plus className="w-4 h-4" /> Add First Student
          </button>
        </div>
      ) : (
        <div className="space-y-3">
          <AnimatePresence>
            {leads.map((lead, i) => (
              <motion.div
                key={lead._id}
                layout
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.02 }}
                className="bg-white rounded-2xl border border-gray-100 hover:border-orange-200 hover:shadow-md p-5 transition-all"
              >
                <div className="flex flex-col sm:flex-row sm:items-start gap-4">
                  {/* Avatar + name */}
                  <div className="flex items-start gap-3 flex-1 min-w-0">
                    <div
                      className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold text-sm flex-shrink-0"
                      style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
                    >
                      {lead.name[0]?.toUpperCase()}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap mb-1.5">
                        <h3 className="font-bold text-gray-900">{lead.name}</h3>
                        <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${ENROLLMENT_COLORS[lead.enrollmentType]}`}>
                          {lead.enrollmentType}
                        </span>
                        <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${PAYMENT_COLORS[lead.paymentStatus]}`}>
                          {lead.paymentStatus}
                        </span>
                        {lead.amountPaid > 0 && (
                          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-gray-100 text-gray-600">
                            Rs. {lead.amountPaid.toLocaleString('en-IN')}
                          </span>
                        )}
                      </div>

                      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-x-4 gap-y-1 text-xs text-gray-500">
                        <span className="flex items-center gap-1 truncate">
                          <Phone className="w-3 h-3 flex-shrink-0" />{lead.phone}
                        </span>
                        <span className="flex items-center gap-1 truncate">
                          <Mail className="w-3 h-3 flex-shrink-0" />{lead.email}
                        </span>
                        {lead.college && (
                          <span className="flex items-center gap-1 truncate">
                            <GraduationCap className="w-3 h-3 flex-shrink-0" />{lead.college}
                          </span>
                        )}
                        {lead.city && (
                          <span className="flex items-center gap-1 truncate">
                            <MapPin className="w-3 h-3 flex-shrink-0" />{lead.city}
                          </span>
                        )}
                        {lead.courseInterest && (
                          <span className="flex items-center gap-1 truncate col-span-2">
                            <BookOpen className="w-3 h-3 flex-shrink-0" />{lead.courseInterest}
                          </span>
                        )}
                        {lead.preferredBatch && (
                          <span className="flex items-center gap-1 truncate">
                            <Calendar className="w-3 h-3 flex-shrink-0" />{lead.preferredBatch}
                          </span>
                        )}
                        {lead.addedByAdmin && (
                          <span className="flex items-center gap-1 truncate">
                            <UserCheck className="w-3 h-3 flex-shrink-0" />By: {lead.addedByAdmin}
                          </span>
                        )}
                        <span className="flex items-center gap-1 truncate">
                          <Calendar className="w-3 h-3 flex-shrink-0" />
                          {new Date(lead.createdAt).toLocaleDateString('en-IN', {
                            day: '2-digit', month: 'short', year: '2-digit',
                          })}
                        </span>
                      </div>

                      {lead.notes && (
                        <div className="mt-2 flex items-start gap-1.5 text-xs text-gray-500 bg-gray-50 rounded-lg px-2.5 py-1.5">
                          <StickyNote className="w-3 h-3 flex-shrink-0 mt-0.5 text-gray-400" />
                          <span className="line-clamp-2">{lead.notes}</span>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="flex items-center gap-2 flex-shrink-0 self-start">
                    <button
                      onClick={() => setEditLead(lead)}
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold text-[#ffa800] bg-orange-50 hover:bg-orange-100 transition-all"
                      title="Edit"
                    >
                      <Edit2 className="w-3.5 h-3.5" /> Edit
                    </button>
                    <button
                      onClick={() => setDeleteLead(lead)}
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold text-red-600 bg-red-50 hover:bg-red-100 transition-all"
                      title="Delete"
                    >
                      <Trash2 className="w-3.5 h-3.5" /> Delete
                    </button>
                  </div>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      )}

      {/* Pagination */}
      {pages > 1 && (
        <div className="flex items-center justify-between bg-white rounded-2xl border border-gray-100 px-5 py-3">
          <p className="text-xs text-gray-500">
            Page {page} of {pages} - {total} leads
          </p>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={page === 1}
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition-all"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="text-sm font-semibold text-gray-700 min-w-[60px] text-center">
              {page} / {pages}
            </span>
            <button
              onClick={() => setPage(p => Math.min(pages, p + 1))}
              disabled={page === pages}
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition-all"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

      {/* Modals */}
      <AnimatePresence>
        {showAdd && (
          <LeadModal
            mode="add"
            onClose={() => setShowAdd(false)}
            onSaved={handleSaved}
          />
        )}
        {editLead && (
          <LeadModal
            mode="edit"
            initial={editLead}
            onClose={() => setEditLead(null)}
            onSaved={handleSaved}
          />
        )}
        {deleteLead && (
          <ConfirmModal
            name={deleteLead.name}
            onConfirm={handleDelete}
            onCancel={() => setDeleteLead(null)}
            loading={deleting}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
