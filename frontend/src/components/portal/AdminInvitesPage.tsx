'use client';

import api from '@/lib/api';
import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Plus, Mail, Phone, Shield, Clock, CheckCircle, XCircle, Copy, ExternalLink, Trash2, AlertCircle, Search, UserPlus, Calendar, Link2, Check, RefreshCw, Key, Filter } from 'lucide-react';

/* --- Types --------------------------------------------------- */
interface Invite {
  id: string;
  email: string;
  mobileNumber: string;
  role: string;
  used: boolean;
  usedBy: string | null;
  usedAt: string | null;
  expiresAt: string;
  invitedBy: string;
  invitedByEmail: string;
  note: string;
  revokedAt: string | null;
  revokedBy: string | null;
  failedAttempts: number;
  isExpired: boolean;
  isRevoked: boolean;
  isActive: boolean;
  inviteLink: string;
  createdAt: string;
}

type FilterType = 'all' | 'active' | 'used' | 'expired' | 'revoked';
type ToastType  = 'success' | 'error' | 'info';

interface Toast {
  id: number;
  message: string;
  type: ToastType;
}

/* --- Toast Notification System ------------------------------- */
function ToastContainer({ toasts, onRemove }: { toasts: Toast[]; onRemove: (id: number) => void }) {
  return (
    <div className="fixed top-5 right-5 z-[100] flex flex-col gap-2 pointer-events-none">
      <AnimatePresence>
        {toasts.map(t => (
          <motion.div
            key={t.id}
            initial={{ opacity: 0, x: 60, scale: 0.9 }}
            animate={{ opacity: 1, x: 0, scale: 1 }}
            exit={{ opacity: 0, x: 60, scale: 0.9 }}
            transition={{ type: 'spring', stiffness: 400, damping: 30 }}
            className={`pointer-events-auto flex items-center gap-3 px-4 py-3 rounded-xl shadow-2xl text-sm font-semibold min-w-[260px] max-w-sm ${
              t.type === 'success' ? 'bg-green-500 text-white' :
              t.type === 'error'   ? 'bg-red-500 text-white' :
                                     'bg-blue-500 text-white'
            }`}
          >
            {t.type === 'success' && <CheckCircle className="w-4 h-4 flex-shrink-0" />}
            {t.type === 'error'   && <AlertCircle className="w-4 h-4 flex-shrink-0" />}
            {t.type === 'info'    && <Shield className="w-4 h-4 flex-shrink-0" />}
            <span className="flex-1">{t.message}</span>
            <button onClick={() => onRemove(t.id)} className="opacity-70 hover:opacity-100 transition-opacity ml-1">
              <XCircle className="w-4 h-4" />
            </button>
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
}

function useToast() {
  const [toasts, setToasts] = useState<Toast[]>([]);
  let counter = 0;

  const addToast = useCallback((message: string, type: ToastType = 'success', duration = 4000) => {
    const id = ++counter;
    setToasts(prev => [...prev, { id, message, type }]);
    setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), duration);
  }, []);

  const removeToast = useCallback((id: number) => {
    setToasts(prev => prev.filter(t => t.id !== id));
  }, []);

  return { toasts, addToast, removeToast };
}

/* --- Copy Button ---------------------------------------------- */
function CopyButton({ text, label = 'Copy', size = 'md' }: { text: string; label?: string; size?: 'sm' | 'md' }) {
  const [copied, setCopied] = useState(false);
  const handle = () => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };
  const base = size === 'sm'
    ? 'px-2.5 py-1.5 text-xs rounded-lg gap-1'
    : 'px-3 py-2 text-sm rounded-xl gap-1.5';
  return (
    <button onClick={handle} title="Copy to clipboard"
      className={`flex items-center font-bold transition-all duration-200 flex-shrink-0 ${base} ${
        copied ? 'bg-green-100 text-green-700 border border-green-300' : 'bg-[#ffa800] text-white hover:bg-orange-600 active:scale-95'
      }`}>
      {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
      {copied ? 'Copied!' : label}
    </button>
  );
}

/* --- Status Badge --------------------------------------------- */
function StatusBadge({ invite }: { invite: Invite }) {
  const cfg = invite.isActive
    ? { cls: 'bg-green-50 text-green-700 border-green-200',  dot: 'bg-green-500',  label: 'Active'  }
    : invite.used
    ? { cls: 'bg-purple-50 text-purple-700 border-purple-200', dot: 'bg-purple-500', label: 'Used'    }
    : invite.revokedAt
    ? { cls: 'bg-red-50 text-red-700 border-red-200',        dot: 'bg-red-500',    label: 'Revoked' }
    : { cls: 'bg-orange-50 text-orange-700 border-orange-200', dot: 'bg-orange-400', label: 'Expired' };

  return (
    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold border ${cfg.cls}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${cfg.dot}`} />
      {cfg.label}
    </span>
  );
}

/* --- Role Badge ----------------------------------------------- */
function RoleBadge({ role }: { role: string }) {
  return (
    <span className={`px-2.5 py-1 rounded-full text-xs font-bold border ${
      role === 'ADMIN'
        ? 'bg-blue-50 text-blue-700 border-blue-200'
        : 'bg-violet-50 text-violet-700 border-violet-200'
    }`}>
      {role}
    </span>
  );
}

/* --- Stat Card ------------------------------------------------ */
function StatCard({
  label, value, icon: Icon, active, onClick, color,
}: {
  label: string; value: number; icon: React.ComponentType<{ className?: string }>;
  active?: boolean; onClick?: () => void; color: string;
}) {
  return (
    <motion.button
      whileHover={{ y: -2, boxShadow: '0 8px 24px rgba(0,0,0,0.08)' }}
      whileTap={{ scale: 0.97 }}
      onClick={onClick}
      className={`w-full text-left bg-white rounded-2xl p-4 shadow-sm border-2 transition-all ${
        active ? 'border-[#ffa800] shadow-md' : 'border-gray-100 hover:border-gray-200'
      }`}
    >
      <div className="flex items-center justify-between mb-3">
        <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${color}`}>
          <Icon className="w-4.5 h-4.5 text-white" />
        </div>
        {active && <div className="w-2 h-2 rounded-full bg-[#ffa800]" />}
      </div>
      <div className="text-2xl font-extrabold text-gray-900 tabular-nums">{value}</div>
      <div className="text-xs text-gray-500 font-medium mt-0.5">{label}</div>
    </motion.button>
  );
}

/* --- Revoke Confirm Modal ------------------------------------- */
function RevokeModal({
  invite,
  onConfirm,
  onCancel,
  loading,
}: {
  invite: Invite;
  onConfirm: () => void;
  onCancel: () => void;
  loading: boolean;
}) {
  return (
    <motion.div
      initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50"
      onClick={onCancel}
    >
      <motion.div
        initial={{ scale: 0.9, y: 16 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.9, y: 16 }}
        onClick={e => e.stopPropagation()}
        className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-7"
      >
        <div className="flex items-start gap-4 mb-5">
          <div className="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center flex-shrink-0">
            <Trash2 className="w-6 h-6 text-red-600" />
          </div>
          <div>
            <h3 className="text-lg font-bold text-gray-900 mb-1">Revoke Invite?</h3>
            <p className="text-sm text-gray-600">
              This will permanently revoke the invite for <strong>{invite.email}</strong>.
              The invite link will stop working immediately.
            </p>
          </div>
        </div>

        <div className="bg-orange-50 border border-orange-200 rounded-xl p-3 mb-5 text-xs text-orange-800">
          ? This action cannot be undone. You will need to generate a new invite if needed.
        </div>

        <div className="flex gap-3">
          <button onClick={onCancel} disabled={loading}
            className="flex-1 py-2.5 border-2 border-gray-200 text-gray-700 font-semibold rounded-xl hover:bg-gray-50 transition-colors text-sm disabled:opacity-50">
            Cancel
          </button>
          <button onClick={onConfirm} disabled={loading}
            className="flex-1 py-2.5 bg-red-500 hover:bg-red-600 text-white font-bold rounded-xl transition-colors text-sm flex items-center justify-center gap-2 disabled:opacity-50">
            {loading
              ? <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /> Revoking...</>
              : <><Trash2 className="w-4 h-4" /> Revoke Invite</>}
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}

/* --- Invite Card ---------------------------------------------- */
function InviteCard({
  invite,
  onRevoke,
  isSuperAdmin,
}: {
  invite: Invite;
  onRevoke: (invite: Invite) => void;
  isSuperAdmin: boolean;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow"
    >
      {/* Header row */}
      <div className="flex items-center justify-between px-5 py-4 border-b border-gray-50 flex-wrap gap-3">
        <div className="flex items-center gap-3 flex-wrap min-w-0">
          <div className="flex items-center gap-2 min-w-0">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#ffa800] to-orange-600 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
              {invite.email[0].toUpperCase()}
            </div>
            <span className="font-bold text-gray-900 truncate">{invite.email}</span>
          </div>
          <StatusBadge invite={invite} />
          <RoleBadge role={invite.role} />
        </div>
        {isSuperAdmin && invite.isActive && (
          <button
            onClick={() => onRevoke(invite)}
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-bold text-red-500 hover:bg-red-50 rounded-lg transition-colors border border-transparent hover:border-red-200 flex-shrink-0"
          >
            <Trash2 className="w-3.5 h-3.5" />
            Revoke
          </button>
        )}
      </div>

      {/* Body */}
      <div className="px-5 py-4 space-y-3">
        {/* Meta */}
        <div className="flex flex-wrap gap-4 text-sm text-gray-500">
          <div className="flex items-center gap-1.5">
            <Phone className="w-3.5 h-3.5 text-gray-400" />
            <span className="font-mono text-xs">{invite.mobileNumber}</span>
          </div>
          <div className="flex items-center gap-1.5">
            <Calendar className="w-3.5 h-3.5 text-gray-400" />
            <span className="text-xs">
              Expires <strong className="text-gray-700">
                {new Date(invite.expiresAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
              </strong>
            </span>
          </div>
          {invite.note && (
            <div className="flex items-center gap-1 text-xs italic text-gray-400">
              <span>"{invite.note}"</span>
            </div>
          )}
        </div>

        {/* Active invite link */}
        {invite.isActive && (
          <div className="rounded-xl border-2 border-[#ffa800]/30 bg-gradient-to-r from-orange-50 to-amber-50 p-3.5">
            <div className="flex items-center gap-2 mb-2">
              <Link2 className="w-3.5 h-3.5 text-[#ffa800]" />
              <span className="text-xs font-bold text-[#ffa800] uppercase tracking-wide">Invite Link</span>
              <span className="text-xs text-gray-400 ml-auto hidden sm:block">Share with invited user</span>
            </div>
            <div className="flex items-center gap-2">
              <code className="flex-1 px-3 py-2 bg-white border border-orange-200 rounded-lg text-xs font-mono text-gray-700 truncate select-all min-w-0">
                {invite.inviteLink}
              </code>
              <CopyButton text={invite.inviteLink} label="Copy" size="sm" />
              <a href={invite.inviteLink} target="_blank" rel="noopener noreferrer"
                className="p-2 bg-white border border-gray-200 text-gray-500 rounded-lg hover:bg-gray-50 transition-colors flex-shrink-0">
                <ExternalLink className="w-3.5 h-3.5" />
              </a>
            </div>
          </div>
        )}

        {/* Used info */}
        {invite.used && invite.usedAt && (
          <div className="flex items-center gap-2 p-3 bg-purple-50 border border-purple-100 rounded-xl text-xs text-purple-700">
            <CheckCircle className="w-3.5 h-3.5 flex-shrink-0" />
            <span>Used on <strong>{new Date(invite.usedAt).toLocaleString('en-IN')}</strong></span>
          </div>
        )}

        {/* Revoked info */}
        {invite.revokedAt && (
          <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-100 rounded-xl text-xs text-red-700">
            <XCircle className="w-3.5 h-3.5 flex-shrink-0" />
            <span>Revoked on <strong>{new Date(invite.revokedAt).toLocaleString('en-IN')}</strong></span>
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="px-5 py-2.5 bg-gray-50/80 border-t border-gray-100 flex items-center justify-between">
        <span className="text-xs text-gray-400">
          By <strong className="text-gray-500">{invite.invitedByEmail}</strong>
          {' - '}
          {new Date(invite.createdAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
        </span>
        {invite.failedAttempts > 0 && (
          <span className="text-xs text-orange-600 font-semibold flex items-center gap-1">
            <AlertCircle className="w-3 h-3" />
            {invite.failedAttempts} failed
          </span>
        )}
      </div>
    </motion.div>
  );
}

/* --- Create Invite Modal -------------------------------------- */
function CreateInviteModal({
  onClose,
  onCreated,
}: {
  onClose: () => void;
  onCreated: (invite: any) => void;
}) {
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState<string | null>(null);
  const [created, setCreated] = useState<any>(null);
  const [form, setForm] = useState({
    email: '', mobileNumber: '', role: 'ADMIN' as 'ADMIN' | 'ORGANIZATION',
    note: '', expiresInDays: 1,
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setForm(p => ({ ...p, [name]: name === 'expiresInDays' ? (parseInt(value) || 1) : value }));
    setError(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const res = await api.post('/api/admin/invites', form);
      setCreated(res.data.invite);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Failed to create invite. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  /* -- Success screen -- */
  if (created) {
    return (
      <motion.div
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
        className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50"
      >
        <motion.div
          initial={{ scale: 0.9, y: 20 }} animate={{ scale: 1, y: 0 }}
          className="bg-white rounded-2xl shadow-2xl max-w-xl w-full p-7 max-h-[90vh] overflow-y-auto"
        >
          {/* Success header */}
          <div className="text-center mb-6">
            <motion.div
              initial={{ scale: 0 }} animate={{ scale: 1 }}
              transition={{ type: 'spring', stiffness: 300, delay: 0.1 }}
              className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4"
            >
              <CheckCircle className="w-8 h-8 text-green-600" />
            </motion.div>
            <h2 className="text-2xl font-extrabold text-gray-900 mb-1">Invite Created! </h2>
            <p className="text-gray-500 text-sm">
              Copy the link below and send it to <strong className="text-gray-700">{created.email}</strong>
            </p>
          </div>

          {/* Big invite link box */}
          <div className="rounded-2xl p-[2px] mb-5 shadow-lg" style={{ background: 'linear-gradient(135deg,#ffa800,#ff6b00)' }}>
            <div className="bg-white rounded-[14px] p-5">
              <div className="flex items-center gap-2 mb-3">
                <Link2 className="w-5 h-5 text-[#ffa800]" />
                <span className="font-bold text-gray-900 text-sm uppercase tracking-wide">
                  Invite Link - Share This!
                </span>
              </div>
              <code className="block w-full px-4 py-3 bg-gray-50 border-2 border-gray-200 rounded-xl text-xs font-mono text-gray-800 break-all select-all mb-3">
                {created.inviteLink}
              </code>
              <div className="flex gap-2 flex-wrap">
                <CopyButton text={created.inviteLink} label="Copy Invite Link" />
                <a href={created.inviteLink} target="_blank" rel="noopener noreferrer"
                  className="flex items-center gap-1.5 px-3 py-2 bg-gray-100 text-gray-700 rounded-xl text-sm font-semibold hover:bg-gray-200 transition-colors">
                  <ExternalLink className="w-4 h-4" /> Open
                </a>
              </div>
            </div>
          </div>

          {/* Details */}
          <div className="grid grid-cols-2 gap-3 mb-6">
            {[
              { label: 'Email',   value: created.email },
              { label: 'Mobile',  value: created.mobileNumber },
              { label: 'Role',    value: created.role },
              { label: 'Expires', value: new Date(created.expiresAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) },
            ].map(({ label, value }) => (
              <div key={label} className="bg-gray-50 rounded-xl p-3">
                <p className="text-xs text-gray-400 font-medium mb-0.5">{label}</p>
                <p className="font-bold text-gray-900 text-sm truncate">{value}</p>
              </div>
            ))}
          </div>

          <button onClick={() => onCreated(created)}
            className="w-full py-3 rounded-xl font-bold text-white text-sm"
            style={{ background: 'linear-gradient(135deg,#ffa800,#ff6b00)' }}>
            Done
          </button>
        </motion.div>
      </motion.div>
    );
  }

  /* -- Create form -- */
  return (
    <motion.div
      initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50"
      onClick={onClose}
    >
      <motion.div
        initial={{ scale: 0.9, y: 20 }} animate={{ scale: 1, y: 0 }}
        onClick={e => e.stopPropagation()}
        className="bg-white rounded-2xl shadow-2xl max-w-lg w-full p-7 max-h-[90vh] overflow-y-auto"
      >
        <div className="flex items-center gap-3 mb-6">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
            style={{ background: 'linear-gradient(135deg,#ffa800,#ff6b00)' }}>
            <Key className="w-5 h-5 text-white" />
          </div>
          <div>
            <h2 className="text-xl font-extrabold text-gray-900">Generate Invite</h2>
            <p className="text-xs text-gray-500">Create a secure one-time invite link</p>
          </div>
        </div>

        {error && (
          <motion.div
            initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }}
            className="mb-4 p-3.5 rounded-xl bg-red-50 border border-red-200 flex items-start gap-2.5"
          >
            <AlertCircle className="w-4 h-4 text-red-500 flex-shrink-0 mt-0.5" />
            <p className="text-sm text-red-700">{error}</p>
          </motion.div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1.5">
              Email Address <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input type="email" name="email" value={form.email} onChange={handleChange} required
                placeholder="admin@example.com"
                className="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none transition-colors" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1.5">
              Mobile Number <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <Phone className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input type="tel" name="mobileNumber" value={form.mobileNumber} onChange={handleChange} required
                placeholder="+91 9876543210"
                className="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none transition-colors" />
            </div>
            <p className="text-xs text-gray-400 mt-1">Invited user must enter this exact number to sign up.</p>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-1.5">
                Role <span className="text-red-500">*</span>
              </label>
              <select name="role" value={form.role} onChange={handleChange} required
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none transition-colors bg-white">
                <option value="ADMIN">Admin</option>
                <option value="ORGANIZATION">Organization</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-1.5">
                Expires In (Days) <span className="text-red-500">*</span>
              </label>
              <input type="number" name="expiresInDays" value={form.expiresInDays} onChange={handleChange}
                min="1" max="30" required
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none transition-colors" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1.5">Note (Optional)</label>
            <textarea name="note" value={form.note} onChange={handleChange} rows={2} maxLength={200}
              placeholder="e.g. For Acme Corp HR team"
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none transition-colors resize-none" />
          </div>

          <div className="flex gap-3 pt-2">
            <button type="button" onClick={onClose}
              className="flex-1 py-3 border-2 border-gray-200 text-gray-700 font-semibold rounded-xl hover:bg-gray-50 transition-colors text-sm">
              Cancel
            </button>
            <button type="submit" disabled={loading}
              className="flex-1 py-3 font-bold text-white rounded-xl text-sm flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
              style={{ background: 'linear-gradient(135deg,#ffa800,#ff6b00)' }}>
              {loading
                ? <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /> Generating...</>
                : <><Plus className="w-4 h-4" /> Generate Invite</>}
            </button>
          </div>
        </form>
      </motion.div>
    </motion.div>
  );
}

/* ─── Main Page Component ────────────────────────────────────── */
export default function AdminInvitesPage() {
  const [user, setUser]               = useState<any>(null);
  const [invites, setInvites]         = useState<Invite[]>([]);
  const [loading, setLoading]         = useState(true);
  const [refreshing, setRefreshing]   = useState(false);
  const [filter, setFilter]           = useState<FilterType>('all');
  const [search, setSearch]           = useState('');
  const [showCreate, setShowCreate]   = useState(false);
  const [revokeTarget, setRevokeTarget] = useState<Invite | null>(null);
  const [revokeLoading, setRevokeLoading] = useState(false);
  const { toasts, addToast, removeToast } = useToast();

  // Fetch current user to determine if SUPERADMIN
  useEffect(() => {
    fetch('/api/admin/me', { credentials: 'include' })
      .then(r => r.json())
      .then(data => { if (data?.user) setUser(data.user); })
      .catch(() => {});
  }, []);

  const isSuperAdmin = user?.role === 'SUPERADMIN';

  // Fetch invites
  const fetchInvites = useCallback(async (showSpinner = true) => {
    if (showSpinner) setLoading(true); else setRefreshing(true);
    try {
      const res = await api.get(`/api/admin/invites?filter=${filter}`);
      setInvites(res.data.invites || []);
    } catch {
      addToast('Failed to load invites', 'error');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, [filter]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => { fetchInvites(); }, [fetchInvites]);

  // Revoke handler
  const handleRevoke = async () => {
    if (!revokeTarget) return;
    setRevokeLoading(true);
    try {
      await api.post(`/api/admin/invites/${revokeTarget.id}/revoke`);
      addToast('Invite revoked successfully', 'success');
      setRevokeTarget(null);
      fetchInvites(false);
    } catch (err: any) {
      addToast(err.response?.data?.error || 'Failed to revoke invite', 'error');
    } finally {
      setRevokeLoading(false);
    }
  };

  // Stats
  const stats = {
    all:     invites.length,
    active:  invites.filter(i => i.isActive).length,
    used:    invites.filter(i => i.used).length,
    expired: invites.filter(i => i.isExpired && !i.used && !i.isRevoked).length,
    revoked: invites.filter(i => i.isRevoked).length,
  };

  // Filter + search
  const filtered = invites.filter(inv => {
    if (!search.trim()) return true;
    const q = search.toLowerCase();
    return (
      inv.email.toLowerCase().includes(q) ||
      inv.role.toLowerCase().includes(q) ||
      inv.note?.toLowerCase().includes(q) ||
      inv.invitedByEmail.toLowerCase().includes(q)
    );
  });

  return (
    <div className="min-h-screen bg-gray-50/50">
      <ToastContainer toasts={toasts} onRemove={removeToast} />

      {/* Revoke modal */}
      <AnimatePresence>
        {revokeTarget && (
          <RevokeModal
            invite={revokeTarget}
            onConfirm={handleRevoke}
            onCancel={() => setRevokeTarget(null)}
            loading={revokeLoading}
          />
        )}
      </AnimatePresence>

      {/* Create modal */}
      <AnimatePresence>
        {showCreate && (
          <CreateInviteModal
            onClose={() => setShowCreate(false)}
            onCreated={() => {
              setShowCreate(false);
              addToast('Invite created successfully!', 'success');
              fetchInvites(false);
            }}
          />
        )}
      </AnimatePresence>

      <div className="max-w-5xl mx-auto px-4 sm:px-6 py-8 space-y-6">

        {/* Header */}
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div>
            <h1 className="text-2xl font-extrabold text-gray-900 flex items-center gap-2">
              <UserPlus className="w-6 h-6 text-[#ffa800]" />
              Admin Invites
            </h1>
            <p className="text-sm text-gray-500 mt-0.5">
              Manage secure invite links for admin and organisation accounts
            </p>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => fetchInvites(false)}
              disabled={refreshing}
              title="Refresh"
              className="p-2.5 rounded-xl border-2 border-gray-200 text-gray-500 hover:bg-gray-100 transition-colors disabled:opacity-50"
            >
              <RefreshCw className={`w-4 h-4 ${refreshing ? 'animate-spin' : ''}`} />
            </button>
            {isSuperAdmin && (
              <button
                onClick={() => setShowCreate(true)}
                className="flex items-center gap-2 px-4 py-2.5 rounded-xl font-bold text-white text-sm shadow-md hover:shadow-lg transition-all active:scale-95"
                style={{ background: 'linear-gradient(135deg,#ffa800,#ff6b00)' }}
              >
                <Plus className="w-4 h-4" />
                Generate Invite
              </button>
            )}
          </div>
        </div>

        {/* SUPERADMIN notice */}
        {!isSuperAdmin && (
          <div className="flex items-start gap-3 p-4 bg-blue-50 border border-blue-200 rounded-2xl text-sm text-blue-800">
            <Shield className="w-4 h-4 flex-shrink-0 mt-0.5" />
            <span>You can view invites, but only a <strong>SuperAdmin</strong> can create or revoke them.</span>
          </div>
        )}

        {/* Stats row */}
        <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
          {(
            [
              { key: 'all',     label: 'Total',   icon: Key,           color: 'bg-gray-500'   },
              { key: 'active',  label: 'Active',  icon: CheckCircle,   color: 'bg-green-500'  },
              { key: 'used',    label: 'Used',    icon: UserPlus,      color: 'bg-purple-500' },
              { key: 'expired', label: 'Expired', icon: Clock,         color: 'bg-orange-400' },
              { key: 'revoked', label: 'Revoked', icon: XCircle,       color: 'bg-red-500'    },
            ] as const
          ).map(({ key, label, icon, color }) => (
            <StatCard
              key={key}
              label={label}
              value={stats[key]}
              icon={icon}
              color={color}
              active={filter === key}
              onClick={() => setFilter(key)}
            />
          ))}
        </div>

        {/* Search + filter bar */}
        <div className="flex gap-3 flex-wrap">
          <div className="relative flex-1 min-w-[220px]">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Search by email, role, note..."
              className="w-full pl-10 pr-4 py-2.5 border-2 border-gray-200 rounded-xl text-sm focus:border-[#ffa800] focus:outline-none transition-colors bg-white"
            />
          </div>
          <div className="flex items-center gap-1.5">
            <Filter className="w-4 h-4 text-gray-400" />
            {(['all', 'active', 'used', 'expired', 'revoked'] as FilterType[]).map(f => (
              <button
                key={f}
                onClick={() => setFilter(f)}
                className={`px-3 py-2 rounded-xl text-xs font-bold capitalize transition-colors ${
                  filter === f
                    ? 'bg-[#ffa800] text-white'
                    : 'bg-white border-2 border-gray-200 text-gray-600 hover:border-gray-300'
                }`}
              >
                {f}
              </button>
            ))}
          </div>
        </div>

        {/* Content */}
        {loading ? (
          <div className="flex flex-col items-center justify-center py-20 gap-3 text-gray-400">
            <div className="w-10 h-10 border-4 border-[#ffa800] border-t-transparent rounded-full animate-spin" />
            <p className="text-sm font-medium">Loading invites…</p>
          </div>
        ) : filtered.length === 0 ? (
          <motion.div
            initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
            className="flex flex-col items-center justify-center py-20 text-gray-400 gap-4"
          >
            <div className="w-16 h-16 rounded-2xl bg-gray-100 flex items-center justify-center">
              <Mail className="w-7 h-7 text-gray-300" />
            </div>
            <div className="text-center">
              <p className="font-bold text-gray-600 mb-1">No invites found</p>
              <p className="text-sm">
                {search ? 'Try a different search term.' : filter !== 'all' ? `No ${filter} invites.` : 'No invites have been created yet.'}
              </p>
            </div>
            {isSuperAdmin && filter === 'all' && !search && (
              <button
                onClick={() => setShowCreate(true)}
                className="flex items-center gap-2 px-5 py-2.5 rounded-xl font-bold text-white text-sm mt-2"
                style={{ background: 'linear-gradient(135deg,#ffa800,#ff6b00)' }}
              >
                <Plus className="w-4 h-4" /> Create First Invite
              </button>
            )}
          </motion.div>
        ) : (
          <div className="space-y-3">
            {filtered.map(invite => (
              <InviteCard
                key={invite.id}
                invite={invite}
                onRevoke={setRevokeTarget}
                isSuperAdmin={isSuperAdmin}
              />
            ))}
            <p className="text-xs text-gray-400 text-center pt-2">
              Showing {filtered.length} of {invites.length} invite{invites.length !== 1 ? 's' : ''}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
