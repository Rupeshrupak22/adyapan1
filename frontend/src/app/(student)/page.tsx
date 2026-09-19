import type { Metadata } from 'next';
import { websiteSchema, organizationSchema, faqSchema, BASE_URL } from '@/lib/seo';
import JsonLd from '@/components/JsonLd';
import HomeSections from './HomeSections';

// Homepage metadata is inherited from root layout - override with page-specific values
export const metadata: Metadata = {
  alternates: { canonical: BASE_URL },
  openGraph: {
    url: BASE_URL,
    type: 'website',
  },
};

export default function Home() {
  const homeFaq = faqSchema([
    {
      question: 'What is Adyapan?',
      answer:
        'Adyapan is an Indian EdTech platform offering 65+ industry-relevant courses with live classes, real internship experience, and guaranteed placement support.',
    },
    {
      question: 'How much do Adyapan courses cost?',
      answer: 'Most Adyapan courses are priced at Rs. 3,000 for the full program, making quality education accessible to all students.',
    },
    {
      question: 'Does Adyapan provide placement support?',
      answer:
        'Yes. Every Adyapan program includes dedicated placement support: resume building, mock interviews, and direct recruiter connections.',
    },
    {
      question: 'Are Adyapan classes live or recorded?',
      answer:
        'All sessions are live and interactive, conducted by industry experts. Recordings are available for revision after each class.',
    },
    {
      question: 'What certificate will I receive?',
      answer:
        'You will receive an industry-recognized certificate from Adyapan upon successful completion of your course and projects.',
    },
  ]);

  return (
    <>
      <JsonLd schema={websiteSchema()} />
      <JsonLd schema={organizationSchema()} />
      <JsonLd schema={homeFaq} />
      <HomeSections />
    </>
  );
}
