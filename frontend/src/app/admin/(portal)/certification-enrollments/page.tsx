'use client';

import { useCallback, useEffect, useState } from 'react';
import { Search, Loader2, Award, ChevronLeft, ChevronRight } from 'lucide-react';

type EnrollmentStatus = 'new' | 'contacted' | 'enrolled' | 'rejected';

interface CertificationEnrollmentRow {
  _id: string;
  certificationName: string;
  companyName: string;
  name: string;
  phone: string;
  email: string;
  college?: string;
  city?: string;
  examDate?: string;
  status: EnrollmentStatus;
  createdAt: string;
}

const LIMIT = 20;

const STATUS_CLASS: Record<EnrollmentStatus, string> = {
  new: 'bg-blue-50 text-blue-700 border-blue-100',
  contacted: 'bg-amber-50 text-amber-700 border-amber-100',
  enrolled: 'bg-green-50 text-green-700 border-green-100',
  rejected: 'bg-red-50 text-red-700 border-red-100',
};

function formatDate(value?: string) {
  if (!value) return '-';
  return new Date(value).toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

export default function AdminCertificationEnrollmentsPage() {
  const [rows, setRows] = useState<CertificationEnrollmentRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState('');
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('all');
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);

  const fetchEnrollments = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({
        page: String(page),
        limit: String(LIMIT),
        ...(search.trim() && { search: search.trim() }),
        ...(status !== 'all' && { status }),
      });
      const res = await fetch(`/api/admin/certification-enrollments?${params}`, {
        credentials: 'include',
      });
      const data = await res.json();
      setRows(data.enrollments || []);
      setTotal(data.total || 0);
    } catch (error) {
      console.error(error);
      setRows([]);
      setTotal(0);
    } finally {
      setLoading(false);
    }
  }, [page, search, status]);

  useEffect(() => {
    fetchEnrollments();
  }, [fetchEnrollments]);

  useEffect(() => {
    setPage(1);
  }, [search, status]);

  const updateStatus = async (id: string, nextStatus: EnrollmentStatus) => {
    setUpdatingId(id);
    try {
      const res = await fetch('/api/admin/certification-enrollments', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ id, status: nextStatus }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Status update failed');
      setRows((prev) => prev.map((row) => (
        row._id === id ? { ...row, status: nextStatus } : row
      )));
    } catch (error) {
      console.error(error);
      await fetchEnrollments();
    } finally {
      setUpdatingId('');
    }
  };

  const pages = Math.max(1, Math.ceil(total / LIMIT));

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Certification Enrollments</h1>
        <p className="text-gray-500 text-sm mt-0.5">Leads submitted from the certification modal - {total} total</p>
      </div>

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search name, phone, email, certification..."
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 bg-white"
          />
        </div>
        <select
          value={status}
          onChange={(e) => setStatus(e.target.value)}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700"
        >
          <option value="all">All Statuses</option>
          <option value="new">New</option>
          <option value="contacted">Contacted</option>
          <option value="enrolled">Enrolled</option>
          <option value="rejected">Rejected</option>
        </select>
      </div>

      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-[1180px] w-full text-sm">
            <thead className="bg-gray-50 text-gray-500">
              <tr>
                {[
                  'Name', 'Phone', 'Email', 'College', 'City', 'Certification',
                  'Company', 'Exam Date', 'Status', 'Created Date',
                ].map((head) => (
                  <th key={head} className="px-4 py-3 text-left font-bold whitespace-nowrap">
                    {head}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {loading ? (
                <tr>
                  <td colSpan={10} className="px-4 py-16 text-center text-gray-400">
                    <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2" />
                    Loading certification enrollments...
                  </td>
                </tr>
              ) : rows.length === 0 ? (
                <tr>
                  <td colSpan={10} className="px-4 py-16 text-center text-gray-400">
                    <Award className="w-10 h-10 mx-auto mb-2 text-gray-200" />
                    No certification enrollments found
                  </td>
                </tr>
              ) : rows.map((row) => (
                <tr key={row._id} className="hover:bg-orange-50/30 transition-colors">
                  <td className="px-4 py-3 font-semibold text-gray-900 whitespace-nowrap">{row.name}</td>
                  <td className="px-4 py-3 text-gray-700 whitespace-nowrap">{row.phone}</td>
                  <td className="px-4 py-3 text-gray-700 whitespace-nowrap">{row.email}</td>
                  <td className="px-4 py-3 text-gray-600 whitespace-nowrap">{row.college || '-'}</td>
                  <td className="px-4 py-3 text-gray-600 whitespace-nowrap">{row.city || '-'}</td>
                  <td className="px-4 py-3 text-gray-900 min-w-[220px]">{row.certificationName}</td>
                  <td className="px-4 py-3 text-gray-700 whitespace-nowrap">{row.companyName}</td>
                  <td className="px-4 py-3 text-gray-700 whitespace-nowrap">{formatDate(row.examDate)}</td>
                  <td className="px-4 py-3 whitespace-nowrap">
                    <select
                      value={row.status}
                      disabled={updatingId === row._id}
                      onChange={(e) => updateStatus(row._id, e.target.value as EnrollmentStatus)}
                      className={`rounded-full border px-3 py-1 text-xs font-bold capitalize focus:outline-none ${STATUS_CLASS[row.status]}`}
                    >
                      <option value="new">New</option>
                      <option value="contacted">Contacted</option>
                      <option value="enrolled">Enrolled</option>
                      <option value="rejected">Rejected</option>
                    </select>
                  </td>
                  <td className="px-4 py-3 text-gray-600 whitespace-nowrap">{formatDate(row.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="flex items-center justify-between">
        <p className="text-sm text-gray-500">
          Page {page} of {pages}
        </p>
        <div className="flex gap-2">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page <= 1}
            className="inline-flex items-center gap-1 px-3 py-2 rounded-xl border border-gray-200 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <ChevronLeft className="w-4 h-4" />
            Prev
          </button>
          <button
            onClick={() => setPage((p) => Math.min(pages, p + 1))}
            disabled={page >= pages}
            className="inline-flex items-center gap-1 px-3 py-2 rounded-xl border border-gray-200 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
          >
            Next
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
