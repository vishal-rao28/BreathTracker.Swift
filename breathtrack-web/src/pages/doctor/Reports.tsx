import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    ChevronLeft, Thermometer, Activity, Wind,
    Loader2
} from 'lucide-react';
import { motion } from 'framer-motion';
import { apiCall } from '../../api/apiService';
import './Reports.css';

interface PatientData {
    name: string;
    age: number;
    gender: string;
    height: string;
    weight: string;
    occupation: string;
    diagnosis: string;
}

interface CheckupData {
    temperature: string;
    oxygen_level: string;
    lung_function: string;
}

interface QuestionnaireData {
    average_score: string;
    date_pneumococcal: string;
    date_flu: string;
    date_pertussis: string;
    date_shingles1: string;
    date_shingles2: string;
    q1_cough: string;
    q2_phlegm: string;
    q3_chest_tightness: string;
    q4_breathlessness: string;
    q5_activity_limitation: string;
    q6_confidence_leaving_home: string;
    q7_sleep_quality: string;
    q8_energy_level: string;
}

const PatientReports: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();

    const [patientData, setPatientData] = useState<PatientData | null>(null);
    const [checkupData, setCheckupData] = useState<CheckupData | null>(null);
    const [questionnaireData, setQuestionnaireData] = useState<QuestionnaireData | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchDetails = async () => {
            try {
                const res = await apiCall('fetch_patient_details.php', 'POST', { patient_id: id });
                if (res.status === 'success') {
                    setPatientData(res.patient);
                    setCheckupData(res.checkup);
                    setQuestionnaireData(res.questionnaire);
                }
            } catch (err) {
                console.error('Failed to fetch patient records', err);
            } finally {
                setLoading(false);
            }
        };
        fetchDetails();
    }, [id]);

    const getScoreCategory = (score: number) => {
        if (score === 0) return { label: 'N/A', color: '#94A3B8' };
        if (score <= 1.0) return { label: 'Mild', color: '#34C98A' };
        if (score <= 2.5) return { label: 'Moderate', color: '#FF9B42' };
        return { label: 'Severe', color: '#FF6B6B' };
    };

    const getSymptomLabel = (val: string) => {
        const i = parseInt(val);
        if (isNaN(i)) return val;
        const labels = ['No symptom', 'Very mild', 'Mild', 'Moderate', 'Severe', 'Very severe'];
        return `${i} - ${labels[i] || 'Score: ' + i}`;
    };

    const formatDate = (date: string) => {
        if (!date || date === 'N/A' || date === 'NA' || date === 'Not Taken') return 'Not Taken';
        return date;
    };

    if (loading) {
        return (
            <div className="rep-loading">
                <Loader2 className="spinner" size={40} />
                <p>Retrieving clinical records...</p>
            </div>
        );
    }

    const avgScore = parseFloat(questionnaireData?.average_score || '0');
    const cat = getScoreCategory(avgScore);

    return (
        <div className="rep-container">
            <header className="rep-header">
                <button className="rep-back-btn" onClick={() => navigate(-1)}>
                    <ChevronLeft size={20} />
                </button>
                <h1>Clinical Analysis</h1>
                <div style={{ width: 40 }} />
            </header>

            <div className="rep-content">
                {/* Hero Card */}
                <motion.section
                    className="rep-hero-card"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                >
                    <div className="rep-hero-top">
                        <div className="rep-hero-patient">
                            <h2>{patientData?.name || 'Patient'}</h2>
                            <p>{patientData?.age} yrs • {patientData?.gender}</p>
                        </div>
                        <div className="rep-hero-score">
                            <span className="score-val">{avgScore.toFixed(2)}</span>
                            <span className="score-cat" style={{ backgroundColor: cat.color + '26', color: cat.color }}>
                                {cat.label}
                            </span>
                        </div>
                    </div>

                    <div className="rep-hero-divider"></div>

                    <div className="rep-hero-grid">
                        <div className="hero-stat">
                            <span className="stat-label">Height</span>
                            <span className="stat-val">{patientData?.height} cm</span>
                        </div>
                        <div className="hero-stat">
                            <span className="stat-label">Weight</span>
                            <span className="stat-val">{patientData?.weight} kg</span>
                        </div>
                        <div className="hero-stat">
                            <span className="stat-label">Occupation</span>
                            <span className="stat-val">{patientData?.occupation}</span>
                        </div>
                    </div>

                    <div className="rep-diagnosis">
                        <span className="diag-label">Reported Diagnosis</span>
                        <p className="diag-val">{patientData?.diagnosis || 'Chronic Respiratory Condition'}</p>
                    </div>
                </motion.section>

                {/* Vitals */}
                <section className="rep-section">
                    <h3 className="section-title">Patient Vitals</h3>
                    <div className="rep-vitals-grid">
                        <div className="vital-badge orange">
                            <div className="vital-icon"><Thermometer size={20} /></div>
                            <span className="vital-val">{checkupData?.temperature}°F</span>
                            <span className="vital-label">Temp</span>
                        </div>
                        <div className="vital-badge blue">
                            <div className="vital-icon"><Activity size={20} /></div>
                            <span className="vital-val">{checkupData?.oxygen_level}%</span>
                            <span className="vital-label">SpO₂</span>
                        </div>
                        <div className="vital-badge purple">
                            <div className="vital-icon"><Wind size={20} /></div>
                            <span className="vital-val">{checkupData?.lung_function}%</span>
                            <span className="vital-label">Lung</span>
                        </div>
                    </div>
                </section>

                {/* Vaccinations */}
                <section className="rep-section">
                    <h3 className="section-title">Vaccination Record</h3>
                    <div className="rep-vaccine-card">
                        {[
                            { t: 'Pneumococcal', d: questionnaireData?.date_pneumococcal },
                            { t: 'Flu Vaccine', d: questionnaireData?.date_flu },
                            { t: 'Pertussis', d: questionnaireData?.date_pertussis },
                            { t: 'Shingles (Dose 1)', d: questionnaireData?.date_shingles1 },
                            { t: 'Shingles (Dose 2)', d: questionnaireData?.date_shingles2 }
                        ].map((v, i) => (
                            <div key={i} className="vaccine-row">
                                <span className="v-name">{v.t}</span>
                                <span className={`v-date ${formatDate(v.d || '') === 'Not Taken' ? 'not-taken' : ''}`}>
                                    {formatDate(v.d || '')}
                                </span>
                            </div>
                        ))}
                    </div>
                </section>

                {/* Questionnaire */}
                <section className="rep-section">
                    <h3 className="section-title">Questionnaire Answers</h3>
                    <div className="rep-q-card">
                        <div className="q-header">
                            <span className="col-q">Question</span>
                            <span className="col-a">Answer</span>
                        </div>
                        <div className="q-rows">
                            {[
                                { q: "Q1. I never cough (0) - I cough all the time (5)", a: questionnaireData?.q1_cough },
                                { q: "Q2. No phlegm (0) - Chest full of phlegm (5)", a: questionnaireData?.q2_phlegm },
                                { q: "Q3. Chest does not feel tight (0) - Feels tight (5)", a: questionnaireData?.q3_chest_tightness },
                                { q: "Q4. Not breathless (0) - Very breathless (5)", a: questionnaireData?.q4_breathlessness },
                                { q: "Q5. No limitation (0) - Very limited (5)", a: questionnaireData?.q5_activity_limitation },
                                { q: "Q6. Confident leaving home (0) - Not confident (5)", a: questionnaireData?.q6_confidence_leaving_home },
                                { q: "Q7. Sleep soundly (0) - Do not sleep soundly (5)", a: questionnaireData?.q7_sleep_quality },
                                { q: "Q8. Lots of energy (0) - No energy (5)", a: questionnaireData?.q8_energy_level }
                            ].map((row, i) => (
                                <div key={i} className="q-row">
                                    <span className="row-q">{row.q}</span>
                                    <span className="row-a">{getSymptomLabel(row.a || '0')}</span>
                                </div>
                            ))}
                        </div>
                        <div className="q-footer">
                            <span className="footer-label">Average Score</span>
                            <span className="footer-val">{avgScore.toFixed(2)} ({cat.label})</span>
                        </div>
                    </div>
                </section>

                <div style={{ paddingBottom: 60 }} />
            </div>
        </div>
    );
};

export default PatientReports;
