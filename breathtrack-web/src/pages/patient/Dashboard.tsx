import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Heart, Shield, MessageSquare, Video,
    BellRing, X
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import DashActionCard from '../../components/DashActionCard';
import './Dashboard.css';

const PatientDashboard: React.FC = () => {
    const { user } = useAuth();
    const navigate = useNavigate();
    const [appeared, setAppeared] = useState(false);
    const [urgentReminders, setUrgentReminders] = useState<any[]>([]);
    const [showBanner, setShowBanner] = useState(false);

    useEffect(() => {
        setAppeared(true);

        // Notification Check
        if (!user) return;
        try {
            const all = JSON.parse(localStorage.getItem('bt_vaccine_reminders') || '{}');
            const list: any[] = all[user.id] || [];
            const today = new Date().toISOString().split('T')[0];

            const dueToday = list.filter(r => {
                // Return true if inhaler alarm (every day) or date matches today
                return r.id === 'inhaler_daily_alarm' || r.dueDate === today;
            });

            if (dueToday.length > 0) {
                setUrgentReminders(dueToday);
                setShowBanner(true);
                // Play soft notification sound
                playNotifySound();
            }
        } catch (e) {
            console.error("Reminder check failed", e);
        }
    }, [user]);

    const playNotifySound = () => {
        try {
            const audio = new Audio('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3');
            audio.volume = 0.5;
            audio.play().catch(() => {
                // Browsers often block auto-play until first click
                console.log("Audio blocked: User must interact with page first.");
            });
        } catch { }
    };

    const getGreeting = () => {
        const hour = new Date().getHours();
        if (hour < 12) return 'Good Morning';
        if (hour < 18) return 'Good Afternoon';
        return 'Good Evening';
    };

    return (
        <div className={`dashboard-view ${appeared ? 'appeared' : ''}`}>
            {/* Urgent Notification Banner */}
            {showBanner && urgentReminders.length > 0 && (
                <div className="urgent-banner slide-down">
                    <div className="urgent-content">
                        <div className="urgent-icon-ring">
                            <BellRing size={20} className="bell-anim" />
                        </div>
                        <div className="urgent-text">
                            <strong>Health Reminder:</strong>
                            <span>You have {urgentReminders.length} task{urgentReminders.length > 1 ? 's' : ''} due today including <i>{urgentReminders[0].title}</i>.</span>
                        </div>
                        <div className="urgent-actions">
                            <button className="view-btn" onClick={() => navigate('/patient/reminders')}>View All</button>
                            <button className="close-banner" onClick={() => setShowBanner(false)}><X size={18} /></button>
                        </div>
                    </div>
                </div>
            )}

            {/* Premium Hero Header */}
            <header className="dashboard-hero">
                <div className="hero-content">
                    <span className="welcome-tag">{getGreeting()}</span>
                    <h1>Hello, {user?.name?.split(' ')[0]} <span className="wave">👋</span></h1>
                    <p>Your respiratory health journey is being tracked. Stay consistent!</p>
                </div>
                <div className="hero-profile" onClick={() => navigate('/patient/profile')}>
                    <div className="hero-avatar">
                        {user?.name?.charAt(0) || 'P'}
                    </div>
                    <div className="hero-user-info">
                        <span className="h-name">{user?.name}</span>
                        <span className="h-id">ID: {user?.id}</span>
                    </div>
                </div>
            </header>

            <div className="dashboard-layout-center">
                <div className="module-grid">
                    <DashActionCard
                        title="Daily Checkup"
                        subtitle="Log vitals & respiratory status"
                        icon={<Heart size={32} />}
                        gradient="linear-gradient(135deg, #1A6B8A, #2E9BBF)"
                        index={0}
                        onClick={() => navigate('/patient/checkup')}
                    />
                    <DashActionCard
                        title="Vaccination & Questionnaires"
                        subtitle="Status & history"
                        icon={<Shield size={32} />}
                        gradient="linear-gradient(135deg, #FF9B42, #FFB75E)"
                        index={1}
                        onClick={() => navigate('/patient/vaccination')}
                    />
                    <DashActionCard
                        title="Medical Advice"
                        subtitle="Care plan & Prescriptions"
                        icon={<MessageSquare size={32} />}
                        gradient="linear-gradient(135deg, #7B6CF6, #B1A8FF)"
                        index={2}
                        onClick={() => navigate('/patient/advice')}
                    />
                    <DashActionCard
                        title="Pulmonary Rehab"
                        subtitle="Guided videos & exercises"
                        icon={<Video size={32} />}
                        gradient="linear-gradient(135deg, #34C98A, #57D9A3)"
                        index={3}
                        onClick={() => navigate('/patient/rehab')}
                    />
                </div>
            </div>
        </div>
    );
};

export default PatientDashboard;
