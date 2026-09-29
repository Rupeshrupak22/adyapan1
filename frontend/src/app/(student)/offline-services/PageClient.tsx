'use client';

import { s3Url } from '@/lib/s3Url';
import Image from 'next/image';
import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  IndianRupee,
  Award,
  Gift,
  Building2,
  FolderOpen,
  MessageSquare,
  Calendar,
  Tablet,
  Video,
  Target,
  CheckCircle,
  ChevronDown,
  Shirt,
  Star,
  Sparkles,
  ArrowRight,
  Download,
  Check,
  Clock,
  Send,
  Phone,
  Users,
  ShieldCheck,
  Trophy,
  Zap,
  Briefcase,
  FileText,
  GraduationCap,
  X,
  MessageCircle,
} from 'lucide-react';
import EmailField from '@/components/forms/EmailField';
import PhoneField from '@/components/forms/PhoneField';
import { isIndianMobile, INDIAN_MOBILE_MESSAGE } from '@/lib/phone';
import { isValidEmail, EMAIL_FORMAT_MESSAGE } from '@/lib/email-format';

/* â"€â"€ Counselor contact details â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
const COUNSELOR_PHONE = '8179124566';
const COUNSELOR_WA    = `https://wa.me/91${COUNSELOR_PHONE}?text=${encodeURIComponent('Hi Adyapan Team, I want to know about offline internship')}`;

/* â"€â"€ Toast component â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
function Toast({
  message, type, onClose,
}: {
  message: string;
  type: 'success' | 'error';
  onClose: () => void;
}) {
  useEffect(() => {
    const t = setTimeout(onClose, 5000);
    return () => clearTimeout(t);
  }, [onClose]);

  return (
    <div
      className={`fixed bottom-6 left-1/2 z-[9999] flex w-[calc(100vw-2rem)] max-w-md -translate-x-1/2 items-start gap-3 rounded-2xl px-5 py-4 shadow-2xl ${
        type === 'success'
          ? 'border border-green-200 bg-green-50 text-green-800'
          : 'border border-red-200 bg-red-50 text-red-800'
      }`}
    >
      <span className="mt-0.5 flex-shrink-0 text-lg">
        {type === 'success' ? '' : ''}
      </span>
      <p className="flex-1 text-sm font-semibold leading-snug">{message}</p>
      <button
        onClick={onClose}
        suppressHydrationWarning
        className="flex-shrink-0 rounded-lg p-1 opacity-60 hover:opacity-100 transition-opacity"
      >
        <X className="h-4 w-4" />
      </button>
    </div>
  );
}

/* â"€â"€ Counselor Modal â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
function CounselorModal({ onClose }: { onClose: () => void }) {
  // Close on Escape key
  useEffect(() => {
    const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-[9998] flex items-center justify-center p-4"
      onClick={(e) => { if (e.target === e.currentTarget) onClose(); }}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />

      {/* Modal */}
      <div
        className="relative w-full max-w-sm overflow-hidden rounded-3xl bg-white shadow-[0_32px_80px_rgba(0,0,0,0.28)]"
      >
          {/* Header */}
          <div className="bg-gradient-to-r from-[#ffa800] to-[#f97316] px-6 py-6 text-white">
            <button
              onClick={onClose}
              suppressHydrationWarning
              className="absolute right-4 top-4 rounded-xl bg-white/20 p-1.5 text-white hover:bg-white/30 transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
            <div className="flex items-center gap-3">
              <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-white/20">
                <Phone className="h-6 w-6 text-white" />
              </div>
              <div>
                <h3 className="text-xl font-black">Talk to Counselor</h3>
                <p className="text-sm text-white/85">We're here to help you enroll</p>
              </div>
            </div>
          </div>

          {/* Body */}
          <div className="px-6 py-6">
            <p className="mb-5 text-sm leading-relaxed text-gray-600">
              Call or WhatsApp our counselor for admission guidance, batch details, and stipend eligibility.
            </p>

            {/* Phone number display */}
            <div className="mb-5 flex items-center gap-3 rounded-2xl border border-orange-100 bg-orange-50 px-4 py-3">
              <Phone className="h-5 w-5 flex-shrink-0 text-orange-500" />
              <div>
                <p className="text-xs font-bold uppercase tracking-wider text-orange-400">Counselor</p>
                <p className="text-xl font-black text-[#111827]">{COUNSELOR_PHONE}</p>
              </div>
            </div>

            {/* Action buttons */}
            <div className="flex flex-col gap-3">
              <a
                href={`tel:${COUNSELOR_PHONE}`}
                className="flex items-center justify-center gap-2 rounded-2xl bg-gradient-to-r from-[#ffa800] to-[#f97316] px-6 py-3.5 font-black text-white shadow-lg transition-all hover:-translate-y-0.5 hover:shadow-xl"
              >
                <Phone className="h-5 w-5" />
                Call Now
              </a>
              <a
                href={COUNSELOR_WA}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center justify-center gap-2 rounded-2xl border-2 border-[#25D366] bg-[#25D366]/10 px-6 py-3.5 font-black text-[#128C7E] transition-all hover:bg-[#25D366]/20"
              >
                <MessageCircle className="h-5 w-5" />
                WhatsApp
              </a>
              <button
                type="button"
                onClick={onClose}
                suppressHydrationWarning
                className="rounded-2xl border border-gray-200 px-6 py-3 text-sm font-bold text-gray-500 transition hover:border-gray-300 hover:bg-gray-50"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      </div>
  );
}

const stagger = {
  hidden: {},
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.08 } },
};

