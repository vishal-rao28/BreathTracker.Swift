import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    ChevronLeft, Thermometer, Wind, Activity,
    CheckCircle2, XCircle
} from 'lucide-react';
import { motion } from 'framer-motion';
import { apiCall } from '../../api/apiService';
import { useAuth } from '../../context/AuthContext';
import './MyAnalysis.css';

interface AnalysisData {
    name: string;
    age: string;
    gender: string;
    height: string;
    weight: string;
    occupation: string;
    diagnosis: string;
    score: number;
    scoreCategory: string;
    vitals: {
        temp: string;
        spo2: string;
        lung: string;
    };
    vaccines: {
        pneumococcal: string;
        flu: string;
        pertussis: string;
        shingles1: string;
        shingles2: string;
    };
    questionnaire: Array<{ q: string; a: string }>;
}

const MyAnalysis: React.FC = () => {
    const navigate = useNavigate();
    const { user } = useAuth();
    const [data, setData] = useState<AnalysisData | null>(null);
    const [loading, setLoading] = useState(true);

    const getScoreCategory = (score: number) => {
        if (score < 1.0) return "Low";
        if (score < 3.0) return "Moderate";
        return "High";
    };

    const getAnswerLabel = (val: string) => {
        const i = parseInt(val);
        if (isNaN(i)) return val;
        switch (i) {
            case 0: return "0 - No symptom";
            case 1: return "1 - Very mild";
            case 2: return "2 - Mild";
            case 3: return "3 - Moderate";
            case 4: return "4 - Severe";
            case 5: return "5 - Very severe";
            default: return `${i}`;
        }
    };

    useEffect(() => {
        const fetchData = async () => {
            if (!user) return;
            const result = await apiCall(`get_patient_details.php`, 'POST', { patient_id: user.id });
            if (result.status === 'success') {
                const p = result.patient;
                const c = result.checkup || {};
                const q = result.questionnaire || {};
                const score = q.average_score ? parseFloat(q.average_score) : 0;

                setData({
                    name: p.name || 'Patient',
                    age: p.age || '—',
                    gender: p.gender || 'N/A',
                    height: p.height || '—',
                    weight: p.weight || '—',
                    occupation: p.occupation || '—',
                    diagnosis: p.diagnosis || 'Chronic Respiratory Condition',
                    score: score,
                    scoreCategory: getScoreCategory(score),
                    vitals: {
                        temp: c.temperature || '—',
                        spo2: c.oxygen_level || '—',
                        lung: c.lung_function || '—'
                    },
                    vaccines: {
                        pneumococcal: q.date_pneumococcal || q.pneumococcal || 'N/A',
                        flu: q.date_flu || q.flu || 'N/A',
                        pertussis: q.date_pertussis || q.pertussis || 'N/A',
                        shingles1: q.date_shingles1 || q.shingles1 || 'N/A',
                        shingles2: q.date_shingles2 || q.shingles2 || 'N/A'
                    },
                    questionnaire: [
                        { q: "Q1. Cough", a: String(q.q1_cough ?? "") },
                        { q: "Q2. Phlegm (Mucus)", a: String(q.q2_phlegm ?? "") },
                        { q: "Q3. Chest Tightness", a: String(q.q3_chest_tightness ?? "") },
                        { q: "Q4. Breathlessness (Stairs/Hills)", a: String(q.q4_breathlessness ?? "") },
                        { q: "Q5. Activity Limitation", a: String(q.q5_activity_limitation ?? "") },
                        { q: "Q6. Confidence leaving home", a: String(q.q6_confidence_leaving_home ?? "") },
                        { q: "Q7. Sleep Quality", a: String(q.q7_sleep_quality ?? "") },
                        { q: "Q8. Energy Level", a: String(q.q8_energy_level ?? "") }
                    ]
                });
            }
            setLoading(false);
        };
        fetchData();
    }, [user]);

    if (loading) return (
        <div className="review-loading">
            <div className="loader"></div>
            <p>Analyzing your records...</p>
        </div>
    );

    if (!data) return null;

    return (
        <div className="analysis-detail-view">
            <header className="analysis-header">
                <button className="back-btn-round" onClick={() => navigate(-1)}>
                    <ChevronLeft size={24} />
                </button>
                <h1>My Analysis</h1>
                <div className="header-spacer"></div>
            </header>

            <div className="analysis-scroll-content">
                {/* Profile Summary Card */}
                <motion.section
                    className="analysis-summary-card"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                >
                    <div className="card-top">
                        <div className="p-info">
                            <h2>{data.name}</h2>
                            <span>{data.age} yrs • {data.gender}</span>
                        </div>
                        <div className="score-badge-area">
                            <span className="score-val">{data.score.toFixed(2)}</span>
                            <span className={`cat-label ${data.scoreCategory.toLowerCase()}`}>
                                {data.scoreCategory}
                            </span>
                        </div>
                    </div>
                    <div className="card-divider"></div>
                    <div className="card-metrics">
                        <div className="metric">
                            <span className="label">Height</span>
                            <span className="val">{data.height} cm</span>
                        </div>
                        <div className="metric">
                            <span className="label">Weight</span>
                            <span className="val">{data.weight} kg</span>
                        </div>
                        <div className="metric">
                            <span className="label">Occupation</span>
                            <span className="val">{data.occupation}</span>
                        </div>
                    </div>
                    <div className="card-diagnosis">
                        <span className="label">Primary Diagnosis</span>
                        <span className="val">{data.diagnosis}</span>
                    </div>
                </motion.section>

                {/* Vital Signs */}
                <section className="vitals-block">
                    <h3>Vital Signs</h3>
                    <div className="vitals-cards">
                        <div className="vital-mini">
                            <div className="v-icon orange"><Thermometer size={20} /></div>
                            <span className="v-val">{data.vitals.temp}°F</span>
                            <span className="v-label">Temp</span>
                        </div>
                        <div className="vital-mini">
                            <div className="v-icon blue"><Activity size={20} /></div>
                            <span className="v-val">{data.vitals.spo2}%</span>
                            <span className="v-label">SpO₂</span>
                        </div>
                        <div className="vital-mini">
                            <div className="v-icon purple"><Wind size={20} /></div>
                            <span className="v-val">{data.vitals.lung}%</span>
                            <span className="v-label">Lung</span>
                        </div>
                    </div>
                </section>

                {/* Vaccination Details */}
                <section className="vaccine-block">
                    <h3>Vaccination Details</h3>
                    <div className="white-box-list">
                        {Object.entries(data.vaccines).map(([key, val]) => (
                            <div key={key} className="vax-row">
                                <span className="vax-name">{key.charAt(0).toUpperCase() + key.slice(1).replace('shingles', 'Shingles Dose ')}</span>
                                <div className={`vax-status ${val === 'N/A' ? 'missing' : 'ready'}`}>
                                    {val === 'N/A' ? <XCircle size={14} /> : <CheckCircle2 size={14} />}
                                    <span>{val}</span>
                                </div>
                            </div>
                        ))}
                    </div>
                </section>

                {/* Questionnaire Details */}
                <section className="questionnaire-block">
                    <div className="block-header">
                        <h3>Questionnaire Answers</h3>
                    </div>
                    <div className="white-box-list">
                        <div className="table-header">
                            <span>Question</span>
                            <span className="a-col">Answer</span>
                        </div>
                        {data.questionnaire.map((item, idx) => (
                            <div key={idx} className="q-row">
                                <span className="q-text">{item.q}</span>
                                <span className="q-ans">{getAnswerLabel(item.a)}</span>
                            </div>
                        ))}
                    </div>
                </section>
            </div>
        </div>
    );
};

export default MyAnalysis;
