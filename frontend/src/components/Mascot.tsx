'use client';

import { useEffect, useRef, useState, useCallback } from 'react';
import { getMediaUrl } from '@/lib/media';

const KICK_DURATION_MS    = 1000;
const KICK_RELEASE_MS     = 160;
const BALL_DIAMETER_RATIO = 0.19;
const TOE_X               = 0.56;
const TOE_Y               = 0.90;

// Resolved through the centralized media helper so these heavy assets are
// served from the external store/CDN (S3 by default) instead of Vercel /public.
// If no media base is configured they fall back to the local /public path.
const ASSETS = {
  juggle:    getMediaUrl('/mascot/assets/mascot_juggle.webm'),
  juggleMp4: getMediaUrl('/mascot/assets/mascot_juggle.mp4'),
  kickPose:  getMediaUrl('/mascot/assets/mascot_kick.png'),
  ball:      getMediaUrl('/mascot/assets/ball_logo.png.png'),
};

const clamp   = (v: number, lo: number, hi: number) => Math.min(hi, Math.max(lo, v));
const easeOut = (t: number) => 1 - (1 - t) ** 3;
const wait    = (ms: number) => new Promise<void>(r => setTimeout(r, ms));

interface BallState {
  x: number; y: number;
  rot: number; scale: number;
  opacity: number; visible: boolean;
}

/* â"€â"€ Remove white/near-white pixels from canvas â"€â"€ */
function removeWhiteBg(ctx: CanvasRenderingContext2D, w: number, h: number) {
  const id   = ctx.getImageData(0, 0, w, h);
  const data = id.data;

  const isBgCandidate = (idx: number) => {
    const offset = idx * 4;
    return data[offset] > 224 && data[offset + 1] > 224 && data[offset + 2] > 224;
  };

  const visited = new Uint8Array(w * h);
  const queue: number[] = [];
  let head = 0;
  const push = (x: number, y: number) => {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    const idx = y * w + x;
    if (visited[idx] || !isBgCandidate(idx)) return;
    visited[idx] = 1;
    queue.push(idx);
  };

  for (let x = 0; x < w; x += 1) {
    push(x, 0);
    push(x, h - 1);
  }
  for (let y = 0; y < h; y += 1) {
    push(0, y);
    push(w - 1, y);
  }

  while (head < queue.length) {
    const idx = queue[head++];
    const x = idx % w;
    const y = Math.floor(idx / w);
    data[idx * 4 + 3] = 0;
    push(x + 1, y);
    push(x - 1, y);
    push(x, y + 1);
    push(x, y - 1);
  }

  ctx.putImageData(id, 0, 0);
}

/* â"€â"€ Pre-process a PNG image -> canvas with white removed (cached) â"€â"€ */
function processImage(src: string): Promise<HTMLCanvasElement> {
  return new Promise(resolve => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => {
      const c   = document.createElement('canvas');
      c.width   = img.naturalWidth;
      c.height  = img.naturalHeight;
      const ctx = c.getContext('2d', { willReadFrequently: true })!;
      ctx.drawImage(img, 0, 0);
      removeWhiteBg(ctx, c.width, c.height);
      resolve(c);
    };
    img.onerror = () => resolve(document.createElement('canvas'));
    img.src = src;
  });
}

// Caches
let kickPoseCache: HTMLCanvasElement | null = null;
let ballCache:     HTMLCanvasElement | null = null;

function getKickPoseCanvas(): Promise<HTMLCanvasElement> {
  if (kickPoseCache) return Promise.resolve(kickPoseCache);
  return processImage(ASSETS.kickPose).then(c => { kickPoseCache = c; return c; });
}

function getBallCanvas(): Promise<HTMLCanvasElement> {
  if (ballCache) return Promise.resolve(ballCache);
  return processImage(ASSETS.ball).then(c => { ballCache = c; return c; });
}

function drawCanvasToCanvas(src: HTMLCanvasElement, target: HTMLCanvasElement | null) {
  if (!target || !src.width) return;
  target.width = src.width;
  target.height = src.height;
  const ctx = target.getContext('2d');
  if (!ctx) return;
  ctx.clearRect(0, 0, target.width, target.height);
  ctx.drawImage(src, 0, 0);
}

