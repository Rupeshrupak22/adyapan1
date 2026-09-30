'use client';

import { sanitizeNameInput, isValidName } from '@/lib/name-format';

type Props = {
  value: string;
  onChange: (name: string) => void;
  label?: string;
  required?: boolean;
  placeholder?: string;
  inputClassName?: string;
  labelClassName?: string;
  name?: string;
  disabled?: boolean;
};

/**
 * Name input that accepts only letters/spaces and auto-capitalises each word.
 * Shows an inline error until the value is a valid capitalised name.
 */
export default function NameField({
  value,
  onChange,
  label = 'Name',
  required = true,
  placeholder = 'Enter your full name',
  inputClassName = 'w-full px-4 py-3 rounded-xl border border-gray-200 bg-white text-sm text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all',
  labelClassName = 'block text-xs font-bold text-gray-600 mb-1.5',
  name = 'name',
  disabled = false,
}: Props) {
  const showError = value.trim().length > 0 && !isValidName(value);

  return (
    <div>
      {label && (
        <label className={labelClassName}>
          {label} {required && <span className="text-red-500">*</span>}
        </label>
      )}
      <input
        type="text"
        name={name}
        value={value}
        onChange={(e) => onChange(sanitizeNameInput(e.target.value))}
        placeholder={placeholder}
        required={required}
        disabled={disabled}
        autoComplete="name"
        className={inputClassName}
      />
      {showError && (
        <p className="mt-1.5 text-xs text-red-500">
          Only letters allowed and must start with a capital letter.
        </p>
      )}
    </div>
  );
}
