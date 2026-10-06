// Root admin layout — no auth wrapping here.
// Protected pages live in (portal)/ which has its own layout with PortalLayout.
// Public pages (invite, signup) live directly under /admin/ with no auth.
export default function AdminRootLayout({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}
