import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { Phone, ShieldCheck, HeartPulse, ChevronLeft, Search, ArrowLeft } from 'lucide-react';
import { apiCall } from '../../api/apiService';
import BTInputField from '../../components/BTInputField';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Login.css';

const RecoverPatientId: React.FC = () => {
    const [phoneNumber, setPhoneNumber] = useState('');
    const [recoveredId, setRecoveredId] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const navigate = useNavigate();

    const handleRecoverId = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!phoneNumber) {
            setError('Please enter your Registered Phone Number');
            return;
        }

        setLoading(true);
        setError('');

        const result = await apiCall('recover_patient_id.php', 'POST', { phone_number: phoneNumber });

        if (result.status === 'success' && result.patient_id) {
            setRecoveredId(result.patient_id);
            setLoading(false);
        } else {
            setError(result.message || 'No account found with this phone number');
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
                    <h1>Recover Your Identity.</h1>
                    <p>Enter your registered phone number to find your unique Patient ID. This ID is essential for accessing your medical records.</p>

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
                        <h2>Recover ID</h2>
                        <p>{recoveredId ? 'We found your account!' : 'Enter your phone number to find your ID'}</p>
                    </header>

                    <form onSubmit={recoveredId ? () => navigate('/patient/login') : handleRecoverId} className="login-form-web">
                        <AnimatePresence mode="wait">
                            {!recoveredId ? (
                                <motion.div
                                    key="input-form"
                                    initial={{ opacity: 0, x: -20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: 20 }}
                                >
                                    <div className="form-group-web">
                                        <label>Phone Number</label>
                                        <BTInputField
                                            icon={<Phone size={20} />}
                                            placeholder="Enter registered phone number"
                                            value={phoneNumber}
                                            onChange={(e) => setPhoneNumber(e.target.value)}
                                        />
                                    </div>
                                </motion.div>
                            ) : (
                                <motion.div
                                    key="id-result"
                                    initial={{ opacity: 0, scale: 0.9 }}
                                    animate={{ opacity: 1, scale: 1 }}
                                    className="id-recovery-result"
                                >
                                    <div className="id-reveal-box" style={{ marginTop: 0 }}>
                                        <span className="id-label">YOUR PATIENT ID</span>
                                        <div className="id-value" style={{ fontSize: '36px', fontWeight: 'bold' }}>{recoveredId}</div>
                                    </div>
                                    <p className="id-note">You can now use this ID to sign into your dashboard safely.</p>
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

                        <BTPrimaryButton
                            type="submit"
                            loading={loading}
                            icon={recoveredId ? <ArrowLeft size={20} /> : <Search size={20} />}
                            className="login-btn-web"
                        >
                            {recoveredId ? 'Back to Login' : 'Find My ID'}
                        </BTPrimaryButton>
                    </form>
                </div>
            </div>
        </div>
    );
};

export default RecoverPatientId;
