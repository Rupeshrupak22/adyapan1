import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { jwtVerify } from 'jose';

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  const authToken = request.cookies.get('authToken')?.value;

  // Admin routes that need protection (all /admin/* except login and invite signup)
  const isAdminRoute =
    pathname.startsWith('/admin') &&
    pathname !== '/admin/login' &&
    !pathname.startsWith('/admin/invite/');

  // Unauthenticated access to protected admin route → redirect to login
  if (isAdminRoute && !authToken) {
    const loginUrl = new URL('/admin/login', request.url);
    return NextResponse.redirect(loginUrl);
  }

  // Already logged-in admin visiting login page → redirect to dashboard
  if (pathname === '/admin/login' && authToken) {
    try {
      const secret = process.env.JWT_SECRET;
      if (!secret) return NextResponse.next();
      const { payload } = await jwtVerify(authToken, new TextEncoder().encode(secret));
      if (payload.role === 'ADMIN' || payload.role === 'SUPERADMIN') {
        return NextResponse.redirect(new URL('/admin', request.url));
      }
    } catch {
      // Invalid token — let them reach the login page
      return NextResponse.next();
    }
  }

  // Verify token for protected admin routes
  if (isAdminRoute && authToken) {
    try {
      const secret = process.env.JWT_SECRET;
      if (!secret) {
        return NextResponse.redirect(new URL('/admin/login', request.url));
      }
      const { payload } = await jwtVerify(authToken, new TextEncoder().encode(secret));
      if (payload.role !== 'ADMIN' && payload.role !== 'SUPERADMIN') {
        return NextResponse.redirect(new URL('/admin/login', request.url));
      }
    } catch {
      return NextResponse.redirect(new URL('/admin/login', request.url));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/admin/:path*'],
};
