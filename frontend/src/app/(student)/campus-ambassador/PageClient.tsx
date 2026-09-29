'use client';

import { s3Url } from '@/lib/s3Url';
import {
  Users, Target, Award, Briefcase, ChevronRight, CheckCircle,
  Globe, TrendingUp, Shield, Zap
} from 'lucide-react';

export default function CampusAmbassadorPage() {
  return (
    <div className="min-h-screen bg-[#fafafa]">
      {/* Hero Section */}
      <section className="relative pt-16 pb-24 sm:pb-32 px-6 overflow-hidden">
        <video
          src={s3Url('/videos/7969486-uhd_3840_2160_30fps.mp4')}
          autoPlay muted loop playsInline preload="metadata"
          className="absolute inset-0 w-full h-full object-cover"
          style={{ zIndex: 0 }}
        />
        <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-black/40 to-black/70" style={{ zIndex: 1 }} />

        <div className="relative z-10 max-w-6xl mx-auto text-center">
          <div>
            <h1 className="text-4xl sm:text-6xl md:text-7xl font-black text-white mb-6 leading-[1.1]">
              Become a{' '}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#ffa800] to-[#ff6b00]">
                Campus Ambassador
              </span>
            </h1>
            <p className="text-lg sm:text-xl text-white/85 max-w-2xl mx-auto mb-10 leading-relaxed">
              Bridge the gap between students and industry. Empower your campus with Adyapan and earn up to Rs. 15,000/month while making a real impact.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-14">
              <a
                href="https://internshala.com/internship/detail/work-from-home-lead-generation-internship-at-srs-adypan-edutech-private-limited1781263141"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center px-8 py-4 bg-gradient-to-r from-[#ffa800] to-[#ff8c00] text-white rounded-full font-bold text-base shadow-lg shadow-orange-500/25 hover:from-[#ff8c00] hover:to-[#ff6b00] hover:-translate-y-1 transition-all duration-300"
              >
                Apply on Internshala
                <ChevronRight className="w-5 h-5 ml-2" />
              </a>
              <a
                href="/campus-ambassador/apply"
                className="inline-flex items-center px-8 py-4 bg-white/10 backdrop-blur border border-white/30 text-white rounded-full font-bold text-base hover:bg-[#ffa800] hover:border-[#ffa800] hover:text-white hover:-translate-y-1 transition-all duration-300"
              >
                Apply Directly
                <ChevronRight className="w-5 h-5 ml-2" />
              </a>
            </div>

            {/* Key Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {[
                { value: 'Rs.1K-15K', label: 'Monthly Stipend', sub: 'Incentive Based' },
                { value: 'All', label: 'Academic Programs', sub: 'Engineering, Management & More' },
                { value: 'Flexible', label: 'Work Schedule', sub: 'Balance with Studies' },
                { value: '100%', label: 'Remote Friendly', sub: 'Work from Anywhere' },
              ].map((stat, i) => (
                <div
                  key={i}
                  className="bg-white/10 backdrop-blur border border-white/15 rounded-2xl p-5 text-center cursor-pointer hover:bg-white/20 hover:border-white/30 hover:-translate-y-1 transition-all"
                >
                  <div className="text-2xl sm:text-3xl font-black text-[#ffa800] mb-1">{stat.value}</div>
                  <p className="text-white font-semibold text-sm">{stat.label}</p>
                  <p className="text-white/60 text-xs mt-0.5">{stat.sub}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* About Section */}
      <section className="py-20 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-14">
            <h2 className="text-3xl sm:text-5xl font-black text-gray-900 mb-4">About Adyapan</h2>
            <p className="text-gray-600 max-w-2xl mx-auto">Bridging the gap between academic learning and industry-ready skills since day one.</p>
          </div>

          <div className="grid sm:grid-cols-2 gap-6">
            {[
              { title: 'Who We Are', text: 'SR\'s Adyapan Edutech Private Limited is a dynamic e-learning organization dedicated to bridging the gap between academic learning and industry skills.' },
              { title: 'Our Vision', text: 'To empower individuals with accessible, quality, and skill-based learning solutions that enhance employability and career growth.' },
              { title: 'Our Approach', text: 'Learner-centric focus with strong industry alignment helps create meaningful pathways for students to transition into the workforce.' },
              { title: 'Why Join Us', text: 'Be part of a mission to transform education. Make a real impact on your campus while building experience and earning competitive incentives.' },
            ].map((item, i) => (
              <div
                key={i}
                className="bg-gray-50 rounded-2xl p-7 border border-gray-100 cursor-default hover:shadow-lg hover:border-orange-100 hover:-translate-y-1 transition-all"
              >
                <h3 className="text-lg font-bold text-gray-900 mb-2 flex items-center gap-2">
                  <span className="w-2 h-2 bg-[#ffa800] rounded-full" />
                  {item.title}
                </h3>
                <p className="text-gray-600 leading-relaxed text-sm">{item.text}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* The Role Section */}
      <section className="py-20 px-6 bg-[#fafafa]">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-14">
            <h2 className="text-3xl sm:text-5xl font-black text-gray-900 mb-4">The Role</h2>
            <p className="text-gray-600 max-w-xl mx-auto">What you&apos;ll do as an Adyapan Campus Ambassador</p>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              { icon: Users, title: 'Bridge Students & Company', desc: 'Serve as the primary connection between students interested in training or internships and Adyapan Edutech.' },
              { icon: Target, title: 'Gather Student Insights', desc: 'Collect valuable feedback regarding academic programs, campus life, and internship expectations.' },
              { icon: Zap, title: 'Promote Initiatives', desc: 'Facilitate webinars, grassroots development, and encourage student participation in programs.' },
              { icon: Globe, title: 'Distribute Information', desc: 'Help share important updates and information with the student community effectively.' },
              { icon: TrendingUp, title: 'Drive Engagement', desc: 'Represent student interests and drive meaningful engagement across your campus.' },
              { icon: Shield, title: 'Maintain Communication', desc: 'Ensure clear and consistent communication between students, peers, and company staff.' },
            ].map((item, i) => (
              <div
                key={i}
                className="bg-white rounded-2xl p-7 border border-gray-100 shadow-sm cursor-default hover:shadow-xl hover:border-orange-100 hover:-translate-y-1 transition-all"
              >
                <div className="w-12 h-12 bg-gradient-to-br from-[#ffa800] to-[#ff6b00] rounded-xl flex items-center justify-center mb-5">
                  <item.icon className="w-6 h-6 text-white" />
                </div>
                <h3 className="text-lg font-bold text-gray-900 mb-2">{item.title}</h3>
                <p className="text-gray-600 text-sm leading-relaxed">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Requirements & Skills */}
      <section className="py-20 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-14">
            <h2 className="text-3xl sm:text-5xl font-black text-gray-900 mb-4">Requirements & Skills</h2>
          </div>

          <div className="grid md:grid-cols-2 gap-10">
            <div>
              <h3 className="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <Briefcase className="w-5 h-5 text-[#ffa800]" />
                Requirements
              </h3>
              <div className="space-y-3">
                {[
                  'Currently enrolled in a relevant academic program',
                  'Interest in student affairs and community engagement',
                  'Passion for campus representation',
                  'Ability to work independently and as part of a team',
                  'Commitment to making a positive impact',
                ].map((req, i) => (
                  <div
                    key={i}
                    className="flex items-start gap-3 p-3 rounded-xl hover:bg-orange-50 transition-colors cursor-default"
                  >
                    <CheckCircle className="w-5 h-5 text-[#ffa800] flex-shrink-0 mt-0.5" />
                    <span className="text-gray-700 font-medium text-sm">{req}</span>
                  </div>
                ))}
              </div>
            </div>

            <div>
              <h3 className="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <Award className="w-5 h-5 text-[#ffa800]" />
                Key Skills
              </h3>
              <div className="space-y-3">
                {[
                  'Excellent interpersonal and communication skills',
                  'Strong organizational abilities with attention to detail',
                  'Collaborative approach to problem-solving',
                  'Ability to engage and inspire diverse groups',
                  'Self-motivated and proactive mindset',
                ].map((skill, i) => (
                  <div
                    key={i}
                    className="flex items-start gap-3 p-3 rounded-xl hover:bg-orange-50 transition-colors cursor-default"
                  >
                    <CheckCircle className="w-5 h-5 text-[#ffa800] flex-shrink-0 mt-0.5" />
                    <span className="text-gray-700 font-medium text-sm">{skill}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Eligibility Section */}
      <section className="py-20 px-6 bg-[#fafafa]">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-14">
            <h2 className="text-3xl sm:text-5xl font-black text-gray-900 mb-4">Who Can Apply?</h2>
            <p className="text-gray-600">Open to students across all disciplines and levels</p>
          </div>

          <div className="grid sm:grid-cols-3 gap-6">
            {[
              { title: 'Engineering Students', items: ['Undergraduates', 'Postgraduates', 'Freshers'] },
              { title: 'Management Students', items: ['MBA Students', 'BBA Students', 'All Levels'] },
              { title: 'Other Disciplines', items: ['Arts', 'Commerce', 'Sciences', 'All Programs'] },
            ].map((category, i) => (
              <div
                key={i}
                className="bg-white rounded-2xl p-8 border border-gray-100 shadow-sm cursor-default hover:shadow-xl hover:border-orange-100 hover:-translate-y-1 transition-all"
              >
                <h3 className="text-xl font-bold text-gray-900 mb-5 text-center">{category.title}</h3>
                <div className="space-y-3 w-fit mx-auto">
                  {category.items.map((item, j) => (
                    <div
                      key={j}
                      className="flex items-center gap-2 text-gray-600"
                    >
                      <span className="w-1.5 h-1.5 bg-[#ffa800] rounded-full flex-shrink-0" />
                      <span className="font-medium text-sm">{item}</span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className="py-24 px-6 bg-gradient-to-br from-[#111827] to-[#1f2937] relative overflow-hidden">
        <div className="absolute inset-0 opacity-30">
          <div className="absolute top-0 left-1/4 w-96 h-96 bg-[#ffa800] rounded-full blur-[120px]" />
          <div className="absolute bottom-0 right-1/4 w-72 h-72 bg-[#ff6b00] rounded-full blur-[100px]" />
        </div>

        <div className="relative z-10 max-w-3xl mx-auto text-center">
          <div>
            <h2 className="text-3xl sm:text-5xl font-black text-white mb-5">
              Ready to Make an Impact?
            </h2>
            <p className="text-lg text-gray-300 mb-10 leading-relaxed max-w-xl mx-auto">
              Join our community of campus ambassadors and become the bridge between students and industry.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-8">
              <a
                href="https://internshala.com/internship/detail/work-from-home-lead-generation-internship-at-srs-adypan-edutech-private-limited1781263141"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center px-10 py-4 bg-gradient-to-r from-[#ffa800] to-[#ff8c00] text-white rounded-full font-bold text-base shadow-lg shadow-orange-500/30 hover:shadow-xl hover:shadow-orange-500/40 hover:-translate-y-1 transition-all"
              >
                Apply on Internshala
                <ChevronRight className="w-5 h-5 ml-2" />
              </a>
              <a
                href="/campus-ambassador/apply"
                className="inline-flex items-center px-10 py-4 bg-white/10 backdrop-blur border border-white/20 text-white rounded-full font-bold text-base hover:bg-white/20 hover:-translate-y-1 transition-all"
              >
                Apply Directly
                <ChevronRight className="w-5 h-5 ml-2" />
              </a>
            </div>

            <p className="text-gray-400 text-sm">
              Stipend: Rs. 1,000 - Rs. 15,000/Month (Incentive Based) - Flexible Schedule - Remote Friendly
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