export default function Mascot() {
  const stageRef        = useRef<HTMLDivElement>(null);
  const shellRef        = useRef<HTMLDivElement>(null);
  const videoRef        = useRef<HTMLVideoElement>(null);
  const juggleCanvasRef = useRef<HTMLCanvasElement>(null);
  const kickCanvasRef   = useRef<HTMLCanvasElement>(null);
  // Ball canvas is always mounted (never conditionally rendered) so ref is always valid
  const ballCanvasRef   = useRef<HTMLCanvasElement>(null);
  const rafRef          = useRef<number>(0);

  const [kicking, setKicking] = useState(false);
  const [facing,  setFacing]  = useState<'left' | 'right'>('right');
  const [ball,    setBall]    = useState<BallState>({
    x: 0, y: 0, rot: 0, scale: 1, opacity: 0, visible: false,
  });
  const [mounted, setMounted] = useState(false);
  const [ballD,   setBallD]   = useState(48);

  const lockedRef = useRef(false);
  const aidRef    = useRef(0);

  /* â"€â"€ Juggle video render loop â"€â"€ */
  const startRenderLoop = useCallback(() => {
    const video  = videoRef.current;
    const canvas = juggleCanvasRef.current;
    if (!video || !canvas) return;
    const ctx = canvas.getContext('2d', { willReadFrequently: true });
    if (!ctx) return;
    cancelAnimationFrame(rafRef.current);

    // Offscreen buffer: removeWhiteBg runs here once per decoded frame,
    // then composited to the visible canvas — no getImageData on display canvas.
    const offscreen = document.createElement('canvas');
    const offCtx = offscreen.getContext('2d', { willReadFrequently: true });

    const processFrame = () => {
      if (video.readyState < 2 || !video.videoWidth) return;
      const w = video.videoWidth, h = video.videoHeight;
      if (offscreen.width !== w)  offscreen.width  = w;
      if (offscreen.height !== h) offscreen.height = h;
      if (offCtx) {
        offCtx.clearRect(0, 0, w, h);
        offCtx.drawImage(video, 0, 0, w, h);
        removeWhiteBg(offCtx, w, h);
      }
      if (canvas.width !== w)  canvas.width  = w;
      if (canvas.height !== h) canvas.height = h;
      ctx.clearRect(0, 0, w, h);
      ctx.drawImage(offscreen, 0, 0);
    };

    // requestVideoFrameCallback (Chrome 83+): fires once per decoded video frame
    // instead of every rAF — reduces removeWhiteBg calls by ~80% on a 24fps video.
    const supportsRVFC = 'requestVideoFrameCallback' in video;

    if (supportsRVFC) {
      let rvfcId = 0;
      const onFrame = () => {
        processFrame();
        if (!video.paused && !video.ended) {
          rvfcId = (video as any).requestVideoFrameCallback(onFrame);
        }
      };
      rvfcId = (video as any).requestVideoFrameCallback(onFrame);
      rafRef.current = -1; // sentinel so cancelAnimationFrame(-1) is a no-op
      (rafRef as any)._rvfcCancel = () => {
        if (rvfcId) (video as any).cancelVideoFrameCallback(rvfcId);
      };
    } else {
      // rAF fallback — throttle to 24fps
      const INTERVAL = 1000 / 24;
      let lastT = 0;
      const draw = (ts: number) => {
        if (ts - lastT >= INTERVAL) { lastT = ts; processFrame(); }
        rafRef.current = requestAnimationFrame(draw);
      };
      rafRef.current = requestAnimationFrame(draw);
    }
  }, []);

  /* â"€â"€ Load juggle video â"€â"€ */
  const loadVideo = useCallback(() => {
    const v = videoRef.current;
    if (!v) return;
    // crossOrigin must be set before src for canvas taint rules
    v.crossOrigin = 'anonymous';
    v.loop  = true;
    v.muted = true;
    v.playsInline = true;
    // Try webm first (better browser support), fall back to mp4
    v.src   = ASSETS.juggle;
    v.load();
    v.play().catch(() => {
      // Fallback to mp4 if webm fails
      v.src = ASSETS.juggleMp4;
      v.crossOrigin = 'anonymous';
      v.load();
      v.play().catch(() => {});
    });
    v.addEventListener('playing', startRenderLoop, { once: true });
  }, [startRenderLoop]);

  /* â"€â"€ Pre-load kick pose + ball, then video — deferred to browser idle â"€â"€
     The mascot is decorative, so we defer its heavy assets (2.5MB webm etc.)
     until the browser is idle. This keeps them off the critical path so they
     don't compete with above-the-fold content, without changing behaviour. */
  useEffect(() => {
    let idleId: number | undefined;
    let started = false;

    const start = () => {
      if (started) return;
      started = true;
      loadVideo();
      getKickPoseCanvas();
      getBallCanvas();
    };

    const w = window as any;
    if (typeof w.requestIdleCallback === 'function') {
      idleId = w.requestIdleCallback(start, { timeout: 2500 });
    } else {
      idleId = window.setTimeout(start, 1200) as unknown as number;
    }

    const t = setTimeout(() => setMounted(true), 500);
    return () => {
      clearTimeout(t);
      if (idleId !== undefined) {
        if (typeof w.cancelIdleCallback === 'function') w.cancelIdleCallback(idleId);
        else clearTimeout(idleId);
      }
      cancelAnimationFrame(rafRef.current);
      // Also cancel requestVideoFrameCallback if it was used
      if ((rafRef as any)._rvfcCancel) (rafRef as any)._rvfcCancel();
    };
  }, [loadVideo]);

  /* â"€â"€ Update ball diameter on resize â"€â"€ */
  useEffect(() => {
    const update = () => {
      const stage = stageRef.current;
      if (stage) {
        setBallD(clamp(stage.clientWidth * BALL_DIAMETER_RATIO, 22, 120));
      }
    };
    update();
    window.addEventListener('resize', update);
    return () => window.removeEventListener('resize', update);
  }, []);

  /* â"€â"€ Draw kick pose onto kickCanvasRef â"€â"€ */
  const showKickPose = useCallback(async () => {
    const src = await getKickPoseCanvas();
    const c   = kickCanvasRef.current;
    if (!c || !src.width) return;
    c.width  = src.width;
    c.height = src.height;
    const ctx = c.getContext('2d')!;
    ctx.clearRect(0, 0, c.width, c.height);
    ctx.drawImage(src, 0, 0);
  }, []);

  /* â"€â"€ Core animation handler - accepts viewport coords â"€â"€ */
  const triggerKick = useCallback(async (clientX: number, clientY: number) => {
    if (lockedRef.current) return;
    lockedRef.current = true;

    const stage = stageRef.current;
    const shell = shellRef.current;
    if (!stage || !shell) { lockedRef.current = false; return; }

    const rect = stage.getBoundingClientRect();
    setFacing(clientX >= rect.left + rect.width / 2 ? 'right' : 'left');

    const sr    = shell.getBoundingClientRect();
    const toeVX = sr.left + shell.clientWidth  * TOE_X;
    const toeVY = sr.top  + shell.clientHeight * TOE_Y;

    // Stop juggle, show kick pose
    cancelAnimationFrame(rafRef.current);
    videoRef.current?.pause();
    await showKickPose();
    setKicking(true);

    await wait(KICK_RELEASE_MS);

    // Draw ball onto the always-mounted canvas
    const ballSrc = await getBallCanvas();
    drawCanvasToCanvas(ballSrc, ballCanvasRef.current);

    // Animate ball
    const aid   = ++aidRef.current;
    const start = { x: toeVX, y: toeVY };
    const end   = { x: clientX, y: clientY };
    const dist  = Math.hypot(end.x - start.x, end.y - start.y);
    const dur   = clamp(520 + dist * 0.45, 520, 1100);
    const arc   = clamp(dist * 0.22, 55, 200);
    const dir   = end.x >= start.x ? 1 : -1;
    const t0    = performance.now();

    // Mascot stage size -> target ball scale at impact
    const impactScale = 1.22;

    // Make ball visible at start position before animating
    setBall({ x: start.x, y: start.y, rot: 0, scale: 1, opacity: 1, visible: true });

    await new Promise<void>(resolve => {
      const step = (now: number) => {
        if (aid !== aidRef.current) { resolve(); return; }
        const t       = clamp((now - t0) / dur, 0, 1);
        const p       = easeOut(t);
        const x       = start.x + (end.x - start.x) * p;
        const y       = start.y + (end.y - start.y) * p - arc * 4 * p * (1 - p);
        const rot     = dir * Math.sin(p * Math.PI) * 10;

        // Travel: slight shrink -> on impact: burst to mascot size -> fade
        let scale: number;
        let opacity: number;
        if (t < 0.88) {
          // In-flight: subtle shrink (perspective effect)
          scale   = 1;
          opacity = 1;
        } else {
          // Impact phase: scale up to mascot size then fade out
          const ip = (t - 0.88) / 0.12;          // 0->1 during impact
          scale   = 1 + Math.sin(ip * Math.PI) * (impactScale - 1);
          opacity = 1 - ip;
        }

        setBall({ x, y, rot, scale, opacity, visible: true });
        if (t < 1) { requestAnimationFrame(step); return; }
        setTimeout(() => { setBall(b => ({ ...b, visible: false })); resolve(); }, 80);
      };
      requestAnimationFrame(step);
    });

    await wait(KICK_DURATION_MS - KICK_RELEASE_MS);
    setKicking(false);
    loadVideo();
    lockedRef.current = false;
  }, [loadVideo, showKickPose]);

  /* â"€â"€ Pointer event listener (handles mouse + touch + stylus) â"€â"€ */
  useEffect(() => {
    const onPointerDown = (e: PointerEvent) => {
      // Ignore if the click is on an interactive element (buttons, links, inputs)
      const target = e.target as HTMLElement;
      if (target.closest('a, button, input, textarea, select, [role="button"]')) return;
      triggerKick(e.clientX, e.clientY);
    };
    window.addEventListener('pointerdown', onPointerDown);
    return () => window.removeEventListener('pointerdown', onPointerDown);
  }, [triggerKick]);

  return (
    <>
      {/* â"€â"€ Mascot stage â"€â"€ */}
      <div
        ref={stageRef}
        aria-hidden="true"
        style={{
          position:      'fixed',
          left:          'max(8px, env(safe-area-inset-left))',
          bottom:        'max(8px, env(safe-area-inset-bottom))',
          width:         'clamp(110px, 18vw, 240px)',
          aspectRatio:   '1/1',
          zIndex:        50,
          pointerEvents: 'none',
          opacity:        mounted ? 1 : 0,
          transition:    'opacity 0.5s ease',
        }}
      >
        <div
          ref={shellRef}
          style={{
            position:        'absolute',
            inset:           0,
            transform:       `scaleX(${facing === 'right' ? 1 : -1})`,
            transformOrigin: '52% 88%',
            transition:      'transform 180ms ease-out',
          }}
        >
          {/* Hidden source video — preload none so the clip only downloads
              when loadVideo() runs on idle, not eagerly on page load. */}
          <video ref={videoRef} crossOrigin="anonymous" playsInline muted loop preload="none" style={{ display: 'none' }} />

          {/* Juggle canvas - white bg removed */}
          <canvas
            ref={juggleCanvasRef}
            style={{
              position: 'absolute', inset: 0,
              width: '100%', height: '100%',
              objectFit: 'contain', objectPosition: 'center bottom',
              pointerEvents: 'none',
              display: kicking ? 'none' : 'block',
            }}
          />

          {/* Kick pose canvas - white bg removed */}
          <canvas
            ref={kickCanvasRef}
            style={{
              position: 'absolute', inset: 0,
              width: '100%', height: '100%',
              objectFit: 'contain', objectPosition: 'center bottom',
              pointerEvents: 'none',
              display: kicking ? 'block' : 'none',
              animation: kicking
                ? 'mascot-kick-pop 1000ms cubic-bezier(0.25,0.9,0.35,1) both'
                : 'none',
            }}
          />
        </div>

      </div>

      {/* â"€â"€ Flying ball - always mounted so ref is always valid â"€â"€ */}
      <div
        aria-hidden="true"
        style={{
          position:      'fixed',
          zIndex:        60,
          width:         ballD,
          height:        ballD,
          left:          ball.x,
          top:           ball.y,
          transform:     `translate(-50%,-50%) rotate(${ball.rot}deg) scale(${ball.scale})`,
          opacity:        ball.visible ? ball.opacity : 0,
          pointerEvents: 'none',
          willChange:    'transform, opacity',
          // Hide visually when not in use but keep in DOM
          visibility:    ball.visible ? 'visible' : 'hidden',
        }}
      >
        <canvas
          ref={ballCanvasRef}
          style={{ width: '100%', height: '100%', display: 'block', objectFit: 'contain' }}
        />
      </div>

      {/* â"€â"€ Keyframes â"€â"€ */}
      <style>{`
        @keyframes mascot-kick-pop {
          0%   { transform: translateY(0)    rotate(0deg);  }
          20%  { transform: translateY(4px)  rotate(-4deg); }
          48%  { transform: translateY(-7px) rotate(7deg);  }
          100% { transform: translateY(0)    rotate(0deg);  }
        }
      `}</style>
    </>
  );
}
