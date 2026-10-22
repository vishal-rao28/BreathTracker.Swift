import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ChevronLeft, CheckCircle2, FileText, Check } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { apiCall } from '../../api/apiService';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Dashboard.css';

const questions = [
    {
        id: 'q1',
        text: 'I never cough vs. I cough all the time',
    },
    {
        id: 'q2',
        text: 'I have no phlegm in my chest vs. My chest is completely full of phlegm',
    },
    {
        id: 'q3',
        text: 'My chest does not feel tight vs. My chest feels very tight',
    },
    {
        id: 'q4',
        text: 'When I walk up a hill or one flight of stairs I am not breathless vs. I am very breathless',
    },
    {
        id: 'q5',
        text: 'I am not limited doing any activities at home vs. I am very limited doing activities',
    },
    {
        id: 'q6',
        text: 'I am confident leaving my home despite my lung condition vs. I am not confident at all',
    },
    {
        id: 'q7',
        text: 'I sleep soundly vs. I don\'t sleep soundly because of my lung condition',
    },
    {
        id: 'q8',
        text: 'I have lots of energy vs. I have no energy',
    }
];

const Questionnaire: React.FC = () => {
    const navigate = useNavigate();
    const { user } = useAuth();
    const [answers, setAnswers] = useState<number[]>(Array(8).fill(0));
    const [loading, setLoading] = useState(false);
    const [existingData, setExistingData] = useState<any>(null);

    // Popup states
    const [showSuccessPopup, setShowSuccessPopup] = useState(false);
    const [submittedScore, setSubmittedScore] = useState<number | null>(null);

    useEffect(() => {
        const fetchExisting = async () => {
            if (!user) return;
            const res = await apiCall('get_questionnaires.php', 'POST', { patient_id: user.id });
            if (res.status === 'success' && res.data) {
                setExistingData(res.data);
                const prevAnswers = [
                    res.data.q1_cough !== null && res.data.q1_cough !== undefined ? Number(res.data.q1_cough) : 0,
                    res.data.q2_phlegm !== null && res.data.q2_phlegm !== undefined ? Number(res.data.q2_phlegm) : 0,
                    res.data.q3_chest_tightness !== null && res.data.q3_chest_tightness !== undefined ? Number(res.data.q3_chest_tightness) : 0,
                    res.data.q4_breathlessness !== null && res.data.q4_breathlessness !== undefined ? Number(res.data.q4_breathlessness) : 0,
                    res.data.q5_activity_limitation !== null && res.data.q5_activity_limitation !== undefined ? Number(res.data.q5_activity_limitation) : 0,
                    res.data.q6_confidence_leaving_home !== null && res.data.q6_confidence_leaving_home !== undefined ? Number(res.data.q6_confidence_leaving_home) : 0,
                    res.data.q7_sleep_quality !== null && res.data.q7_sleep_quality !== undefined ? Number(res.data.q7_sleep_quality) : 0,
                    res.data.q8_energy_level !== null && res.data.q8_energy_level !== undefined ? Number(res.data.q8_energy_level) : 0
                ];
                setAnswers(prevAnswers);
            }
        };
        fetchExisting();
    }, [user]);

    const handleSelect = (qIndex: number, score: number) => {
        const newAnswers = [...answers];
        newAnswers[qIndex] = score;
        setAnswers(newAnswers);
    };

    const handleSubmit = async () => {
        if (!user) return;
        setLoading(true);

        const payload = {
            patient_id: user.id,
            date_pneumococcal: existingData?.date_pneumococcal || "N/A",
            date_flu: existingData?.date_flu || "N/A",
            date_pertussis: existingData?.date_pertussis || "N/A",
            date_shingles1: existingData?.date_shingles1 || "N/A",
            date_shingles2: existingData?.date_shingles2 || "N/A",
            q1_cough: answers[0],
            q2_phlegm: answers[1],
            q3_chest_tightness: answers[2],
            q4_breathlessness: answers[3],
            q5_activity_limitation: answers[4],
            q6_confidence_leaving_home: answers[5],
            q7_sleep_quality: answers[6],
            q8_energy_level: answers[7]
        };

        try {
            const res = await apiCall('submit_questionnaires.php', 'POST', payload);
            setLoading(false);

            if (res.status === 'success') {
                setSubmittedScore(res.average_score);
                setShowSuccessPopup(true);
            } else {
                alert(res.message || 'Error saving questionnaire');
            }
        } catch (error) {
            console.error('Error submitting questionnaire:', error);
            alert('A network error occurred. Please try again.');
            setLoading(false);
        }
    };

    const handleClosePopup = () => {
        setShowSuccessPopup(false);
        navigate('/patient/dashboard');
    };

    return (
        <div className="dashboard-screen" style={{ overflowY: 'auto' }}>
            <header className="meds-header" style={{ padding: '24px', background: 'var(--bt-primary)' }}>
                <button className="back-btn" onClick={() => navigate(-1)} style={{ background: 'transparent', border: 'none', color: 'white', display: 'flex' }}>
                    <ChevronLeft size={28} />
                </button>
                <h1 style={{ color: 'white', marginLeft: '12px' }}>CAT Assessment</h1>
            </header>

            <div style={{ padding: '24px' }}>
                {existingData && (
                    <div className="status-pill" style={{ margin: '0 auto 24px auto', width: 'fit-content' }}>
                        <FileText size={16} />
                        <span style={{ marginLeft: '8px' }}>
                            Previous Score: {existingData.average_score !== undefined && existingData.average_score !== null ? existingData.average_score : '—'}
                        </span>
                    </div>
                )}

                <div style={{ marginBottom: '24px' }}>
                    <p style={{ color: 'var(--bt-text-second)' }}>
                        For each item below, select the number that best describes you currently (0 = Best, 5 = Worst).
                    </p>
                </div>

                {questions.map((q, index) => (
                    <motion.div
                        key={q.id}
                        className="action-cards-grid"
                        style={{ marginBottom: '24px', padding: '16px', background: 'var(--bt-surface)', borderRadius: '16px', boxShadow: 'var(--shadow-sm)' }}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.1 }}
                    >
                        <h4 style={{ marginBottom: '16px', lineHeight: '1.4' }}>{index + 1}. {q.text}</h4>
                        <div style={{ display: 'flex', justifyContent: 'space-between', gap: '8px' }}>
                            {[0, 1, 2, 3, 4, 5].map(score => {
                                const isSelected = answers[index] === score;
                                return (
                                    <button
                                        key={score}
                                        onClick={() => handleSelect(index, score)}
                                        style={{
                                            flex: 1,
                                            height: '44px',
                                            borderRadius: '12px',
                                            border: `2px solid ${isSelected ? 'var(--bt-primary)' : 'var(--bt-surface2)'}`,
                                            background: isSelected ? 'var(--bt-primary)' : 'transparent',
                                            color: isSelected ? 'white' : 'var(--bt-text-primary)',
                                            fontWeight: 'bold',
                                            fontSize: '16px',
                                            cursor: 'pointer',
                                            transition: 'all 0.2s'
                                        }}
                                    >
                                        {score}
                                    </button>
                                );
                            })}
                        </div>
                    </motion.div>
                ))}

                <div style={{ margin: '32px 0 48px 0' }}>
                    <BTPrimaryButton onClick={handleSubmit} loading={loading} icon={<CheckCircle2 size={20} />}>
                        Submit Assessment
                    </BTPrimaryButton>
                </div>
            </div>

            {/* Custom Premium Success Popup */}
            {showSuccessPopup && (
                <div className="success-popup-overlay">
                    <div className="success-popup-card">
                        <div className="success-popup-icon-container">
                            <Check size={40} strokeWidth={2.5} />
                        </div>
                        <h2>Assessment Submitted!</h2>
                        <p>Your COPD Assessment (CAT) has been saved successfully in your medical file.</p>
                        {submittedScore !== null && (
                            <div className="success-popup-score-badge">
                                Average Score: {submittedScore}
                            </div>
                        )}
                        <button className="success-popup-button" onClick={handleClosePopup}>
                            Okay
                        </button>
                    </div>
                </div>
            )}

            {/* Local Styles for Success Popup */}
            <style>{`
                .success-popup-overlay {
                    position: fixed;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: rgba(15, 23, 42, 0.6);
                    backdrop-filter: blur(8px);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    z-index: 10000;
                    animation: fadeInPopup 0.25s ease-out forwards;
                }

                .success-popup-card {
                    background: #ffffff;
                    border-radius: 28px;
                    padding: 40px 32px;
                    text-align: center;
                    max-width: 420px;
                    width: 90%;
                    box-shadow: 0 24px 48px rgba(0, 0, 0, 0.16);
                    animation: scaleInPopup 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
                }

                .success-popup-icon-container {
                    width: 72px;
                    height: 72px;
                    background: rgba(16, 185, 129, 0.12);
                    color: #10B981;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin: 0 auto 20px auto;
                }

                .success-popup-card h2 {
                    font-size: 22px;
                    font-weight: 700;
                    color: #0f172a;
                    margin: 0 0 10px 0;
                }

                .success-popup-card p {
                    font-size: 15px;
                    color: #64748b;
                    line-height: 1.5;
                    margin: 0 0 20px 0;
                }

                .success-popup-score-badge {
                    background: #f1f5f9;
                    padding: 8px 16px;
                    border-radius: 12px;
                    font-weight: 700;
                    color: var(--bt-primary);
                    display: inline-block;
                    margin-bottom: 24px;
                    font-size: 15px;
                }

                .success-popup-button {
                    background: var(--bt-primary);
                    color: white;
                    border: none;
                    padding: 14px 28px;
                    border-radius: 16px;
                    font-size: 16px;
                    font-weight: 600;
                    width: 100%;
                    cursor: pointer;
                    box-shadow: 0 8px 16px rgba(91, 76, 245, 0.2);
                    transition: all 0.2s;
                }

                .success-popup-button:hover {
                    background: #4333cc;
                    box-shadow: 0 12px 20px rgba(91, 76, 245, 0.3);
                }

                .success-popup-button:active {
                    transform: scale(0.98);
                }

                @keyframes fadeInPopup {
                    from { opacity: 0; }
                    to { opacity: 1; }
                }

                @keyframes scaleInPopup {
                    from { opacity: 0; transform: scale(0.9) translateY(10px); }
                    to { opacity: 1; transform: scale(1) translateY(0); }
                }
            `}</style>
        </div>
    );
};

export default Questionnaire;
