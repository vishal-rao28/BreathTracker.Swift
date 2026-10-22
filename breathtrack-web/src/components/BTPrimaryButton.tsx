import React from 'react';
import './BTPrimaryButton.css';

interface BTPrimaryButtonProps {
    children: React.ReactNode;
    onClick?: () => void;
    type?: 'button' | 'submit';
    variant?: 'teal' | 'purple' | 'outline';
    loading?: boolean;
    disabled?: boolean;
    icon?: React.ReactNode;
    className?: string;
    fullWidth?: boolean;
}

const BTPrimaryButton: React.FC<BTPrimaryButtonProps> = ({
    children,
    onClick,
    type = 'button',
    variant = 'teal',
    loading = false,
    disabled = false,
    icon,
    className = '',
    fullWidth = true,
}) => {
    return (
        <button
            type={type}
            onClick={onClick}
            disabled={disabled || loading}
            className={`bt-primary-button ${variant} ${fullWidth ? 'full-width' : ''} ${className} btn-press`}
        >
            {loading ? (
                <div className="spinner"></div>
            ) : (
                <>
                    <span className="bt-btn-inner">{children}</span>
                    {icon && <span className="btn-icon">{icon}</span>}
                </>
            )}
        </button>
    );
};

export default BTPrimaryButton;