const features = [
  { icon: FolderOpen, title: 'Practical Projects & Real Training', desc: 'Build portfolio-ready projects with guided labs, reviews, and practical offline mentoring.' },
  { icon: Building2, title: 'Industry Visits & Exposure', desc: 'See real teams, tools, workflows, and workplace expectations up close.' },
  { icon: MessageSquare, title: 'Offline Mock Interview Prep', desc: 'Practice technical, HR, and confidence rounds with industry-focused feedback.' },
  { icon: Calendar, title: 'Flexible Offline Classes', desc: 'Choose morning, evening, weekend, or flexible batches based on your college schedule.' },
  { icon: Gift, title: 'T-Shirt & Goodies Included', desc: 'Get an Adyapan internship kit that makes the program feel official from day one.' },
  { icon: Award, title: 'Special Internship Certificate', desc: 'Earn a certificate that highlights your project work, training, and internship experience.' },
  { icon: Tablet, title: 'Tablet Support & Resources', desc: 'Access structured learning materials and device support for smoother practice.' },
  { icon: Video, title: 'Offline Recorded Sessions', desc: 'Revisit every lecture recording so revision stays simple after class.' },
  { icon: Target, title: 'Placement Support Till Placement', desc: 'Resume guidance, interview prep, mentor sessions, and recruiter connections continue until placement.' },
  { icon: IndianRupee, title: 'Stipend up to Rs. 15,000', desc: 'High-performing students can qualify for stipend opportunities up to Rs. 15,000.' },
];

const journey = [
  {
    title: 'Enroll',
    desc:  'Submit your details and reserve your offline internship seat.',
    img:   'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&q=80',
    alt:   'Person filling enrollment form on laptop',
  },
  {
    title: 'Attend Offline Training',
    desc:  'Learn from mentors in a focused classroom environment.',
    img:   'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=400&q=80',
    alt:   'Students attending classroom training session',
  },
  {
    title: 'Build Practical Projects',
    desc:  'Create real projects that prove your skills.',
    img:   'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400&q=80',
    alt:   'Developer coding a real project on computer',
  },
  {
    title: 'Mock Interviews',
    desc:  'Prepare with offline interview rounds and feedback.',
    img:   'https://images.unsplash.com/photo-1565688534245-05d6b5be184a?w=400&q=80',
    alt:   'Two people in a professional interview setting',
  },
  {
    title: 'Industry Visit',
    desc:  'Experience how professional teams work in real companies.',
    img:   'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400&q=80',
    alt:   'Modern office with professional team working',
  },
  {
    title: 'Placement + Stipend',
    desc:  'Get placement support and stipend opportunity up to Rs. 15,000.',
    img:   'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=400&q=80',
    alt:   'Professional handshake for job placement',
  },
];

const kit = [
  {
    icon: Shirt,
    title: 'Adyapan T-Shirt',
    desc: 'Premium program merchandise for offline interns.',
    img: 'https://images.unsplash.com/photo-1779880437508-34fc25ce495c?w=400&q=80',
    alt: 'Orange branded t-shirt',
  },
  {
    icon: Gift,
    title: 'Goodies',
    desc: 'Useful starter kit items for your classroom journey.',
    img: 'https://images.unsplash.com/photo-1607344645866-009c320b63e0?w=400&q=80',
    alt: 'Gift box with goodies',
  },
  {
    icon: Tablet,
    title: 'Tablet Support',
    desc: 'Device support and digital practice access.',
    img: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&q=80',
    alt: 'Digital tablet device',
  },
  {
    icon: Award,
    title: 'Special Certificate',
    desc: 'Internship certificate for your resume and LinkedIn.',
    img: 'https://images.unsplash.com/photo-1589330694653-ded6df03f754?w=400&q=80',
    alt: 'Achievement certificate with award',
  },
];

const placement = [
  'Resume guidance',
  'Mock interviews',
  'Industry mentor sessions',
  'Interview preparation',
  'Recruiter connections',
  'Stipend opportunity up to Rs. 15,000',
];

const testimonials = [
  { name: 'Rahul Sharma', role: 'Web Development Intern', quote: 'The offline training made me consistent. Projects, mock interviews, and mentor reviews helped me talk confidently in interviews.' },
  { name: 'Priya Patel', role: 'Data Science Intern', quote: 'The industry visit and recorded sessions were a huge advantage. I could revise every class and improve my project step by step.' },
  { name: 'Arjun Singh', role: 'AI/ML Intern', quote: 'Adyapan felt serious and premium from day one. The certificate, kit, and placement guidance gave the program real value.' },
];

const faqs = [
  { q: 'Who can apply for this offline internship?', a: 'Students from graduation, post-graduation, engineering, management, commerce, and related streams can apply.' },
  { q: 'Is the program fully offline?', a: 'Yes. The training is designed around offline classes, practical labs, mock interviews, and mentor-led sessions.' },
  { q: 'Will I get recorded sessions?', a: 'Yes. Recorded sessions are provided for every lecture so you can revise after class.' },
  { q: 'What is the stipend amount?', a: 'Eligible students can get stipend opportunities up to Rs. 15,000 based on performance, projects, and available opportunities.' },
  { q: 'Do you provide placement support?', a: 'Yes. Adyapan provides placement support till placement through resume guidance, interview prep, mentors, and recruiter connections.' },
  { q: 'Can I choose my batch timing?', a: 'Yes. Preferred batches include morning, evening, weekend, and flexible options based on student demand.' },
];

