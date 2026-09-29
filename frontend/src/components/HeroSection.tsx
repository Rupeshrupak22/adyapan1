'use client';

import React, { useState, useEffect, useRef, useMemo, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { s3Url } from '@/lib/s3Url';
import InternshipModal from './InternshipModal';

const WORDS = ['Sell', 'Launch', 'Brand', 'Grow', 'Build'];

const POPULAR = [
  'Artificial Intelligence', 'Data Science', 'Web Development',
  'Digital Marketing', 'Python Full Stack', 'UI/UX Design',
];

const cards = [
  {
    img: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?q=80&w=800&auto=format&fit=crop',
    label: 'Skills Assessment',
    sub: 'Industrial Skill Development',
    tag: 'Skills',
  },
  {
    img: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=800&auto=format&fit=crop',
    label: 'Career',
    sub: 'Minor & Major Projects',
    tag: 'Career',
  },
  {
    img: 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=800&auto=format&fit=crop',
    label: 'Placement',
    sub: '95% Placed*',
    tag: 'Placement',
  },
];

const ALL_COURSES = [
  'Artificial Intelligence','Machine Learning','Data Science','Web Development',
  'App Development','Python Full Stack','Java Full Stack','DevOps Engineering',
  'Cloud Computing','AWS','Cyber Security','UI/UX Design','Graphic Design',
  'Finance','Investment Banking','Digital Marketing','Social Media Marketing',
  'HRM','Supply Chain Management','Embedded Systems','IoT & Robotics',
  'AutoCAD','CATIA','Bioinformatics','Medical Coding','Construction Planning',
];

const HISTORY_KEY = 'adyapan_search_history';

function HeroSection() {
  const [wordIdx,  setWordIdx]  = useState(0);
  const [active,   setActive]   = useState(0);
  const [query,    setQuery]    = useState('');
  const [showDrop, setShowDrop] = useState(false);
  const [history,  setHistory]  = useState<string[]>([]);
  const [internOpen, setInternOpen] = useState(false);
  const sectionRef = useRef<HTMLElement>(null);
  const videoRef   = useRef<HTMLVideoElement>(null);
  const inputRef   = useRef<HTMLInputElement>(null);
  const router     = useRouter();

  const [isVisible, setIsVisible] = useState(true);

  /* IntersectionObserver & Tab Visibility to pause video & intervals */
  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;

    const obs = new IntersectionObserver(([entry]) => {
      setIsVisible(entry.isIntersecting);
    }, { threshold: 0.1 });

    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  /* Pause background video when offscreen or tab inactive */
  useEffect(() => {
    const v = videoRef.current;
    if (!v) return;

    const handleVisibility = () => {
      if (document.hidden || !isVisible) {
        v.pause();
      } else {
        v.play().catch(() => {});
      }
    };

    document.addEventListener('visibilitychange', handleVisibility);
    handleVisibility();

    return () => document.removeEventListener('visibilitychange', handleVisibility);
  }, [isVisible]);

  /* rotate words */
  useEffect(() => {
    if (!isVisible) return;

    const t = setInterval(() => {
      if (!document.hidden) {
        setWordIdx(i => (i + 1) % WORDS.length);
      }
    }, 2200);

    return () => clearInterval(t);
  }, [isVisible]);

  /* load search history from localStorage */
  useEffect(() => {
    try {
      const h = JSON.parse(localStorage.getItem(HISTORY_KEY) || '[]');
      setHistory(Array.isArray(h) ? h.slice(0, 6) : []);
    } catch { setHistory([]); }
  }, []);

  const saveToHistory = useCallback((term: string) => {
    try {
      const prev = JSON.parse(localStorage.getItem(HISTORY_KEY) || '[]') as string[];
      const next = [term, ...prev.filter(x => x !== term)].slice(0, 6);
      localStorage.setItem(HISTORY_KEY, JSON.stringify(next));
      setHistory(next);
    } catch {}
  }, []);

  const removeFromHistory = useCallback((term: string, e: React.MouseEvent) => {
    e.stopPropagation();
    try {
      setHistory(prev => {
        const next = prev.filter(x => x !== term);
        localStorage.setItem(HISTORY_KEY, JSON.stringify(next));
        return next;
      });
    } catch {}
  }, []);

  const slug = (s: string) =>
    s.toLowerCase().replace(/[^a-z0-9\s-]/g, '').replace(/\s+/g, '-').replace(/-+/g, '-').trim();

  const navigate = useCallback((term: string) => {
    saveToHistory(term);
    setShowDrop(false);
    setQuery(term);
    const match = ALL_COURSES.find(c => c.toLowerCase().includes(term.toLowerCase()));
    router.push(`/courses/${slug(match || term)}`);
  }, [router, saveToHistory]);

  const go = useCallback(() => { if (query.trim()) navigate(query.trim()); }, [query, navigate]);

  const isTyping = query.trim().length > 0;
  const suggestions = useMemo(() => {
    if (!isTyping) return [];
    const q = query.toLowerCase();
    return ALL_COURSES.filter(c => c.toLowerCase().includes(q)).slice(0, 7);
  }, [isTyping, query]);

  const showHistory = !isTyping && history.length > 0;
  const showPopular = !isTyping && history.length === 0;
  const dropVisible = showDrop && (suggestions.length > 0 || showHistory || showPopular);

  return (
    <>
    <section ref={sectionRef} className="relative overflow-hidden" style={{ minHeight: '92vh' }}>

      {/* Full background video (autoplay hero). preload=metadata avoids forcing
          a full eager download; the browser streams as it plays. */}
      <video
        ref={videoRef}
        src={s3Url('/videos/8126367-hd_1920_1080_25fps.mp4')}
        autoPlay
        muted
        loop
        playsInline
        preload="metadata"
        className="absolute inset-0 w-full h-full object-cover pointer-events-none"
        style={{ zIndex: 0 }}
      />

      {/* Overlay */}
      <div className="absolute inset-0 pointer-events-none" style={{
        zIndex: 1,
        background: 'transparent(105deg, rgba(250, 239, 239, 0.72) 0%, rgba(253, 246, 246, 0.57) 55%, rgba(248, 245, 245, 0.72) 100%)',
      }} />

      {/* Main content */}
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 w-full flex items-center"
        style={{ zIndex: 2, minHeight: '92vh' }}>
        <div className="w-full grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-10 items-center py-12 lg:py-16">

          {/* LEFT */}
          <div className="flex flex-col gap-6">

            {/* Headline (static render, no enter fade/slide) */}
            <h1
              className="font-black leading-[1.0] tracking-tight text-white"
              style={{ fontSize: 'clamp(52px, 7vw, 90px)' }}
            >
              Don't Just<br />Learn.<br />
              <span className="relative inline-block" style={{ minWidth: 220 }}>
                <span
                  style={{
                    display: 'inline-block',
                    color: '#f97316',
                    textShadow: '0 4px 24px rgba(249,115,22,0.5)',
                  }}
                >
                  {WORDS[wordIdx]}
                </span>
              </span>
              <br />Yourself.
            </h1>

            {/* Search bar */}
            <div className="relative w-full max-w-sm sm:max-w-md">
              <div className="flex items-stretch rounded-2xl overflow-hidden shadow-2xl"
                style={{ border: '2px solid rgba(255,255,255,0.25)' }}>
                <input
                  ref={inputRef}
                  type="text"
                  placeholder="Find your passion"
                  value={query}
                  autoComplete="off"
                  suppressHydrationWarning
                  onChange={e => {
                    setQuery(e.target.value);
                    setShowDrop(true);
                  }}
                  onFocus={() => setShowDrop(true)}
                  onBlur={() => setTimeout(() => setShowDrop(false), 180)}
                  onKeyDown={e => e.key === 'Enter' && go()}
                  className="flex-1 px-5 py-4 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"
                  style={{ background: 'rgba(255,255,255,0.95)' }}
                />
                <button
                  onClick={go}
                  className="px-7 py-4 font-black text-white text-sm hover:opacity-90 transition-opacity"
                  style={{ background: 'linear-gradient(135deg,#f97316,#ea580c)' }}
                >
                  Go
                </button>
              </div>

              {/* Dropdown */}
              {dropVisible && (
                <div
                  className="absolute top-full left-0 right-0 mt-2 rounded-2xl overflow-hidden shadow-2xl"
                  style={{
                    background: 'white',
                    border: '1px solid rgba(0,0,0,0.08)',
                    zIndex: 50,
                  }}
                >
                  {isTyping && suggestions.map((c, i) => (
                    <button key={i}
                      onMouseDown={() => navigate(c)}
                      className="w-full text-left px-5 py-3 text-sm font-medium text-gray-800 hover:bg-orange-50 hover:text-orange-600 border-b border-gray-100 last:border-0 transition-colors flex items-center gap-2"
                    >
                      <svg className="w-3.5 h-3.5 text-orange-400 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                      </svg>
                      {c}
                    </button>
                  ))}

                  {showHistory && (
                    <>
                      <div className="px-5 pt-3 pb-1 flex items-center justify-between">
                        <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Recent Searches</span>
                        <button
                          onMouseDown={() => {
                            localStorage.removeItem(HISTORY_KEY);
                            setHistory([]);
                          }}
                          className="text-[10px] text-orange-400 hover:text-orange-600 font-semibold"
                        >
                          Clear all
                        </button>
                      </div>
                      {history.map((h, i) => (
                        <button key={i}
                          onMouseDown={() => navigate(h)}
                          className="w-full text-left px-5 py-3 text-sm font-medium text-gray-700 hover:bg-orange-50 hover:text-orange-600 border-b border-gray-100 last:border-0 transition-colors flex items-center gap-2 group"
                        >
                          <svg className="w-3.5 h-3.5 text-gray-400 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                            <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                          </svg>
                          <span className="flex-1">{h}</span>
                          <span
                            onMouseDown={e => removeFromHistory(h, e)}
                            className="opacity-0 group-hover:opacity-100 text-gray-300 hover:text-red-400 transition-all text-base leading-none px-1"
                          >
                            ×
                          </span>
                        </button>
                      ))}
                    </>
                  )}

                  {showPopular && (
                    <>
                      <div className="px-5 pt-3 pb-1">
                        <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Popular Courses</span>
                      </div>
                      {POPULAR.map((p, i) => (
                        <button key={i}
                          onMouseDown={() => navigate(p)}
                          className="w-full text-left px-5 py-3 text-sm font-medium text-gray-700 hover:bg-orange-50 hover:text-orange-600 border-b border-gray-100 last:border-0 transition-colors flex items-center gap-2"
                        >
                          <svg className="w-3.5 h-3.5 text-orange-400 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                            <path strokeLinecap="round" strokeLinejoin="round" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                          </svg>
                          {p}
                        </button>
                      ))}
                    </>
                  )}
                </div>
              )}
            </div>

            {/* Stats */}
            <div className="flex items-center gap-8 flex-wrap">
              {[
                { n: '10K+', l: 'Students' },
                { n: '70+',  l: 'Programs' },
                { n: '95%*', l: 'Placement' },
              ].map(({ n, l }) => (
                <div key={l} className="text-white">
                  <div className="font-black text-2xl leading-none">{n}</div>
                  <div className="text-white/70 text-xs font-semibold mt-0.5 uppercase tracking-wider">{l}</div>
                </div>
              ))}
            </div>

            {/* Hiring Partners */}
            <div>
              <div className="text-white/50 text-xs font-semibold uppercase tracking-widest mb-3">Top Hiring Partners</div>
              <div className="flex items-center gap-3 flex-wrap">
                {[
                  { name: 'Wipro',   img: 'https://upload.wikimedia.org/wikipedia/commons/a/a0/Wipro_Primary_Logo_Color_RGB.svg' },
                  { name: 'Infosys', img: 'https://upload.wikimedia.org/wikipedia/commons/9/95/Infosys_logo.svg' },
                ].map(({ name, img }) => (
                  <div
                    key={name}
                    className="flex items-center gap-2 px-3 py-2 rounded-xl bg-white/10 backdrop-blur-sm border border-white/20"
                  >
                    <img src={img} alt={name} className="h-5 w-auto object-contain brightness-0 invert" />
                    <span className="text-white text-xs font-bold">{name}</span>
                  </div>
                ))}
                <div className="text-white/40 text-xs font-medium">+ 148 more</div>
              </div>
            </div>

            {/* Apply for Internship button */}
            <div>
              <button
                onClick={() => setInternOpen(true)}
                className="inline-flex items-center gap-2 px-6 py-3 rounded-full font-bold text-sm text-white transition-all duration-200 hover:-translate-y-0.5 hover:shadow-xl"
                style={{ background: 'linear-gradient(135deg, #f97316, #ea580c)', boxShadow: '0 8px 24px rgba(249,115,22,0.4)' }}
              >
                🚀 Apply for Internship
              </button>
            </div>
          </div>

          {/* RIGHT - expanding cards */}
          <div
            className="hidden lg:flex gap-3 items-end"
            style={{ height: 480 }}
          >
            {cards.map((card, i) => {
              const isActive = i === active;
              return (
                <div
                  key={i}
                  onClick={() => setActive(i)}
                  onMouseEnter={() => setActive(i)}
                  className="relative rounded-3xl overflow-hidden cursor-pointer flex-shrink-0 transition-all duration-300"
                  style={{
                    flex: isActive ? 2.5 : 0.65,
                    height: isActive ? '100%' : '72%',
                    minWidth: 0,
                    boxShadow: isActive
                      ? '0 28px 64px rgba(0,0,0,0.5), 0 0 0 3px rgba(249,115,22,0.7)'
                      : '0 8px 24px rgba(0,0,0,0.35)',
                  }}
                >
                  <div className="relative w-full h-full">
                    <Image
                      src={card.img}
                      alt={card.label}
                      fill
                      sizes="(max-width: 1024px) 0px, 33vw"
                      className="object-cover"
                      priority={i === 0}
                    />
                  </div>
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/10 to-transparent" />

                  {isActive && (
                    <div className="absolute bottom-0 left-0 right-0 p-5">
                      <div className="text-white font-black text-lg leading-tight">{card.label}</div>
                      <div className="text-white/60 text-xs uppercase tracking-widest mt-1">{card.sub}</div>
                    </div>
                  )}

                  {!isActive && (
                    <div className="absolute bottom-0 left-0 right-0 p-3 flex justify-center">
                      <div
                        className="px-3 py-2 rounded-xl text-white font-bold text-xs"
                        style={{
                          background: 'rgba(0,0,0,0.65)',
                          writingMode: 'vertical-rl',
                          transform: 'rotate(180deg)',
                        }}
                      >
                        {card.tag}
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
    <InternshipModal isOpen={internOpen} onClose={() => setInternOpen(false)} />
    </>
  );
}

export default React.memo(HeroSection);
