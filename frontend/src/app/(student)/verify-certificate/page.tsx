import { Metadata } from 'next';
import VerifyCertificatePage from '@/components/VerifyCertificatePage';

export const metadata: Metadata = {
  title: 'Verify Certificate | Adyapan',
  description: 'Verify the authenticity of your Adyapan certificate instantly. Enter your certificate ID to confirm its validity and download your certificate.',
  openGraph: {
    title: 'Verify Certificate | Adyapan',
    description: 'Instantly verify any Adyapan certificate by entering the certificate ID.',
  },
};

export default function VerifyCertificate() {
  return <VerifyCertificatePage />;
}