const companies = [
  {
    name: 'TCS',
    logo: s3Url('/logos/companies/tcs.png'),       
    color: 'from-blue-500 to-blue-700',
    bg: 'from-blue-500/20 to-blue-700/20',
  },
  {
    name: 'Infosys',
    logo: s3Url('/logos/companies/infosys.png'),        
    color: 'from-indigo-500 to-indigo-700',
    bg: 'from-indigo-500/20 to-indigo-700/20',
  },
  {
    name: 'Wipro',
    logo: s3Url('/logos/companies/wipro.png'),          
    color: 'from-purple-500 to-purple-700',
    bg: 'from-purple-500/20 to-purple-700/20',
  },
  {
    name: 'HCL',
    logo: s3Url('/logos/companies/hcl.png'),           
    color: 'from-green-500 to-green-700',
    bg: 'from-green-500/20 to-green-700/20',
  },
  {
    name: 'Tech Mahindra',
    logo: s3Url('/logos/companies/techmahindra.png'), 
    color: 'from-red-500 to-red-700',
    bg: 'from-red-500/20 to-red-700/20',
  },
  {
    name: 'Accenture',
    logo: s3Url('/logos/companies/accenture.png'),      
    color: 'from-violet-500 to-violet-700',
    bg: 'from-violet-500/20 to-violet-700/20',
  },
  {
    name: 'Cognizant',
    logo: s3Url('/logos/companies/cognizant.png'),     
    color: 'from-blue-400 to-cyan-600',
    bg: 'from-blue-400/20 to-cyan-600/20',
  },
  {
    name: 'Capgemini',
    logo: s3Url('/logos/companies/capgemini.png'),      
    color: 'from-sky-500 to-sky-700',
    bg: 'from-sky-500/20 to-sky-700/20',
  },
  {
    name: 'IBM',
    logo: s3Url('/logos/companies/ibm.png'),            
    color: 'from-blue-600 to-blue-900',
    bg: 'from-blue-600/20 to-blue-900/20',
  },
  {
    name: 'Deloitte',
    logo: s3Url('/logos/companies/deloitte.png'),      
    color: 'from-emerald-500 to-emerald-700',
    bg: 'from-emerald-500/20 to-emerald-700/20',
  },
];
const courses = ['Web Development', 'Data Science', 'AI/ML', 'Digital Marketing', 'UI/UX Design', 'Python Full Stack', 'Java Full Stack', 'Other'];
const batches = ['Morning Batch', 'Evening Batch', 'Weekend Batch', 'Flexible Batch'];

const initialForm = {
  name: '',
  phone: '',
  email: '',
  college: '',
  courseInterest: '',
  preferredBatch: '',
  city: '',
};

function SectionIntro({ kicker, title, desc, titleClassName, descClassName }: { kicker: string; title: string; desc?: string; titleClassName?: string; descClassName?: string }) {
  return (
    <div
      className="mx-auto mb-12 max-w-3xl text-center"
    >
      <p className="mb-3 text-xs font-black uppercase tracking-[0.24em] text-orange-500">{kicker}</p>
      <h2 className={`text-3xl font-black leading-tight sm:text-4xl lg:text-5xl ${titleClassName ?? 'text-[#111827]'}`}>{title}</h2>
      {desc && <p className={`mt-4 text-base leading-7 sm:text-lg ${descClassName ?? 'text-gray-600'}`}>{desc}</p>}
    </div>
  );
}

