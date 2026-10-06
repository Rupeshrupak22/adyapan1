'use client';

import api from '@/lib/api';
import { useEffect, useState, useCallback } from 'react';
import { motion } from 'framer-motion';
import useDebounce from '@/hooks/useDebounce';
import {
  Search, ChevronLeft, ChevronRight, Eye, Download,
  CheckCircle, Clock, AlertCircle, CreditCard, IndianRupee,
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
    failed: { cls: 'bg-red-100 text-red-700', icon: AlertCircle },
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

export default function AdminPaymentsPage() {
  const [payments, setPayments] = useState<Payment[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [filterPlan, setFilterPlan] = useState('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [page, setPage] = useState(1);
  const [pagination, setPagination] = useState({ total: 0, pages: 1 });
  const [totalRevenue, setTotalRevenue] = useState(0);

  // Debounce search - waits 500ms after user stops typing
  const debouncedSearch = useDebounce(search, 500);

  const fetchPayments = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({
        page: String(page),
        limit: '15',
        ...(debouncedSearch && { search: debouncedSearch }),
        ...(filterStatus && { status: filterStatus }),
        ...(filterPlan && { plan: filterPlan }),
        ...(dateFrom && { dateFrom }),
        ...(dateTo && { dateTo }),
      });
      const res = await api.get(`/api/admin/payments?${params}`);
      const data = res.data.payments || [];
      setPayments(data);
      setPagination(res.data.pagination || { total: 0, pages: 1 });
      setTotalRevenue(data.filter((p: Payment) => p.status === 'success').reduce((s: number, p: Payment) => s + p.totalAmount, 0));
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, [page, debouncedSearch, filterStatus, filterPlan, dateFrom, dateTo]);

  useEffect(() => { fetchPayments(); }, [fetchPayments]);

  // Reset to page 1 when debounced search changes
  useEffect(() => { setPage(1); }, [debouncedSearch]);

  const methodIcon = (method: string) => {
    const icons: Record<string, string> = { upi: '', card: '', netbanking: '', emi: '...', wallet: '' };
    return icons[method] || '';
  };

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
          <input
            type="text"
            placeholder="Search payment ID, student..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 bg-white"
          />
        </div>
        <select
          value={filterStatus}
          onChange={e => { setFilterStatus(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700"
        >
          <option value="">All Statuses</option>
          <option value="success">Success</option>
          <option value="pending">Pending</option>
          <option value="failed">Failed</option>
        </select>
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
        <input
          type="date"
          value={dateFrom}
          onChange={e => { setDateFrom(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700"
        />
        <input
          type="date"
          value={dateTo}
          onChange={e => { setDateTo(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700"
        />
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/50">
                {['Payment ID', 'Order ID', 'Student', 'Course', 'Plan', 'Amount', 'Status', 'Method', 'Date', 'Actions'].map(h => (
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
                    {[...Array(10)].map((_, j) => (
                      <td key={j} className="px-4 py-3">
                        <div className="h-4 bg-gray-100 rounded animate-pulse" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : payments.length === 0 ? (
                <tr>
                  <td colSpan={10} className="px-4 py-12 text-center text-gray-400">
                    <CreditCard className="w-8 h-8 mx-auto mb-2 text-gray-200" />
                    No payments found
                  </td>
                </tr>
              ) : (
                payments.map((payment) => (
                  <motion.tr
                    key={payment.id}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    className="hover:bg-orange-50/30 transition-colors"
                  >
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
                      {payment.planLabel ? (
                        <span className="px-2 py-0.5 bg-orange-50 text-[#ffa800] rounded-full text-xs font-medium whitespace-nowrap">
                          {payment.planLabel}
                        </span>
                      ) : '-'}
                    </td>
                    <td className="px-4 py-3">
                      <p className="font-semibold text-gray-900 whitespace-nowrap">Rs. {payment.totalAmount?.toLocaleString('en-IN')}</p>
                      {payment.gstAmount > 0 && (
                        <p className="text-xs text-gray-400">incl. Rs. {payment.gstAmount?.toLocaleString('en-IN')} GST</p>
                      )}
                    </td>
                    <td className="px-4 py-3"><StatusBadge status={payment.status} /></td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <span className="text-sm">{methodIcon(payment.paymentMethod)}</span>
                      <span className="text-xs text-gray-500 ml-1 capitalize">{payment.paymentMethod}</span>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-500 whitespace-nowrap">
                      {new Date(payment.paidAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: '2-digit' })}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <button
                          className="p-1.5 rounded-lg text-gray-400 hover:text-[#ffa800] hover:bg-orange-50 transition-all"
                          title="View"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button
                          className="p-1.5 rounded-lg text-gray-400 hover:text-blue-500 hover:bg-blue-50 transition-all"
                          title="Download Receipt"
                        >
                          <Download className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </motion.tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100">
            <p className="text-xs text-gray-400">
              Page {page} of {pagination.pages} - {pagination.total} payments
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
    </div>
  );
}
