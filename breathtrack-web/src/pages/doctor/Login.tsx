import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { User, Lock, ArrowRight, Stethoscope, FileText, Video, ShieldCheck, ChevronLeft } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import BTInputField from '../../components/BTInputField';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Login.css';

const DoctorLogin: React.FC = () => {
    const [doctorId, setDoctorId] = useState('');
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
            id: doctorId,
            password,
            role: 'doctor'
        });

        if (result.success) {
            navigate('/doctor/dashboard');
        } else {
            setError(result.message);
            setLoading(false);
        }
    };

    return (
        <div className="login-page-web">
            <div className="login-side-banner doctor-banner">
                <div className="banner-content">
                    <div className="banner-logo">
                        <Stethoscope size={40} color="white" />
                        <span>BreathTrack Clinical</span>
                    </div>
                    <h1>Elevating Patient Care.</h1>
                    <p>Monitor patient health metrics, assign clinical reports, and manage appointments with your patients seamlessly.</p>

                    <div className="banner-features">
                        <div className="feature-item">
                            <ShieldCheck size={20} />
                            <span>HIPAA Compliant Data Storage</span>
                        </div>
                        <div className="feature-item">
                            <Video size={20} />
                            <span>Patient Video Library Management</span>
                        </div>
                        <div className="feature-item">
                            <FileText size={20} />
                            <span>Comprehensive Clinical Reporting</span>
                        </div>
                    </div>
                </div>
                <div className="banner-overlay doctor-overlay"></div>
            </div>

            <div className="login-form-side">
                <div className="login-card-web">
                    <header className="login-header-web">
                        <Link to="/select-role" className="back-link-web" style={{ marginBottom: '24px' }}>
                            <ChevronLeft size={16} /> Back to Role Selection
                        </Link>
                        <h2>Doctor Sign In</h2>
                        <p>Enter your credentials to access the clinical portal</p>
                    </header>

                    <form onSubmit={handleLogin} className="login-form-web doctor-form">
                        <div className="form-group-web">
                            <div className="label-row">
                                <label>DOCTOR ID</label>
                            </div>
                            <BTInputField
                                icon={<User size={20} />}
                                placeholder="e.g. doc_002"
                                value={doctorId}
                                onChange={(e) => setDoctorId(e.target.value)}
                            />
                        </div>

                        <div className="form-group-web">
                            <div className="label-row">
                                <label>PASSWORD</label>
                                <Link to="/doctor/forgot-password" style={{ color: '#5b4cf5' }}>Forgot?</Link>
                            </div>
                            <BTInputField
                                icon={<Lock size={20} />}
                                type="password"
                                placeholder="••••••••"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                            />
                        </div>

                        {error && <motion.div className="error-alert" initial={{ scale: 0.95, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}>{error}</motion.div>}

                        <BTPrimaryButton
                            type="submit"
                            loading={loading}
                            icon={<ArrowRight size={20} />}
                            className="login-btn-web doctor-signin-btn"
                        >
                            Log into Portal
                        </BTPrimaryButton>
                    </form>
                </div>
            </div>
        </div>
    );
};

export default DoctorLogin;
