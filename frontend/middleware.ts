import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { jwtVerify } from 'jose';

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  const authToken = request.cookies.get('authToken')?.value;

  // Public admin routes — no auth needed
  const isPublicAdminRoute =
    pathname === '/admin/login' ||
    pathname.startsWith('/admin/invite/') ||
    pathname.startsWith('/admin/signup');

  // Protected admin route = starts with /admin but not public
  const isAdminRoute = pathname.startsWith('/admin') && !isPublicAdminRoute;

  // Unauthenticated → redirect to login
  if (isAdminRoute && !authToken) {
    return NextResponse.redirect(new URL('/admin/login', request.url));
  }

  // Already logged-in admin visiting login → redirect to dashboard
  if (pathname === '/admin/login' && authToken) {
    try {
      const secret = process.env.JWT_SECRET;
      if (!secret) return NextResponse.next();
      const { payload } = await jwtVerify(authToken, new TextEncoder().encode(secret));
      if (payload.role === 'ADMIN' || payload.role === 'SUPERADMIN') {
        return NextResponse.redirect(new URL('/admin/dashboard', request.url));
      }
    } catch {
      return NextResponse.next();
    }
  }

  // Verify token for protected routes
  if (isAdminRoute && authToken) {
    try {
      const secret = process.env.JWT_SECRET;
      if (!secret) return NextResponse.redirect(new URL('/admin/login', request.url));
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
