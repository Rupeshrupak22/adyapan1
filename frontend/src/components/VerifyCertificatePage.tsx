'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Search, CheckCircle2, XCircle, Award, Download,
  Calendar, BookOpen, User, BadgeCheck, Loader2,
  Share2, Copy, Check, Shield, Sparkles,
} from 'lucide-react';

// ── Types ─────────────────────────────────────────────────────
interface CertResult {
  valid: boolean;
  certificateId?: string;
  studentName?: string;
  courseName?: string;
  types?: string[];
  issuedAt?: string;
  status?: string;
  certificateUrl?: string | null;
  certificateFiles?: Array<{ name: string; url: string }>;
  error?: string;
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('en-IN', { day: '2-digit', month: 'long', year: 'numeric' });
}

function DetailCard({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="bg-gray-50 rounded-2xl px-4 py-3.5 border border-gray-100">
      <div className="flex items-center gap-1.5 text-gray-400 text-xs mb-1">{icon} {label}</div>
      <p className="text-gray-900 font-semibold text-sm">{value}</p>
    </div>
  );
}

// ── Confetti particle ─────────────────────────────────────────
const COLORS = ['#ffa800', '#22c55e', '#3b82f6', '#f472b6', '#a855f7', '#ef4444', '#06b6d4'];
const SHAPES = ['circle', 'square', 'ribbon'] as const;

interface Particle {
  id: number;
  x: number;
  color: string;
  shape: typeof SHAPES[number];
  size: number;
  delay: number;
  duration: number;
  rotate: number;
  drift: number;
}

function Confetti({ show }: { show: boolean }) {
  const [particles, setParticles] = useState<Particle[]>([]);

  useEffect(() => {
    if (!show) { setParticles([]); return; }
    const list: Particle[] = Array.from({ length: 80 }, (_, i) => ({
      id: i,
      x: Math.random() * 100,
      color: COLORS[Math.floor(Math.random() * COLORS.length)],
      shape: SHAPES[Math.floor(Math.random() * SHAPES.length)],
      size: 6 + Math.random() * 8,
      delay: Math.random() * 0.8,
      duration: 2.2 + Math.random() * 1.8,
      rotate: Math.random() * 720 - 360,
      drift: (Math.random() - 0.5) * 120,
    }));
    setParticles(list);
    // Auto-clear after animation
    const t = setTimeout(() => setParticles([]), 4500);
    return () => clearTimeout(t);
  }, [show]);

  if (!particles.length) return null;

  return (
    <div className="fixed inset-0 pointer-events-none z-50 overflow-hidden">
      {particles.map(p => (
        <motion.div
          key={p.id}
          initial={{ opacity: 1, y: -20, x: `calc(${p.x}vw + 0px)`, rotate: 0, scale: 1 }}
          animate={{
            opacity: [1, 1, 0],
            y: ['0vh', '110vh'],
            x: [`calc(${p.x}vw + 0px)`, `calc(${p.x}vw + ${p.drift}px)`],
            rotate: p.rotate,
            scale: [1, 0.7],
          }}
          transition={{ delay: p.delay, duration: p.duration, ease: 'easeIn' }}
          style={{ position: 'absolute', top: 0, width: p.size, height: p.shape === 'ribbon' ? p.size * 2.5 : p.size }}
          className="overflow-hidden"
        >
          <div style={{
            width: '100%', height: '100%',
            backgroundColor: p.color,
            borderRadius: p.shape === 'circle' ? '50%' : '2px',
          }} />
        </motion.div>
      ))}
    </div>
  );
}

