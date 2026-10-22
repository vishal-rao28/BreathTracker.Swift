import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ChevronLeft, Thermometer, Minus, Plus } from 'lucide-react';
import { useCheckup } from '../../../context/CheckupContext';
import BTPrimaryButton from '../../../components/BTPrimaryButton';
import './TempCheck.css';

const TempCheck: React.FC = () => {
    const [temp, setTemp] = useState(98.6);
    const navigate = useNavigate();
    const { updateData } = useCheckup();

    const getStatus = (t: number) => {
        if (t < 97) return { text: 'Below Normal', color: '#56CCF2' };
        if (t <= 99) return { text: 'Normal Range', color: '#34C98A' };
        if (t <= 100.4) return { text: 'Slight Fever', color: '#FF9B42' };
        return { text: 'High Fever', color: '#FF6B6B' };
    };

    const status = getStatus(temp);

    const handleContinue = () => {
        updateData({ temperature: temp });
        navigate('/patient/checkup/oxygen');
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
                <div className="step-indicator">Step 1 of 3 — Temperature</div>

                <motion.div
                    className="temp-display-container"
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                >
                    <div className="glow-circle">
                        <Thermometer size={48} color="var(--bt-primary)" />
                    </div>

                    <div className="temp-value">
                        {temp.toFixed(1)}<span>°F</span>
                    </div>

                    <div className="status-badge" style={{ backgroundColor: `${status.color}20`, color: status.color }}>
                        {status.text}
                    </div>
                </motion.div>

                <div className="controls-row">
                    <button className="control-btn minus btn-press" onClick={() => setTemp(t => t - 0.1)}>
                        <Minus size={24} />
                    </button>
                    <button className="control-btn plus btn-press" onClick={() => setTemp(t => t + 0.1)}>
                        <Plus size={24} />
                    </button>
                </div>
            </main>

            <footer className="checkup-footer">
                <BTPrimaryButton onClick={handleContinue}>
                    Continue to Oxygen Check
                </BTPrimaryButton>
            </footer>
        </div>
    );
};

export default TempCheck;
