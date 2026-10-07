'use client';

import api from '@/lib/api';
import { useEffect, useState, useCallback, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Award, Search, ChevronLeft, ChevronRight,
  CheckCircle, Clock, Download, Mail, Plus, X,
  Loader2, AlertCircle, ChevronDown, Pencil, Trash2,
  FileText, ImageIcon, UploadCloud, CheckCircle2,
} from 'lucide-react';

// ── Types ─────────────────────────────────────────────────────
interface CertFile { name: string; url: string; }

interface Certificate {
  id: string;
  certificateId: string;
  studentName: string;
  studentEmail: string;
  studentPhone: string;
  courseName: string;
  courseSlug: string;
  certificateType: string;
  certificateTypes: string[];
  status: string;
  emailSent: boolean;
  issuedAt: string;
  downloadUrl: string;
  certificateUrl: string;
  certificateFiles: CertFile[];
}

// ── Preset cert types ─────────────────────────────────────────
const PRESET_TYPES = [
  { value: 'course_completion',     label: 'Course Completion' },
  { value: 'internship_completion', label: 'Internship Completion' },
  { value: 'project_completion',    label: 'Project Completion' },
  { value: 'best_performance',      label: 'Best Performance' },
  { value: 'other',                 label: 'Other…' },
];

interface FormState {
  studentName: string; studentEmail: string;
  courseName: string;  courseSlug: string;
  certificateTypes: string[]; otherType: string;
  issuedAt: string; status: string;
}

const EMPTY_FORM: FormState = {
  studentName: '', studentEmail: '', courseName: '', courseSlug: '',
  certificateTypes: [], otherType: '',
  issuedAt: new Date().toISOString().slice(0, 10), status: 'pending',
};

function prettyType(val: string) {
  const found = PRESET_TYPES.find(t => t.value === val);
  return found ? found.label : val.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
}
function toDateInput(iso: string) {
  try { return new Date(iso).toISOString().slice(0, 10); } catch { return iso; }
}

// ── Status badge ──────────────────────────────────────────────
function StatusBadge({ status }: { status: string }) {
  return status === 'ready' ? (
    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-700">
      <CheckCircle className="w-3 h-3" /> Ready
    </span>
  ) : (
    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-700">
      <Clock className="w-3 h-3" /> Pending
    </span>
  );
}

