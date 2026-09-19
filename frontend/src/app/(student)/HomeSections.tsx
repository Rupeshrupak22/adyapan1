'use client';

import dynamic from 'next/dynamic';

// Above-the-fold: client-only (avoid SSR localStorage issues)
const HeroSection    = dynamic(() => import('@/components/HeroSection'),    { ssr: false });
const MarqueeBanner  = dynamic(() => import('@/components/MarqueeBanner'),  { ssr: false });
// Below-the-fold: lazy-loaded after initial paint
const CommunityShowcaseSection    = dynamic(() => import('@/components/CommunityShowcaseSection'));
const HowItWorksSection           = dynamic(() => import('@/components/HowItWorksSection'));
const AddOnsSection               = dynamic(() => import('@/components/AddOnsSection'));
const TestimonialsSection         = dynamic(() => import('@/components/TestimonialsSection'));
const CertificationsSection       = dynamic(() => import('@/components/CertificationsSection'));
const CertificateShowcaseSection  = dynamic(() => import('@/components/CertificateShowcaseSection'));
const GlobalCertificationPartners = dynamic(() => import('@/components/GlobalCertificationPartners'));

export default function HomeSections() {
  return (
    <div className="flex flex-col">
      <HeroSection />
      <MarqueeBanner variant="dark" speed={28} />
      <CommunityShowcaseSection />
      <HowItWorksSection />
      <AddOnsSection />
      <MarqueeBanner variant="orange" speed={32} />
      <TestimonialsSection />
      <CertificationsSection />
      <MarqueeBanner variant="glass" speed={26} />
      <CertificateShowcaseSection />
      <GlobalCertificationPartners />
    </div>
  );
}
