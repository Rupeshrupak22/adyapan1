'use client';

import api from '@/lib/api';
import { useEffect, useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import useDebounce from '@/hooks/useDebounce';
import {
  Search, ChevronLeft, ChevronRight, Eye, X,
  CheckCircle, Clock, AlertCircle, CreditCard, IndianRupee,
  Phone, Mail, MessageCircle, Copy, Check,
} from 'lucide-react';

interface Payment {
  id: string;
  paymentId: string;
  orderId: string;
  studentName: string;
  studentEmail: string;
  studentPhone: string;
  courseName: string;
  planLabel: string;
  baseAmount: number;
  gstAmount: number;
  totalAmount: number;
  currency: string;
  status: string;
  paymentMethod: string;
  isTestMode: boolean;
  paidAt: string;
  userId: string;
}

function StatusBadge({ status }: { status: string }) {
  const map: Record<string, { cls: string; icon: any }> = {
    success: { cls: 'bg-green-100 text-green-700', icon: CheckCircle },
    pending: { cls: 'bg-amber-100 text-amber-700', icon: Clock },
    failed:  { cls: 'bg-red-100 text-red-700',     icon: AlertCircle },
  };
  const cfg = map[status] || { cls: 'bg-gray-100 text-gray-500', icon: null };
  const Icon = cfg.icon;
  return (
    <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium ${cfg.cls}`}>
      {Icon && <Icon className="w-3 h-3" />}
      {status}
    </span>
  );
}

function CopyBtn({ text }: { text: string }) {
  const [copied, setCopied] = useState(false);
  return (
    <button onClick={() => { navigator.clipboard.writeText(text); setCopied(true); setTimeout(() => setCopied(false), 1500); }}
      className="p-1 rounded text-gray-400 hover:text-[#ffa800] transition-colors" title="Copy">
      {copied ? <Check className="w-3.5 h-3.5 text-green-500" /> : <Copy className="w-3.5 h-3.5" />}
    </button>
  );
}

function PaymentDetailModal({ payment, onClose }: { payment: Payment; onClose: () => void }) {
  return (
    <AnimatePresence>
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
        className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
        onClick={onClose}>
        <motion.div initial={{ scale: 0.95, y: 16 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.95, y: 16 }}
          onClick={e => e.stopPropagation()}
          className="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden">
          {/* Header */}
          <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-[#ffa800]/10 flex items-center justify-center">
                <CreditCard className="w-5 h-5 text-[#ffa800]" />
              </div>
              <div>
                <h2 className="text-base font-bold text-gray-900">Payment Details</h2>
                <p className="text-xs text-gray-400">{payment.paymentId}</p>
              </div>
            </div>
            <button onClick={onClose} className="p-1.5 rounded-lg text-gray-400 hover:bg-gray-100 transition-colors">
              <X className="w-4 h-4" />
            </button>
          </div>

          {/* Body */}
          <div className="p-6 space-y-4">
            {/* Status + mode */}
            <div className="flex items-center gap-3">
              <StatusBadge status={payment.status} />
              {payment.isTestMode && (
                <span className="px-2 py-0.5 bg-purple-100 text-purple-600 rounded-full text-xs font-medium">TEST MODE</span>
              )}
            </div>

            {/* IDs */}
            <div className="bg-gray-50 rounded-xl p-4 space-y-2">
              {[
                { label: 'Payment ID', value: payment.paymentId },
                { label: 'Order ID',   value: payment.orderId },
              ].map(({ label, value }) => (
                <div key={label} className="flex items-center justify-between gap-2">
                  <span className="text-xs text-gray-500 w-24 shrink-0">{label}</span>
                  <span className="font-mono text-xs text-gray-800 truncate flex-1">{value || '-'}</span>
                  {value && <CopyBtn text={value} />}
                </div>
              ))}
            </div>

            {/* Student */}
            <div className="space-y-1.5">
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wide">Student</p>
              <p className="font-semibold text-gray-900">{payment.studentName}</p>
              <p className="text-sm text-gray-500">{payment.studentEmail}</p>
              <div className="flex gap-2 mt-2">
                {payment.studentPhone && (
                  <a href={`tel:${payment.studentPhone}`} className="flex items-center gap-1 px-3 py-1.5 bg-blue-50 text-blue-600 rounded-lg text-xs font-medium hover:bg-blue-100 transition-colors">
                    <Phone className="w-3.5 h-3.5" /> Call
                  </a>
                )}
                <a href={`mailto:${payment.studentEmail}`} className="flex items-center gap-1 px-3 py-1.5 bg-gray-50 text-gray-600 rounded-lg text-xs font-medium hover:bg-gray-100 transition-colors">
                  <Mail className="w-3.5 h-3.5" /> Email
                </a>
                {payment.studentPhone && (
                  <a href={`https://wa.me/91${payment.studentPhone.replace(/\D/g, '')}`} target="_blank" rel="noopener noreferrer"
                    className="flex items-center gap-1 px-3 py-1.5 bg-green-50 text-green-600 rounded-lg text-xs font-medium hover:bg-green-100 transition-colors">
                    <MessageCircle className="w-3.5 h-3.5" /> WhatsApp
                  </a>
                )}
              </div>
            </div>

            {/* Course + Amount */}
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-orange-50 rounded-xl p-3">
                <p className="text-xs text-gray-500 mb-1">Course</p>
                <p className="font-semibold text-gray-900 text-sm">{payment.courseName}</p>
                <p className="text-xs text-[#ffa800] mt-0.5">{payment.planLabel || '-'}</p>
              </div>
              <div className="bg-green-50 rounded-xl p-3">
                <p className="text-xs text-gray-500 mb-1">Amount</p>
                <p className="font-bold text-gray-900">Rs. {payment.totalAmount?.toLocaleString('en-IN')}</p>
                {payment.gstAmount > 0 && (
                  <p className="text-xs text-gray-400">incl. Rs. {payment.gstAmount?.toLocaleString('en-IN')} GST</p>
                )}
              </div>
            </div>

            {/* Method + Date */}
            <div className="flex gap-3 text-sm text-gray-600">
              <span className="capitalize">Method: <strong>{payment.paymentMethod || '-'}</strong></span>
              <span>·</span>
              <span>{new Date(payment.paidAt).toLocaleString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</span>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}

export default function AdminPaymentsPage() {
  const [payments, setPayments]         = useState<Payment[]>([]);
  const [loading, setLoading]           = useState(true);
  const [search, setSearch]             = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [filterPlan, setFilterPlan]     = useState('');
  const [dateFrom, setDateFrom]         = useState('');
  const [dateTo, setDateTo]             = useState('');
  const [page, setPage]                 = useState(1);
  const [pagination, setPagination]     = useState({ total: 0, pages: 1 });
  const [totalRevenue, setTotalRevenue] = useState(0);
  const [selectedPayment, setSelectedPayment] = useState<Payment | null>(null);

  const debouncedSearch = useDebounce(search, 500);

  const fetchPayments = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({
        page: String(page), limit: '15',
        ...(debouncedSearch && { search: debouncedSearch }),
        ...(filterStatus && { status: filterStatus }),
        ...(filterPlan   && { plan: filterPlan }),
        ...(dateFrom     && { dateFrom }),
        ...(dateTo       && { dateTo }),
      });
      const res = await api.get(`/api/admin/payments?${params}`);
      setPayments(res.data.payments || []);
      setPagination(res.data.pagination || { total: 0, pages: 1 });
      // Use server-side total revenue (all matching payments, not just current page)
      setTotalRevenue(res.data.totalRevenue || 0);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, [page, debouncedSearch, filterStatus, filterPlan, dateFrom, dateTo]);

  useEffect(() => { fetchPayments(); }, [fetchPayments]);
  useEffect(() => { setPage(1); }, [debouncedSearch]);

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Payments</h1>
          <p className="text-gray-500 text-sm mt-0.5">{pagination.total} total transactions</p>
        </div>
        <div className="flex items-center gap-2 px-4 py-2 bg-green-50 rounded-xl border border-green-100">
          <IndianRupee className="w-4 h-4 text-green-600" />
          <span className="text-sm font-semibold text-green-700">
            Rs. {totalRevenue.toLocaleString('en-IN')} collected
          </span>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input type="text" placeholder="Search payment ID, student..."
            value={search} onChange={e => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 bg-white" />
        </div>
        <select value={filterStatus} onChange={e => { setFilterStatus(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700">
          <option value="">All Statuses</option>
          <option value="success">Success</option>
          <option value="pending">Pending</option>
          <option value="failed">Failed</option>
        </select>
        <select value={filterPlan} onChange={e => { setFilterPlan(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700">
          <option value="">All Plans</option>
          <option value="Plan 1">Plan 1</option>
          <option value="Plan 2">Plan 2</option>
          <option value="Plan 3">Plan 3</option>
          <option value="Plan 4">Plan 4</option>
        </select>
        <input type="date" value={dateFrom} onChange={e => { setDateFrom(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700" />
        <input type="date" value={dateTo} onChange={e => { setDateTo(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700" />
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/50">
                {['Payment ID', 'Order ID', 'Student', 'Course', 'Plan', 'Amount', 'Status', 'Method', 'Date', 'Actions'].map(h => (
                  <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                [...Array(8)].map((_, i) => (
                  <tr key={i}>{[...Array(10)].map((_, j) => (
                    <td key={j} className="px-4 py-3"><div className="h-4 bg-gray-100 rounded animate-pulse" /></td>
                  ))}</tr>
                ))
              ) : payments.length === 0 ? (
                <tr>
                  <td colSpan={10} className="px-4 py-12 text-center text-gray-400">
                    <CreditCard className="w-8 h-8 mx-auto mb-2 text-gray-200" />
                    No payments found
                  </td>
                </tr>
              ) : payments.map(payment => (
                <motion.tr key={payment.id} initial={{ opacity: 0 }} animate={{ opacity: 1 }}
                  className="hover:bg-orange-50/30 transition-colors">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1.5">
                      <span className="font-mono text-xs text-gray-700 max-w-[100px] truncate">{payment.paymentId}</span>
                      {payment.isTestMode && (
                        <span className="px-1.5 py-0.5 bg-purple-100 text-purple-600 rounded text-[10px] font-medium">TEST</span>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-3 font-mono text-xs text-gray-500 max-w-[100px] truncate">{payment.orderId}</td>
                  <td className="px-4 py-3">
                    <p className="font-medium text-gray-900 whitespace-nowrap">{payment.studentName}</p>
                    <p className="text-xs text-gray-400">{payment.studentEmail}</p>
                  </td>
                  <td className="px-4 py-3 text-gray-700 max-w-[140px] truncate">{payment.courseName}</td>
                  <td className="px-4 py-3">
                    {payment.planLabel
                      ? <span className="px-2 py-0.5 bg-orange-50 text-[#ffa800] rounded-full text-xs font-medium whitespace-nowrap">{payment.planLabel}</span>
                      : '-'}
                  </td>
                  <td className="px-4 py-3">
                    <p className="font-semibold text-gray-900 whitespace-nowrap">Rs. {payment.totalAmount?.toLocaleString('en-IN')}</p>
                    {payment.gstAmount > 0 && (
                      <p className="text-xs text-gray-400">incl. Rs. {payment.gstAmount?.toLocaleString('en-IN')} GST</p>
                    )}
                  </td>
                  <td className="px-4 py-3"><StatusBadge status={payment.status} /></td>
                  <td className="px-4 py-3 text-xs text-gray-500 capitalize whitespace-nowrap">{payment.paymentMethod || '-'}</td>
                  <td className="px-4 py-3 text-xs text-gray-500 whitespace-nowrap">
                    {new Date(payment.paidAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: '2-digit' })}
                  </td>
                  <td className="px-4 py-3">
                    <button onClick={() => setSelectedPayment(payment)}
                      className="p-1.5 rounded-lg text-gray-400 hover:text-[#ffa800] hover:bg-orange-50 transition-all" title="View Details">
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>

        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100">
            <p className="text-xs text-gray-400">
              Showing {(page - 1) * 15 + 1}–{Math.min(page * 15, pagination.total)} of {pagination.total}
            </p>
            <div className="flex items-center gap-1.5">
              <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}
                className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 disabled:opacity-40 transition-all">
                <ChevronLeft className="w-4 h-4" />
              </button>
              <span className="text-sm font-medium text-gray-700 px-1">{page} / {pagination.pages}</span>
              <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page === pagination.pages}
                className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 disabled:opacity-40 transition-all">
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Payment Detail Modal */}
      {selectedPayment && (
        <PaymentDetailModal payment={selectedPayment} onClose={() => setSelectedPayment(null)} />
      )}
    </div>
  );
}
