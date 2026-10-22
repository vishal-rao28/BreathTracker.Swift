import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Calendar, Users, FileSearch, PlayCircle,
    Activity, Clock, CheckCircle2, Stethoscope
} from 'lucide-react';
import { motion } from 'framer-motion';
import { useAuth } from '../../context/AuthContext';
import { apiCall } from '../../api/apiService';
import DashActionCard from '../../components/DashActionCard';
import './Dashboard.css';

const DoctorDashboard: React.FC = () => {
    const { user } = useAuth();
    const navigate = useNavigate();
    const [pendingCount, setPendingCount] = useState(0);

    useEffect(() => {
        const fetchStats = async () => {
            const aRes = await apiCall('fetch_appointments.php');
            if (aRes.appointments) {
                const pending = aRes.appointments.filter((a: any) => a.status === 'pending');
                setPendingCount(pending.length);
            }
        };
        fetchStats();
    }, [user]);

    return (
        <div className="doctor-dashboard-view">
            <header className="dashboard-welcome">
                <span className="welcome-tag">Doctor Portal</span>
                <h1>Welcome, Dr. {user?.name?.split(' ').pop()}</h1>
            </header>

            <motion.div
                className="doctor-overview-card"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5 }}
            >
                <div className="card-bg-icon">
                    <Stethoscope size={240} />
                </div>

                <div className="card-top-row">
                    <span className="hero-badge">Doctor Dashboard</span>
                </div>

                <div className="card-main-content">
                    <h2>Today's Overview</h2>
                    <p>Check pending appointments and patient respiratory syncs status.</p>
                </div>

                <div className="mini-stats-row">
                    <div className="mini-stat-box" onClick={() => navigate('/doctor/appointments')}>
                        <div className="ms-icon">
                            <Clock size={16} />
                        </div>
                        <div className="ms-info">
                            <span className="ms-value">{pendingCount}</span>
                            <span className="ms-label">Pending</span>
                        </div>
                    </div>
                    <div className="mini-stat-box" onClick={() => navigate('/doctor/patients')}>
                        <div className="ms-icon" style={{ backgroundColor: 'rgba(52, 201, 138, 0.1)', color: '#34C98A' }}>
                            <Users size={16} />
                        </div>
                        <div className="ms-info">
                            <span className="ms-value">Select</span>
                            <span className="ms-label">Patient</span>
                        </div>
                    </div>
                    <div className="mini-stat-box">
                        <div className="ms-icon active">
                            <CheckCircle2 size={16} />
                        </div>
                        <div className="ms-info">
                            <span className="ms-value">Active</span>
                            <span className="ms-label">Status</span>
                        </div>
                    </div>
                </div>
            </motion.div>

            <div className="doctor-grid-layout single-col">
                <section className="dashboard-section">
                    <div className="section-header-row">
                        <Activity size={20} />
                        <h2>Medical Management</h2>
                    </div>
                    <div className="actions-grid-custom">
                        <DashActionCard
                            title="Patient List"
                            subtitle="Access history & files"
                            icon={<Users size={28} />}
                            gradient="var(--bt-primary-gradient)"
                            index={1}
                            onClick={() => navigate('/doctor/patients')}
                        />
                        <DashActionCard
                            title="Appointments"
                            subtitle="Handle daily schedule"
                            icon={<Calendar size={28} />}
                            gradient="var(--bt-doctor-gradient)"
                            index={2}
                            onClick={() => navigate('/doctor/appointments')}
                        />
                        <DashActionCard
                            title="Report Search"
                            subtitle="Query medical data"
                            icon={<FileSearch size={28} />}
                            gradient="linear-gradient(135deg, #FF9B42, #FFB75E)"
                            index={3}
                            onClick={() => navigate('/doctor/search')}
                        />
                        <DashActionCard
                            title="Videos"
                            subtitle="Doctor resources"
                            icon={<PlayCircle size={28} />}
                            gradient="linear-gradient(135deg, #7B6CF6, #B1A8FF)"
                            index={4}
                            onClick={() => navigate('/doctor/videos')}
                        />
                    </div>
                </section>
            </div>
        </div>
    );
};

export default DoctorDashboard;
