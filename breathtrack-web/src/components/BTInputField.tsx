import React, { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import './BTInputField.css';

interface BTInputFieldProps {
    label?: string;
    icon?: React.ReactNode;
    placeholder?: string;
    type?: string;
    value: string;
    onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
    error?: string;
    className?: string;
    disabled?: boolean;
}

const BTInputField: React.FC<BTInputFieldProps> = ({
    label,
    icon,
    placeholder,
    type = 'text',
    value,
    onChange,
    error,
    className = '',
    disabled = false,
}) => {
    const [showPassword, setShowPassword] = useState(false);
    const isPassword = type === 'password';

    return (
        <div className={`bt-input-container ${className} ${disabled ? 'disabled' : ''}`}>
            {label && <label className="bt-input-label">{label}</label>}
            <div className={`bt-input-wrapper ${error ? 'error' : ''} ${disabled ? 'disabled' : ''}`}>
                {icon && <span className="bt-input-icon">{icon}</span>}
                <input
                    type={isPassword ? (showPassword ? 'text' : 'password') : type}
                    placeholder={placeholder}
                    value={value}
                    onChange={onChange}
                    disabled={disabled}
                    className="bt-input-field"
                />
                {isPassword && (
                    <button
                        type="button"
                        className="password-toggle"
                        onClick={() => setShowPassword(!showPassword)}
                    >
                        {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                    </button>
                )}
            </div>
            {error && <span className="bt-input-error-text">{error}</span>}
        </div>
    );
};

export default BTInputField;
