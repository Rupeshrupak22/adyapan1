'use client';

import { useState, useEffect, useCallback } from 'react';
import { motion } from 'framer-motion';
import {
  Search, ShoppingBag, Phone, Mail, MessageCircle,
  RefreshCw, AlertTriangle, ChevronLeft, ChevronRight, Filter,
} from 'lucide-react';

interface PurchasedCourse {
  _id: string;
  userId: string;
  userName: string;
  userEmail: string;
  userPhone: string;
  courseSlug: string;
  courseName: string;
  planLabel: string;
  amountPaid: number;
  paymentId: string;
  enrollmentStatus: string;
  enrolledAt: string;
}

export default function PurchasedCoursesPage() {
  const [courses, setCourses]       = useState<PurchasedCourse[]>([]);
  const [loading, setLoading]       = useState(true);
  const [error, setError]           = useState('');
  const [search, setSearch]         = useState('');
  const [courseFilter, setCourse]   = useState('');
  const [page, setPage]             = useState(1);
  const [total, setTotal]           = useState(0);
  const LIMIT = 20;

  const fetchCourses = useCallback(async () => {
    setLoading(true); setError('');
    try {
      const params = new URLSearchParams({ search, course: courseFilter, page: String(page), limit: String(LIMIT) });
      const res  = await fetch(`/api/admin/enrollments?${params}`, { credentials: 'include' });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to load');
      setCourses(data.enrollments || []);
      setTotal(data.total || 0);
    } catch (e: any) { setError(e.message); }
    finally { setLoading(false); }
  }, [search, courseFilter, page]);

  useEffect(() => { fetchCourses(); }, [fetchCourses]);

  const pages = Math.ceil(total / LIMIT);

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Purchased Courses</h1>
          <p className="text-gray-500 text-sm mt-1">{total} total purchases</p>
        </div>
        <button onClick={fetchCourses} className="flex items-center gap-2 px-4 py-2 rounded-xl border border-gray-200 text-sm text-gray-600 hover:bg-gray-50 transition-all">
          <RefreshCw className="w-4 h-4" /> Refresh
        </button>
      </div>

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input type="text" placeholder="Search by student name, email..."
            value={search} onChange={e => { setSearch(e.target.value); setPage(1); }}
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none focus:shadow-[0_0_0_3px_rgba(255,168,0,0.1)] transition-all" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input type="text" placeholder="Filter by course..."
            value={courseFilter} onChange={e => { setCourse(e.target.value); setPage(1); }}
            className="pl-9 pr-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none transition-all" />
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-8 space-y-3">{[...Array(5)].map((_, i) => <div key={i} className="h-14 bg-gray-100 rounded-xl animate-pulse" />)}</div>
        ) : error ? (
          <div className="p-12 text-center"><AlertTriangle className="w-8 h-8 text-amber-400 mx-auto mb-2" /><p className="text-gray-600">{error}</p></div>
        ) : courses.length === 0 ? (
          <div className="p-12 text-center">
            <ShoppingBag className="w-10 h-10 text-gray-200 mx-auto mb-3" />
            <p className="text-gray-500 font-medium">No purchased courses found</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-100 bg-gray-50/50">
                  {['Student', 'Course', 'Plan', 'Amount Paid', 'Payment ID', 'Date', 'Actions'].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {courses.map((c, i) => (
                  <motion.tr key={c._id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.03 }}
                    className="hover:bg-orange-50/30 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                          style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
                          {c.userName?.[0]?.toUpperCase() || 'S'}
                        </div>
                        <div>
                          <p className="text-sm font-semibold text-gray-900">{c.userName || '-'}</p>
                          <p className="text-xs text-gray-400">{c.userEmail}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <p className="text-sm font-medium text-gray-900 max-w-[160px] truncate">{c.courseName}</p>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-xs font-medium text-gray-600 bg-gray-100 px-2 py-0.5 rounded-full">{c.planLabel || '-'}</span>
                    </td>
                    <td className="px-4 py-3">
                      <p className="text-sm font-semibold text-green-700">Rs. {(c.amountPaid || 0).toLocaleString('en-IN')}</p>
                    </td>
                    <td className="px-4 py-3">
                      <p className="text-xs text-gray-500 font-mono max-w-[120px] truncate">{c.paymentId || '-'}</p>
                    </td>
                    <td className="px-4 py-3">
                      <p className="text-xs text-gray-500 whitespace-nowrap">
                        {new Date(c.enrolledAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}
                      </p>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1.5">
                        {c.userPhone && (
                          <a href={`tel:${c.userPhone}`} className="w-7 h-7 flex items-center justify-center rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors" title="Call">
                            <Phone className="w-3.5 h-3.5" />
                          </a>
                        )}
                        <a href={`mailto:${c.userEmail}`} className="w-7 h-7 flex items-center justify-center rounded-lg bg-gray-50 text-gray-600 hover:bg-gray-100 transition-colors" title="Email">
                          <Mail className="w-3.5 h-3.5" />
                        </a>
                        {c.userPhone && (
                          <a href={`https://wa.me/91${c.userPhone.replace(/\D/g, '')}`} target="_blank" rel="noopener noreferrer"
                            className="w-7 h-7 flex items-center justify-center rounded-lg bg-green-50 text-green-600 hover:bg-green-100 transition-colors" title="WhatsApp">
                            <MessageCircle className="w-3.5 h-3.5" />
                          </a>
                        )}
                      </div>
                    </td>
                  </motion.tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {pages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100">
            <p className="text-xs text-gray-500">Showing {(page - 1) * LIMIT + 1}"{Math.min(page * LIMIT, total)} of {total}</p>
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
