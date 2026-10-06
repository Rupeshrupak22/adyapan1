'use client';

import { useState, useEffect, useCallback } from 'react';
import { motion } from 'framer-motion';
import {
  Search, Users, Phone, Mail, MessageCircle,
  RefreshCw, AlertTriangle, ChevronLeft, ChevronRight, Filter,
  MapPin, BookOpen,
} from 'lucide-react';

interface Lead {
  _id: string;
  name: string;
  phone: string;
  email: string;
  college: string;
  courseInterest: string;
  city: string;
  status: string;
  createdAt: string;
}

const STATUS_COLORS: Record<string, string> = {
  new:            'bg-blue-100 text-blue-700 border-blue-200',
  contacted:      'bg-yellow-100 text-yellow-700 border-yellow-200',
  enrolled:       'bg-green-100 text-green-700 border-green-200',
  converted:      'bg-purple-100 text-purple-700 border-purple-200',
  rejected:       'bg-red-100 text-red-700 border-red-200',
  not_interested: 'bg-gray-100 text-gray-600 border-gray-200',
};

export default function OfflineEnrollmentsPage() {
  const [leads, setLeads]           = useState<Lead[]>([]);
  const [loading, setLoading]       = useState(true);
  const [error, setError]           = useState('');
  const [search, setSearch]         = useState('');
  const [statusFilter, setStatus]   = useState('all');
  const [page, setPage]             = useState(1);
  const [total, setTotal]           = useState(0);
  const LIMIT = 20;

  const fetchLeads = useCallback(async () => {
    setLoading(true); setError('');
    try {
      const params = new URLSearchParams({ search, status: statusFilter, page: String(page), limit: String(LIMIT) });
      const res  = await fetch(`/api/admin/offline-leads?${params}`, { credentials: 'include' });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to load');
      setLeads(data.leads || []);
      setTotal(data.total || 0);
    } catch (e: any) { setError(e.message); }
    finally { setLoading(false); }
  }, [search, statusFilter, page]);

  useEffect(() => { fetchLeads(); }, [fetchLeads]);

  const pages = Math.ceil(total / LIMIT);

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Offline Enrollments</h1>
          <p className="text-gray-500 text-sm mt-1">{total} total leads</p>
        </div>
        <button onClick={fetchLeads} className="flex items-center gap-2 px-4 py-2 rounded-xl border border-gray-200 text-sm text-gray-600 hover:bg-gray-50 transition-all">
          <RefreshCw className="w-4 h-4" /> Refresh
        </button>
      </div>

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input type="text" placeholder="Search by name, email, phone, city..."
            value={search} onChange={e => { setSearch(e.target.value); setPage(1); }}
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none focus:shadow-[0_0_0_3px_rgba(255,168,0,0.1)] transition-all" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <select value={statusFilter} onChange={e => { setStatus(e.target.value); setPage(1); }}
            className="pl-9 pr-8 py-2.5 border border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none appearance-none bg-white cursor-pointer">
            <option value="all">All Status</option>
            <option value="new">New</option>
            <option value="contacted">Contacted</option>
            <option value="enrolled">Enrolled</option>
            <option value="converted">Converted</option>
            <option value="rejected">Rejected</option>
            <option value="not_interested">Not Interested</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-8 space-y-3">{[...Array(5)].map((_, i) => <div key={i} className="h-14 bg-gray-100 rounded-xl animate-pulse" />)}</div>
        ) : error ? (
          <div className="p-12 text-center"><AlertTriangle className="w-8 h-8 text-amber-400 mx-auto mb-2" /><p className="text-gray-600">{error}</p></div>
        ) : leads.length === 0 ? (
          <div className="p-12 text-center">
            <Users className="w-10 h-10 text-gray-200 mx-auto mb-3" />
            <p className="text-gray-500 font-medium">No offline leads found</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-100 bg-gray-50/50">
                  {['Student', 'Contact', 'Course Interest', 'Location', 'Status', 'Date', 'Actions'].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {leads.map((lead, i) => (
                  <motion.tr key={lead._id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.03 }}
                    className="hover:bg-orange-50/30 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                          style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
                          {lead.name?.[0]?.toUpperCase() || 'L'}
                        </div>
                        <div>
                          <p className="text-sm font-semibold text-gray-900">{lead.name}</p>
                          <p className="text-xs text-gray-400">{lead.college || '-'}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <p className="text-sm text-gray-700">{lead.phone}</p>
                      <p className="text-xs text-gray-400">{lead.email}</p>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1.5">
                        <BookOpen className="w-3.5 h-3.5 text-gray-400 flex-shrink-0" />
                        <span className="text-sm text-gray-700 max-w-[140px] truncate">{lead.courseInterest || '-'}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1.5">
                        <MapPin className="w-3.5 h-3.5 text-gray-400 flex-shrink-0" />
                        <span className="text-sm text-gray-600">{lead.city || '-'}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold border ${STATUS_COLORS[lead.status] || 'bg-gray-100 text-gray-600 border-gray-200'}`}>
                        {lead.status?.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <p className="text-xs text-gray-500 whitespace-nowrap">
                        {new Date(lead.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}
                      </p>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1.5">
                        <a href={`tel:${lead.phone}`} className="w-7 h-7 flex items-center justify-center rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors" title="Call">
                          <Phone className="w-3.5 h-3.5" />
                        </a>
                        <a href={`mailto:${lead.email}`} className="w-7 h-7 flex items-center justify-center rounded-lg bg-gray-50 text-gray-600 hover:bg-gray-100 transition-colors" title="Email">
                          <Mail className="w-3.5 h-3.5" />
                        </a>
                        <a href={`https://wa.me/91${lead.phone.replace(/\D/g, '')}`} target="_blank" rel="noopener noreferrer"
                          className="w-7 h-7 flex items-center justify-center rounded-lg bg-green-50 text-green-600 hover:bg-green-100 transition-colors" title="WhatsApp">
                          <MessageCircle className="w-3.5 h-3.5" />
                        </a>
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
