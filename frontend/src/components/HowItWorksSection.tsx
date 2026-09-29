'use client';

import React, { useEffect, useRef, useState } from 'react';
import { Play, Square, Volume2, VolumeX } from 'lucide-react';
import { s3Url } from '@/lib/s3Url';

const pillars = [
  {
    icon: (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
      </svg>
    ),
    title: 'Verified Skills',
    desc: 'Every skill you earn is blockchain-verified and trusted by top companies',
  },
  {
    icon: (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
      </svg>
    ),
    title: 'Real Projects',
    desc: 'Work on actual business tasks from companies and build your portfolio',
  },
  {
    icon: (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M13 10V3L4 14h7v7l9-11h-7z" />
      </svg>
    ),
    title: 'Direct Placement',
    desc: 'Top performers get flagged for full-time interviews by the same companies',
  },
];

const HowItWorksSection = () => {
  const sectionRef = useRef<HTMLElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isMuted, setIsMuted] = useState(true);
  const [activeVideoIndex, setActiveVideoIndex] = useState(0);

  const videoSources = [
    s3Url('/videos/final-web-video.mp4'),
    s3Url('/videos/1.mp4'),
    s3Url('/videos/3.mp4'),
  ];

  /* IntersectionObserver to pause video when offscreen or tab inactive */
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting || document.hidden) {
          video.pause();
        } else {
          video.play().catch(() => { });
        }
      },
      { threshold: 0.15 }
    );

    if (sectionRef.current) {
      observer.observe(sectionRef.current);
    }

    const handleVisibility = () => {
      if (document.hidden) {
        video.pause();
      }
    };
    document.addEventListener('visibilitychange', handleVisibility);

    return () => {
      observer.disconnect();
      document.removeEventListener('visibilitychange', handleVisibility);
    };
  }, [activeVideoIndex]);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    video.load();
    const playPromise = video.play();
    if (playPromise) {
      playPromise
        .then(() => setIsPlaying(true))
        .catch(() => setIsPlaying(false));
    }
  }, [activeVideoIndex]);

  const togglePlayback = () => {
    const video = videoRef.current;
    if (!video) return;

    if (video.paused) {
      video.play()
        .then(() => setIsPlaying(true))
        .catch(() => setIsPlaying(false));
      return;
    }

    video.pause();
    video.currentTime = 0;
    setIsPlaying(false);
  };

  const toggleMute = () => {
    const nextMuted = !isMuted;
    setIsMuted(nextMuted);
    if (videoRef.current) {
      videoRef.current.muted = nextMuted;
    }
  };

  return (
    <section ref={sectionRef} id="skills" className="bg-[#f5f0eb] py-20 px-6">
      <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">

        {/* Left */}
        <div>
          <h2 className="text-4xl md:text-5xl font-extrabold text-[#1a1a2e] leading-tight mb-4 tracking-tight">
            Where India's Students<br />
            <span style={{ color: '#f90' }}>Learn Skills, Earn Income</span><br />
            &amp; Get Hired<span style={{ color: '#f90' }}>.</span>
          </h2>

          <p className="text-gray-500 text-base mb-10 max-w-sm leading-relaxed">
            The modern job market demands more than a degree. Adyapan gives you
            verified skills, real project experience, and a direct path to employment.
          </p>

          {/* Pillars */}
          <div className="space-y-6">
            {pillars.map((p, i) => (
              <div
                key={i}
                className="flex items-start space-x-4 cursor-default group"
              >
                <div className="w-10 h-10 rounded-full border border-[#e0d8d0] bg-white flex items-center justify-center flex-shrink-0 text-[#1a1a2e] group-hover:border-[#f90] transition-colors">
                  {p.icon}
                </div>
                <div>
                  <div className="font-bold text-[#1a1a2e] mb-1">{p.title}</div>
                  <div className="text-gray-400 text-sm leading-relaxed">{p.desc}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Right video */}
        <div className="relative w-full max-w-[360px] mx-auto lg:ml-auto lg:mr-10">
          {/* Stats card */}
          <div className="absolute -top-6 -left-4 z-10 bg-[#d8e8c8] rounded-2xl px-6 py-4 flex gap-8 shadow-sm">
            <div>
              <span className="text-3xl font-extrabold text-[#1a1a2e]">10K+</span>
              <span className="text-xs text-gray-500 block uppercase tracking-wider mt-0.5">Active Learners</span>
            </div>
            <div className="w-px bg-[#c0d0b0]" />
            <div>
              <span className="text-3xl font-extrabold text-[#1a1a2e]">150+</span>
              <span className="text-xs text-gray-500 block uppercase tracking-wider mt-0.5">Partner Companies</span>
            </div>
          </div>

          {/* Main video */}
          <div className="rounded-3xl overflow-hidden aspect-[9/16] bg-[#c8d4d8] relative">
            <video
              key={videoSources[activeVideoIndex]}
              ref={videoRef}
              src={videoSources[activeVideoIndex]}
              aria-label="Adyapan students and learning experience"
              autoPlay
              loop
              muted={isMuted}
              playsInline
              preload="metadata"
              onCanPlay={() => {
                if (videoRef.current && !document.hidden) {
                  videoRef.current.play()
                    .then(() => setIsPlaying(true))
                    .catch(() => setIsPlaying(false));
                }
              }}
              onError={() => {
                setActiveVideoIndex((currentIndex) =>
                  currentIndex < videoSources.length - 1 ? currentIndex + 1 : 0
                );
              }}
              onPlay={() => setIsPlaying(true)}
              onPause={() => setIsPlaying(false)}
              className="w-full h-full object-cover"
            >
              <source src={videoSources[activeVideoIndex]} type="video/mp4" />
            </video>
          </div>

          {/* Video controls */}
          <div className="absolute bottom-4 right-4 z-10 flex gap-2">
            <button
              type="button"
              aria-label={isPlaying ? 'Stop video' : 'Play video'}
              onClick={togglePlayback}
              className="w-10 h-10 bg-white/90 rounded-full flex items-center justify-center shadow-md hover:bg-white hover:scale-105 transition-all text-[#1a1a2e]"
            >
              {isPlaying ? <Square className="w-4 h-4" fill="currentColor" /> : <Play className="w-4 h-4 ml-0.5" fill="currentColor" />}
            </button>
            <button
              type="button"
              aria-label={isMuted ? 'Unmute video' : 'Mute video'}
              onClick={toggleMute}
              className="w-10 h-10 bg-white/90 rounded-full flex items-center justify-center shadow-md hover:bg-white hover:scale-105 transition-all text-[#1a1a2e]"
            >
              {isMuted ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
            </button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default React.memo(HowItWorksSection);
