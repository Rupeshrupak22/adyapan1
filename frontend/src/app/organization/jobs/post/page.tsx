'use client';

import { motion } from 'framer-motion';
import Link from 'next/link';
import { ArrowLeft, Briefcase, Clock, Bell } from 'lucide-react';

export default function PostJobPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 via-white to-amber-50 flex flex-col">
      {/* Back */}
      <div className="max-w-2xl mx-auto w-full px-4 sm:px-6 pt-8 pb-4">
        <Link
          href="/organization/jobs"
          className="inline-flex items-center gap-2 text-sm font-medium text-gray-500 hover:text-orange-500 transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Jobs
        </Link>
      </div>

      {/* Main card */}
      <div className="flex-1 flex items-center justify-center px-4 pb-16">
        <motion.div
          initial={{ opacity: 0, y: 30, scale: 0.96 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
          className="w-full max-w-md bg-white rounded-3xl shadow-xl border border-gray-100 overflow-hidden text-center"
        >
          {/* Orange top bar */}
          <div className="h-1.5 w-full" style={{ background: 'linear-gradient(90deg,#f97316,#fbbf24,#f97316)' }} />

          <div className="px-8 py-12">
            {/* Animated icon */}
            <motion.div
              animate={{ y: [0, -8, 0] }}
              transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
              className="w-20 h-20 rounded-2xl bg-orange-100 border-2 border-orange-200 flex items-center justify-center mx-auto mb-6"
            >
              <Briefcase className="w-10 h-10 text-orange-500" />
            </motion.div>

            {/* Badge */}
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-orange-100 text-orange-600 text-xs font-bold uppercase tracking-widest mb-5">
              <motion.span
                animate={{ scale: [1, 1.4, 1] }}
                transition={{ duration: 1.5, repeat: Infinity }}
                className="w-1.5 h-1.5 rounded-full bg-orange-500"
              />
              Coming Soon
            </span>

            <h1 className="text-3xl font-extrabold text-gray-900 mb-3">
              Post a <span className="text-orange-500">Job</span>
            </h1>

            <p className="text-gray-500 text-sm leading-relaxed mb-8">
              We're building a powerful job posting system for verified companies.
              Post internships, full-time, part-time, and freelance opportunities
              directly to 1000+ Adyapan students.
            </p>

            {/* Features preview */}
            <div className="space-y-3 mb-8 text-left">
              {[
                'Post verified jobs & internships',
                'Reach 1000+ job-ready students',
                'Review applications & shortlist',
                'Hire full-time, part-time or intern',
              ].map((f) => (
                <div key={f} className="flex items-center gap-3 text-sm text-gray-600">
                  <div className="w-5 h-5 rounded-full bg-orange-100 flex items-center justify-center flex-shrink-0">
                    <div className="w-2 h-2 rounded-full bg-orange-500" />
                  </div>
                  {f}
                </div>
              ))}
            </div>

            {/* Notify CTA — real mailto so the action works */}
            <motion.a
              href="mailto:support@adyapan.com?subject=Notify%20me%20when%20Job%20Posting%20launches"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="flex items-center gap-3 p-4 rounded-2xl border-2 border-orange-200 bg-orange-50 hover:bg-orange-100 transition-colors"
            >
              <Bell className="w-5 h-5 text-orange-500 flex-shrink-0" />
              <div className="text-left">
                <p className="text-sm font-bold text-gray-800">Get notified when it launches</p>
                <p className="text-xs text-gray-500 mt-0.5">Contact us at support@adyapan.com</p>
              </div>
            </motion.a>

            {/* Clock note */}
            <div className="flex items-center justify-center gap-2 mt-6 text-xs text-gray-400">
              <Clock className="w-3.5 h-3.5" />
              Launching very soon - stay tuned!
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
