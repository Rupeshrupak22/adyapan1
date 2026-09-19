'use client';

import { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { motion, AnimatePresence } from 'framer-motion';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

interface User {
  name?: string;
  email?: string;
  phone?: string;
  avatar?: string;
  role?: string;
}

interface Props {
  user: User;
  onUserUpdate: (u: User) => void;
}

/* â"€â"€ Icon components â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
const Icon = ({ d, className = '' }: { d: string; className?: string }) => (
  <svg className={`w-4 h-4 ${className}`} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
    <path strokeLinecap="round" strokeLinejoin="round" d={d} />
  </svg>
);

const ICONS = {
  edit:        'M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z',
  update:      'M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15',
  courses:     'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253',
  wishlist:    'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z',
  certificate: 'M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z',
  project:     'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01',
  billing:     'M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z',
  bell:        'M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9',
  moon:        'M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z',
  sun:         'M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z',
  logout:      'M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1',
  camera:      'M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z M15 13a3 3 0 11-6 0 3 3 0 016 0z',
  close:       'M6 18L18 6M6 6l12 12',
};

/* â"€â"€ Portal â€" renders children into document.body so `position: fixed`
   escapes any transformed/blurred ancestor (e.g. the sticky navbar). â"€â"€ */
function Portal({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = useState(false);
  useEffect(() => { setMounted(true); return () => setMounted(false); }, []);
  if (!mounted) return null;
  return createPortal(children, document.body);
}

/* â"€â"€ Edit Profile Modal â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
function EditProfileModal({
  user,
  onClose,
  onSave,
}: {
  user: User;
  onClose: () => void;
  onSave: (u: User) => void;
}) {
  const [name,    setName]    = useState(user.name    || '');
  const [phone,   setPhone]   = useState(user.phone   || '');
  const [avatar,  setAvatar]  = useState(user.avatar  || '');
  const [preview, setPreview] = useState(user.avatar  || '');
  const [saving,  setSaving]  = useState(false);
  const [error,   setError]   = useState('');
  const fileRef = useRef<HTMLInputElement>(null);

  const handleFile = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = ev => {
      const result = ev.target?.result as string;
      setPreview(result);
      setAvatar(result);
    };
    reader.readAsDataURL(file);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError('');
    try {
      const res = await fetch('/api/auth/update-profile', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, phone, avatar }),
      });
      const data = await res.json();
      if (!res.ok) { setError(data.error || 'Failed to save'); setSaving(false); return; }
      onSave(data.user);
      onClose();
    } catch {
      setError('Something went wrong.');
    } finally {
      setSaving(false);
    }
  };

  const initials = name ? name.split(' ').map((w: string) => w[0]).join('').toUpperCase().slice(0, 2) : '?';

  return (
    <div
      className="fixed inset-0 z-[9999] flex items-center justify-center p-4 overflow-y-auto"
      style={{ margin: 0 }}
    >
      {/* Backdrop */}
      <motion.div
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
        className="fixed inset-0 bg-black/60 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal card */}
      <motion.div
        initial={{ opacity: 0, scale: 0.92, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.92, y: 20 }}
        transition={{ type: 'spring', stiffness: 300, damping: 28 }}
        className="relative z-10 w-full max-w-md rounded-3xl bg-white shadow-2xl overflow-hidden my-auto"
        onClick={e => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-gradient-to-r from-[#ffa800] to-[#ff8c00] px-6 py-5 flex items-center justify-between">
          <h2 className="text-lg font-bold text-white">Edit Profile</h2>
          <button onClick={onClose} className="text-white/80 hover:text-white transition-colors">
            <Icon d={ICONS.close} className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSave} className="p-6 space-y-5">
          {/* Avatar picker */}
          <div className="flex flex-col items-center gap-3">
            <div className="relative">
              {preview ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={preview} alt="avatar" className="w-20 h-20 rounded-full object-cover ring-4 ring-[#ffa800]/30" />
              ) : (
                <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[#ffa800] to-[#ff6b00] flex items-center justify-center text-white text-2xl font-bold ring-4 ring-[#ffa800]/30">
                  {initials}
                </div>
              )}
              <button
                type="button"
                onClick={() => fileRef.current?.click()}
                className="absolute -bottom-1 -right-1 w-7 h-7 rounded-full bg-[#ffa800] flex items-center justify-center shadow-lg hover:bg-[#e69500] transition-colors"
              >
                <Icon d={ICONS.camera} className="w-3.5 h-3.5 text-white" />
              </button>
            </div>
            <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handleFile} />
            <p className="text-xs text-gray-400">Click camera to change photo</p>
          </div>

          {/* Name */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Full Name</label>
            <input
              value={name}
              onChange={e => setName(e.target.value)}
              placeholder="Your full name"
              className="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#ffa800]/50 focus:border-[#ffa800] transition-all"
            />
          </div>

          {/* Phone */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Phone Number</label>
            <input
              value={phone}
              onChange={e => setPhone(e.target.value)}
              placeholder="+91 00000 00000"
              className="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#ffa800]/50 focus:border-[#ffa800] transition-all"
            />
          </div>

          {/* Email (read-only) */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Email</label>
            <input
              value={user.email || ''}
              readOnly
              className="w-full rounded-xl border border-gray-100 bg-gray-50 px-4 py-2.5 text-sm text-gray-400 cursor-not-allowed"
            />
          </div>

          {error && <p className="text-xs text-red-500 bg-red-50 rounded-lg px-3 py-2">{error}</p>}

          <div className="flex gap-3 pt-1">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 rounded-xl border border-gray-200 py-2.5 text-sm font-semibold text-gray-600 hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={saving}
              className="flex-1 rounded-xl bg-gradient-to-r from-[#ffa800] to-[#ff8c00] py-2.5 text-sm font-semibold text-white hover:from-[#e69500] hover:to-[#e07800] transition-all disabled:opacity-60 flex items-center justify-center gap-2"
            >
              {saving ? (
                <><svg className="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/></svg>Saving...</>
              ) : 'Save Changes'}
            </button>
          </div>
        </form>
      </motion.div>
    </div>
  );
}

/* â"€â"€ Purchased Courses Modal â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
function PurchasedCoursesModal({ onClose }: { onClose: () => void }) {
  const router = useRouter();
  const [courses, setCourses] = useState<{ courseName: string; planLabel: string; progressPercent: number; enrolledAt: string }[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/user/dashboard')
      .then(r => r.json())
      .then(d => {
        const list = (d.courses ?? []).map((c: any) => ({
          courseName:      c.enrollment?.courseName ?? c.course?.title ?? 'Course',
          planLabel:       c.enrollment?.planLabel  ?? '',
          progressPercent: c.progress?.progressPercent ?? 0,
          enrolledAt:      c.enrollment?.enrolledAt ?? '',
        }));
        setCourses(list);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4" style={{ margin: 0 }}>
      {/* Backdrop */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="absolute inset-0 bg-black/60 backdrop-blur-md"
        onClick={onClose}
      />

      {/* Modal - centered, glassmorphism */}
      <motion.div
        initial={{ opacity: 0, scale: 0.88, y: 32 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.88, y: 32 }}
        transition={{ type: 'spring', stiffness: 320, damping: 28 }}
        className="relative w-full max-w-md rounded-3xl overflow-hidden shadow-2xl z-10"
        style={{
          background: 'rgba(255,255,255,0.98)',
          backdropFilter: 'blur(24px) saturate(1.6)',
          WebkitBackdropFilter: 'blur(24px) saturate(1.6)',
          border: '1px solid rgba(255,255,255,0.6)',
          boxShadow: '0 32px 80px -12px rgba(0,0,0,0.25), 0 0 0 1px rgba(255,168,0,0.12)',
        }}
      >
        {/* Orange top stripe */}
        <div className="h-1 w-full bg-gradient-to-r from-[#ffa800] via-[#ff8c00] to-[#ffa800]" />

        {/* Header */}
        <div className="relative px-6 pt-6 pb-4 flex items-center justify-between">
          <div>
            <h2 className="text-lg font-extrabold text-gray-900">My Courses</h2>
            <p className="text-xs text-gray-400 mt-0.5">Your enrolled programs & progress</p>
          </div>
          <motion.button
            whileHover={{ scale: 1.1, rotate: 90 }}
            whileTap={{ scale: 0.9 }}
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-gray-100 hover:bg-red-50 flex items-center justify-center text-gray-400 hover:text-red-500 transition-colors"
          >
            <Icon d={ICONS.close} className="w-4 h-4" />
          </motion.button>
        </div>

        {/* Body */}
        <div className="px-6 pb-6 max-h-[60vh] overflow-y-auto space-y-3"
          style={{ scrollbarWidth: 'thin', scrollbarColor: '#ffa800 transparent' }}>

          {loading ? (
            <div className="flex flex-col items-center justify-center py-12 gap-3">
              <div className="w-10 h-10 border-3 border-[#ffa800] border-t-transparent rounded-full animate-spin" />
              <p className="text-sm text-gray-400">Loading your courses...</p>
            </div>
          ) : courses.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-16 h-16 rounded-2xl bg-orange-50 flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl"></span>
              </div>
              <p className="font-bold text-gray-800 mb-1">No courses yet</p>
              <p className="text-sm text-gray-400 mb-5">Enroll in a program to start learning</p>
              <Link
                href="/"
                onClick={onClose}
                className="inline-flex items-center gap-2 rounded-xl px-5 py-2.5 text-sm font-bold text-white transition-all hover:shadow-lg hover:shadow-orange-200"
                style={{ background: 'linear-gradient(135deg,#ffa800,#ff6b00)' }}
              >
                Browse Programs &rarr;
              </Link>
            </div>
          ) : (
            courses.map((course, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, x: -12 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.07 }}
                whileHover={{ scale: 1.02, y: -2 }}
                className="rounded-2xl p-4 cursor-default transition-all"
                style={{
                  background: 'rgba(255,248,235,0.8)',
                  border: '1px solid rgba(255,168,0,0.2)',
                  boxShadow: '0 2px 12px rgba(255,168,0,0.08)',
                }}
              >
                <div className="flex items-center gap-3 mb-3">
                  {/* Number badge */}
                  <div
                    className="w-9 h-9 rounded-xl flex items-center justify-center text-white text-sm font-black flex-shrink-0"
                    style={{ background: 'linear-gradient(135deg,#ffa800,#ff6b00)' }}
                  >
                    {i + 1}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold text-gray-900 truncate">{course.courseName}</p>
                    {course.planLabel && (
                      <p className="text-xs text-gray-500 mt-0.5">{course.planLabel}</p>
                    )}
                  </div>
                  {/* Progress badge */}
                  <span
                    className={`text-xs font-extrabold px-2.5 py-1 rounded-full flex-shrink-0 ${
                      course.progressPercent === 100
                        ? 'bg-green-100 text-green-700'
                        : 'bg-orange-100 text-[#ffa800]'
                    }`}
                  >
                    {course.progressPercent === 100 ? ' Done' : `${course.progressPercent}%`}
                  </span>
                </div>

                {/* Progress bar */}
                <div className="h-2 bg-white/80 rounded-full overflow-hidden border border-orange-100">
                  <motion.div
                    className={`h-full rounded-full ${
                      course.progressPercent === 100
                        ? 'bg-gradient-to-r from-green-400 to-green-500'
                        : 'bg-gradient-to-r from-[#ffa800] to-[#ff6b00]'
                    }`}
                    initial={{ width: 0 }}
                    animate={{ width: `${course.progressPercent}%` }}
                    transition={{ duration: 1, ease: 'easeOut', delay: i * 0.1 }}
                  />
                </div>
              </motion.div>
            ))
          )}
        </div>

        {/* Footer CTA */}
        {courses.length > 0 && (
          <div className="px-6 pb-6">
            <motion.button
              whileHover={{ scale: 1.02, boxShadow: '0 8px 30px rgba(255,168,0,0.4)' }}
              whileTap={{ scale: 0.97 }}
              onClick={() => { onClose(); router.push('/dashboard/student'); }}
              className="w-full py-3 rounded-2xl text-white text-sm font-extrabold tracking-wide transition-all"
              style={{ background: 'linear-gradient(135deg,#ffa800 0%,#ff6b00 100%)' }}
            >
              Go to My Dashboard &rarr;
            </motion.button>
          </div>
        )}
      </motion.div>
    </div>
  );
}

