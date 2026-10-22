import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    ChevronLeft, User, Calendar, Ruler,
    Weight, Stethoscope, Briefcase, BarChart3,
    Heart, ChevronRight
} from 'lucide-react';
import { motion } from 'framer-motion';
import { apiCall } from '../../api/apiService';
import { useAuth } from '../../context/AuthContext';
import './CopdHealthReview.css';

interface ReviewData {
    name: string;
    age: string;
    gender: string;
    height: string;
    weight: string;
    diagnosis: string;
    occupation: string;
    analysisScore: number;
}

const CopdHealthReview: React.FC = () => {
    const navigate = useNavigate();
    const { user } = useAuth();
    const [data, setData] = useState<ReviewData | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            if (!user) return;
            const result = await apiCall(`get_patient_details.php`, 'POST', { patient_id: user.id });
            if (result.status === 'success') {
                const patient = result.patient;
                const questionnaire = result.questionnaire;
                setData({
                    name: patient.name || '—',
                    age: patient.age || '—',
                    gender: patient.gender || '—',
                    height: patient.height || '—',
                    weight: patient.weight || '—',
                    diagnosis: patient.diagnosis || '—',
                    occupation: patient.occupation || '—',
                    analysisScore: questionnaire?.average_score ? parseFloat(questionnaire.average_score) : 0
                });
            }
            setLoading(false);
        };
        fetchData();
    }, [user]);

    const tiles = [
        { icon: <User size={22} />, title: "Name", value: data?.name, color: "var(--bt-primary)", delay: 0.1 },
        { icon: <Calendar size={22} />, title: "Age", value: data?.age ? `${data.age} yrs` : '—', color: "var(--bt-accent-orange)", delay: 0.15 },
        { icon: <User size={22} />, title: "Gender", value: data?.gender, color: "var(--bt-accent-purple)", delay: 0.2 },
        { icon: <Ruler size={22} />, title: "Height", value: data?.height ? `${data.height} cm` : '—', color: "var(--bt-accent-green)", delay: 0.25 },
        { icon: <Weight size={22} />, title: "Weight", value: data?.weight ? `${data.weight} kg` : '—', color: "var(--bt-accent)", delay: 0.3 },
        { icon: <Stethoscope size={22} />, title: "Diagnosis", value: data?.diagnosis, color: "#5A67D8", delay: 0.35 },
        { icon: <Briefcase size={22} />, title: "Occupation", value: data?.occupation, color: "#D69E2E", delay: 0.4 },
        {
            icon: <BarChart3 size={22} />,
            title: "My Analysis",
            value: data?.analysisScore ? data.analysisScore.toFixed(2) : '—',
            color: "#E53E3E",
            delay: 0.45,
            interactive: true,
            onClick: () => navigate('/patient/advice/analysis')
        }
    ];

    if (loading) return (
        <div className="review-loading">
            <div className="loader"></div>
            <p>Summarizing your health...</p>
        </div>
    );

    return (
        <div className="review-page-view">
            <header className="review-header">
                <button className="back-btn-round" onClick={() => navigate(-1)}>
                    <ChevronLeft size={24} />
                </button>
                <h1>My COPD Review</h1>
                <div className="header-spacer"></div>
            </header>

            <div className="review-content">
                <motion.div
                    className="profile-summary-header"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                >
                    <div className="summary-icon-box">
                        <Heart size={30} color="white" />
                    </div>
                    <div className="summary-text">
                        <h2>Health Profile Summary</h2>
                        <p>Personal data & metrics</p>
                    </div>
                </motion.div>

                <div className="review-grid">
                    {tiles.map((tile, idx) => (
                        <motion.div
                            key={idx}
                            className={`review-tile ${tile.interactive ? 'interactive' : ''} btn-press`}
                            onClick={tile.onClick}
                            initial={{ opacity: 0, scale: 0.8, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            transition={{ delay: tile.delay, type: 'spring', damping: 15 }}
                            style={{ borderColor: tile.interactive ? `${tile.color}4D` : 'var(--bt-border)' }}
                        >
                            <div className="tile-icon-circle" style={{ backgroundColor: `${tile.color}1F`, color: tile.color }}>
                                {tile.icon}
                            </div>
                            <div className="tile-info">
                                <span className="tile-label">{tile.title}</span>
                                <span className="tile-value">{tile.value}</span>
                            </div>
                            {tile.interactive && (
                                <div className="tile-action" style={{ color: tile.color }}>
                                    <span>View Detail</span>
                                    <ChevronRight size={14} />
                                </div>
                            )}
                        </motion.div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default CopdHealthReview;