// ── Cert Type Picker ──────────────────────────────────────────
function CertTypePicker({ selected, otherType, onChange, onOtherChange }: {
  selected: string[]; otherType: string;
  onChange: (v: string[]) => void; onOtherChange: (v: string) => void;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const h = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener('mousedown', h);
    return () => document.removeEventListener('mousedown', h);
  }, []);

  const toggle = (v: string) => {
    if (selected.includes(v)) { onChange(selected.filter(x => x !== v)); if (v === 'other') onOtherChange(''); }
    else onChange([...selected, v]);
  };

  const label = () => {
    if (!selected.length) return 'Select type(s)…';
    const labels = selected.map(v => v === 'other' && otherType ? otherType : prettyType(v));
    return labels.length <= 2 ? labels.join(', ') : `${labels[0]}, ${labels[1]} +${labels.length - 2} more`;
  };

  return (
    <div ref={ref} className="relative">
      <button type="button" onClick={() => setOpen(o => !o)}
        className={`w-full flex items-center justify-between px-3 py-2 rounded-xl border text-sm bg-white text-left transition-all
          ${open ? 'border-[#ffa800] ring-2 ring-[#ffa800]/10' : 'border-gray-200 hover:border-gray-300'}`}>
        <span className={selected.length ? 'text-gray-800' : 'text-gray-400'}>{label()}</span>
        <ChevronDown className={`w-4 h-4 text-gray-400 shrink-0 transition-transform ${open ? 'rotate-180' : ''}`} />
      </button>
      <AnimatePresence>
        {open && (
          <motion.div initial={{ opacity: 0, y: -6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -6 }}
            transition={{ duration: 0.15 }}
            className="absolute z-50 top-full mt-1.5 left-0 right-0 bg-white border border-gray-200 rounded-xl shadow-lg overflow-hidden">
            {PRESET_TYPES.map(t => (
              <label key={t.value} className="flex items-center gap-3 px-4 py-2.5 cursor-pointer hover:bg-orange-50/60 transition-colors">
                <input type="checkbox" checked={selected.includes(t.value)} onChange={() => toggle(t.value)}
                  className="w-4 h-4 rounded border-gray-300 accent-[#ffa800]" />
                <span className={`text-sm ${t.value === 'other' ? 'text-[#ffa800] font-medium' : 'text-gray-700'}`}>{t.label}</span>
              </label>
            ))}
            <AnimatePresence>
              {selected.includes('other') && (
                <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }} transition={{ duration: 0.2 }}
                  className="overflow-hidden border-t border-gray-100">
                  <div className="px-4 py-3 bg-orange-50/40">
                    <label className="block text-xs font-medium text-gray-500 mb-1.5">Enter custom type name</label>
                    <input type="text" autoFocus placeholder="e.g. Excellence Award" value={otherType}
                      onChange={e => onOtherChange(e.target.value)}
                      className="w-full px-3 py-2 rounded-lg border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white" />
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

// ── File Upload Zone ──────────────────────────────────────────
interface UploadedFile extends CertFile { uploading?: boolean; error?: string; localId: string; }

function FileUploadZone({ files, setFiles }: {
  files: UploadedFile[];
  setFiles: React.Dispatch<React.SetStateAction<UploadedFile[]>>;
}) {
  const inputRef   = useRef<HTMLInputElement>(null);
  const [dragging, setDragging] = useState(false);

  const uploadFile = async (file: File) => {
    const localId = `${Date.now()}-${Math.random()}`;
    const entry: UploadedFile = {
      localId,
      name:      file.name.replace(/\.[^/.]+$/, ''),
      url:       '',
      uploading: true,
    };
    setFiles(prev => [...prev, entry]);

    try {
      const fd = new FormData();
      fd.append('file', file);
      fd.append('name', entry.name);

      const res  = await fetch('/api/admin/certificates/upload-file', { method: 'POST', body: fd, credentials: 'include' });
      const data = await res.json();

      if (!res.ok) {
        setFiles(prev => prev.map(f => f.localId === localId ? { ...f, uploading: false, error: data.error || 'Upload failed' } : f));
      } else {
        setFiles(prev => prev.map(f => f.localId === localId ? { ...f, uploading: false, url: data.url, name: data.name || entry.name } : f));
      }
    } catch {
      setFiles(prev => prev.map(f => f.localId === localId ? { ...f, uploading: false, error: 'Network error' } : f));
    }
  };

  const handleFiles = (picked: FileList | null) => {
    if (!picked) return;
    Array.from(picked).forEach(f => {
      const ok = ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'].includes(f.type);
      if (ok) uploadFile(f);
    });
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault(); setDragging(false);
    handleFiles(e.dataTransfer.files);
  };

  const removeFile = (localId: string) => setFiles(prev => prev.filter(f => f.localId !== localId));

  const updateName = (localId: string, name: string) =>
    setFiles(prev => prev.map(f => f.localId === localId ? { ...f, name } : f));

  return (
    <div className="space-y-3">
      <label className="block text-xs font-medium text-gray-600">
        Certificate Files <span className="text-gray-400 font-normal">(PDF or image, up to 20 MB each)</span>
      </label>

      {/* Drop zone */}
      <div
        onDragOver={e => { e.preventDefault(); setDragging(true); }}
        onDragLeave={() => setDragging(false)}
        onDrop={handleDrop}
        onClick={() => inputRef.current?.click()}
        className={`flex flex-col items-center justify-center gap-2 px-4 py-6 rounded-xl border-2 border-dashed cursor-pointer transition-all
          ${dragging ? 'border-[#ffa800] bg-orange-50' : 'border-gray-200 hover:border-[#ffa800]/50 hover:bg-gray-50'}`}
      >
        <UploadCloud className={`w-7 h-7 ${dragging ? 'text-[#ffa800]' : 'text-gray-300'}`} />
        <div className="text-center">
          <p className="text-sm font-medium text-gray-600">Drag & drop files here, or <span className="text-[#ffa800]">browse</span></p>
          <p className="text-xs text-gray-400 mt-0.5">PDF, JPG, PNG, WEBP — multiple files allowed</p>
        </div>
        <input ref={inputRef} type="file" accept=".pdf,image/jpeg,image/png,image/webp"
          multiple className="hidden" onChange={e => handleFiles(e.target.files)} />
      </div>

      {/* Uploaded file list */}
      {files.length > 0 && (
        <div className="space-y-3">
          {files.map((f, idx) => (
            <div key={f.localId}
              className={`rounded-xl border overflow-hidden transition-colors
                ${f.error ? 'border-red-200 bg-red-50' : f.uploading ? 'border-gray-200 bg-gray-50' : 'border-[#ffa800]/30 bg-[#fffbf2]'}`}>

              {/* Top row — file info + remove */}
              <div className="flex items-center gap-3 px-3 py-2.5">
                {/* Icon */}
                <div className={`shrink-0 w-8 h-8 rounded-lg flex items-center justify-center
                  ${f.error ? 'bg-red-100' : f.uploading ? 'bg-gray-100' : 'bg-[#ffa800]/10'}`}>
                  {f.uploading
                    ? <Loader2 className="w-4 h-4 animate-spin text-gray-400" />
                    : f.error
                    ? <AlertCircle className="w-4 h-4 text-red-500" />
                    : f.url?.includes('.pdf') || f.name?.toLowerCase().includes('pdf')
                      ? <FileText className="w-4 h-4 text-[#ffa800]" />
                      : <ImageIcon className="w-4 h-4 text-[#ffa800]" />}
                </div>

                {/* Original filename */}
                <div className="flex-1 min-w-0">
                  {f.uploading
                    ? <p className="text-xs text-gray-500 truncate">Uploading…</p>
                    : f.error
                    ? <p className="text-xs text-red-600 truncate">{f.error}</p>
                    : <p className="text-xs text-gray-500 truncate font-mono">
                        {f.url.split('/').pop()?.slice(0, 40) || `File ${idx + 1}`}
                      </p>
                  }
                </div>

                {/* Status + remove */}
                <div className="flex items-center gap-1.5 shrink-0">
                  {!f.uploading && !f.error && f.url && (
                    <CheckCircle2 className="w-3.5 h-3.5 text-green-500" />
                  )}
                  <button type="button" onClick={() => removeFile(f.localId)}
                    className="p-1 rounded-lg text-gray-400 hover:text-red-500 hover:bg-red-50 transition-all">
                    <X className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>

              {/* Name field — always visible after upload success */}
              {!f.uploading && !f.error && f.url && (
                <div className="px-3 pb-3">
                  <label className="block text-[10px] font-semibold text-[#ffa800] uppercase tracking-wider mb-1">
                    Display Name for Student <span className="text-red-400">*</span>
                  </label>
                  <input
                    type="text"
                    value={f.name}
                    onChange={e => updateName(f.localId, e.target.value)}
                    placeholder="e.g. Course Completion Certificate, Internship Certificate…"
                    className="w-full px-3 py-2 rounded-lg border border-[#ffa800]/30 bg-white text-sm text-gray-800 placeholder-gray-300 focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 font-medium"
                  />
                  <p className="text-[10px] text-gray-400 mt-1">This name is shown to the student on the verify page</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ── Shared CertForm ───────────────────────────────────────────
function CertForm({ form, setForm, files, setFiles, error, saving, submitLabel, onSubmit, onCancel }: {
  form: FormState; setForm: React.Dispatch<React.SetStateAction<FormState>>;
  files: UploadedFile[]; setFiles: React.Dispatch<React.SetStateAction<UploadedFile[]>>;
  error: string; saving: boolean; submitLabel: React.ReactNode;
  onSubmit: (e: React.FormEvent) => void; onCancel: () => void;
}) {
  const handleCourseName = (v: string) => {
    const slug = v.toLowerCase().trim().replace(/[^a-z0-9\s-]/g,'').replace(/\s+/g,'-').replace(/-+/g,'-');
    setForm(f => ({ ...f, courseName: v, courseSlug: slug }));
  };
  const set = (field: string, value: string) => setForm(f => ({ ...f, [field]: value }));

  return (
    <form onSubmit={onSubmit} className="px-6 py-5 space-y-4 max-h-[80vh] overflow-y-auto">
      {/* Name */}
      <div>
        <label className="block text-xs font-medium text-gray-600 mb-1">Student Name <span className="text-red-500">*</span></label>
        <input type="text" required placeholder="e.g. Rahul Sharma" value={form.studentName}
          onChange={e => set('studentName', e.target.value)}
          className="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10" />
      </div>

      {/* Email */}
      <div>
        <label className="block text-xs font-medium text-gray-600 mb-1">Student Email <span className="text-red-500">*</span></label>
        <input type="email" required placeholder="student@email.com" value={form.studentEmail}
          onChange={e => set('studentEmail', e.target.value)}
          className="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10" />
      </div>

      {/* Course Name + Slug */}
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-xs font-medium text-gray-600 mb-1">Course Name <span className="text-red-500">*</span></label>
          <input type="text" required placeholder="e.g. Full Stack Dev" value={form.courseName}
            onChange={e => handleCourseName(e.target.value)}
            className="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10" />
        </div>
        <div>
          <label className="block text-xs font-medium text-gray-600 mb-1">Course Slug <span className="text-red-500">*</span></label>
          <input type="text" required placeholder="full-stack-dev" value={form.courseSlug}
            onChange={e => set('courseSlug', e.target.value)}
            className="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 font-mono" />
        </div>
      </div>

      {/* Certificate Type */}
      <div>
        <label className="block text-xs font-medium text-gray-600 mb-1">
          Certificate Type <span className="text-red-500">*</span>
          {form.certificateTypes.length > 0 && (
            <span className="ml-2 px-1.5 py-0.5 bg-[#ffa800]/10 text-[#ffa800] rounded text-[10px] font-semibold">
              {form.certificateTypes.length} selected
            </span>
          )}
        </label>
        <CertTypePicker
          selected={form.certificateTypes} otherType={form.otherType}
          onChange={v => setForm(f => ({ ...f, certificateTypes: v }))}
          onOtherChange={v => setForm(f => ({ ...f, otherType: v }))} />
        {form.certificateTypes.length > 0 && (
          <div className="flex flex-wrap gap-1.5 mt-2">
            {form.certificateTypes.map(v => (
              <span key={v} className="inline-flex items-center gap-1 px-2 py-0.5 bg-[#ffa800]/10 text-[#ffa800] rounded-full text-xs font-medium">
                {v === 'other' && form.otherType ? form.otherType : prettyType(v)}
                <button type="button" onClick={() => setForm(f => ({
                  ...f, certificateTypes: f.certificateTypes.filter(t => t !== v),
                  otherType: v === 'other' ? '' : f.otherType,
                }))} className="hover:text-red-500 transition-colors">
                  <X className="w-2.5 h-2.5" />
                </button>
              </span>
            ))}
          </div>
        )}
      </div>

      {/* Issued Date + Status */}
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-xs font-medium text-gray-600 mb-1">Issued Date</label>
          <input type="date" value={form.issuedAt} onChange={e => set('issuedAt', e.target.value)}
            className="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white" />
        </div>
        <div>
          <label className="block text-xs font-medium text-gray-600 mb-1">Status</label>
          <select value={form.status} onChange={e => set('status', e.target.value)}
            className="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700">
            <option value="pending">Pending</option>
            <option value="ready">Ready</option>
          </select>
        </div>
      </div>

      {/* ── File Upload ── */}
      <div className="pt-1 border-t border-gray-100">
        <FileUploadZone files={files} setFiles={setFiles} />
      </div>

      {/* Error */}
      {error && (
        <div className="flex items-center gap-2 px-3 py-2.5 rounded-xl bg-red-50 border border-red-100 text-sm text-red-600">
          <AlertCircle className="w-4 h-4 shrink-0" /> {error}
        </div>
      )}

      {/* Actions */}
      <div className="flex items-center justify-end gap-3 pt-1">
        <button type="button" onClick={onCancel}
          className="px-4 py-2 rounded-xl text-sm text-gray-600 hover:bg-gray-100 transition-colors">
          Cancel
        </button>
        <button type="submit" disabled={saving || files.some(f => f.uploading)}
          className="flex items-center gap-2 px-5 py-2 bg-[#ffa800] text-white rounded-xl text-sm font-medium hover:bg-[#e69700] disabled:opacity-60 transition-colors">
          {saving ? <><Loader2 className="w-4 h-4 animate-spin" /> Saving…</> : submitLabel}
        </button>
      </div>
    </form>
  );
}

// ── Modal shell ───────────────────────────────────────────────
function Modal({ open, onClose, title, subtitle, children }: {
  open: boolean; onClose: () => void; title: string; subtitle?: string; children: React.ReactNode;
}) {
  return (
    <AnimatePresence>
      {open && (
        <>
          <motion.div key="bd" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="fixed inset-0 z-40 bg-black/40 backdrop-blur-sm" onClick={onClose} />
          <motion.div key="md"
            initial={{ opacity: 0, y: 40, scale: 0.97 }} animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 20, scale: 0.97 }}
            transition={{ type: 'spring', stiffness: 320, damping: 30 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4 pointer-events-none">
            <div className="w-full max-w-lg bg-white rounded-2xl shadow-2xl pointer-events-auto overflow-hidden"
              onClick={e => e.stopPropagation()}>
              <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-gray-100">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl bg-[#ffa800]/10 flex items-center justify-center">
                    <Award className="w-5 h-5 text-[#ffa800]" />
                  </div>
                  <div>
                    <h2 className="text-base font-semibold text-gray-900">{title}</h2>
                    {subtitle && <p className="text-xs text-gray-400 mt-0.5">{subtitle}</p>}
                  </div>
                </div>
                <button onClick={onClose} className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-all">
                  <X className="w-4 h-4" />
                </button>
              </div>
              {children}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

// ── Helper: build certificateFiles payload from UploadedFile[] ─
function buildFilesPayload(files: UploadedFile[]): CertFile[] {
  return files.filter(f => f.url && !f.uploading && !f.error)
    .map(f => ({ name: f.name || '', url: f.url }));
}

// ── Add Modal ─────────────────────────────────────────────────
function AddModal({ open, onClose, onSuccess }: { open: boolean; onClose: () => void; onSuccess: () => void }) {
  const [form, setForm]       = useState<FormState>({ ...EMPTY_FORM });
  const [files, setFiles]     = useState<UploadedFile[]>([]);
  const [saving, setSaving]   = useState(false);
  const [error, setError]     = useState('');
  const [created, setCreated] = useState<string | null>(null);

  const handleClose = () => { setForm({ ...EMPTY_FORM }); setFiles([]); setError(''); setCreated(null); onClose(); };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); setError('');
    if (form.certificateTypes.length === 0) { setError('Please select at least one certificate type'); return; }
    if (form.certificateTypes.includes('other') && !form.otherType.trim()) { setError('Please enter a custom certificate type name'); return; }
    if (files.some(f => f.uploading)) { setError('Please wait for all files to finish uploading'); return; }

    setSaving(true);
    try {
      const res = await fetch('/api/admin/certificates', {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, credentials: 'include',
        body: JSON.stringify({
          studentName: form.studentName, studentEmail: form.studentEmail,
          courseName: form.courseName, courseSlug: form.courseSlug,
          certificateTypes: form.certificateTypes, otherType: form.otherType,
          issuedAt: form.issuedAt, status: form.status,
          certificateFiles: buildFilesPayload(files),
        }),
      });
      const data = await res.json();
      if (!res.ok) setError(data.error || 'Something went wrong');
      else { setCreated(data.certificateId); onSuccess(); }
    } catch { setError('Network error — please try again'); }
    finally { setSaving(false); }
  };

  return (
    <Modal open={open} onClose={handleClose} title="Add Student Certificate"
      subtitle="A unique certificate ID will be generated automatically">
      {created ? (
        <div className="px-6 py-10 text-center space-y-4">
          <div className="w-14 h-14 rounded-full bg-green-100 flex items-center justify-center mx-auto">
            <CheckCircle className="w-7 h-7 text-green-600" />
          </div>
          <div>
            <p className="font-semibold text-gray-900">Certificate created!</p>
            <p className="text-sm text-gray-500 mt-1">ID: <span className="font-mono font-bold text-[#ffa800]">{created}</span></p>
          </div>
          <button onClick={handleClose}
            className="mt-2 px-6 py-2 bg-[#ffa800] text-white rounded-xl text-sm font-medium hover:bg-[#e69700] transition-colors">
            Close
          </button>
        </div>
      ) : (
        <CertForm form={form} setForm={setForm} files={files} setFiles={setFiles}
          error={error} saving={saving}
          submitLabel={<><Plus className="w-4 h-4" /> Add Certificate</>}
          onSubmit={handleSubmit} onCancel={handleClose} />
      )}
    </Modal>
  );
}

// ── Edit Modal ────────────────────────────────────────────────
function EditModal({ cert, onClose, onSuccess }: { cert: Certificate | null; onClose: () => void; onSuccess: () => void }) {
  const [form, setForm]     = useState<FormState>({ ...EMPTY_FORM });
  const [files, setFiles]   = useState<UploadedFile[]>([]);
  const [saving, setSaving] = useState(false);
  const [error, setError]   = useState('');

  useEffect(() => {
    if (!cert) return;
    const presetValues = PRESET_TYPES.filter(t => t.value !== 'other').map(t => t.value);
    const customTypes  = cert.certificateTypes.filter(t => !presetValues.includes(t));
    const presetSel    = cert.certificateTypes.filter(t => presetValues.includes(t));
    setForm({
      studentName: cert.studentName, studentEmail: cert.studentEmail,
      courseName: cert.courseName,   courseSlug: cert.courseSlug,
      certificateTypes: customTypes.length > 0 ? [...presetSel, 'other'] : presetSel,
      otherType: customTypes[0] || '',
      issuedAt: toDateInput(cert.issuedAt), status: cert.status,
    });
    // Pre-populate existing files
    setFiles((cert.certificateFiles || []).map((f, i) => ({
      localId: `existing-${i}-${f.url}`, name: f.name, url: f.url,
    })));
    setError('');
  }, [cert]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); setError('');
    if (form.certificateTypes.length === 0) { setError('Please select at least one certificate type'); return; }
    if (form.certificateTypes.includes('other') && !form.otherType.trim()) { setError('Please enter a custom certificate type name'); return; }
    if (files.some(f => f.uploading)) { setError('Please wait for all files to finish uploading'); return; }

    setSaving(true);
    try {
      const res = await fetch(`/api/admin/certificates/${cert!.id}`, {
        method: 'PATCH', headers: { 'Content-Type': 'application/json' }, credentials: 'include',
        body: JSON.stringify({
          studentName: form.studentName, studentEmail: form.studentEmail,
          courseName: form.courseName, courseSlug: form.courseSlug,
          certificateTypes: form.certificateTypes, otherType: form.otherType,
          issuedAt: form.issuedAt, status: form.status,
          certificateFiles: buildFilesPayload(files),
        }),
      });
      const data = await res.json();
      if (!res.ok) setError(data.error || 'Something went wrong');
      else { onSuccess(); onClose(); }
    } catch { setError('Network error — please try again'); }
    finally { setSaving(false); }
  };

  return (
    <Modal open={!!cert} onClose={onClose} title="Edit Certificate" subtitle={cert?.certificateId}>
      <CertForm form={form} setForm={setForm} files={files} setFiles={setFiles}
        error={error} saving={saving}
        submitLabel={<><Pencil className="w-4 h-4" /> Save Changes</>}
        onSubmit={handleSubmit} onCancel={onClose} />
    </Modal>
  );
}

// ── Delete Modal ──────────────────────────────────────────────
function DeleteModal({ cert, onClose, onSuccess }: { cert: Certificate | null; onClose: () => void; onSuccess: () => void }) {
  const [deleting, setDeleting] = useState(false);

  const handleDelete = async () => {
    if (!cert) return;
    setDeleting(true);
    try { await fetch(`/api/admin/certificates/${cert.id}`, { method: 'DELETE', credentials: 'include' }); onSuccess(); onClose(); }
    catch { /* silent */ } finally { setDeleting(false); }
  };

  return (
    <AnimatePresence>
      {cert && (
        <>
          <motion.div key="bd" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="fixed inset-0 z-40 bg-black/40 backdrop-blur-sm" onClick={onClose} />
          <motion.div key="md"
            initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95 }}
            transition={{ type: 'spring', stiffness: 320, damping: 30 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4 pointer-events-none">
            <div className="w-full max-w-sm bg-white rounded-2xl shadow-2xl pointer-events-auto p-6 text-center space-y-4"
              onClick={e => e.stopPropagation()}>
              <div className="w-12 h-12 rounded-full bg-red-100 flex items-center justify-center mx-auto">
                <Trash2 className="w-6 h-6 text-red-500" />
              </div>
              <div>
                <p className="font-semibold text-gray-900">Delete certificate?</p>
                <p className="text-sm text-gray-500 mt-1">
                  <span className="font-mono text-[#ffa800]">{cert.certificateId}</span> — <span className="font-medium">{cert.studentName}</span>
                </p>
                <p className="text-xs text-red-500 mt-1">This cannot be undone.</p>
              </div>
              <div className="flex gap-3 justify-center pt-1">
                <button onClick={onClose}
                  className="px-5 py-2 rounded-xl text-sm text-gray-600 hover:bg-gray-100 transition-colors border border-gray-200">
                  Cancel
                </button>
                <button onClick={handleDelete} disabled={deleting}
                  className="flex items-center gap-2 px-5 py-2 bg-red-500 text-white rounded-xl text-sm font-medium hover:bg-red-600 disabled:opacity-60 transition-colors">
                  {deleting ? <><Loader2 className="w-4 h-4 animate-spin" /> Deleting…</> : <><Trash2 className="w-4 h-4" /> Delete</>}
                </button>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

// ── Main Page ─────────────────────────────────────────────────
export default function CertificatesPage() {
  const [certs, setCerts]               = useState<Certificate[]>([]);
  const [loading, setLoading]           = useState(true);
  const [search, setSearch]             = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [page, setPage]                 = useState(1);
  const [pagination, setPagination]     = useState({ total: 0, pages: 1 });
  const [summary, setSummary]           = useState({ totalReady: 0, totalPending: 0, totalEmailSent: 0 });
  const [showAdd, setShowAdd]           = useState(false);
  const [editCert, setEditCert]         = useState<Certificate | null>(null);
  const [deleteCert, setDeleteCert]     = useState<Certificate | null>(null);

  const fetchCerts = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({
        page: String(page), limit: '15',
        ...(search && { search }),
        ...(filterStatus && { status: filterStatus }),
      });
      const res = await api.get(`/api/admin/certificates?${params}`);
      setCerts(res.data.certificates || []);
      setPagination(res.data.pagination || { total: 0, pages: 1 });
      setSummary(res.data.summary || { totalReady: 0, totalPending: 0, totalEmailSent: 0 });
    } catch (err) { console.error(err); }
    finally { setLoading(false); }
  }, [page, search, filterStatus]);

  useEffect(() => { fetchCerts(); }, [fetchCerts]);
  useEffect(() => {
    const t = setTimeout(() => { setPage(1); fetchCerts(); }, 400);
    return () => clearTimeout(t);
  }, [search]);

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Certificates</h1>
          <p className="text-gray-500 text-sm mt-0.5">{pagination.total} total certificates</p>
        </div>
        <div className="flex items-center gap-3 flex-wrap">
          <div className="flex items-center gap-2 px-3 py-2 bg-green-50 rounded-xl border border-green-100">
            <CheckCircle className="w-4 h-4 text-green-600" />
            <span className="text-sm font-semibold text-green-700">{summary.totalReady} ready</span>
          </div>
          <div className="flex items-center gap-2 px-3 py-2 bg-amber-50 rounded-xl border border-amber-100">
            <Clock className="w-4 h-4 text-amber-600" />
            <span className="text-sm font-semibold text-amber-700">{summary.totalPending} pending</span>
          </div>
          <button onClick={() => setShowAdd(true)}
            className="flex items-center gap-2 px-4 py-2 bg-[#ffa800] text-white rounded-xl text-sm font-semibold hover:bg-[#e69700] transition-colors shadow-sm shadow-[#ffa800]/30">
            <Plus className="w-4 h-4" /> Add Student
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input type="text" placeholder="Search by student, course, certificate ID..."
            value={search} onChange={e => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/10 bg-white" />
        </div>
        <select value={filterStatus} onChange={e => { setFilterStatus(e.target.value); setPage(1); }}
          className="px-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:border-[#ffa800] bg-white text-gray-700">
          <option value="">All Statuses</option>
          <option value="ready">Ready</option>
          <option value="pending">Pending</option>
        </select>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/50">
                {['Certificate ID','Student','Course','Type','Files','Status','Issued Date','Actions'].map(h => (
                  <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                [...Array(6)].map((_, i) => (
                  <tr key={i}>{[...Array(8)].map((_, j) => (
                    <td key={j} className="px-4 py-3"><div className="h-4 bg-gray-100 rounded animate-pulse" /></td>
                  ))}</tr>
                ))
              ) : certs.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-4 py-16 text-center text-gray-400">
                    <Award className="w-8 h-8 mx-auto mb-2 text-gray-200" />
                    <p>No certificates found</p>
                    <button onClick={() => setShowAdd(true)}
                      className="mt-3 inline-flex items-center gap-1.5 px-4 py-1.5 bg-[#ffa800] text-white rounded-xl text-xs font-semibold hover:bg-[#e69700] transition-colors">
                      <Plus className="w-3.5 h-3.5" /> Add first certificate
                    </button>
                  </td>
                </tr>
              ) : certs.map(cert => {
                const types = cert.certificateTypes?.length ? cert.certificateTypes : [cert.certificateType];
                const fileCount = cert.certificateFiles?.length || 0;
                return (
                  <motion.tr key={cert.id} initial={{ opacity: 0 }} animate={{ opacity: 1 }}
                    className="hover:bg-orange-50/30 transition-colors">
                    <td className="px-4 py-3">
                      <span className="font-mono text-xs text-[#ffa800] font-semibold">{cert.certificateId}</span>
                    </td>
                    <td className="px-4 py-3">
                      <p className="font-medium text-gray-900 whitespace-nowrap">{cert.studentName}</p>
                      <p className="text-xs text-gray-400">{cert.studentEmail || '—'}</p>
                    </td>
                    <td className="px-4 py-3 text-gray-700 max-w-[140px] truncate">{cert.courseName}</td>
                    <td className="px-4 py-3">
                      <div className="flex flex-wrap gap-1">
                        {types.map(t => (
                          <span key={t} className="px-2 py-0.5 bg-blue-50 text-blue-700 rounded-full text-xs font-medium capitalize whitespace-nowrap">
                            {prettyType(t)}
                          </span>
                        ))}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      {fileCount > 0 ? (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 bg-green-50 text-green-700 rounded-full text-xs font-medium">
                          <FileText className="w-3 h-3" /> {fileCount}
                        </span>
                      ) : (
                        <span className="text-xs text-gray-300">—</span>
                      )}
                    </td>
                    <td className="px-4 py-3"><StatusBadge status={cert.status} /></td>
                    <td className="px-4 py-3 text-xs text-gray-500 whitespace-nowrap">
                      {new Date(cert.issuedAt).toLocaleDateString('en-IN', { day:'2-digit', month:'short', year:'2-digit' })}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <button onClick={() => setEditCert(cert)}
                          className="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-all" title="Edit">
                          <Pencil className="w-3.5 h-3.5" />
                        </button>
                        {cert.certificateUrl ? (
                          <a href={cert.certificateUrl} target="_blank" rel="noopener noreferrer"
                            className="p-1.5 rounded-lg text-gray-400 hover:text-[#ffa800] hover:bg-orange-50 transition-all" title="Download">
                            <Download className="w-3.5 h-3.5" />
                          </a>
                        ) : null}
                        {cert.studentEmail && (
                          <a href={`mailto:${cert.studentEmail}`}
                            className="p-1.5 rounded-lg text-gray-400 hover:text-blue-500 hover:bg-blue-50 transition-all" title="Email">
                            <Mail className="w-3.5 h-3.5" />
                          </a>
                        )}
                        <button onClick={() => setDeleteCert(cert)}
                          className="p-1.5 rounded-lg text-gray-400 hover:text-red-500 hover:bg-red-50 transition-all" title="Delete">
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </td>
                  </motion.tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100">
            <p className="text-xs text-gray-400">Page {page} of {pagination.pages} · {pagination.total} certificates</p>
            <div className="flex items-center gap-1.5">
              <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}
                className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 disabled:opacity-40 transition-all">
                <ChevronLeft className="w-4 h-4" />
              </button>
              {Array.from({ length: Math.min(pagination.pages, 5) }, (_, i) => i + 1).map(pg => (
                <button key={pg} onClick={() => setPage(pg)}
                  className={`w-7 h-7 rounded-lg text-xs font-medium transition-all ${page === pg ? 'bg-[#ffa800] text-white' : 'text-gray-500 hover:bg-gray-100'}`}>
                  {pg}
                </button>
              ))}
              <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page === pagination.pages}
                className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 disabled:opacity-40 transition-all">
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>

      <AddModal    open={showAdd}    onClose={() => setShowAdd(false)}    onSuccess={fetchCerts} />
      <EditModal   cert={editCert}   onClose={() => setEditCert(null)}    onSuccess={fetchCerts} />
      <DeleteModal cert={deleteCert} onClose={() => setDeleteCert(null)}  onSuccess={fetchCerts} />
    </div>
  );
}
