'use client';

import { useState } from 'react';
import { Phone, Mail, Send, CheckCircle, Clock, Instagram, Linkedin, ChevronDown } from 'lucide-react';
import EmailField from '@/components/forms/EmailField';
import PhoneField from '@/components/forms/PhoneField';
import { isIndianMobile, INDIAN_MOBILE_MESSAGE } from '@/lib/phone';
import { isValidEmail, EMAIL_FORMAT_MESSAGE } from '@/lib/email-format';

const CONTACT_INFO = [
  { icon: Phone, label: 'Phone', value: '+91 81791 24566', href: 'tel:+918179124566', color: 'from-green-500 to-emerald-600' },
  { icon: Mail, label: 'Email', value: 'support@adyapan.com', href: 'mailto:support@adyapan.com', color: 'from-blue-500 to-indigo-600' },
  { icon: Clock, label: 'Hours', value: 'Mon - Sat, 11 AM - 8 PM', href: null, color: 'from-[#ffa800] to-[#ff6b00]' },
];

const SOCIAL_LINKS = {
  instagram: 'https://www.instagram.com/adyapan_?igsh=MWw1NGwwNTIwZXU2eQ==',
  linkedin: 'https://www.linkedin.com/company/adyapan-edutech-pvt-ltd/posts/?feedView=all',
};

const FAQS = [
  { q: 'How do I enroll in a course?', a: 'Visit our Programs page, choose your course, and click Enroll Now. Payment is processed securely via Razorpay.' },
  { q: 'Are classes live or recorded?', a: 'All sessions are live and interactive. Recordings are available for revision after each class.' },
  { q: 'Do you provide placement support?', a: 'Yes — resume reviews, mock interviews, and direct recruiter connections are included in every program.' },
  { q: 'Can I get a refund?', a: 'Registration Fee once paid is strictly non-refundable and non-transferable under any circumstances. No refund request will be accepted after 5 days from the date of  REG. day full payment. By making the payment, the student agrees to this condition.' },
];

