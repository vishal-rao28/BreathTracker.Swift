import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { LogOut, Calendar, User as UserIcon, Briefcase, Activity } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { apiCall } from '../../api/apiService';
import './Profile.css';

const Profile: React.FC = () => {
    const { user, logout } = useAuth();
    const navigate = useNavigate();
    const [details, setDetails] = useState({
        age: '—',
        gender: '—',
        occupation: '—'
    });

    useEffect(() => {
        const fetchDetails = async () => {
            if (!user) return;
            const res = await apiCall('get_patient_details.php', 'POST', { patient_id: user.id });
            if (res.status === 'success' && res.patient) {
                setDetails({
                    age: res.patient.age ? `${res.patient.age} yrs` : '—',
                    gender: res.patient.gender || '—',
                    occupation: res.patient.occupation || '—'
                });
            }
        };
        fetchDetails();
    }, [user]);

    const handleLogout = () => {
        logout();
        navigate('/patient/login');
    };

    const initials = user?.name ? user.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase() : 'P';

    return (
        <div className="profile-container-ios">
            {/* Hero Avatar Banner */}
            <div className="hero-banner-ios">
                <div className="banner-gradient">
                    <div className="circle-overlay o1"></div>
                    <div className="circle-overlay o2"></div>
                </div>
                <div className="banner-content-box">
                    <div className="avatar-circle-main">
                        <span className="avatar-initials">{initials}</span>
                    </div>
                    <div className="user-hero-text">
                        <h2>{user?.name || 'Patient'}</h2>
                        <span className="id-capsule">ID: {user?.id}</span>
                    </div>
                </div>
            </div>

            <div className="profile-scroll-p">
                <div className="section-title-ios-p">Personal Info</div>

                <div className="info-grid-ios">
                    <div className="profile-card-mini orange">
                        <div className="card-icon-p"><Calendar size={20} /></div>
                        <div className="card-labels-p">
                            <span className="p-label">Age</span>
                            <span className="p-value">{details.age}</span>
                        </div>
                    </div>
                    <div className="profile-card-mini purple">
                        <div className="card-icon-p"><UserIcon size={20} /></div>
                        <div className="card-labels-p">
                            <span className="p-label">Gender</span>
                            <span className="p-value">{details.gender}</span>
                        </div>
                    </div>
                    <div className="profile-card-mini green">
                        <div className="card-icon-p"><Briefcase size={20} /></div>
                        <div className="card-labels-p">
                            <span className="p-label">Occupation</span>
                            <span className="p-value">{details.occupation}</span>
                        </div>
                    </div>
                    <div className="profile-card-mini blue">
                        <div className="card-icon-p"><Activity size={20} /></div>
                        <div className="card-labels-p">
                            <span className="p-label">Condition</span>
                            <span className="p-value">COPD</span>
                        </div>
                    </div>
                </div>

                <button className="sign-out-btn-ios" onClick={handleLogout}>
                    <LogOut size={18} />
                    <span>Sign Out</span>
                </button>
            </div>
        </div>
    );
};

export default Profile;