export default function OfflineServicesPage() {
  const [openFaq, setOpenFaq]           = useState<number | null>(0);
  const [form, setForm]                 = useState(initialForm);
  const [loading, setLoading]           = useState(false);
  const [showCounselor, setShowCounselor] = useState(false);
  const [toast, setToast]               = useState<{ message: string; type: 'success' | 'error' } | null>(null);

  const closeToast     = useCallback(() => setToast(null), []);
  const closeCounselor = useCallback(() => setShowCounselor(false), []);

  const scrollToForm = () =>
    document.getElementById('enroll-form')?.scrollIntoView({ behavior: 'smooth', block: 'start' });

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (!isValidEmail(form.email)) {
      setToast({ type: 'error', message: EMAIL_FORMAT_MESSAGE });
      return;
    }
    if (!isIndianMobile(form.phone)) {
      setToast({ type: 'error', message: INDIAN_MOBILE_MESSAGE });
      return;
    }

    setLoading(true);
    setToast(null);

    try {
      const res  = await fetch('/api/offline-leads', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(form),
      });
      const data = await res.json();

      if (res.status === 503) {
        setToast({ type: 'error', message: 'Database connection failed. Please try again later.' });
        return; // keep form data
      }

      if (res.status === 409) {
        setToast({ type: 'error', message: data.error || 'You have already submitted an enquiry in the last 24 hours.' });
        return; // keep form data
      }

      if (!res.ok) {
        setToast({ type: 'error', message: data.error || 'Something went wrong. Please try again.' });
        return; // keep form data
      }

      // Success
      setToast({ type: 'success', message: 'Enrollment submitted successfully. Our counselor will contact you soon.' });
      setForm(initialForm); // reset only on success
    } catch {
      setToast({ type: 'error', message: 'Network error. Please check your connection and try again.' });
      // keep form data on network error
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen overflow-x-hidden bg-white text-[#111827]">
      {/* â"€â"€ Toast â"€â"€ */}
      
        {toast && <Toast message={toast.message} type={toast.type} onClose={closeToast} />}
      

      {/* â"€â"€ Counselor Modal â"€â"€ */}
      {showCounselor && <CounselorModal onClose={closeCounselor} />}
      <section className="relative isolate overflow-hidden bg-[#11121f] px-4 pb-16 pt-16 text-white sm:px-6 lg:px-8 lg:pb-24 lg:pt-20">
        <div className="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_20%_20%,rgba(255,168,0,0.30),transparent_28%),radial-gradient(circle_at_82%_8%,rgba(249,115,22,0.22),transparent_26%),linear-gradient(135deg,#11121f_0%,#17172b_50%,#080913_100%)]" />
        <div
          className="absolute left-1/2 top-20 -z-10 h-80 w-80 -translate-x-1/2 rounded-full bg-orange-500/25 blur-3xl"
        />
        <div className="absolute inset-0 -z-10 bg-[linear-gradient(rgba(255,255,255,0.035)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.035)_1px,transparent_1px)] bg-[size:72px_72px]" />

        <div className="mx-auto grid max-w-7xl items-center gap-12 lg:grid-cols-[1.02fr_0.98fr]">
          <div className="relative z-10">
            <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-orange-300/30 bg-white/10 px-4 py-2 text-sm font-bold text-orange-100 shadow-[0_0_30px_rgba(255,168,0,0.16)] backdrop-blur-xl">
              <Sparkles className="h-4 w-4 text-[#ffa800]" />
              Stipend up to Rs. 15,000 + Placement Support Till Placement
            </div>

            <h1 className="max-w-4xl text-4xl font-black leading-[1.03] tracking-tight sm:text-6xl lg:text-7xl">
              6-Month Offline Internship Program
            </h1>

            <p className="mt-6 max-w-2xl text-lg leading-8 text-white/76 sm:text-xl">
              Learn practically, build real projects, prepare for interviews, and become industry-ready with offline training.
            </p>

            <div className="mt-6 flex flex-wrap items-center gap-2 text-sm font-semibold text-white/82">
              {['Offline Classes', 'Practical Projects', 'Industry Mentors'].map((item) => (
                <span key={item} className="rounded-full border border-white/10 bg-white/8 px-3 py-1.5 backdrop-blur">
                  {item}
                </span>
              ))}
            </div>

            <div className="relative mt-9 flex flex-col gap-3 sm:flex-row">
              <div className="absolute -inset-4 -z-10 rounded-full bg-orange-500/20 blur-2xl" />
              <button
                type="button"
                onClick={scrollToForm}
                suppressHydrationWarning
                className="inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-gradient-to-r from-[#ffa800] to-[#f97316] px-7 py-4 text-base font-black text-white shadow-[0_18px_55px_rgba(249,115,22,0.38)] transition-all hover:-translate-y-0.5 hover:shadow-[0_22px_70px_rgba(249,115,22,0.52)] sm:w-auto"
              >
                Enroll Now <ArrowRight className="h-5 w-5" />
              </button>
              <button
                type="button"
                onClick={scrollToForm}
                suppressHydrationWarning
                className="inline-flex w-full items-center justify-center gap-2 rounded-2xl border border-white/20 bg-white/10 px-7 py-4 text-base font-black text-white backdrop-blur-xl transition-all hover:-translate-y-0.5 hover:border-orange-300/60 hover:bg-white/16 sm:w-auto"
              >
                <Download className="h-5 w-5" /> Download Brochure
              </button>
            </div>

            <div className="mt-10 grid grid-cols-2 gap-3 sm:grid-cols-4">
              {[
                { icon: IndianRupee, label: 'Rs. 15K Stipend' },
                { icon: Award, label: 'Special Certificate' },
                { icon: Gift, label: 'T-Shirt & Goodies' },
                { icon: Building2, label: 'Industry Visit' },
              ].map(({ icon: Icon, label }) => (
                <div key={label} className="rounded-2xl border border-white/14 bg-white/10 p-4 text-center shadow-2xl backdrop-blur-xl transition-transform hover:-translate-y-1">
                  <Icon className="mx-auto mb-2 h-6 w-6 text-[#ffa800]" />
                  <p className="text-sm font-extrabold text-white">{label}</p>
                </div>
              ))}
            </div>
          </div>

          <div
            className="relative mx-auto w-full max-w-xl"
          >
            <div className="absolute -inset-5 rounded-[2rem] bg-gradient-to-br from-orange-400/30 via-white/5 to-transparent blur-2xl" />
            <div className="relative overflow-hidden rounded-[2rem] border border-white/14 bg-white/10 p-3 shadow-[0_24px_80px_rgba(0,0,0,0.35)] backdrop-blur-xl">
              <div className="relative aspect-[4/5] overflow-hidden rounded-[1.55rem] bg-orange-50">
                <Image
                  src={s3Url('/images/room-teaching3.jpg')}
                  alt="Students attending practical offline training at Adyapan"
                  fill
                  priority
                  sizes="(min-width: 1024px) 42vw, 92vw"
                  className="object-cover"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-[#11121f]/70 via-transparent to-transparent" />
              </div>
            </div>

            <div
              className="absolute -left-2 top-10 rounded-2xl border border-white/18 bg-white/90 p-4 text-[#111827] shadow-2xl backdrop-blur-xl sm:-left-8"
            >
              <p className="text-xs font-bold uppercase tracking-widest text-gray-500">Live Path</p>
              <p className="mt-1 text-lg font-black">Train - Build - Place</p>
            </div>

            <div
              className="absolute -right-2 bottom-14 rounded-2xl border border-orange-200 bg-white/92 p-4 text-[#111827] shadow-2xl backdrop-blur-xl sm:-right-8"
            >
              <div className="flex items-center gap-3">
                <div className="rounded-xl bg-orange-100 p-2 text-orange-600">
                  <ShieldCheck className="h-5 w-5" />
                </div>
                <div>
                  <p className="text-xs font-bold uppercase tracking-widest text-orange-500">Support</p>
                  <p className="text-base font-semibold text-white">Till Placement</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="bg-gradient-to-r from-[#ffa800] to-[#f97316] px-4 py-8 text-white sm:px-6">
        <div className="mx-auto grid max-w-6xl grid-cols-2 gap-5 text-center md:grid-cols-4">
          {[
            ['6 Months', 'Offline internship'],
            ['10+', 'Career benefits'],
            ['Rs. 15,000', 'Stipend opportunity'],
            ['Till placed', 'Placement support'],
          ].map(([value, label]) => (
            <div key={label}>
              <p className="text-3xl font-black">{value}</p>
              <p className="mt-1 text-sm font-semibold text-white/85">{label}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl">
          <SectionIntro
            kicker="Program Benefits"
            title="Everything a student needs to become industry-ready"
            desc="Offline discipline, practical projects, mentor feedback, and placement support in one high-impact internship experience."
          />
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-5">
            {features.map(({ icon: Icon, title, desc }) => (
              <div
                key={title}
                className="group rounded-2xl border border-gray-100 bg-white p-5 shadow-[0_12px_36px_rgba(17,24,39,0.06)] transition-all duration-300 hover:-translate-y-1 hover:border-orange-300 hover:shadow-[0_18px_55px_rgba(249,115,22,0.16)]"
              >
                <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-orange-50 text-orange-600 transition-colors group-hover:bg-gradient-to-br group-hover:from-[#ffa800] group-hover:to-[#f97316] group-hover:text-white">
                  <Icon className="h-6 w-6" />
                </div>
                <h3 className="text-base font-black leading-snug text-[#111827]">{title}</h3>
                <p className="mt-2 text-sm leading-6 text-gray-600">{desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-[#fff7ed] px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl">
          <SectionIntro kicker="Why Offline Internship?" title="Classroom energy meets real career outcomes" />
          <div className="grid gap-8 lg:grid-cols-[0.95fr_1.05fr] lg:items-center">
            <div className="relative min-h-[420px] overflow-hidden rounded-[2rem] shadow-2xl">
              <Image src={s3Url('/images/in-room-teaching01.jpg')} alt="Offline classroom training at Adyapan" fill loading="lazy" sizes="(min-width: 1024px) 45vw, 92vw" className="object-cover" />
              <div className="absolute inset-0 bg-gradient-to-t from-black/65 via-black/10 to-transparent" />
              <div className="absolute bottom-6 left-6 right-6 rounded-2xl border border-white/20 bg-white/12 p-5 text-white backdrop-blur-xl">
                <p className="text-sm font-semibold text-orange-200">Built for students who learn better in person</p>
                <p className="mt-2 text-2xl font-black">Mentor-led training, live doubt solving, and project accountability.</p>
              </div>
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              {[
                { icon: Users, title: 'Real classroom focus', desc: 'Stay consistent with peer energy, direct mentor feedback, and structured attendance.' },
                { icon: Briefcase, title: 'Project-first learning', desc: 'Every module pushes you toward proof-of-work projects you can show recruiters.' },
                { icon: Trophy, title: 'Interview confidence', desc: 'Practice offline until you can explain your work clearly and calmly.' },
                { icon: Zap, title: 'Career momentum', desc: 'Placement actions start early, so your learning and job prep move together.' },
              ].map(({ icon: Icon, title, desc }) => (
                <div key={title} className="rounded-2xl bg-white p-6 shadow-sm">
                  <Icon className="mb-4 h-7 w-7 text-orange-500" />
                  <h3 className="text-lg font-black text-[#111827]">{title}</h3>
                  <p className="mt-2 text-sm leading-6 text-gray-600">{desc}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section className="px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl">
          <SectionIntro kicker="Journey Timeline" title="Your 6-step offline internship journey" />
          <div className="relative grid gap-4 md:grid-cols-3 lg:grid-cols-6">
            {journey.map((step, index) => (
              <div
                key={step.title}
                className="group relative overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-orange-200 hover:shadow-[0_16px_48px_rgba(249,115,22,0.14)]"
              >
                {/* Image */}
                <div className="relative h-32 w-full overflow-hidden">
                  <Image
                    src={step.img}
                    alt={step.alt}
                    fill
                    sizes="(min-width: 1024px) 16vw, (min-width: 768px) 33vw, 100vw"
                    className="object-cover transition-transform duration-500 group-hover:scale-105"
                  />
                  {/* Gradient overlay */}
                  <div className="absolute inset-0 bg-gradient-to-t from-white/90 via-white/20 to-transparent" />
                  {/* Step number badge */}
                  <div className="absolute left-3 top-3 flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-[#ffa800] to-[#f97316] text-sm font-black text-white shadow-lg">
                    {index + 1}
                  </div>
                </div>
                {/* Text */}
                <div className="p-4">
                  <h3 className="font-black text-[#111827] leading-snug">{step.title}</h3>
                  <p className="mt-1.5 text-xs leading-5 text-gray-500">{step.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-[#11121f] px-4 py-20 text-white sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl">
          <SectionIntro kicker="Internship Kit" title="A premium offline starter kit" desc="Everything feels more official when your program gives you tools, identity, and proof." titleClassName="text-white" descClassName="text-white/80" />
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {kit.map(({ icon: Icon, title, desc, img, alt }) => (
              <div
                key={title}
                className="group overflow-hidden rounded-2xl border border-white/10 bg-white/8 shadow-2xl backdrop-blur-xl transition-all duration-300 hover:-translate-y-1 hover:border-orange-400/40 hover:shadow-[0_20px_60px_rgba(255,168,0,0.18)]"
              >
                {/* Image */}
                <div className="relative h-36 w-full overflow-hidden">
                  <Image
                    src={img}
                    alt={alt}
                    fill
                    sizes="(min-width: 1024px) 20vw, (min-width: 640px) 50vw, 100vw"
                    className="object-cover transition-transform duration-500 group-hover:scale-105"
                  />
                  {/* Dark overlay */}
                  <div className="absolute inset-0 bg-gradient-to-t from-[#11121f]/80 via-[#11121f]/30 to-transparent" />
                  {/* Icon badge */}
                  <div className="absolute bottom-3 left-3 flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-[#ffa800] to-[#f97316] shadow-lg">
                    <Icon className="h-5 w-5 text-white" />
                  </div>
                </div>
                {/* Text */}
                <div className="p-5">
                  <h3 className="text-base font-black text-white">{title}</h3>
                  <p className="mt-1.5 text-sm leading-6 text-white/60">{desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto grid max-w-7xl gap-8 lg:grid-cols-[0.9fr_1.1fr] lg:items-center">
          <div>
            <p className="mb-3 text-xs font-black uppercase tracking-[0.24em] text-orange-500">Placement & Stipend</p>
            <h2 className="text-3xl font-black leading-tight text-[#111827] sm:text-5xl">Placement Support Till You Get Placed</h2>
            <p className="mt-5 text-lg leading-8 text-gray-600">
              We combine practical training with placement actions: resume guidance, interview preparation, mentor sessions, and recruiter connections.
            </p>
            <button type="button" onClick={() => setShowCounselor(true)} suppressHydrationWarning className="mt-8 inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-[#111827] px-7 py-4 font-black text-white transition hover:bg-[#f97316] sm:w-auto">
              Talk to Counselor <Phone className="h-5 w-5" />
            </button>
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            {placement.map((item) => (
              <div key={item} className="flex items-center gap-3 rounded-2xl border border-orange-100 bg-orange-50/70 p-5 cursor-pointer hover:shadow-lg hover:border-orange-200">
                <span className="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-white text-orange-500 shadow-sm">
                  <Check className="h-5 w-5" />
                </span>
                <span className="font-extrabold text-[#111827]">{item}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="enroll-form" className="bg-[#fff7ed] px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto grid max-w-7xl gap-10 lg:grid-cols-[0.9fr_1.1fr] lg:items-start">
          <div className="lg:sticky lg:top-24">
            <p className="mb-3 text-xs font-black uppercase tracking-[0.24em] text-orange-500">Enroll Now</p>
            <h2 className="text-3xl font-black leading-tight text-[#111827] sm:text-5xl">Reserve your seat for the offline internship</h2>
            <p className="mt-5 text-lg leading-8 text-gray-600">
              Fill the form and Adyapan's counselor team will guide you on batch timing, course fit, stipend eligibility, and placement support.
            </p>
            <div className="mt-8 grid gap-4 sm:grid-cols-2">
              {[
                { icon: Clock, text: 'Counselor follow-up' },
                { icon: FileText, text: 'Brochure guidance' },
                { icon: GraduationCap, text: 'Course fit review' },
                { icon: ShieldCheck, text: 'Admin lead tracking' },
              ].map(({ icon: Icon, text }) => (
                <div key={text} className="rounded-2xl bg-white p-4 shadow-sm cursor-pointer hover:shadow-lg hover:border hover:border-orange-100">
                  <Icon className="mb-2 h-5 w-5 text-orange-500" />
                  <p className="text-sm font-black text-[#111827]">{text}</p>
                </div>
              ))}
            </div>
          </div>

          <form onSubmit={handleSubmit} className="rounded-[2rem] border border-orange-100 bg-white p-5 shadow-[0_24px_80px_rgba(249,115,22,0.15)] sm:p-8">
            <div className="grid gap-4 sm:grid-cols-2">
              {[
                { name: 'name', label: 'Name', type: 'text', required: true },
                { name: 'college', label: 'College', type: 'text', required: false },
              ].map((field) => (
                <label key={field.name}>
                  <span className="mb-2 block text-sm font-bold text-gray-700">{field.label}</span>
                  <input
                    name={field.name}
                    type={field.type}
                    required={field.required}
                    value={form[field.name as keyof typeof form]}
                    onChange={(event) => setForm((prev) => ({ ...prev, [field.name]: event.target.value }))}
                    suppressHydrationWarning
                    className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm font-semibold text-[#111827] outline-none transition focus:border-orange-400 focus:bg-white focus:ring-4 focus:ring-orange-100"
                  />
                </label>
              ))}

              <PhoneField
                label="Phone"
                name="phone"
                value={form.phone}
                onChange={(digits) => setForm((prev) => ({ ...prev, phone: digits }))}
                placeholder="10-digit mobile number"
                inputClassName="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm font-semibold text-[#111827] outline-none transition focus:border-orange-400 focus:bg-white focus:ring-4 focus:ring-orange-100"
                labelClassName="mb-2 block text-sm font-bold text-gray-700"
              />

              <EmailField
                label="Email"
                email={form.email}
                onEmailChange={(v) => setForm((prev) => ({ ...prev, email: v }))}
                placeholder="Enter your email address"
                inputClassName="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm font-semibold text-[#111827] outline-none transition focus:border-orange-400 focus:bg-white focus:ring-4 focus:ring-orange-100"
                labelClassName="mb-2 block text-sm font-bold text-gray-700"
              />

              <label className="sm:col-span-2">
                <span className="mb-2 block text-sm font-bold text-gray-700">City</span>
                <input
                  name="city"
                  type="text"
                  value={form.city}
                  onChange={(event) => setForm((prev) => ({ ...prev, city: event.target.value }))}
                  suppressHydrationWarning
                  className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm font-semibold text-[#111827] outline-none transition focus:border-orange-400 focus:bg-white focus:ring-4 focus:ring-orange-100"
                />
              </label>

              <label>
                <span className="mb-2 block text-sm font-bold text-gray-700">Course Interest</span>
                <select
                  name="courseInterest"
                  required
                  value={form.courseInterest}
                  onChange={(event) => setForm((prev) => ({ ...prev, courseInterest: event.target.value }))}
                  className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm font-semibold text-[#111827] outline-none transition focus:border-orange-400 focus:bg-white focus:ring-4 focus:ring-orange-100"
                >
                  <option value="">Select course</option>
                  {courses.map((course) => <option key={course} value={course}>{course}</option>)}
                </select>
              </label>

              <label>
                <span className="mb-2 block text-sm font-bold text-gray-700">Preferred Batch</span>
                <select
                  name="preferredBatch"
                  required
                  value={form.preferredBatch}
                  onChange={(event) => setForm((prev) => ({ ...prev, preferredBatch: event.target.value }))}
                  className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm font-semibold text-[#111827] outline-none transition focus:border-orange-400 focus:bg-white focus:ring-4 focus:ring-orange-100"
                >
                  <option value="">Select batch</option>
                  {batches.map((batch) => <option key={batch} value={batch}>{batch}</option>)}
                </select>
              </label>
            </div>

            <div className="mt-6 flex flex-col gap-3 sm:flex-row">
              <button
                type="submit"
                disabled={loading}
                suppressHydrationWarning
                className="inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-gradient-to-r from-[#ffa800] to-[#f97316] px-7 py-4 font-black text-white shadow-lg transition hover:-translate-y-0.5 disabled:cursor-not-allowed disabled:opacity-70"
              >
                {loading ? (
                  <>
                    <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                    Submitting...
                  </>
                ) : (
                  <>Enroll Now <Send className="h-5 w-5" /></>
                )}
              </button>
              <button
                type="button"
                onClick={() => setShowCounselor(true)}
                suppressHydrationWarning
                className="inline-flex w-full items-center justify-center gap-2 rounded-2xl border border-gray-200 px-7 py-4 font-black text-[#111827] transition hover:border-orange-300 hover:bg-orange-50"
              >
                Talk to Counselor <Phone className="h-5 w-5" />
              </button>
            </div>
          </form>
        </div>
      </section>

      <section className="px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl">
          <SectionIntro kicker="Student Stories" title="Trusted by students preparing for real careers" />
          <div className="grid gap-5 md:grid-cols-3">
            {testimonials.map((item) => (
              <div key={item.name} className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm cursor-pointer hover:shadow-xl hover:border-orange-100">
                <div className="mb-4 flex gap-1 text-orange-400">
                  {[...Array(5)].map((_, i) => <Star key={i} className="h-4 w-4 fill-current" />)}
                </div>
                <p className="text-sm leading-7 text-gray-600">"{item.quote}"</p>
                <div className="mt-6 border-t border-gray-100 pt-4">
                  <p className="font-black text-[#111827]">{item.name}</p>
                  <p className="text-sm font-semibold text-orange-500">{item.role}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-[#11121f] px-4 py-14 text-white sm:px-6 lg:px-8 overflow-hidden">
        <style>{`
          @keyframes company-left {
            0%   { transform: translateX(0); }
            100% { transform: translateX(-50%); }
          }
          @keyframes company-right {
            0%   { transform: translateX(-50%); }
            100% { transform: translateX(0); }
          }
        `}</style>
        <div className="mx-auto max-w-7xl">
          <p
            className="mb-8 text-center text-sm font-bold uppercase tracking-[0.22em] text-white/50"
          >
            Recruiter and company exposure ecosystem
          </p>
          
          {/* Marquee Container */}
          <div className="relative">
            {/* Gradient overlays for fade effect */}
            <div className="absolute left-0 top-0 bottom-0 w-24 bg-gradient-to-r from-[#11121f] to-transparent z-10 pointer-events-none" />
            <div className="absolute right-0 top-0 bottom-0 w-24 bg-gradient-to-l from-[#11121f] to-transparent z-10 pointer-events-none" />
            
            {/* Row 1 - scrolls left */}
            <div className="flex overflow-hidden">
              <div
                className="flex gap-4 pr-4"
                style={{
                  width: 'max-content',
                  animation: 'company-left 50s linear infinite',
                  willChange: 'transform',
                }}
              >
                {[...companies, ...companies, ...companies, ...companies].map((company, index) => (
                  <div
                    key={`${company.name}-${index}`}
                    className="group relative flex-shrink-0 w-52 h-32 rounded-2xl border border-white/10 bg-white/6 backdrop-blur overflow-hidden transition-all duration-300 hover:border-orange-400/60 hover:bg-white/10 hover:scale-105 hover:shadow-[0_0_32px_rgba(255,168,0,0.30)] cursor-pointer"
                  >
                    {/* Hover colour wash */}
                    <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                      <div className={`absolute inset-0 bg-gradient-to-br ${company.bg}`} />
                    </div>

                    {/* Card body */}
                    <div className="relative z-10 flex h-full flex-col items-center justify-center gap-2.5 px-5 py-4">
                      {/* White logo pill */}
                      <div className="flex h-12 w-40 items-center justify-center rounded-xl bg-white px-3 py-1.5 shadow-md transition-transform duration-300 group-hover:scale-110 group-hover:shadow-lg">
                        <img
                          src={company.logo}
                          alt={`${company.name} logo`}
                          className="h-full w-full object-contain"
                          loading="lazy"
                          onError={(e) => {
                            const target = e.currentTarget;
                            target.style.display = 'none';
                            const parent = target.parentElement;
                            if (parent && !parent.querySelector('span')) {
                              const span = document.createElement('span');
                              span.className = 'text-sm font-black text-gray-700';
                              span.textContent = company.name;
                              parent.appendChild(span);
                            }
                          }}
                        />
                      </div>
                      {/* Name */}
                      <p className="text-xs font-bold tracking-wide text-white/55 transition-colors duration-300 group-hover:text-white/90">
                        {company.name}
                      </p>
                      {/* Animated underline */}
                      <div className={`h-0.5 w-0 rounded-full bg-gradient-to-r ${company.color} transition-all duration-300 group-hover:w-14`} />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Row 2 - scrolls right (reverse) */}
            <div className="mt-4 flex overflow-hidden">
              <div
                className="flex gap-4 pr-4"
                style={{
                  width: 'max-content',
                  animation: 'company-right 60s linear infinite',
                  willChange: 'transform',
                }}
              >
                {[...companies].reverse().concat([...companies].reverse(), [...companies].reverse(), [...companies].reverse()).map((company, index) => (
                  <div
                    key={`rev-${company.name}-${index}`}
                    className="group relative flex-shrink-0 w-44 h-20 rounded-2xl border border-white/8 bg-white/5 backdrop-blur overflow-hidden transition-all duration-300 hover:border-orange-400/40 hover:bg-white/10 hover:scale-105 hover:shadow-[0_0_20px_rgba(255,168,0,0.2)] cursor-pointer"
                  >
                    <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                      <div className={`absolute inset-0 bg-gradient-to-br ${company.bg}`} />
                    </div>
                    <div className="relative z-10 flex h-full items-center justify-center gap-3 px-4">
                      {/* Mini logo pill */}
                      <div className="flex h-8 w-20 flex-shrink-0 items-center justify-center rounded-lg bg-white px-2 py-1 shadow-sm transition-transform duration-300 group-hover:scale-110">
                        <img
                          src={company.logo}
                          alt={`${company.name} logo`}
                          className="h-full w-full object-contain"
                          loading="lazy"
                        />
                      </div>
                      <p className="text-xs font-bold text-white/55 transition-colors duration-300 group-hover:text-white/90 truncate">
                        {company.name}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
          
          {/* Static grid for mobile fallback */}
          <div className="mt-8 grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-5 lg:hidden">
            {companies.slice(0, 10).map((company) => (
              <div
                key={company.name}
                className="group relative rounded-2xl border border-white/10 bg-white/8 px-4 py-5 text-center backdrop-blur transition-all duration-300 hover:border-orange-400/50 hover:bg-white/12 hover:scale-105"
              >
                <div className="mb-2 flex justify-center">
                  <div className="flex h-10 w-24 items-center justify-center rounded-lg bg-white px-2 py-1 shadow-md transition-transform duration-300 group-hover:scale-110">
                    <img
                      src={company.logo}
                      alt={`${company.name} logo`}
                      className="h-full w-full object-contain"
                      loading="lazy"
                    />
                  </div>
                </div>
                <p className="text-xs font-bold text-white/60 group-hover:text-white transition-colors">
                  {company.name}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-4xl">
          <SectionIntro kicker="FAQs" title="Questions students ask before enrolling" />
          <div className="space-y-3">
            {faqs.map((faq, index) => (
              <div key={faq.q} className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm cursor-pointer hover:shadow-md hover:border-orange-100">
                <button type="button" onClick={() => setOpenFaq(openFaq === index ? null : index)} suppressHydrationWarning className="flex w-full items-center justify-between gap-4 p-5 text-left">
                  <span className="font-black text-[#111827]">{faq.q}</span>
                  <ChevronDown className={`h-5 w-5 flex-shrink-0 text-orange-500 transition-transform ${openFaq === index ? 'rotate-180' : ''}`} />
                </button>
                
                  {openFaq === index && (
                    <div>
                      <p className="border-t border-gray-100 px-5 pb-5 pt-4 text-sm leading-7 text-gray-600">{faq.a}</p>
                    </div>
                  )}
                
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="px-4 pb-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl overflow-hidden rounded-[2rem] bg-gradient-to-br from-[#ffa800] to-[#f97316] p-8 text-white shadow-[0_24px_80px_rgba(249,115,22,0.28)] sm:p-12">
          <div className="grid gap-8 lg:grid-cols-[1fr_auto] lg:items-center">
            <div>
              <p className="mb-3 text-sm font-black uppercase tracking-[0.22em] text-white/75">Final Call</p>
              <h2 className="text-3xl font-black leading-tight sm:text-5xl">Start your offline internship journey with Adyapan.</h2>
              <p className="mt-4 max-w-2xl text-base font-semibold leading-7 text-white/82">Practical projects, mentor-led classes, industry visits, goodies, certificate, placement support, and stipend opportunities in one premium program.</p>
            </div>
            <button type="button" onClick={scrollToForm} suppressHydrationWarning className="inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-white px-8 py-4 font-black text-[#111827] shadow-xl transition hover:-translate-y-0.5 lg:w-auto">
              Enroll Now <CheckCircle className="h-5 w-5 text-orange-500" />
            </button>
          </div>
        </div>
      </section>
    </div>
  );
}
