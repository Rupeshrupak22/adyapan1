'use client';

import { usePathname } from 'next/navigation';
import PortalLayout from '@/components/portal/PortalLayout';

// These admin sub-routes are PUBLIC — no auth needed
const PUBLIC_ADMIN_PATHS = ['/admin/invite/', '/admin/signup'];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  // Check if current path is a public route
  const isPublic = PUBLIC_ADMIN_PATHS.some(p => pathname.startsWith(p));

  if (isPublic) {
    // Render without PortalLayout — no auth check, no sidebar
    return <>{children}</>;
  }

  return <PortalLayout portalType="admin">{children}</PortalLayout>;
}