// ── Big celebration overlay ───────────────────────────────────
function CelebrationOverlay({ name, onDone }: { name: string; onDone: () => void }) {
  useEffect(() => {
    const t = setTimeout(onDone, 3200);
    return () => clearTimeout(t);
  }, [onDone]);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.3 }}
      className="fixed inset-0 z-40 flex items-center justify-center pointer-events-none"
    >
      {/* Radial glow */}
      <motion.div
        initial={{ scale: 0, opacity: 0 }}
        animate={{ scale: 2.5, opacity: 0 }}
        transition={{ duration: 1.2, ease: 'easeOut' }}
        className="absolute w-64 h-64 rounded-full bg-green-400/30"
      />

      {/* Center card */}
      <motion.div
        initial={{ scale: 0.3, opacity: 0, y: 40 }}
        animate={{ scale: 1, opacity: 1, y: 0 }}
        exit={{ scale: 0.8, opacity: 0, y: -20 }}
        transition={{ type: 'spring', stiffness: 300, damping: 20, delay: 0.1 }}
        className="bg-white rounded-3xl shadow-2xl px-10 py-8 text-center max-w-xs mx-4 pointer-events-auto"
      >
        {/* Animated checkmark */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: [0, 1.3, 1] }}
          transition={{ duration: 0.5, delay: 0.2, times: [0, 0.7, 1] }}
          className="w-20 h-20 rounded-full bg-gradient-to-br from-green-400 to-emerald-500 flex items-center justify-center mx-auto mb-4 shadow-lg shadow-green-200"
        >
          <CheckCircle2 className="w-10 h-10 text-white" />
        </motion.div>

        {/* Sparkles row */}
        <motion.div
          initial={{ opacity: 0, scale: 0.5 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.45, duration: 0.4 }}
          className="flex justify-center gap-2 mb-3"
        >
          {['🎉', '✨', '🏆', '✨', '🎉'].map((e, i) => (
            <motion.span key={i} initial={{ y: 0 }}
              animate={{ y: [0, -8, 0] }}
              transition={{ delay: 0.5 + i * 0.08, duration: 0.5, repeat: 2 }}
              className="text-xl">{e}</motion.span>
          ))}
        </motion.div>

        <motion.p
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="text-2xl font-extrabold text-gray-900 mb-1"
        >
          Congratulations!
        </motion.p>
        <motion.p
          initial={{ opacity: 0, y: 6 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="text-[#ffa800] font-semibold text-base mb-1"
        >
          {name}
        </motion.p>
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.7 }}
          className="text-gray-500 text-sm"
        >
          Certificate verified successfully 🎓
        </motion.p>
      </motion.div>
    </motion.div>
  );
}

