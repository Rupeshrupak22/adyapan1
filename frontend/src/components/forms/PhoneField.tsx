'use client';

import { sanitizeMobileInput, isIndianMobile } from '@/lib/phone';

type Props = {
  value: string;
  onChange: (digits: string) => void;
  label?: string;
  required?: boolean;
  placeholder?: string;
  inputClassName?: string;
  labelClassName?: string;
  name?: string;
  disabled?: boolean;
  /** Show the +91 prefix box. */
  showPrefix?: boolean;
};

/**
 * Indian mobile input. Stores only the 10-digit core in `value`.
 * Displays a fixed +91 prefix and validates start digit 6-9.
 */
export default function PhoneField({
  value,
  onChange,
  label = 'Phone',
  required = true,
  placeholder = '10-digit mobile number',
  inputClassName = 'w-full px-4 py-3 rounded-xl border border-gray-200 bg-white text-sm text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all',
  labelClassName = 'block text-xs font-bold text-gray-600 mb-1.5',
  name = 'phone',
  disabled = false,
  showPrefix = true,
}: Props) {
  const valid = isIndianMobile(value);
  const showError = value.length > 0 && !valid;

  return (
    <div>
      {label && (
        <label className={labelClassName}>
          {label} {required && <span className="text-red-500">*</span>}
        </label>
      )}
      <div className="flex gap-2">
        {showPrefix && (
          <span className="rounded-xl border border-gray-200 px-3 py-3 text-sm bg-gray-50 text-gray-600 shrink-0 flex items-center">
            +91
          </span>
        )}
        <input
          type="tel"
          name={name}
          inputMode="numeric"
          value={value}
          onChange={(e) => onChange(sanitizeMobileInput(e.target.value))}
          placeholder={placeholder}
          maxLength={10}
          required={required}
          disabled={disabled}
          className={inputClassName}
        />
      </div>
      {showError && (
        <p className="mt-1.5 text-xs text-red-500">
          {value.length < 10
            ? `${10 - value.length} more digit${10 - value.length === 1 ? '' : 's'} needed`
            : 'Number must start with 6, 7, 8 or 9.'}
        </p>
      )}
    </div>
  );
}
