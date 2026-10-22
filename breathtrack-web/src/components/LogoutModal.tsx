import React from 'react';
import { LogOut, X } from 'lucide-react';
import './LogoutModal.css';

interface LogoutModalProps {
    isOpen: boolean;
    onClose: () => void;
    onConfirm: () => void;
}

const LogoutModal: React.FC<LogoutModalProps> = ({ isOpen, onClose, onConfirm }) => {
    if (!isOpen) return null;

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="logout-modal-container" onClick={(e) => e.stopPropagation()}>
                <button className="modal-close-btn" onClick={onClose}>
                    <X size={20} />
                </button>

                <div className="modal-content">
                    <div className="logout-icon-wrapper">
                        <LogOut size={32} />
                    </div>

                    <h3>Confirm Logout</h3>
                    <p>Are you sure you want to log out of your account? You will need to log in again to access your dashboard.</p>

                    <div className="modal-actions">
                        <button className="btn-cancel" onClick={onClose}>
                            Cancel
                        </button>
                        <button className="btn-confirm" onClick={onConfirm}>
                            Logout
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default LogoutModal;
