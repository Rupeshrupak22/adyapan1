// Signup redirect page is PUBLIC — bypass the admin PortalLayout
// which would redirect unauthenticated users to /admin/login.
export default function SignupLayout({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}
