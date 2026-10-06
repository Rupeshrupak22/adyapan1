'use client';

import { useState, useEffect, useCallback } from 'react';
import { motion } from 'framer-motion';
import {
  Search, GraduationCap, Phone, Mail, MessageCircle,
  RefreshCw, AlertTriangle, ChevronLeft, ChevronRight,
  CheckCircle, Clock, XCircle, Filter,
} from 'lucide-react';

interface Enrollment {
  _id: string;
  userId: string;
  userName: string;
  userEmail: string;
  userPhone: string;
  courseSlug: string;
  courseName: string;
  planLabel: string;
  amountPaid: number;
  enrollmentStatus: string;
  enrolledAt: string;
  paymentId: string;
}

const STATUS_COLORS: Record<string, string> = {
  active:    'bg-green-100 text-green-700 border-green-200',
  completed: 'bg-blue-100 text-blue-700 border-blue-200',
  expired:   'bg-gray-100 text-gray-600 border-gray-200',
  cancelled: 'bg-red-100 text-red-700 border-red-200',
};

const STATUS_ICONS: Record<string, any> = {
  active:    CheckCircle,
  completed: CheckCircle,
  expired:   Clock,
  cancelled: XCircle,
};

export default function OnlineEnrollmentsPage() {
  const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
  const [loading, setLoading]         = useState(true);
  const [error, setError]             = useState('');
  const [search, setSearch]           = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [page, setPage]               = useState(1);
  const [total, setTotal]             = useState(0);
  const LIMIT = 20;

  const fetchEnrollments = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const params = new URLSearchParams({
        search, status: statusFilter, page: String(page), limit: String(LIMIT),
      });
      const res  = await fetch(`/api/admin/enrollments?${params}`, { credentials: 'include' });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to load');
      setEnrollments(data.enrollments || []);
      setTotal(data.total || 0);
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, [search, statusFilter, page]);

  useEffect(() => { fetchEnrollments(); }, [fetchEnrollments]);

  const pages = Math.ceil(total / LIMIT);

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Online Enrollments</h1>
          <p className="text-gray-500 text-sm mt-1">{total} total enrollments</p>
        </div>
        <button onClick={fetchEnrollments} className="flex items-center gap-2 px-4 py-2 rounded-xl border border-gray-200 text-sm text-gray-600 hover:bg-gray-50 transition-all">
          <RefreshCw className="w-4 h-4" /> Refresh
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search by name, email, course..."
            value={search}
            onChange={e => { setSearch(e.target.value); setPage(1); }}
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none focus:shadow-[0_0_0_3px_rgba(255,168,0,0.1)] transition-all"
          />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <select
            value={statusFilter}
            onChange={e => { setStatusFilter(e.target.value); setPage(1); }}
            className="pl-9 pr-8 py-2.5 border border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none appearance-none bg-white cursor-pointer"
          >
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="completed">Completed</option>
            <option value="expired">Expired</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-8 space-y-3">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-14 bg-gray-100 rounded-xl animate-pulse" />
            ))}
          </div>
        ) : error ? (
          <div className="p-12 text-center">
            <AlertTriangle className="w-8 h-8 text-amber-400 mx-auto mb-2" />
            <p className="text-gray-600">{error}</p>
          </div>
        ) : enrollments.length === 0 ? (
          <div className="p-12 text-center">
            <GraduationCap className="w-10 h-10 text-gray-200 mx-auto mb-3" />
            <p className="text-gray-500 font-medium">No enrollments found</p>
            <p className="text-gray-400 text-sm mt-1">Try adjusting your search or filters</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-100 bg-gray-50/50">
                  {['Student', 'Course', 'Plan', 'Amount', 'Status', 'Enrolled', 'Actions'].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {enrollments.map((e, i) => {
                  const StatusIcon = STATUS_ICONS[e.enrollmentStatus] || Clock;
                  return (
                    <motion.tr
                      key={e._id}
                      initial={{ opacity: 0, y: 8 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: i * 0.03 }}
                      className="hover:bg-orange-50/30 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                            style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
                            {e.userName?.[0]?.toUpperCase() || 'S'}
                          </div>
                          <div>
                            <p className="text-sm font-semibold text-gray-900">{e.userName || '-'}</p>
                            <p className="text-xs text-gray-400">{e.userEmail}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        <p className="text-sm font-medium text-gray-900 max-w-[160px] truncate">{e.courseName}</p>
                        <p className="text-xs text-gray-400">{e.courseSlug}</p>
                      </td>
                      <td className="px-4 py-3">
                        <span className="text-xs font-medium text-gray-600 bg-gray-100 px-2 py-0.5 rounded-full">
                          {e.planLabel || '-'}
                        </span>
                      </td>
                      <td className="px-4 py-3">
                        <p className="text-sm font-semibold text-gray-900">Rs. {(e.amountPaid || 0).toLocaleString('en-IN')}</p>
                      </td>
                      <td className="px-4 py-3">
                        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold border ${STATUS_COLORS[e.enrollmentStatus] || 'bg-gray-100 text-gray-600 border-gray-200'}`}>
                          <StatusIcon className="w-3 h-3" />
                          {e.enrollmentStatus}
                        </span>
                      </td>
                      <td className="px-4 py-3">
                        <p className="text-xs text-gray-500 whitespace-nowrap">
                          {new Date(e.enrolledAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}
                        </p>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1.5">
                          {e.userPhone && (
                            <a href={`tel:${e.userPhone}`}
                              className="w-7 h-7 flex items-center justify-center rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors"
                              title="Call">
                              <Phone className="w-3.5 h-3.5" />
                            </a>
                          )}
                          {e.userEmail && (
                            <a href={`mailto:${e.userEmail}`}
                              className="w-7 h-7 flex items-center justify-center rounded-lg bg-gray-50 text-gray-600 hover:bg-gray-100 transition-colors"
                              title="Email">
                              <Mail className="w-3.5 h-3.5" />
                            </a>
                          )}
                          {e.userPhone && (
                            <a href={`https://wa.me/91${e.userPhone.replace(/\D/g, '')}`} target="_blank" rel="noopener noreferrer"
                              className="w-7 h-7 flex items-center justify-center rounded-lg bg-green-50 text-green-600 hover:bg-green-100 transition-colors"
                              title="WhatsApp">
                              <MessageCircle className="w-3.5 h-3.5" />
                            </a>
                          )}
                        </div>
                      </td>
                    </motion.tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination */}
        {pages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100">
            <p className="text-xs text-gray-500">
              Showing {(page - 1) * LIMIT + 1}"{Math.min(page * LIMIT, total)} of {total}
            </p>
            <div className="flex items-center gap-2">
              <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}
                className="w-8 h-8 flex items-center justify-center rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition-all">
                <ChevronLeft className="w-4 h-4" />
              </button>
              <span className="text-sm font-medium text-gray-700">{page} / {pages}</span>
              <button onClick={() => setPage(p => Math.min(pages, p + 1))} disabled={page === pages}
                className="w-8 h-8 flex items-center justify-center rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition-all">
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
