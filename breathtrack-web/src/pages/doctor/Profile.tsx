import React, { useState, useEffect } from 'react';
import { User, Mail, Phone, Calendar, Briefcase, ShieldCheck, ChevronLeft } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { apiCall } from '../../api/apiService';
import './Profile.css';

const DoctorProfile: React.FC = () => {
    const { user, updateUser } = useAuth();
    const navigate = useNavigate();
    const [profileData, setProfileData] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    const [isEditing, setIsEditing] = useState(false);
    const [editName, setEditName] = useState('');
    const [editAge, setEditAge] = useState('');
    const [editEmail, setEditEmail] = useState('');
    const [editPhone, setEditPhone] = useState('');
    const [updating, setUpdating] = useState(false);

    useEffect(() => {
        const fetchProfile = async () => {
            if (!user?.id) return;
            try {
                const response = await apiCall('get_doctor_profile.php', 'POST', {
                    doctor_id: user.id
                });
                if (response.status === 'success') {
                    setProfileData(response.data);
                    setEditName(response.data.name || '');
                    setEditAge(response.data.age !== null && response.data.age !== undefined ? String(response.data.age) : '');
                    setEditEmail(response.data.email || '');
                    setEditPhone(response.data.phone || '');
                }
            } catch (error) {
                console.error('Error fetching doctor profile:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchProfile();
    }, [user]);

    if (loading) {
        return (
            <div className="profile-loading-ios">
                <div className="ios-spinner"></div>
            </div>
        );
    }

    const handleSave = async () => {
        if (!user?.id) return;
        if (!editName.trim()) {
            alert('Name cannot be empty');
            return;
        }
        setUpdating(true);
        try {
            const response = await apiCall('update_doctor_profile.php', 'POST', {
                doctor_id: user.id,
                name: editName,
                age: editAge ? parseInt(editAge) : null,
                email: editEmail,
                phone: editPhone
            });
            if (response.status === 'success') {
                setProfileData({
                    ...profileData,
                    name: editName,
                    age: editAge ? parseInt(editAge) : null,
                    email: editEmail,
                    phone: editPhone
                });
                updateUser({ name: editName });
                setIsEditing(false);
            } else {
                alert(response.message || 'Failed to update profile');
            }
        } catch (error) {
            console.error('Error updating doctor profile:', error);
            alert('Connection failed. Please check if your server is running.');
        } finally {
            setUpdating(false);
        }
    };

    const doctorName = profileData?.name || '';

    return (
        <div className="profile-ios-wrapper">
            <header className="profile-ios-header">
                <button className="ios-back-btn" onClick={() => navigate('/doctor/dashboard')}>
                    <ChevronLeft size={24} />
                </button>
                <h1>My Profile</h1>
                {isEditing ? (
                    <button className="ios-save-btn" onClick={handleSave} disabled={updating}>
                        {updating ? 'Saving...' : 'Save'}
                    </button>
                ) : (
                    <button className="ios-edit-btn" onClick={() => setIsEditing(true)}>
                        Edit
                    </button>
                )}
            </header>

            <div className="profile-ios-content">
                <div className="profile-avatar-section">
                    <div className="avatar-circle-ios">
                        <User size={50} strokeWidth={1.5} />
                    </div>
                    <span className="doc-type-label">Primary Consultant</span>
                </div>

                <div className="profile-details-list">
                    <ProfileDetailRow
                        icon={<User />}
                        label="Name"
                        value={isEditing ? editName : doctorName}
                        isEditing={isEditing}
                        onChange={setEditName}
                    />
                    <ProfileDetailRow
                        icon={<Calendar />}
                        label="Age"
                        value={isEditing ? editAge : (profileData?.age ? `${profileData.age} years` : '—')}
                        isEditing={isEditing}
                        onChange={setEditAge}
                        type="number"
                    />
                    <ProfileDetailRow
                        icon={<Mail />}
                        label="Email"
                        value={isEditing ? editEmail : (profileData?.email || '—')}
                        isEditing={isEditing}
                        onChange={setEditEmail}
                        type="email"
                    />
                    <ProfileDetailRow
                        icon={<Phone />}
                        label="Phone"
                        value={isEditing ? editPhone : (profileData?.phone || '—')}
                        isEditing={isEditing}
                        onChange={setEditPhone}
                        type="tel"
                    />
                    <ProfileDetailRow
                        icon={<Briefcase />}
                        label="Specialization"
                        value="Pulmonologist"
                        isEditing={false}
                    />
                    <ProfileDetailRow
                        icon={<ShieldCheck />}
                        label="Doctor ID"
                        value={user?.id || '—'}
                        isEditing={false}
                    />
                </div>
            </div>
        </div>
    );
};

interface RowProps {
    icon: React.ReactNode;
    label: string;
    value: string;
    isEditing?: boolean;
    onChange?: (val: string) => void;
    type?: string;
}

const ProfileDetailRow: React.FC<RowProps> = ({ icon, label, value, isEditing, onChange, type = 'text' }) => (
    <div className="ios-detail-row">
        <div className="row-icon-container">
            {icon}
        </div>
        <div className="row-text-container">
            <span className="row-label">{label}</span>
            {isEditing ? (
                <input
                    type={type}
                    value={value}
                    onChange={(e) => onChange && onChange(e.target.value)}
                    className="ios-profile-input"
                />
            ) : (
                <span className="row-value">{value}</span>
            )}
        </div>
    </div>
);

export default DoctorProfile;
