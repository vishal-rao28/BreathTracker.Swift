import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronLeft, FileSearch, Pill, ChevronRight } from 'lucide-react';
import { motion } from 'framer-motion';
import './Advice.css';

const MedicalAdvice: React.FC = () => {
    const navigate = useNavigate();
    const [appeared, setAppeared] = useState(false);

    useEffect(() => {
        setAppeared(true);
    }, []);

    const adviceCards = [
        {
            title: "COPD Health Review",
            subtitle: "Personalized medical checklist",
            icon: <FileSearch size={28} />,
            color: "var(--bt-primary)",
            bg: "rgba(26, 107, 138, 0.12)",
            path: "/patient/advice/review"
        },
        {
            title: "Medication Diary",
            subtitle: "Active prescriptions & advice",
            icon: <Pill size={28} />,
            color: "var(--bt-accent-green)",
            bg: "rgba(52, 201, 138, 0.12)",
            path: "/patient/meds"
        }
    ];

    return (
        <div className="advice-page-view">
            <header className="advice-header">
                <button className="back-btn-round" onClick={() => navigate(-1)}>
                    <ChevronLeft size={24} />
                </button>
                <h1>Treatment Advice</h1>
                <div className="header-spacer"></div>
            </header>

            <div className={`advice-content ${appeared ? 'appeared' : ''}`}>
                <motion.div
                    className="advice-intro"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6 }}
                >
                    <h2>Your Care Plan</h2>
                    <p>Review your latest medical checkup results, medications, and therapeutic resources.</p>
                </motion.div>

                <div className="advice-cards-list">
                    {adviceCards.map((card, idx) => (
                        <motion.div
                            key={idx}
                            className="advice-card-modern btn-press"
                            onClick={() => navigate(card.path)}
                            initial={{ opacity: 0, scale: 0.9, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            transition={{ delay: 0.1 + idx * 0.1, type: 'spring', damping: 15 }}
                        >
                            <div className="card-icon-circle" style={{ backgroundColor: card.bg, color: card.color }}>
                                {card.icon}
                            </div>
                            <div className="card-text">
                                <h3>{card.title}</h3>
                                <p>{card.subtitle}</p>
                            </div>
                            <ChevronRight size={18} className="card-chevron" />
                        </motion.div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default MedicalAdvice;
