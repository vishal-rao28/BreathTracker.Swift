import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { User, Lock, ArrowRight, Stethoscope, ChevronLeft, CheckCircle2, KeyRound } from 'lucide-react';
import { apiCall } from '../../api/apiService';
import BTInputField from '../../components/BTInputField';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Login.css';

const DoctorForgotPassword: React.FC = () => {
    const [doctorId, setDoctorId] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [isVerified, setIsVerified] = useState(false);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    const navigate = useNavigate();

    const handleVerifyId = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!doctorId) {
            setError('Please enter your Doctor ID');
            return;
        }

        setLoading(true);
        setError('');

        const result = await apiCall('verify_doctor.php', 'POST', { doctor_id: doctorId });

        if (result.status === 'success') {
            setIsVerified(true);
            setLoading(false);
        } else {
            setError(result.message || 'Doctor ID not found');
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

        const result = await apiCall('doctor_forgot_password.php', 'POST', {
            doctor_id: doctorId,
            new_password: newPassword
        });

        if (result.status === 'success') {
            setSuccess('Password reset successfully!');
            setLoading(false);
            setTimeout(() => {
                navigate('/doctor/login');
            }, 2000);
        } else {
            setError(result.message || 'Failed to reset password');
            setLoading(false);
        }
    };

    return (
        <div className="doctor-login-page">
            <div className="doctor-portal-bg">
                <div className="doctor-dot-pattern"></div>
            </div>

            <motion.div
                className="doctor-login-card"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5 }}
                style={{ width: '100%', maxWidth: '440px' }}
            >
                <div className="doctor-card-header">
                    <div className="doctor-badge-ios">
                        <Stethoscope size={14} />
                        <span>Doctor Portal</span>
                    </div>
                </div>

                <div className="doctor-login-content">
                    <div className="doctor-titles">
                        <Link to="/doctor/login" className="back-link-web" style={{ marginBottom: '16px', color: '#7B6CF6', display: 'flex', alignItems: 'center' }}>
                            <ChevronLeft size={16} /> Back to Login
                        </Link>
                        <h1>Forgot Password</h1>
                        <p>{isVerified ? 'Create a new secure password' : 'Enter your Doctor ID to verify'}</p>
                    </div>

                    <form onSubmit={isVerified ? handleResetPassword : handleVerifyId} className="doctor-form">
                        <div className="form-group-web" style={{ marginBottom: '20px' }}>
                            <label style={{ display: 'block', fontSize: '14px', fontWeight: 600, color: 'var(--bt-text-second)', marginBottom: '8px' }}>Doctor ID</label>
                            <BTInputField
                                icon={<User size={20} />}
                                placeholder="e.g. doc_123"
                                value={doctorId}
                                onChange={(e) => setDoctorId(e.target.value)}
                                disabled={isVerified}
                            />
                        </div>

                        <AnimatePresence mode="wait">
                            {isVerified && (
                                <motion.div
                                    initial={{ height: 0, opacity: 0 }}
                                    animate={{ height: 'auto', opacity: 1 }}
                                    exit={{ height: 0, opacity: 0 }}
                                    style={{ overflow: 'hidden' }}
                                >
                                    <div className="verification-badge" style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#34C98A', fontSize: '14px', fontWeight: 600, marginBottom: '20px' }}>
                                        <CheckCircle2 size={16} />
                                        <span>ID Verified</span>
                                    </div>

                                    <div className="form-group-web" style={{ marginBottom: '20px' }}>
                                        <label style={{ display: 'block', fontSize: '14px', fontWeight: 600, color: 'var(--bt-text-second)', marginBottom: '8px' }}>New Password</label>
                                        <BTInputField
                                            icon={<Lock size={20} />}
                                            type="password"
                                            placeholder="Enter new password"
                                            value={newPassword}
                                            onChange={(e) => setNewPassword(e.target.value)}
                                        />
                                    </div>

                                    <div className="form-group-web" style={{ marginBottom: '20px' }}>
                                        <label style={{ display: 'block', fontSize: '14px', fontWeight: 600, color: 'var(--bt-text-second)', marginBottom: '8px' }}>Confirm New Password</label>
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
                                className="doctor-login-error"
                                initial={{ opacity: 0, height: 0 }}
                                animate={{ opacity: 1, height: 'auto' }}
                                style={{ color: '#FF6B6B', fontSize: '14px', marginBottom: '16px' }}
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
                                    marginBottom: '20px',
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
                            variant="purple"
                            loading={loading}
                            icon={isVerified ? <KeyRound size={20} /> : <ArrowRight size={20} />}
                            fullWidth
                            className="doctor-signin-btn"
                        >
                            {isVerified ? 'Reset Password' : 'Verify My ID'}
                        </BTPrimaryButton>
                    </form>
                </div>
            </motion.div>
        </div>
    );
};

export default DoctorForgotPassword;