export default function ContactPageClient() {
  const [form, setForm] = useState({ name: '', email: '', phone: '', subject: '', message: '' });
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [errorMsg, setErrorMsg] = useState('');
  const [openFaq, setOpenFaq] = useState<number | null>(null);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isValidEmail(form.email)) {
      setErrorMsg(EMAIL_FORMAT_MESSAGE);
      setStatus('error');
      return;
    }
    if (!isIndianMobile(form.phone)) {
      setErrorMsg(INDIAN_MOBILE_MESSAGE);
      setStatus('error');
      return;
    }
    setStatus('loading');
    setErrorMsg('');
    try {
      const res = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      if (res.ok) {
        setStatus('success');
        setForm({ name: '', email: '', phone: '', subject: '', message: '' });
      } else {
        const data = await res.json().catch(() => ({}));
        setErrorMsg(data.error || 'Something went wrong. Please try again.');
        setStatus('error');
      }
    } catch {
      setErrorMsg('Something went wrong. Please try again.');
      setStatus('error');
    }
  };

  return (
    <div className="min-h-screen bg-[#fafafa]">
      {/* Hero Header */}
      <section className="relative pt-16 pb-20 px-6 overflow-hidden bg-gradient-to-b from-[#111827] to-[#1f2937] text-white">
        <div className="relative z-10 max-w-4xl mx-auto text-center">
          <h1 className="text-4xl sm:text-6xl font-black mb-4 tracking-tight">
            Get in <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#ffa800] to-[#ff6b00]">Touch</span>
          </h1>
          <p className="text-gray-300 text-base sm:text-lg max-w-xl mx-auto leading-relaxed">
            Have questions about our programs or need career guidance? Our team is here to help you every step of the way.
          </p>
        </div>
      </section>

      {/* Info Cards */}
      <section className="-mt-10 px-6 relative z-20">
        <div className="max-w-5xl mx-auto grid sm:grid-cols-3 gap-5">
          {CONTACT_INFO.map((item, i) => {
            const Icon = item.icon;
            const Content = (
              <div
                className="bg-white rounded-2xl p-6 border border-gray-100 shadow-lg shadow-gray-200/50 hover:shadow-xl hover:-translate-y-1 transition-all flex items-center gap-4 cursor-pointer"
              >
                <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${item.color} flex items-center justify-center flex-shrink-0 text-white`}>
                  <Icon className="w-6 h-6" />
                </div>
                <div>
                  <p className="text-xs font-bold text-gray-400 uppercase tracking-wider">{item.label}</p>
                  <p className="font-extrabold text-gray-900 text-sm mt-0.5">{item.value}</p>
                </div>
              </div>
            );

            return item.href ? (
              <a key={i} href={item.href}>
                {Content}
              </a>
            ) : (
              <div key={i}>{Content}</div>
            );
          })}
        </div>
      </section>

      {/* Main Content Grid */}
      <section className="py-16 px-6">
        <div className="max-w-5xl mx-auto grid lg:grid-cols-12 gap-12 items-start">

          {/* Contact Form */}
          <div className="lg:col-span-7 bg-white rounded-3xl p-8 border border-gray-100 shadow-sm">
            <h2 className="text-2xl font-black text-gray-900 mb-2">Send Us a Message</h2>
            <p className="text-gray-500 text-sm mb-8">Fill out the form below and we'll get back to you within 24 hours.</p>

            {status === 'success' ? (
              <div className="p-6 bg-green-50 border border-green-200 rounded-2xl text-center">
                <CheckCircle className="w-12 h-12 text-green-500 mx-auto mb-3" />
                <h3 className="font-bold text-green-900 text-lg mb-1">Message Sent!</h3>
                <p className="text-green-700 text-sm">Thank you for reaching out. Our team will contact you shortly.</p>
                <button
                  onClick={() => setStatus('idle')}
                  className="mt-4 px-6 py-2 bg-green-600 text-white font-bold text-xs rounded-full hover:bg-green-700 transition-colors"
                >
                  Send Another
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-5">
                <div className="grid sm:grid-cols-2 gap-5">
                  <div>
                    <label className="block text-xs font-bold text-gray-700 uppercase mb-1.5">Full Name *</label>
                    <input
                      type="text"
                      name="name"
                      required
                      value={form.name}
                      onChange={handleChange}
                      placeholder="John Doe"
                      className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-[#ffa800] focus:bg-white transition-colors"
                    />
                  </div>
                  <EmailField
                    label="EMAIL ADDRESS"
                    email={form.email}
                    onEmailChange={(v) => setForm((prev) => ({ ...prev, email: v }))}
                    placeholder="john@example.com"
                    inputClassName="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-[#ffa800] focus:bg-white transition-colors"
                    labelClassName="block text-xs font-bold text-gray-700 uppercase mb-1.5"
                  />
                </div>

                <div className="grid sm:grid-cols-2 gap-5">
                  <PhoneField
                    label="PHONE NUMBER"
                    name="phone"
                    value={form.phone}
                    onChange={(digits) => setForm((prev) => ({ ...prev, phone: digits }))}
                    placeholder="10-digit mobile number"
                    inputClassName="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-[#ffa800] focus:bg-white transition-colors"
                    labelClassName="block text-xs font-bold text-gray-700 uppercase mb-1.5"
                  />
                  <div>
                    <label className="block text-xs font-bold text-gray-700 uppercase mb-1.5">Subject</label>
                    <select
                      name="subject"
                      value={form.subject}
                      onChange={handleChange}
                      className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-[#ffa800] focus:bg-white transition-colors"
                    >
                      <option value="">Select a topic</option>
                      <option value="Course Inquiry">Course Inquiry</option>
                      <option value="Placement Support">Placement Support</option>
                      <option value="Partnership">Partnership / Hire Students</option>
                      <option value="Other">Other</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-700 uppercase mb-1.5">Message *</label>
                  <textarea
                    name="message"
                    required
                    rows={4}
                    value={form.message}
                    onChange={handleChange}
                    placeholder="Tell us how we can help you..."
                    className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-[#ffa800] focus:bg-white transition-colors resize-none"
                  />
                </div>

                {status === 'error' && (
                  <p className="text-red-500 text-xs font-semibold">{errorMsg || 'Something went wrong. Please try again.'}</p>
                )}

                <button
                  type="submit"
                  disabled={status === 'loading'}
                  className="w-full py-4 bg-gradient-to-r from-[#ffa800] to-[#ff8c00] hover:from-[#ff8c00] hover:to-[#ff6b00] text-white font-bold rounded-xl shadow-lg shadow-orange-500/20 hover:-translate-y-0.5 transition-all flex items-center justify-center gap-2 text-sm disabled:opacity-50"
                >
                  {status === 'loading' ? (
                    'Sending...'
                  ) : (
                    <>
                      <Send className="w-4 h-4" />
                      Send Message
                    </>
                  )}
                </button>
              </form>
            )}
          </div>

          {/* Sidebar: Socials & FAQ */}
          <div className="lg:col-span-5 space-y-8">
            {/* Social Links */}
            <div className="bg-white rounded-3xl p-8 border border-gray-100 shadow-sm">
              <h3 className="text-lg font-bold text-gray-900 mb-4">Connect With Us</h3>
              <p className="text-gray-500 text-sm mb-6">Follow us on social media for daily updates, career tips, and course announcements.</p>
              
              <div className="flex gap-4">
                <a
                  href={SOCIAL_LINKS.instagram}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex-1 py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-xl font-bold text-xs flex items-center justify-center gap-2 hover:-translate-y-0.5 transition-all shadow-md"
                >
                  <Instagram className="w-4 h-4" />
                  Instagram
                </a>
                <a
                  href={SOCIAL_LINKS.linkedin}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex-1 py-3 bg-[#0A66C2] text-white rounded-xl font-bold text-xs flex items-center justify-center gap-2 hover:-translate-y-0.5 transition-all shadow-md"
                >
                  <Linkedin className="w-4 h-4" />
                  LinkedIn
                </a>
              </div>
            </div>

            {/* FAQs */}
            <div className="bg-white rounded-3xl p-8 border border-gray-100 shadow-sm">
              <h3 className="text-lg font-bold text-gray-900 mb-4">Frequently Asked Questions</h3>
              <div className="space-y-3">
                {FAQS.map((faq, i) => {
                  const isOpen = openFaq === i;
                  return (
                    <div
                      key={i}
                      className="border border-gray-100 rounded-xl overflow-hidden"
                    >
                      <button
                        onClick={() => setOpenFaq(isOpen ? null : i)}
                        className="w-full p-4 text-left font-bold text-xs text-gray-800 flex items-center justify-between hover:bg-orange-50/50 transition-colors"
                      >
                        <span>{faq.q}</span>
                        <ChevronDown className={`w-4 h-4 text-gray-400 transition-transform ${isOpen ? 'rotate-180' : ''}`} />
                      </button>
                      {isOpen && (
                        <div className="px-4 pb-4 text-xs text-gray-600 leading-relaxed border-t border-gray-50 pt-3">
                          {faq.a}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
