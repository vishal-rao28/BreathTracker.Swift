import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { User, Lock, ArrowRight, ShieldCheck, HeartPulse, ChevronLeft } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import BTInputField from '../../components/BTInputField';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Login.css';

const PatientLogin: React.FC = () => {
    const [patientId, setPatientId] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const { login } = useAuth();
    const navigate = useNavigate();

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        const result = await login({
            id: patientId,
            password,
            role: 'patient'
        });

        if (result.success) {
            navigate('/patient/dashboard');
        } else {
            setError(result.message);
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
                    <h1>Empowering Your Respiratory Health.</h1>
                    <p>Access your medical reports, track symptoms, and stay connected with your doctor from anywhere.</p>

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
                        <Link to="/select-role" className="back-link-web" style={{ marginBottom: '24px' }}>
                            <ChevronLeft size={16} /> Back to Role Selection
                        </Link>
                        <h2>Patient Sign In</h2>
                        <p>Enter your credentials to access your dashboard</p>
                    </header>

                    <form onSubmit={handleLogin} className="login-form-web">
                        <div className="form-group-web">
                            <div className="label-row">
                                <label>Patient ID</label>
                                <Link to="/patient/recover-id">Forgot ID?</Link>
                            </div>
                            <BTInputField
                                icon={<User size={20} />}
                                placeholder="e.g. pat_123"
                                value={patientId}
                                onChange={(e) => setPatientId(e.target.value)}
                            />
                        </div>

                        <div className="form-group-web">
                            <div className="label-row">
                                <label>Password</label>
                                <Link to="/patient/forgot-password">Forgot?</Link>
                            </div>
                            <BTInputField
                                icon={<Lock size={20} />}
                                type="password"
                                placeholder="Your secure password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                            />
                        </div>

                        {error && <motion.div className="error-alert" initial={{ scale: 0.95, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}>{error}</motion.div>}

                        <BTPrimaryButton
                            type="submit"
                            loading={loading}
                            icon={<ArrowRight size={20} />}
                            className="login-btn-web"
                        >
                            Log into Dashboard
                        </BTPrimaryButton>
                    </form>

                    <footer className="login-footer-web">
                        <p>New to BreathTrack? <Link to="/patient/signup">Create an account</Link></p>
                    </footer>
                </div>
            </div>
        </div>
    );
};

export default PatientLogin;
