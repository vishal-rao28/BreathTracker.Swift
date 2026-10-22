import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    ChevronRight, Wind, Droplet, Pill,
    Activity, ChevronLeft, User, Loader2,
    CalendarDays
} from 'lucide-react';
import { motion } from 'framer-motion';
import { apiCall } from '../../api/apiService';
import './SubmitReport.css';

interface PatientData {
    patient_id: string;
    name: string;
    age: number;
}

const SubmitReport: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const [patient, setPatient] = useState<PatientData | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchPatient = async () => {
            try {
                const res = await apiCall('get_patient_details.php', 'POST', { patient_id: id });
                if (res.status === 'success') {
                    setPatient(res.patient);
                }
            } catch (err) {
                console.error('Failed to fetch patient', err);
            } finally {
                setLoading(false);
            }
        };
        fetchPatient();
    }, [id]);

    const cards = [
        {
            title: "PFT Values",
            subtitle: "Record lung function & severity",
            icon: <Wind size={24} />,
            color: "#5B4CF5",
            bg: "rgba(91, 76, 245, 0.12)",
            route: `/doctor/submit/pft/${id}`
        },
        {
            title: "ABG Report",
            subtitle: "Arterial blood gas analysis",
            icon: <Droplet size={24} />,
            color: "#FF6B6B",
            bg: "rgba(255, 107, 107, 0.12)",
            route: `/doctor/submit/abg/${id}`
        },
        {
            title: "Medication Diary",
            subtitle: "Update prescriptions & advice",
            icon: <Pill size={24} />,
            color: "#34C98A",
            bg: "rgba(52, 201, 138, 0.12)",
            route: `/doctor/submit/meds/${id}`
        },
        {
            title: "Inhaler Adherence",
            subtitle: "View patient's inhaler history",
            icon: <CalendarDays size={24} />,
            color: "#7B6CF6",
            bg: "rgba(123, 108, 246, 0.12)",
            route: `/doctor/submit/adherence/${id}`
        },
        {
            title: "6 Min Walk Test",
            subtitle: "Record walk test observations",
            icon: <Activity size={24} />,
            color: "#1A6B8A",
            bg: "rgba(26, 107, 138, 0.12)",
            route: `/doctor/submit/walk/${id}`
        }
    ];

    if (loading) {
        return (
            <div className="sr-loading">
                <Loader2 className="sr-spinner" size={40} />
                <p>Loading patient details...</p>
            </div>
        );
    }

    return (
        <div className="sr-container">
            <header className="sr-header">
                <button className="sr-back-btn" onClick={() => navigate('/doctor/patients')}>
                    <ChevronLeft size={20} />
                </button>
                <h1>Clinical Submission</h1>
                <div style={{ width: 40 }} />
            </header>

            <div className="sr-content">
                <motion.div
                    className="sr-hero"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                >
                    <div className="sr-avatar-wrapper">
                        <div className="sr-avatar">
                            <User size={40} />
                        </div>
                    </div>
                    <h2>{patient?.name || 'Patient'}</h2>
                    <p>New Clinical Entry • ID: {id}</p>
                </motion.div>

                <div className="sr-menu">
                    {cards.map((card, idx) => (
                        <motion.div
                            key={card.title}
                            className="sr-action-card btn-press"
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: idx * 0.1 }}
                            onClick={() => navigate(card.route)}
                        >
                            <div className="sr-card-left">
                                <div className="sr-icon" style={{ backgroundColor: card.bg, color: card.color }}>
                                    {card.icon}
                                </div>
                                <div className="sr-card-info">
                                    <h3>{card.title}</h3>
                                    <p>{card.subtitle}</p>
                                </div>
                            </div>
                            <ChevronRight className="sr-card-chevron" size={18} />
                        </motion.div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default SubmitReport;
