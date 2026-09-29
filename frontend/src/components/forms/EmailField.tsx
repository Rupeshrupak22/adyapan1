'use client';

import { isValidEmail } from '@/lib/email-format';

type Props = {
  email: string;
  onEmailChange: (email: string) => void;
  label?: string;
  required?: boolean;
  placeholder?: string;
  inputClassName?: string;
  labelClassName?: string;
  disabled?: boolean;
  name?: string;
};

/**
 * Plain email input with format validation only (no OTP verification).
 * Rejects malformed values (missing @, missing domain dot, spaces, double @, etc.)
 * and shows an inline error while the user types.
 */
export default function EmailField({
  email,
  onEmailChange,
  label = 'Email',
  required = true,
  placeholder = 'Enter your email address',
  inputClassName = 'w-full px-4 py-3 rounded-xl border border-gray-200 bg-white text-sm text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all',
  labelClassName = 'block text-xs font-bold text-gray-600 mb-1.5',
  disabled = false,
  name = 'email',
}: Props) {
  const showError = email.trim().length > 0 && !isValidEmail(email);

  return (
    <div>
      {label && (
        <label className={labelClassName}>
          {label} {required && <span className="text-red-500">*</span>}
        </label>
      )}
      <input
        type="email"
        name={name}
        value={email}
        onChange={(e) => onEmailChange(e.target.value)}
        placeholder={placeholder}
        required={required}
        disabled={disabled}
        className={inputClassName}
      />
      {showError && (
        <p className="mt-1.5 text-xs text-red-500">Enter a valid email address (e.g. name@example.com).</p>
      )}
    </div>
  );
}
