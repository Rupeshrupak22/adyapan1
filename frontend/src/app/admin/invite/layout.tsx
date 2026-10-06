// Invite acceptance pages are PUBLIC — bypass the admin PortalLayout
// which would redirect unauthenticated users to /admin/login.
export default function InviteLayout({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}
