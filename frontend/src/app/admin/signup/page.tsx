'use client';

/**
 * /admin/signup?token=...
 *
 * Legacy redirect — invite links previously pointed here.
 * Reads the token query param and redirects to the actual
 * invite acceptance page at /admin/invite/[token].
 */

import { useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';

export default function AdminSignupRedirect() {
  const router       = useRouter();
  const searchParams = useSearchParams();
  const token        = searchParams.get('token');

  useEffect(() => {
    if (token) {
      router.replace(`/admin/invite/${token}`);
    } else {
      router.replace('/admin/login');
    }
  }, [token, router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-orange-50 to-amber-50">
      <div className="flex flex-col items-center gap-3">
        <div className="w-10 h-10 border-4 border-[#ffa800] border-t-transparent rounded-full animate-spin" />
        <p className="text-sm text-gray-500 font-medium">Loading invite...</p>
      </div>
    </div>
  );
}