// ── Main page ─────────────────────────────────────────────────
export default function VerifyCertificatePage() {
  const [certId, setCertId]         = useState('');
  const [loading, setLoading]       = useState(false);
  const [result, setResult]         = useState<CertResult | null>(null);
  const [netError, setNetError]     = useState('');
  const [copied, setCopied]         = useState(false);
  const [celebrate, setCelebrate]   = useState(false);
  const [showConfetti, setShowConfetti] = useState(false);
  const inputRef  = useRef<HTMLInputElement>(null);
  const resultRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const id = params.get('id');
    if (id) { setCertId(id.toUpperCase()); doVerify(id); }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const doVerify = async (id?: string) => {
    const query = (id ?? certId).trim().toUpperCase();
    if (!query) { inputRef.current?.focus(); return; }
    setLoading(true); setNetError(''); setResult(null);
    try {
      const res  = await fetch(`/api/verify-certificate?id=${encodeURIComponent(query)}`);
      const data = await res.json();
      setResult(data);
      if (data.valid) {
        // Fire celebration!
        setShowConfetti(true);
        setCelebrate(true);
        setTimeout(() => setShowConfetti(false), 4500);
      }
      setTimeout(() => resultRef.current?.scrollIntoView({ behavior: 'smooth', block: 'nearest' }), 500);
    } catch {
      setNetError('Network error — please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleShare = async () => {
    const url = `${window.location.origin}/verify-certificate?id=${result?.certificateId}`;
    if (navigator.share) { await navigator.share({ title: 'Adyapan Certificate Verification', url }); }
    else { await navigator.clipboard.writeText(url); setCopied(true); setTimeout(() => setCopied(false), 2000); }
  };

  const handleCopyId = async () => {
    await navigator.clipboard.writeText(result?.certificateId || '');
    setCopied(true); setTimeout(() => setCopied(false), 2000);
  };

  return (
    <>
      {/* Confetti layer */}
      <Confetti show={showConfetti} />

      {/* Celebration overlay */}
      <AnimatePresence>
        {celebrate && result?.valid && (
          <CelebrationOverlay
            name={result.studentName || 'Student'}
            onDone={() => setCelebrate(false)}
          />
        )}
      </AnimatePresence>

      <div className="min-h-screen bg-white">

        {/* ── Hero ─────────────────────────────────────── */}
        <section className="bg-gradient-to-br from-[#fffbf2] via-white to-[#fff8ee] border-b border-orange-100">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 pt-14 pb-16 text-center">

            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.4 }}
              className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#ffa800]/10 border border-[#ffa800]/25 text-[#ffa800] text-sm font-medium mb-5">
              <Shield className="w-4 h-4" />
              Official Certificate Verification Portal
            </motion.div>

            <motion.h1 initial={{ opacity: 0, y: 14 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.45, delay: 0.05 }}
              className="text-4xl sm:text-5xl font-extrabold text-gray-900 leading-tight mb-4">
              Verify Your<br />
              <span className="text-[#ffa800]">Adyapan Certificate</span>
            </motion.h1>

            <motion.p initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.4, delay: 0.1 }}
              className="text-gray-500 text-lg max-w-xl mx-auto mb-10">
              Enter your certificate ID to instantly verify its authenticity and download your certificate.
            </motion.p>

            {/* Search box */}
            <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.4, delay: 0.15 }}
              className="flex flex-col sm:flex-row gap-3 max-w-xl mx-auto">
              <div className="relative flex-1">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-300" />
                <input
                  ref={inputRef}
                  type="text"
                  placeholder="e.g. ADYP-2026-K7HX3MQP"
                  value={certId}
                  onChange={e => { setCertId(e.target.value.toUpperCase()); setResult(null); setNetError(''); }}
                  onKeyDown={e => e.key === 'Enter' && doVerify()}
                  className="w-full pl-12 pr-4 py-3.5 rounded-2xl bg-white border border-gray-200 text-gray-800 placeholder-gray-300 text-sm font-mono tracking-wider shadow-sm focus:outline-none focus:border-[#ffa800] focus:ring-2 focus:ring-[#ffa800]/15 transition-all"
                />
              </div>
              <motion.button
                onClick={() => doVerify()}
                disabled={loading || !certId.trim()}
                whileTap={{ scale: 0.96 }}
                className="flex items-center justify-center gap-2 px-6 py-3.5 bg-[#ffa800] text-white font-semibold rounded-2xl hover:bg-[#e69700] disabled:opacity-50 transition-all shadow-md shadow-[#ffa800]/25 shrink-0"
              >
                {loading
                  ? <><Loader2 className="w-5 h-5 animate-spin" /> Verifying…</>
                  : <><BadgeCheck className="w-5 h-5" /> Verify</>}
              </motion.button>
            </motion.div>

            {netError && <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="mt-3 text-red-500 text-sm">{netError}</motion.p>}
          </div>
        </section>

        {/* ── Result ───────────────────────────────────── */}
        <section className="max-w-2xl mx-auto px-4 sm:px-6 py-10">
          <AnimatePresence mode="wait">
            {result && (
              <motion.div
                ref={resultRef}
                key="result"
                initial={{ opacity: 0, y: 30, scale: 0.97 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: -16 }}
                transition={{ duration: 0.4, type: 'spring', stiffness: 260, damping: 24 }}
              >
                {result.valid ? (
                  /* ── Valid certificate ── */
                  <div className="rounded-3xl border border-gray-100 shadow-xl shadow-green-50 overflow-hidden">

                    {/* Animated green header */}
                    <motion.div
                      initial={{ opacity: 0, y: -20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.1, duration: 0.4 }}
                      className="bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 px-6 py-6 relative overflow-hidden"
                    >
                      {/* Shimmer sweep */}
                      <motion.div
                        initial={{ x: '-100%' }}
                        animate={{ x: '200%' }}
                        transition={{ delay: 0.3, duration: 0.9, ease: 'easeInOut' }}
                        className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent skew-x-12"
                      />
                      <div className="relative flex items-center gap-4">
                        <motion.div
                          initial={{ scale: 0, rotate: -180 }}
                          animate={{ scale: 1, rotate: 0 }}
                          transition={{ delay: 0.2, type: 'spring', stiffness: 300 }}
                          className="w-14 h-14 rounded-full bg-white/25 flex items-center justify-center shrink-0 shadow-lg"
                        >
                          <CheckCircle2 className="w-8 h-8 text-white" />
                        </motion.div>
                        <div>
                          <motion.div initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.3 }}>
                            <p className="text-white font-extrabold text-xl leading-tight flex items-center gap-2">
                              Certificate Verified <Sparkles className="w-5 h-5" />
                            </p>
                            <p className="text-white/80 text-sm mt-0.5">This is an authentic Adyapan certificate</p>
                          </motion.div>
                        </div>
                      </div>
                    </motion.div>

                    {/* Body */}
                    <div className="bg-white px-6 py-6 space-y-5">

                      {/* Certificate ID */}
                      <motion.div
                        initial={{ opacity: 0, x: -16 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.2 }}
                        className="flex items-center justify-between bg-[#fffbf2] rounded-2xl px-4 py-3.5 border border-orange-100"
                      >
                        <div>
                          <p className="text-gray-400 text-xs mb-0.5">Certificate ID</p>
                          <p className="font-mono font-bold text-[#ffa800] text-xl tracking-wider">{result.certificateId}</p>
                        </div>
                        <button onClick={handleCopyId}
                          className="p-2 rounded-xl bg-orange-50 hover:bg-orange-100 text-[#ffa800] transition-all">
                          {copied ? <Check className="w-4 h-4 text-green-500" /> : <Copy className="w-4 h-4" />}
                        </button>
                      </motion.div>

                      {/* Details grid */}
                      <motion.div
                        initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}
                        className="grid grid-cols-1 sm:grid-cols-2 gap-3"
                      >
                        <DetailCard icon={<User className="w-3.5 h-3.5" />}     label="Student Name"     value={result.studentName!} />
                        <DetailCard icon={<BookOpen className="w-3.5 h-3.5" />} label="Course"           value={result.courseName!} />
                        <DetailCard icon={<Award className="w-3.5 h-3.5" />}    label="Certificate Type" value={result.types!.join(', ')} />
                        <DetailCard icon={<Calendar className="w-3.5 h-3.5" />} label="Issued On"        value={formatDate(result.issuedAt!)} />
                      </motion.div>

                      {/* Status */}
                      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.4 }}
                        className="flex items-center gap-3">
                        <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold border
                          ${result.status === 'ready' ? 'bg-green-50 text-green-700 border-green-200' : 'bg-amber-50 text-amber-700 border-amber-200'}`}>
                          <motion.span
                            animate={{ scale: [1, 1.4, 1] }}
                            transition={{ duration: 1, repeat: Infinity, repeatDelay: 2 }}
                            className={`w-1.5 h-1.5 rounded-full inline-block ${result.status === 'ready' ? 'bg-green-500' : 'bg-amber-500'}`}
                          />
                          {result.status === 'ready' ? 'Active & Valid' : 'Processing'}
                        </span>
                        <span className="text-gray-400 text-xs">Issued by Adyapan Edutech Pvt. Ltd.</span>
                      </motion.div>

                      {/* Downloads */}
                      <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.45 }}
                        className="flex flex-col gap-3 pt-1">
                        {result.certificateFiles && result.certificateFiles.length > 0 ? (
                          <div className="space-y-2">
                            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Download Certificate Files</p>
                            {result.certificateFiles.map((f, i) => {
                              const isPdf = f.url.toLowerCase().includes('.pdf') || f.url.toLowerCase().includes('/pdf');
                              return (
                                <motion.a
                                  key={i}
                                  href={f.url} target="_blank" rel="noopener noreferrer" download
                                  initial={{ opacity: 0, x: -12 }}
                                  animate={{ opacity: 1, x: 0 }}
                                  transition={{ delay: 0.5 + i * 0.08 }}
                                  whileHover={{ scale: 1.01 }}
                                  whileTap={{ scale: 0.98 }}
                                  className="flex items-center gap-3 px-4 py-3 bg-[#ffa800] text-white rounded-2xl hover:bg-[#e69700] transition-all shadow-md shadow-[#ffa800]/20 group"
                                >
                                  <div className="w-9 h-9 rounded-xl bg-white/20 flex items-center justify-center shrink-0">
                                    {isPdf
                                      ? <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6zm-1 1.5L18.5 9H13V3.5z"/></svg>
                                      : <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M21 19V5a2 2 0 00-2-2H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/></svg>
                                    }
                                  </div>
                                  <div className="flex-1 min-w-0">
                                    <p className="font-semibold text-sm truncate">{f.name || `Certificate File ${i + 1}`}</p>
                                    <p className="text-white/70 text-xs">{isPdf ? 'PDF Document' : 'Image File'} · Click to download</p>
                                  </div>
                                  <Download className="w-4 h-4 text-white/70 shrink-0 group-hover:translate-y-0.5 transition-transform" />
                                </motion.a>
                              );
                            })}
                          </div>
                        ) : result.certificateUrl ? (
                          <motion.a whileHover={{ scale: 1.01 }} whileTap={{ scale: 0.98 }}
                            href={result.certificateUrl} target="_blank" rel="noopener noreferrer" download
                            className="flex items-center justify-center gap-2 px-5 py-3 bg-[#ffa800] text-white font-semibold rounded-2xl hover:bg-[#e69700] transition-all shadow-md shadow-[#ffa800]/20">
                            <Download className="w-5 h-5" /> Download Certificate
                          </motion.a>
                        ) : (
                          <div className="flex items-center justify-center gap-2 px-5 py-3 bg-gray-100 text-gray-400 rounded-2xl text-sm cursor-not-allowed">
                            <Download className="w-4 h-4" /> No files uploaded yet
                          </div>
                        )}

                        <button onClick={handleShare}
                          className="flex items-center justify-center gap-2 px-5 py-3 bg-white border border-gray-200 text-gray-700 font-medium rounded-2xl hover:bg-gray-50 transition-all text-sm shadow-sm">
                          {copied ? <><Check className="w-4 h-4 text-green-500" /> Copied!</> : <><Share2 className="w-4 h-4" /> Share Verification Link</>}
                        </button>
                      </motion.div>
                    </div>

                    {/* Footer */}
                    <div className="bg-gray-50 border-t border-gray-100 px-6 py-3 flex items-center justify-between">
                      <span className="text-gray-400 text-xs">adyapan.com/verify-certificate</span>
                      <div className="flex items-center gap-1 text-green-600 text-xs font-medium">
                        <CheckCircle2 className="w-3.5 h-3.5" /> Authentic
                      </div>
                    </div>
                  </div>
                ) : (
                  /* ── Invalid ── */
                  <motion.div
                    initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}
                    className="rounded-3xl border border-red-100 bg-white shadow-lg overflow-hidden"
                  >
                    <div className="bg-gradient-to-r from-red-500 to-rose-500 px-6 py-5 flex items-center gap-4">
                      <div className="w-11 h-11 rounded-full bg-white/25 flex items-center justify-center shrink-0">
                        <XCircle className="w-6 h-6 text-white" />
                      </div>
                      <div>
                        <p className="text-white font-bold text-lg">Certificate Not Found</p>
                        <p className="text-white/80 text-sm">We couldn't verify this certificate ID</p>
                      </div>
                    </div>
                    <div className="px-6 py-6 space-y-4">
                      <p className="text-gray-500 text-sm leading-relaxed">
                        No certificate with ID{' '}
                        <span className="font-mono font-semibold text-gray-800">{certId}</span>{' '}
                        was found. Please double-check and try again.
                      </p>
                      <ul className="text-gray-400 text-xs space-y-1.5 list-disc list-inside">
                        <li>Make sure there are no extra spaces or typos</li>
                        <li>IDs look like <span className="font-mono">ADYP-2026-K7HX3MQP</span></li>
                        <li>Contact <a href="mailto:support@adyapan.com" className="text-[#ffa800] hover:underline">support@adyapan.com</a> if this is an error</li>
                      </ul>
                      <button onClick={() => { setResult(null); setCertId(''); inputRef.current?.focus(); }}
                        className="w-full py-3 rounded-2xl bg-gray-100 text-gray-700 text-sm font-medium hover:bg-gray-200 transition-all">
                        Try Again
                      </button>
                    </div>
                  </motion.div>
                )}
              </motion.div>
            )}
          </AnimatePresence>
        </section>

        {/* ── How it works ─────────────────────────────── */}
        {!result && !loading && (
          <motion.section initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.3 }}
            className="max-w-4xl mx-auto px-4 sm:px-6 pb-20">
            <p className="text-center text-gray-400 text-xs font-semibold uppercase tracking-widest mb-8">How it works</p>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
              {[
                { step: '01', title: 'Enter Certificate ID',  desc: 'Type your certificate ID from the certificate document (e.g. ADYP-2026-XXXXXXXX)', icon: <Search     className="w-5 h-5 text-[#ffa800]" /> },
                { step: '02', title: 'Instant Verification',  desc: 'We check our secure database and return the result in seconds — no login required',  icon: <BadgeCheck className="w-5 h-5 text-[#ffa800]" /> },
                { step: '03', title: 'Download & Share',      desc: 'Download your certificate PDF and share the verified link with employers or colleges',  icon: <Download   className="w-5 h-5 text-[#ffa800]" /> },
              ].map((item, i) => (
                <motion.div key={item.step}
                  initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35 + i * 0.08 }}
                  className="bg-white border border-gray-100 rounded-2xl p-5 shadow-sm hover:shadow-md transition-shadow space-y-3">
                  <div className="flex items-center gap-2.5">
                    <span className="text-[#ffa800] text-xs font-bold">{item.step}</span>
                    {item.icon}
                  </div>
                  <p className="text-gray-900 font-semibold text-sm">{item.title}</p>
                  <p className="text-gray-400 text-xs leading-relaxed">{item.desc}</p>
                </motion.div>
              ))}
            </div>
          </motion.section>
        )}
      </div>
    </>
  );
}
