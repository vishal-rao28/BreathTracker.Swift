import React from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { User, Stethoscope, ChevronRight, Activity, ShieldCheck } from 'lucide-react';
import './RoleSelection.css';

const RoleSelection: React.FC = () => {
    const navigate = useNavigate();

    const roles = [
        {
            id: 'patient',
            title: "I'm a Patient",
            desc: 'Track vitals, manage medications and connect with your doctor.',
            icon: <User size={32} />,
            path: '/patient/login',
            theme: 'patient',
            extra: 'Access to health dashboard'
        },
        {
            id: 'doctor',
            title: "I'm a Doctor",
            desc: 'Analyze patient data, review reports and provide consultations.',
            icon: <Stethoscope size={32} />,
            path: '/doctor/login',
            theme: 'doctor',
            extra: 'Medical control panel'
        }
    ];

    return (
        <div className="role-selection-web">
            <div className="role-inner-container">
                <header className="role-header-web">
                    <div className="brand-badge">🫁 BreathTrack</div>
                    <h1>Welcome to BreathTrack</h1>
                    <p>Select your workspace to get started</p>
                </header>

                <div className="role-cards-wrapper">
                    {roles.map((role, idx) => (
                        <motion.div
                            key={role.id}
                            className={`role-platform-card ${role.theme}`}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: idx * 0.1 }}
                            onClick={() => navigate(role.path)}
                        >
                            <div className="platform-icon">{role.icon}</div>
                            <div className="platform-content">
                                <h3>{role.title}</h3>
                                <p>{role.desc}</p>
                                <div className="platform-meta">
                                    <span className="meta-tag">{role.extra}</span>
                                </div>
                            </div>
                            <ChevronRight className="arrow-icon" size={24} />
                        </motion.div>
                    ))}
                </div>

                <footer className="role-footer-web">
                    <div className="footer-info">
                        <Activity size={16} />
                        <span>Real-time Health Monitoring</span>
                    </div>
                    <div className="footer-info">
                        <ShieldCheck size={16} />
                        <span>HIPAA Compliant Security</span>
                    </div>
                </footer>
            </div>
        </div>
    );
};

export default RoleSelection;
