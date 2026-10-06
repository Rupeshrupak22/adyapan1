'use client';

import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Users, Phone, Mail, GraduationCap, MapPin, Calendar,
  Search, Filter, ChevronDown, AlertCircle, Loader2, CheckCircle,
} from 'lucide-react';

interface Lead {
  _id: string;
  name: string;
  phone: string;
  email: string;
  college: string;
  courseInterest: string;
  preferredBatch: string;
  city: string;
  status: string;
  createdAt: string;
}

const STATUS_CFG: Record<string, { label: string; cls: string }> = {
  new:            { label: 'New',           cls: 'bg-blue-100 text-blue-700' },
  contacted:      { label: 'Contacted',     cls: 'bg-yellow-100 text-yellow-700' },
  enrolled:       { label: 'Enrolled',      cls: 'bg-green-100 text-green-700' },
  not_interested: { label: 'Not Interested',cls: 'bg-gray-100 text-gray-500' },
};

export default function OfflineLeadsPage() {
  const [leads,   setLeads]   = useState<Lead[]>([]);
  const [loading, setLoading] = useState(true);
  const [error,   setError]   = useState('');
  const [search,  setSearch]  = useState('');
  const [filter,  setFilter]  = useState('');
  const [updating, setUpdating] = useState<string | null>(null);

  const fetchLeads = useCallback(async () => {
    setLoading(true);
    try {
      const params = filter ? `?status=${filter}` : '';
      const res  = await fetch(`/api/admin/offline-leads${params}`, { credentials: 'include' });
      const data = await res.json();
      if (data.success) setLeads(data.leads || []);
      else setError(data.error || 'Failed to load leads');
    } catch { setError('Failed to load leads'); }
    finally { setLoading(false); }
  }, [filter]);

  useEffect(() => { fetchLeads(); }, [fetchLeads]);

  const updateStatus = async (id: string, status: string) => {
    setUpdating(id);
    try {
      await fetch(`/api/admin/offline-leads?id=${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ status }),
      });
      setLeads(prev => prev.map(l => l._id === id ? { ...l, status } : l));
    } finally { setUpdating(null); }
  };

  const filtered = leads.filter(l => {
    const q = search.toLowerCase();
    return !q || l.name.toLowerCase().includes(q) || l.email.toLowerCase().includes(q) ||
      l.phone.includes(q) || l.city.toLowerCase().includes(q);
  });

  const stats = {
    total:     leads.length,
    new:       leads.filter(l => l.status === 'new').length,
    contacted: leads.filter(l => l.status === 'contacted').length,
    enrolled:  leads.filter(l => l.status === 'enrolled').length,
  };

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Offline Internship Leads</h1>
        <p className="text-gray-500 text-sm mt-0.5">Enquiries from the Offline Services landing page</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        {[
          { label: 'Total Leads', value: stats.total,     color: 'bg-orange-100 text-orange-600' },
          { label: 'New',         value: stats.new,       color: 'bg-blue-100 text-blue-600' },
          { label: 'Contacted',   value: stats.contacted, color: 'bg-yellow-100 text-yellow-600' },
          { label: 'Enrolled',    value: stats.enrolled,  color: 'bg-green-100 text-green-600' },
        ].map(s => (
          <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm">
            <div className={`w-10 h-10 rounded-xl flex items-center justify-center mb-3 ${s.color}`}>
              <Users className="w-5 h-5" />
            </div>
            <p className="text-2xl font-extrabold text-gray-900">{s.value}</p>
            <p className="text-sm text-gray-500 mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input type="text" placeholder="Search name, email, phone..." value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-orange-400 bg-white" />
        </div>
        <div className="relative">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <select value={filter} onChange={e => setFilter(e.target.value)}
            className="pl-9 pr-8 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-orange-400 bg-white text-gray-700 appearance-none">
            <option value="">All Status</option>
            <option value="new">New</option>
            <option value="contacted">Contacted</option>
            <option value="enrolled">Enrolled</option>
            <option value="not_interested">Not Interested</option>
          </select>
          <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
        </div>
      </div>

      {/* Table */}
      {loading ? (
        <div className="space-y-3">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-gray-100 p-5 animate-pulse">
              <div className="h-4 bg-gray-200 rounded w-1/4 mb-2" />
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
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 bg-white rounded-2xl border border-gray-100">
          <Users className="w-12 h-12 text-gray-200 mx-auto mb-3" />
          <p className="text-gray-500 font-medium">No leads found</p>
        </div>
      ) : (
        <div className="space-y-3">
          <AnimatePresence>
            {filtered.map(lead => {
              const sc = STATUS_CFG[lead.status] || STATUS_CFG.new;
              return (
                <motion.div key={lead._id} layout initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
                  className="bg-white rounded-2xl border border-gray-100 hover:border-orange-200 p-5 transition-all">
                  <div className="flex flex-col sm:flex-row sm:items-start gap-4">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-3 flex-wrap mb-2">
                        <h3 className="font-bold text-gray-900">{lead.name}</h3>
                        <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${sc.cls}`}>{sc.label}</span>
                      </div>
                      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2 text-xs text-gray-500">
                        <span className="flex items-center gap-1"><Phone className="w-3 h-3" />{lead.phone}</span>
                        <span className="flex items-center gap-1"><Mail className="w-3 h-3" />{lead.email}</span>
                        {lead.college && <span className="flex items-center gap-1"><GraduationCap className="w-3 h-3" />{lead.college}</span>}
                        {lead.city && <span className="flex items-center gap-1"><MapPin className="w-3 h-3" />{lead.city}</span>}
                        {lead.courseInterest && <span className="flex items-center gap-1 col-span-2">Course: {lead.courseInterest}</span>}
                        {lead.preferredBatch && <span className="flex items-center gap-1">Batch: {lead.preferredBatch}</span>}
                        <span className="flex items-center gap-1"><Calendar className="w-3 h-3" />
                          {new Date(lead.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: '2-digit' })}
                        </span>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      {updating === lead._id
                        ? <Loader2 className="w-4 h-4 animate-spin text-orange-500" />
                        : (
                          <select value={lead.status} onChange={e => updateStatus(lead._id, e.target.value)}
                            className="px-3 py-2 rounded-xl border border-gray-200 text-xs font-semibold focus:outline-none focus:border-orange-400 bg-white text-gray-700">
                            <option value="new">New</option>
                            <option value="contacted">Contacted</option>
                            <option value="enrolled">Enrolled</option>
                            <option value="not_interested">Not Interested</option>
                          </select>
                        )}
                    </div>
                  </div>
                </motion.div>
              );
            })}
          </AnimatePresence>
        </div>
      )}
    </div>
  );
}
