import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ChevronLeft, Minus, Plus } from 'lucide-react';
import { useCheckup } from '../../../context/CheckupContext';
import { useAuth } from '../../../context/AuthContext';
import { apiCall } from '../../../api/apiService';
import BTPrimaryButton from '../../../components/BTPrimaryButton';
import './TempCheck.css';

const LungFunction: React.FC = () => {
    const [fev1, setFev1] = useState(75);
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();
    const { data, resetData } = useCheckup();
    const { user } = useAuth();

    const getStage = (f: number) => {
        if (f >= 80) return { stage: 'I', text: 'Mild', color: '#34C98A' };
        if (f >= 50) return { stage: 'II', text: 'Moderate', color: '#FF9B42' };
        if (f >= 30) return { stage: 'III', text: 'Severe', color: '#FF6B6B' };
        return { stage: 'IV', text: 'Very Severe', color: '#7B6CF6' };
    };

    const status = getStage(fev1);

    const handleComplete = async () => {
        if (!user) return;
        setLoading(true);

        const payload = {
            patient_id: user.id,
            temperature: data.temperature,
            oxygen_level: data.oxygen_level,
            lung_function: fev1
        };

        const result = await apiCall('save_checkup.php', 'POST', payload);

        if (result.success || result.status === 'success') {
            resetData();
            navigate('/patient/dashboard');
        } else {
            alert(result.message || 'Failed to submit checkup');
            setLoading(false);
        }
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
                <div className="step-indicator">Step 3 of 3 — Lung Function</div>

                <motion.div
                    className="temp-display-container"
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                >
                    <div className="glow-circle">
                        <span style={{ fontSize: '48px' }}>🫁</span>
                    </div>

                    <div className="temp-value">
                        {fev1}<span>%</span>
                    </div>

                    <div className="status-badge" style={{ backgroundColor: `${status.color}20`, color: status.color }}>
                        GOLD Stage {status.stage} ({status.text})
                    </div>
                </motion.div>

                <div className="controls-row">
                    <button className="control-btn minus btn-press" onClick={() => setFev1(f => Math.max(10, f - 1))}>
                        <Minus size={24} />
                    </button>
                    <button className="control-btn plus btn-press" onClick={() => setFev1(f => Math.min(100, f + 1))}>
                        <Plus size={24} />
                    </button>
                </div>
            </main>

            <footer className="checkup-footer">
                <BTPrimaryButton onClick={handleComplete} loading={loading}>
                    Complete Checkup
                </BTPrimaryButton>
            </footer>
        </div>
    );
};

export default LungFunction;
