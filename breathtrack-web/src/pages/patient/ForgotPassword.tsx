import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { User, Lock, ArrowRight, ShieldCheck, HeartPulse, ChevronLeft, CheckCircle2, KeyRound } from 'lucide-react';
import { apiCall } from '../../api/apiService';
import BTInputField from '../../components/BTInputField';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Login.css';

const ForgotPassword: React.FC = () => {
    const [patientId, setPatientId] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [isVerified, setIsVerified] = useState(false);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    const navigate = useNavigate();

    const handleVerifyId = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!patientId) {
            setError('Please enter your Patient ID');
            return;
        }

        setLoading(true);
        setError('');

        const result = await apiCall('verify_patient.php', 'POST', { patient_id: patientId });

        if (result.status === 'success') {
            setIsVerified(true);
            setLoading(false);
        } else {
            setError(result.message || 'Patient ID not found');
            setLoading(false);
        }
    };

    const handleResetPassword = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newPassword || !confirmPassword) {
            setError('All fields are required');
            return;
        }

        if (newPassword !== confirmPassword) {
            setError('Passwords do not match');
            return;
        }

        setLoading(true);
        setError('');

        const result = await apiCall('patient_forgot_password.php', 'POST', {
            patient_id: patientId,
            new_password: newPassword
        });

        if (result.status === 'success') {
            setSuccess('Password reset successfully!');
            setLoading(false);
            setTimeout(() => {
                navigate('/patient/login');
            }, 2000);
        } else {
            setError(result.message || 'Failed to reset password');
            setLoading(false);
        }
    };

    return (
        <div className="login-page-web">
            <div className="login-side-banner">
                <div className="banner-content">
                    <div className="banner-logo">
                        <HeartPulse size={40} color="white" />
                        <span>BreathTrack</span>
                    </div>
                    <h1>Reset Your Access.</h1>
                    <p>Enter your patient ID to verify your identity and set a new secure password for your account.</p>

                    <div className="banner-features">
                        <div className="feature-item">
                            <ShieldCheck size={20} />
                            <span>Encrypted & Secure Patient Data</span>
                        </div>
                    </div>
                </div>
                <div className="banner-overlay"></div>
            </div>

            <div className="login-form-side">
                <div className="login-card-web">
                    <header className="login-header-web">
                        <Link to="/patient/login" className="back-link-web">
                            <ChevronLeft size={16} /> Back to Login
                        </Link>
                        <h2>Forgot Password</h2>
                        <p>{isVerified ? 'Create a new secure password' : 'Enter your Patient ID to verify'}</p>
                    </header>

                    <form onSubmit={isVerified ? handleResetPassword : handleVerifyId} className="login-form-web">
                        <div className="form-group-web">
                            <label>Patient ID</label>
                            <BTInputField
                                icon={<User size={20} />}
                                placeholder="e.g. pat_123"
                                value={patientId}
                                onChange={(e) => setPatientId(e.target.value)}
                                disabled={isVerified}
                            />
                        </div>

                        <AnimatePresence mode="wait">
                            {isVerified && (
                                <motion.div
                                    initial={{ height: 0, opacity: 0 }}
                                    animate={{ height: 'auto', opacity: 1 }}
                                    exit={{ height: 0, opacity: 0 }}
                                    className="verification-success-fields"
                                >
                                    <div className="verification-badge">
                                        <CheckCircle2 size={16} color="#34C98A" />
                                        <span>ID Verified</span>
                                    </div>

                                    <div className="form-group-web">
                                        <label>New Password</label>
                                        <BTInputField
                                            icon={<Lock size={20} />}
                                            type="password"
                                            placeholder="Enter new password"
                                            value={newPassword}
                                            onChange={(e) => setNewPassword(e.target.value)}
                                        />
                                    </div>

                                    <div className="form-group-web">
                                        <label>Confirm New Password</label>
                                        <BTInputField
                                            icon={<Lock size={20} />}
                                            type="password"
                                            placeholder="Confirm new password"
                                            value={confirmPassword}
                                            onChange={(e) => setConfirmPassword(e.target.value)}
                                        />
                                    </div>
                                </motion.div>
                            )}
                        </AnimatePresence>

                        {error && (
                            <motion.div
                                className="error-alert"
                                initial={{ scale: 0.95, opacity: 0 }}
                                animate={{ scale: 1, opacity: 1 }}
                            >
                                {error}
                            </motion.div>
                        )}

                        {success && (
                            <motion.div
                                className="success-alert"
                                initial={{ scale: 0.95, opacity: 0 }}
                                animate={{ scale: 1, opacity: 1 }}
                                style={{
                                    backgroundColor: '#E7F9F1',
                                    color: '#166534',
                                    padding: '12px 16px',
                                    borderRadius: '12px',
                                    marginBottom: '24px',
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '8px',
                                    fontSize: '14px',
                                    border: '1px solid rgba(52, 201, 138, 0.2)'
                                }}
                            >
                                <CheckCircle2 size={18} />
                                {success}
                            </motion.div>
                        )}

                        <BTPrimaryButton
                            type="submit"
                            loading={loading}
                            icon={isVerified ? <KeyRound size={20} /> : <ArrowRight size={20} />}
                            className="login-btn-web"
                        >
                            {isVerified ? 'Reset Password' : 'Verify My ID'}
                        </BTPrimaryButton>
                    </form>
                </div>
            </div>
        </div>
    );
};

export default ForgotPassword;
