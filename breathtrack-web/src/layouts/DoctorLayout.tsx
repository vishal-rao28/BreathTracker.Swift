import React from 'react';
import { useNavigate } from 'react-router-dom';
import { LayoutDashboard, Users, Calendar, FileSearch, LogOut, Stethoscope, Bell, PlayCircle, User } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import LogoutModal from '../components/LogoutModal';
import { apiCall } from '../api/apiService';
import './DoctorLayout.css';

interface DoctorLayoutProps {
    children: React.ReactNode;
}

const DoctorLayout: React.FC<DoctorLayoutProps> = ({ children }) => {
    const { user, logout } = useAuth();
    const navigate = useNavigate();
    const [pendingCount, setPendingCount] = React.useState(0);

    const navItems = [
        { icon: <LayoutDashboard size={22} />, label: 'Dashboard', path: '/doctor/dashboard' },
        { icon: <Users size={22} />, label: 'Patient List', path: '/doctor/patients' },
        { icon: <Calendar size={22} />, label: 'Appointments', path: '/doctor/appointments' },
        { icon: <FileSearch size={22} />, label: 'Report Search', path: '/doctor/search' },
        { icon: <PlayCircle size={22} />, label: 'Videos', path: '/doctor/videos' },
        { icon: <User size={22} />, label: 'Profile', path: '/doctor/profile' },
    ];

    React.useEffect(() => {
        const fetchCount = async () => {
            try {
                const res = await apiCall('fetch_appointments.php');
                if (res.appointments) {
                    const pending = res.appointments.filter((a: any) => a.status?.toLowerCase() === 'pending');
                    setPendingCount(pending.length);
                }
            } catch (e) {
                console.error("Failed to fetch notification count", e);
            }
        };
        fetchCount();
        const interval = setInterval(fetchCount, 30000); // Check every 30s
        return () => clearInterval(interval);
    }, []);

    const [showLogoutModal, setShowLogoutModal] = React.useState(false);

    const handleLogout = () => {
        logout();
        navigate('/select-role');
    };

    const isActive = (path: string) => window.location.pathname === path;

    return (
        <div className="doctor-layout">
            <aside className="doctor-sidebar">
                <div className="sidebar-logo" onClick={() => navigate('/doctor/dashboard')} style={{ cursor: 'pointer' }}>
                    <div className="doctor-logo-icon"><Stethoscope size={28} /></div>
                    <span className="logo-text">DoctorPortal</span>
                </div>

                <nav className="sidebar-nav">
                    {navItems.map((item, idx) => (
                        <div
                            key={idx}
                            className={`nav-item ${isActive(item.path) ? 'active' : ''}`}
                            onClick={() => item.path !== '#' && navigate(item.path)}
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

            <main className="doctor-main-container">
                <header className="doctor-main-header">
                    <div className="header-context">
                        <span className="current-view">Medical Panel</span>
                    </div>
                    <div className="header-actions">
                        <div
                            className={`notification-bell ${pendingCount > 0 ? 'has-pending' : ''}`}
                            onClick={() => navigate('/doctor/notifications')}
                            style={{ cursor: 'pointer' }}
                        >
                            <Bell size={20} color={pendingCount > 0 ? 'var(--bt-primary)' : 'currentColor'} />
                            {pendingCount > 0 && <span className="badge">{pendingCount}</span>}
                        </div>
                        <div className="doc-profile-header" onClick={() => navigate('/doctor/profile')} style={{ cursor: 'pointer' }}>
                            <div className="doc-info">
                                <span className="doc-name">{user?.name}</span>
                                <span className="doc-role">Medical Consultant</span>
                            </div>
                            <div className="doc-avatar">
                                <Stethoscope size={20} />
                            </div>
                        </div>
                    </div>
                </header>

                <div className="content-scroll">
                    {children}
                </div>
            </main>
        </div>
    );
};

export default DoctorLayout;
