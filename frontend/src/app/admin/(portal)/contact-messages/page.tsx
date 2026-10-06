'use client';

import { useEffect, useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Search, Mail, CheckCircle, Clock, MessageSquare,
  ChevronLeft, ChevronRight, X, Phone, AlertCircle,
} from 'lucide-react';

interface ContactMsg {
  _id: string;
  name: string;
  email: string;
  phone?: string;
  subject: string;
  message: string;
  status: 'new' | 'read' | 'replied';
  ip?: string;
  createdAt: string;
}

const STATUS_CFG = {
  new:     { label: 'New',     cls: 'bg-blue-100 text-blue-700',   icon: AlertCircle },
  read:    { label: 'Read',    cls: 'bg-gray-100 text-gray-600',   icon: Clock },
  replied: { label: 'Replied', cls: 'bg-green-100 text-green-700', icon: CheckCircle },
};

function StatusBadge({ status }: { status: ContactMsg['status'] }) {
  const cfg  = STATUS_CFG[status];
  const Icon = cfg.icon;
  return (
    <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold ${cfg.cls}`}>
      <Icon className="w-3 h-3" />
      {cfg.label}
    </span>
  );
}

function MessageModal({
  msg,
  onClose,
  onStatusChange,
}: {
  msg: ContactMsg;
  onClose: () => void;
  onStatusChange: (id: string, status: ContactMsg['status']) => void;
}) {
  const [updating, setUpdating] = useState(false);

  const update = async (status: ContactMsg['status']) => {
    setUpdating(true);
    try {
      await fetch('/api/admin/contact-messages', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ id: msg._id, status }),
      });
      onStatusChange(msg._id, status);
    } finally {
      setUpdating(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 16 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 16 }}
        className="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg z-10 overflow-hidden"
        onClick={e => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold text-sm"
              style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
              {msg.name[0]?.toUpperCase()}
            </div>
            <div>
              <p className="font-bold text-gray-900 text-sm">{msg.name}</p>
              <p className="text-xs text-gray-400">{msg.email}</p>
            </div>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 p-1 rounded-lg hover:bg-gray-100 transition-all">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-6 space-y-4">
          {/* Meta */}
          <div className="flex flex-wrap items-center gap-3">
            <StatusBadge status={msg.status} />
            {msg.phone && (
              <span className="flex items-center gap-1 text-xs text-gray-500">
                <Phone className="w-3 h-3" /> {msg.phone}
              </span>
            )}
            <span className="text-xs text-gray-400">
              {new Date(msg.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
            </span>
          </div>

          {/* Subject */}
          <div className="bg-orange-50 border border-orange-100 rounded-xl px-4 py-2.5">
            <p className="text-xs font-bold text-orange-600 uppercase tracking-wider mb-0.5">Subject</p>
            <p className="text-sm font-semibold text-gray-900">{msg.subject}</p>
          </div>

          {/* Message */}
          <div className="bg-gray-50 rounded-xl px-4 py-3">
            <p className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-1.5">Message</p>
            <p className="text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">{msg.message}</p>
          </div>

          {/* Actions */}
          <div className="flex gap-2 pt-1">
            <a
              href={`mailto:${msg.email}?subject=Re: ${encodeURIComponent(msg.subject)}`}
              className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl text-sm font-bold text-white transition-all"
              style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
              onClick={() => update('replied')}
            >
              <Mail className="w-4 h-4" /> Reply via Email
            </a>
            {msg.status === 'new' && (
              <button
                onClick={() => update('read')}
                disabled={updating}
                className="px-4 py-2.5 rounded-xl text-sm font-semibold text-gray-700 border border-gray-200 hover:bg-gray-50 transition-all disabled:opacity-50"
              >
                Mark Read
              </button>
            )}
            {msg.status !== 'replied' && (
              <button
                onClick={() => update('replied')}
                disabled={updating}
                className="px-4 py-2.5 rounded-xl text-sm font-semibold text-green-700 border border-green-200 bg-green-50 hover:bg-green-100 transition-all disabled:opacity-50"
              >
                Mark Replied
              </button>
            )}
          </div>
        </div>
      </motion.div>
    </div>
  );
}

export default function AdminContactMessagesPage() {
  const [messages,  setMessages]  = useState<ContactMsg[]>([]);
  const [loading,   setLoading]   = useState(true);
  const [search,    setSearch]    = useState('');
  const [filter,    setFilter]    = useState('');
  const [page,      setPage]      = useState(1);
  const [total,     setTotal]     = useState(0);
  const [statusCounts, setStatusCounts] = useState({ new: 0, read: 0, replied: 0 });
  const [selected,  setSelected]  = useState<ContactMsg | null>(null);
  const LIMIT = 20;

  const fetchMessages = useCallback(async (showLoader = true) => {
    if (showLoader) setLoading(true);
    try {
      const params = new URLSearchParams({
        page: String(page), limit: String(LIMIT),
        ...(search.trim() && { search }),
        ...(filter        && { status: filter }),
      });
      const res  = await fetch(`/api/admin/contact-messages?${params}`, { credentials: 'include', cache: 'no-store' });
      const data = await res.json();
      setMessages(data.messages || []);
      setTotal(data.total || 0);
      setStatusCounts(data.statusCounts || { new: 0, read: 0, replied: 0 });
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  }, [page, search, filter]);

  useEffect(() => { fetchMessages(true); }, [fetchMessages]);
  useEffect(() => {
    const id = window.setInterval(() => fetchMessages(false), 15000);
    const onFocus = () => fetchMessages(false);
    window.addEventListener('focus', onFocus);
    window.addEventListener('portal-data-updated', onFocus);
    return () => {
      window.clearInterval(id);
      window.removeEventListener('focus', onFocus);
      window.removeEventListener('portal-data-updated', onFocus);
    };
  }, [fetchMessages]);
  useEffect(() => { setPage(1); }, [search, filter]);

  const handleStatusChange = (id: string, status: ContactMsg['status']) => {
    const previous = messages.find(m => m._id === id)?.status;
    setMessages(prev => prev.map(m => m._id === id ? { ...m, status } : m));
    if (previous && previous !== status) {
      setStatusCounts(prev => ({
        ...prev,
        [previous]: Math.max(0, prev[previous] - 1),
        [status]: prev[status] + 1,
      }));
    }
    window.dispatchEvent(new Event('portal-data-updated'));
    if (selected?._id === id) setSelected(prev => prev ? { ...prev, status } : null);
  };

  const pages = Math.ceil(total / LIMIT);
  const counts = statusCounts;

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Contact Messages</h1>
        <p className="text-gray-500 text-sm mt-0.5">Messages submitted via the /contact page - {total} total</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4">
        {([
          { label: 'New',     value: counts.new,     color: 'bg-blue-50 text-blue-600 border-blue-100' },
          { label: 'Read',    value: counts.read,    color: 'bg-gray-50 text-gray-600 border-gray-200' },
          { label: 'Replied', value: counts.replied, color: 'bg-green-50 text-green-600 border-green-100' },
        ] as const).map(s => (
          <div key={s.label} className={`rounded-2xl border p-4 ${s.color}`}>
            <p className="text-2xl font-extrabold">{s.value}</p>
            <p className="text-xs font-semibold mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text" placeholder="Search name, email, subject..."
            value={search} onChange={e => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 bg-white"
          />
        </div>
        <select
          value={filter} onChange={e => setFilter(e.target.value)}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700"
        >
          <option value="">All Statuses</option>
          <option value="new">New</option>
          <option value="read">Read</option>
          <option value="replied">Replied</option>
        </select>
      </div>

      {/* List */}
      {loading ? (
        <div className="space-y-3">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-gray-100 p-5 animate-pulse">
              <div className="h-4 bg-gray-200 rounded w-1/3 mb-2" />
              <div className="h-3 bg-gray-100 rounded w-2/3" />
            </div>
          ))}
        </div>
      ) : messages.length === 0 ? (
        <div className="text-center py-20 bg-white rounded-2xl border border-gray-100">
          <MessageSquare className="w-12 h-12 text-gray-200 mx-auto mb-3" />
          <p className="text-gray-500 font-medium">No messages found</p>
        </div>
      ) : (
        <div className="space-y-2">
          {messages.map((msg, i) => (
            <motion.div
              key={msg._id}
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.02 }}
              onClick={() => setSelected(msg)}
              className={`bg-white rounded-2xl border p-4 cursor-pointer hover:border-orange-200 hover:shadow-sm transition-all ${
                msg.status === 'new' ? 'border-blue-200 bg-blue-50/30' : 'border-gray-100'
              }`}
            >
              <div className="flex items-start justify-between gap-4">
                <div className="flex items-start gap-3 flex-1 min-w-0">
                  <div
                    className="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                    style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}
                  >
                    {msg.name[0]?.toUpperCase()}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap mb-0.5">
                      <p className="font-semibold text-gray-900 text-sm">{msg.name}</p>
                      <StatusBadge status={msg.status} />
                    </div>
                    <p className="text-xs text-gray-400 mb-1">{msg.email}</p>
                    <p className="text-sm font-medium text-gray-700 truncate">{msg.subject}</p>
                    <p className="text-xs text-gray-400 truncate mt-0.5">{msg.message}</p>
                  </div>
                </div>
                <p className="text-xs text-gray-400 whitespace-nowrap flex-shrink-0">
                  {new Date(msg.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short' })}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Pagination */}
      {pages > 1 && (
        <div className="flex items-center justify-between bg-white rounded-2xl border border-gray-100 px-5 py-3">
          <p className="text-xs text-gray-500">Page {page} of {pages} - {total} messages</p>
          <div className="flex items-center gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-40 transition-all">
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button onClick={() => setPage(p => Math.min(pages, p + 1))} disabled={page === pages}
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-40 transition-all">
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

      {/* Detail modal */}
      <AnimatePresence>
        {selected && (
          <MessageModal
            msg={selected}
            onClose={() => setSelected(null)}
            onStatusChange={handleStatusChange}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
