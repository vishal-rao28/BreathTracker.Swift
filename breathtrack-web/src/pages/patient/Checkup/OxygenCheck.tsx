import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ChevronLeft, Wind, Minus, Plus } from 'lucide-react';
import { useCheckup } from '../../../context/CheckupContext';
import BTPrimaryButton from '../../../components/BTPrimaryButton';
import './TempCheck.css'; // Reusing layout styles

const OxygenCheck: React.FC = () => {
    const [oxygen, setOxygen] = useState(98);
    const navigate = useNavigate();
    const { updateData } = useCheckup();

    const getStatus = (o: number) => {
        if (o < 90) return { text: 'Critical', color: '#FF6B6B' };
        if (o < 95) return { text: 'Low Oxygen', color: '#FF9B42' };
        return { text: 'Normal SpO2', color: '#34C98A' };
    };

    const status = getStatus(oxygen);

    const handleContinue = () => {
        updateData({ oxygen_level: oxygen });
        navigate('/patient/checkup/lung');
    };

    return (
        <div className="checkup-screen">
            <header className="checkup-header">
                <button className="back-btn" onClick={() => navigate(-1)}>
                    <ChevronLeft size={24} />
                </button>
                <h1>Health Checkup</h1>
            </header>

            <main className="checkup-content">
                <div className="step-indicator">Step 2 of 3 — Oxygen Level</div>

                <motion.div
                    className="temp-display-container"
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                >
                    <div className="glow-circle">
                        <Wind size={48} color="var(--bt-primary-light)" />
                    </div>

                    <div className="temp-value">
                        {oxygen}<span>%</span>
                    </div>

                    <div className="status-badge" style={{ backgroundColor: `${status.color}20`, color: status.color }}>
                        {status.text}
                    </div>
                </motion.div>

                <div className="controls-row">
                    <button className="control-btn minus btn-press" onClick={() => setOxygen(o => Math.max(80, o - 1))}>
                        <Minus size={24} />
                    </button>
                    <button className="control-btn plus btn-press" onClick={() => setOxygen(o => Math.min(100, o + 1))}>
                        <Plus size={24} />
                    </button>
                </div>
            </main>

            <footer className="checkup-footer">
                <BTPrimaryButton onClick={handleContinue}>
                    Continue to Lung Function
                </BTPrimaryButton>
            </footer>
        </div>
    );
};

export default OxygenCheck;
