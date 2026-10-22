import React from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import BTPrimaryButton from '../components/BTPrimaryButton';
import './Welcome.css';

const Welcome: React.FC = () => {
    const navigate = useNavigate();

    return (
        <div className="welcome-screen">
            <div className="hero-gradient-overlay"></div>

            <motion.div
                className="welcome-content"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, ease: "easeOut" }}
            >
                <div className="logo-container">
                    <span className="lungs-icon">🫁</span>
                    <h1 className="brand-name">BreathTrack</h1>
                </div>

                <motion.p
                    className="tagline"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.5, duration: 1 }}
                >
                    Breathe Better. Live Better.
                </motion.p>

                <div className="button-container">
                    <BTPrimaryButton
                        onClick={() => navigate('/select-role')}
                        className="stagger-3"
                    >
                        Get Started
                    </BTPrimaryButton>
                </div>
            </motion.div>
        </div>
    );
};

export default Welcome;
