import React, { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Calendar, Bell, UserCircle, LogOut, LayoutDashboard } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { apiCall } from '../api/apiService';
import LogoutModal from '../components/LogoutModal';
import './PatientLayout.css';

interface PatientLayoutProps {
    children: React.ReactNode;
}

const PatientLayout: React.FC<PatientLayoutProps> = ({ children }) => {
    const { user, logout } = useAuth();
    const navigate = useNavigate();
    const location = useLocation();
    const [hasUpdate, setHasUpdate] = useState(false);
    const [showLogoutModal, setShowLogoutModal] = useState(false);
    const [inhalerAlarmTime, setInhalerAlarmTime] = useState<string | null>(null);
    const [showAlarmPopup, setShowAlarmPopup] = useState(false);

    useEffect(() => {
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }, []);

    const getLocalDateString = () => {
        const d = new Date();
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    const handleMarkTaken = async () => {
        if (!user?.id) return;
        const today = getLocalDateString();
        localStorage.setItem(`inhaler_taken_${user.id}_${today}`, 'true');
        localStorage.removeItem(`inhaler_snooze_until_${user.id}`);
        window.dispatchEvent(new Event('inhaler-status-updated'));
        try {
            await apiCall('mark_inhaler_taken.php', 'POST', { patient_id: user.id, date_taken: today });
        } catch (err) {
            console.error("Failed to mark inhaler taken from layout:", err);
        }
        setShowAlarmPopup(false);
    };

    const handleRemindLater = () => {
        if (!user?.id) return;
        // Snooze for 5 minutes (in milliseconds)
        const snoozeTarget = Date.now() + 5 * 60 * 1000;
        localStorage.setItem(`inhaler_snooze_until_${user.id}`, String(snoozeTarget));
        setShowAlarmPopup(false);
    };

    useEffect(() => {
        if (!user?.id) return;
        const localVal = localStorage.getItem(`inhaler_alarm_${user.id}`);
        if (localVal) {
            setInhalerAlarmTime(localVal);
        } else {
            apiCall('get_reminders.php', 'POST', { patient_id: user.id })
                .then(res => {
                    if (res.status === 'success' && Array.isArray(res.reminders)) {
                        const daily = res.reminders.find((r: any) => r.id === 'inhaler_daily_alarm');
                        if (daily && daily.alarmTime) {
                            setInhalerAlarmTime(daily.alarmTime);
                            localStorage.setItem(`inhaler_alarm_${user.id}`, daily.alarmTime);
                        }
                    }
                })
                .catch(err => console.error(err));
        }
    }, [user]);

    useEffect(() => {
        if (!user?.id) return;
        let isChecking = false;

        const checkTime = async () => {
            if (isChecking) return;

            const currentAlarmTime = localStorage.getItem(`inhaler_alarm_${user.id}`) || inhalerAlarmTime;
            const now = new Date();
            const todayStr = now.toDateString();
            const todayDateStr = getLocalDateString();

            const isTaken = localStorage.getItem(`inhaler_taken_${user.id}_${todayDateStr}`) === 'true';
            if (isTaken) {
                localStorage.removeItem(`inhaler_snooze_until_${user.id}`);
                return;
            }

            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const currentTime = `${hours}:${minutes}`;

            // Check normal alarm trigger
            const isAlarmTime = currentAlarmTime && currentTime === currentAlarmTime;
            const lastAlerted = localStorage.getItem(`last_inhaler_alert_${user.id}`);
            const shouldAlertAlarm = isAlarmTime && (lastAlerted !== todayStr);

            // Check snooze trigger
            const snoozeUntil = localStorage.getItem(`inhaler_snooze_until_${user.id}`);
            const shouldAlertSnooze = snoozeUntil && Date.now() >= Number(snoozeUntil);

            if (shouldAlertAlarm || shouldAlertSnooze) {
                // Verify with backend before showing popup — user may have tapped "Taken" on mobile
                isChecking = true;
                try {
                    const res = await apiCall('get_inhaler_history.php', 'POST', { patient_id: user.id });
                    if (res.status === 'success' && res.taken_dates?.includes(todayDateStr)) {
                        // User already took it on another device!
                        localStorage.setItem(`inhaler_taken_${user.id}_${todayDateStr}`, 'true');
                        localStorage.removeItem(`inhaler_snooze_until_${user.id}`);
                        isChecking = false;
                        return;
                    }
                } catch (e) {
                    console.error('Failed to sync inhaler status', e);
                }
                isChecking = false;

                setShowAlarmPopup(true);
                localStorage.setItem(`last_inhaler_alert_${user.id}`, todayStr);

                // Clear the snooze trigger so it does not fire repeatedly
                localStorage.removeItem(`inhaler_snooze_until_${user.id}`);

                if ('Notification' in window && Notification.permission === 'granted') {
                    new Notification("Daily Inhaler Reminder 🫁", {
                        body: "It's time to take your daily inhaler dose for better breathing.",
                        tag: "inhaler-alarm"
                    });
                }
            }
        };

        const interval = setInterval(checkTime, 10000);
        checkTime();

        return () => clearInterval(interval);
    }, [user, inhalerAlarmTime]);

    const handleLogout = () => {
        logout();
        navigate('/select-role');
    };

    useEffect(() => {
        const checkStatus = async () => {
            if (user?.id) {
                // If we are already on reminders page, clear the update flag
                if (location.pathname === '/patient/reminders') {
                    setHasUpdate(false);
                    return;
                }

                try {
                    const response = await apiCall('get_appointment.php', 'POST', { patient_id: user.id });
                    if (response.status === 'success' && response.appointment?.status?.toLowerCase() === 'accepted') {
                        setHasUpdate(true);
                    }
                } catch (err) {
                    console.error('Failed to check notification status');
                }
            }
        };

        checkStatus();
        // Check every 30 seconds for background updates
        const interval = setInterval(checkStatus, 30000);
        return () => clearInterval(interval);
    }, [user, location.pathname]);

    const navItems = [
        { icon: <LayoutDashboard size={22} />, label: 'Dashboard', path: '/patient/dashboard' },
        { icon: <Calendar size={22} />, label: 'Appointment', path: '/patient/appointments' },
        {
            icon: (
                <div style={{ position: 'relative' }}>
                    <Bell size={22} />
                    {hasUpdate && <span className="notification-dot"></span>}
                </div>
            ),
            label: 'Reminders',
            path: '/patient/reminders'
        },
        { icon: <UserCircle size={22} />, label: 'Profile', path: '/patient/profile' },
    ];

    const isActive = (path: string) => location.pathname === path;

    return (
        <div className="patient-layout">
            {/* Desktop Sidebar */}
            <aside className="sidebar">
                <div className="sidebar-logo" onClick={() => navigate('/patient/dashboard')} style={{ cursor: 'pointer' }}>
                    <div className="logo-icon">🫁</div>
                    <span className="logo-text">BreathTrack</span>
                </div>

                <nav className="sidebar-nav">
                    {navItems.map((item) => (
                        <div
                            key={item.path}
                            className={`nav-item ${isActive(item.path) ? 'active' : ''}`}
                            onClick={() => navigate(item.path)}
                        >
                            <span className="nav-icon">{item.icon}</span>
                            <span className="nav-label">{item.label}</span>
                        </div>
                    ))}
                </nav>

                <div className="sidebar-footer">
                    <div className="nav-item logout" onClick={() => setShowLogoutModal(true)}>
                        <span className="nav-icon"><LogOut size={22} /></span>
                        <span className="nav-label">Logout</span>
                    </div>
                </div>
            </aside>

            <LogoutModal
                isOpen={showLogoutModal}
                onClose={() => setShowLogoutModal(false)}
                onConfirm={handleLogout}
            />

            {showAlarmPopup && (
                <div className="alarm-popup-overlay">
                    <div className="alarm-popup-card">
                        <div className="alarm-popup-header">
                            <span className="alarm-lungs-icon">🫁</span>
                        </div>
                        <h3>Daily Inhaler Time!</h3>
                        <p>It's time to take your daily inhaler dose for better breathing and symptom management.</p>
                        <div className="alarm-popup-actions">
                            <button className="alarm-btn taken" onClick={handleMarkTaken}>
                                I've Taken It
                            </button>
                            <button className="alarm-btn dismiss" onClick={handleRemindLater}>
                                Remind Me Later
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Main Content Area */}
            <main className="main-container">
                <header className="main-header">
                    <div className="header-search">
                        {/* Placeholder for search or context info */}
                    </div>
                    <div className="header-actions">
                        <div className="notification-bell" onClick={() => navigate('/patient/reminders')}>
                            <Bell size={20} />
                            {hasUpdate && <span className="notification-badge"></span>}
                        </div>
                        <div className="user-profile-header">
                            <div className="user-info">
                                <span className="user-name">{user?.name || 'Patient'}</span>
                                <span className="user-role">Patient ID: {user?.id}</span>
                            </div>
                            <div className="avatar-small">
                                <UserCircle size={32} />
                            </div>
                        </div>
                    </div>
                </header>

                <div className="content-scroll">
                    {children}
                </div>
            </main>

            {/* Mobile Bottom Navigation */}
            <nav className="mobile-nav">
                {navItems.map((item) => (
                    <div
                        key={item.path}
                        className={`mobile-nav-item ${isActive(item.path) ? 'active' : ''}`}
                        onClick={() => navigate(item.path)}
                    >
                        {item.icon}
                        <span>{item.label}</span>
                    </div>
                ))}
            </nav>
        </div>
    );
};

export default PatientLayout;