/* â"€â"€ Main ProfileDropdown â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
export default function ProfileDropdown({ user, onUserUpdate }: Props) {
  const router = useRouter();
  const [open,            setOpen]            = useState(false);
  const [showEditModal,   setShowEditModal]   = useState(false);
  const [showCourses,     setShowCourses]     = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  /* close on outside click */
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const handleLogout = async () => {
    await fetch('/api/auth/logout', { method: 'POST' });
    window.dispatchEvent(new Event('auth-change'));
    router.push('/');
    router.refresh();
  };

  const initials = user.name
    ? user.name.split(' ').map((w: string) => w[0]).join('').toUpperCase().slice(0, 2)
    : user.email?.[0]?.toUpperCase() ?? '?';
  const userRole = (user.role || 'STUDENT').toUpperCase();

  /* menu item helper */
  const MenuItem = ({
    icon, label, onClick, href, badge, danger = false,
  }: {
    icon: string; label: string; onClick?: () => void; href?: string;
    badge?: number; danger?: boolean;
  }) => {
    const cls = `group flex items-center gap-3 w-full px-5 py-3.5 text-[15px] font-semibold transition-all duration-150 ${
      danger
        ? 'text-red-500 hover:bg-red-50 hover:text-red-600'
        : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900'
    }`;
    const content = (
      <>
        <span className={`flex-shrink-0 w-8 h-8 rounded-lg flex items-center justify-center transition-colors ${
          danger ? 'bg-red-50 group-hover:bg-red-100' : 'bg-gray-100 group-hover:bg-gray-200'
        }`}>
          <Icon d={icon} className={danger ? 'text-red-500' : 'text-gray-500 group-hover:text-gray-700'} />
        </span>
        <span className="flex-1 text-left">{label}</span>
        {badge ? (
          <span className="ml-auto flex h-5 min-w-5 items-center justify-center rounded-full bg-[#ffa800] px-1.5 text-[10px] font-bold text-white">
            {badge}
          </span>
        ) : null}
      </>
    );

    if (href) return <Link href={href} onClick={() => setOpen(false)} className={cls}>{content}</Link>;
    return <button type="button" onClick={onClick} className={cls}>{content}</button>;
  };

  return (
    <>
      {/* â"€â"€ Trigger button â"€â"€ */}
      <div className="relative" ref={ref}>
        <button
          type="button"
          onClick={() => setOpen(v => !v)}
          aria-expanded={open}
          aria-haspopup="menu"
          className="flex items-center gap-2 rounded-full bg-gradient-to-r from-[#ffa800] to-[#ff8c00] px-3 py-1.5 text-sm font-semibold text-white shadow-md hover:shadow-lg hover:from-[#e69500] hover:to-[#e07800] transition-all"
        >
          {user.avatar ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={user.avatar} alt="avatar" className="w-6 h-6 rounded-full object-cover ring-2 ring-white/50" />
          ) : (
            <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-white text-[#ffa800] text-xs font-bold">
              {initials}
            </span>
          )}
          <span className="max-w-[90px] truncate hidden sm:block">{user.name?.split(' ')[0] || user.email}</span>
          <svg className={`h-3 w-3 transition-transform duration-200 ${open ? 'rotate-180' : ''}`} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
          </svg>
        </button>

        {/* â"€â"€ Dropdown â"€â"€ */}
        <AnimatePresence>
          {open && (
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: -8 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: -8 }}
              transition={{ type: 'spring', stiffness: 350, damping: 28 }}
              className="absolute right-0 mt-3 w-[288px] rounded-xl bg-white shadow-2xl border border-gray-100/80 overflow-hidden z-[1000]"
              role="menu"
              style={{ boxShadow: '0 18px 45px -18px rgba(15,23,42,0.35), 0 0 0 1px rgba(15,23,42,0.04)' }}
            >
              {/* â"€â"€ User header â"€â"€ */}
              <div className="relative bg-gradient-to-br from-[#ffa800] via-[#ff9800] to-[#ff6b00] px-5 py-6">
                {/* decorative circles */}
                <div className="absolute top-0 right-0 w-28 h-28 rounded-full bg-white/10 -translate-y-10 translate-x-10" />
                <div className="absolute bottom-0 left-0 w-16 h-16 rounded-full bg-white/10 translate-y-5 -translate-x-7" />

                <div className="relative flex items-center gap-3">
                  {user.avatar ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={user.avatar} alt="avatar" className="w-16 h-16 rounded-2xl object-cover ring-2 ring-white/35 shadow-lg" />
                  ) : (
                    <div className="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center text-white text-2xl font-bold ring-2 ring-white/35 shadow-lg">
                      {initials}
                    </div>
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="font-extrabold text-white text-base leading-tight truncate uppercase">{user.name || 'User'}</p>
                    <p className="text-white/80 text-xs font-semibold truncate mt-1">{user.email}</p>
                    <span className="mt-1.5 inline-block rounded-full bg-white/25 px-2.5 py-0.5 text-[10px] font-extrabold text-white uppercase tracking-wide">
                      {userRole === 'COMPANY' ? 'Organization' : 'Student'}
                    </span>
                  </div>
                </div>
              </div>

              {/* â"€â"€ Menu items â"€â"€ */}
              <div className="py-3">
                <MenuItem icon={ICONS.edit}    label="Edit Profile"   onClick={() => { setOpen(false); setShowEditModal(true); }} />

                <div className="my-2 mx-5 border-t border-gray-100" />

                {/* Student-only menu items */}
                {userRole === 'STUDENT' && (
                  <>
                    <MenuItem icon={ICONS.courses}     label="My Purchased Courses" onClick={() => { setOpen(false); setShowCourses(true); }} />
                    <MenuItem icon={ICONS.wishlist}    label="Wishlist"             onClick={() => { setOpen(false); router.push('/dashboard/student?tab=courses'); }} />
                    <MenuItem icon={ICONS.certificate} label="Certificates"         onClick={() => { setOpen(false); router.push('/dashboard/student?tab=certificates'); }} />
                    <MenuItem icon={ICONS.project}     label="Track Your Project"   onClick={() => { setOpen(false); router.push('/company/my-projects'); }} />
                  </>
                )}

                {/* Organization/Admin menu items */}
                {['COMPANY', 'ADMIN', 'SUPERADMIN'].includes(userRole) && (
                  <>
                    <MenuItem icon={ICONS.courses}     label="Find Employees"       onClick={() => { setOpen(false); router.push('/company/find-employee'); }} />
                    <MenuItem icon={ICONS.wishlist}    label="My Shortlists"        onClick={() => { setOpen(false); router.push('/company/shortlists'); }} />
                  </>
                )}

                <div className="my-2 mx-5 border-t border-gray-100" />

                <MenuItem icon={ICONS.logout} label="Logout" onClick={handleLogout} danger />
              </div>

              {/* â"€â"€ Footer â"€â"€ */}
              <div className="px-4 py-3.5 bg-gray-50 border-t border-gray-100">
                <p className="text-[10px] font-medium text-gray-400 text-center">
                  Adyapan Skills &copy; 2026 - <Link href="/privacy" className="hover:text-[#ffa800]">Privacy</Link> - <Link href="/terms" className="hover:text-[#ffa800]">Terms</Link>
                </p>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* â"€â"€ Modals â"€â"€ */}
      <Portal>
        <AnimatePresence>
          {showEditModal && (
            <EditProfileModal
              user={user}
              onClose={() => setShowEditModal(false)}
              onSave={(updated) => {
                onUserUpdate(updated);
                window.dispatchEvent(new Event('auth-change'));
              }}
            />
          )}
        </AnimatePresence>
      </Portal>

      <Portal>
        <AnimatePresence>
          {showCourses && <PurchasedCoursesModal onClose={() => setShowCourses(false)} />}
        </AnimatePresence>
      </Portal>
    </>
  );
}
