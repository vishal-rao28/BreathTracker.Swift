import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, BellOff, ChevronLeft, Check, X, Calendar, Phone, Mail, MapPin, Stethoscope, FileText, Wind, Clock, Video, Eye } from 'lucide-react';
import { apiCall } from '../../api/apiService';
import './Notifications.css';

interface Appointment {
    id: string;
    patientId: string;
    name: string;
    age: number;
    gender: string;
    symptoms: string;
    phone: string;
    status: string;
    preferred_date: string;
    preferred_time: string;
    email: string;
    address: string;
    copd_confirmed: string;
    duration_symptoms: string;
    medications: string;
    allergies: string;
    smoking_status: string;
    consultation_mode: string;
}

const DoctorNotifications: React.FC = () => {
    const navigate = useNavigate();
    const [appointments, setAppointments] = useState<Appointment[]>([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [loading, setLoading] = useState(true);
    const [message, setMessage] = useState('');
    const [selectedAppt, setSelectedAppt] = useState<Appointment | null>(null);

    const fetchNotifications = async () => {
        setLoading(true);
        try {
            const res = await apiCall('fetch_appointments.php', 'GET', {});
            if (res && res.appointments) {
                const pending = res.appointments
                    .filter((a: any) => a.status?.toLowerCase() === 'pending')
                    .map((a: any) => ({
                        id: a.appointment_id,
                        patientId: a.patient_id,
                        name: a.name || 'Unnamed',
                        age: parseInt(a.age) || 0,
                        gender: a.gender || 'Other',
                        symptoms: a.symptoms || '',
                        phone: a.contact || '',
                        status: a.status,
                        preferred_date: a.preferred_date || '',
                        preferred_time: a.preferred_time || '',
                        email: a.email || '',
                        address: a.address || '',
                        copd_confirmed: a.copd_confirmed == '1' || a.copd_confirmed === true ? 'Yes' : 'No',
                        duration_symptoms: a.duration_symptoms || '',
                        medications: a.medications || '',
                        allergies: a.allergies || '',
                        smoking_status: a.smoking_status || '',
                        consultation_mode: a.consultation_mode || ''
                    }));
                setAppointments(pending);
            }
        } catch (error) {
            console.error('Error fetching appointments:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchNotifications();
    }, []);

    const handleStatusUpdate = async (id: string, status: string) => {
        try {
            const res = await apiCall('update_appointment_status.php', 'POST', {
                appointment_id: id,
                status: status
            });
            if (res.status === 'success') {
                setAppointments(prev => prev.filter(a => a.id !== id));
                setSelectedAppt(null);
                setMessage(status === 'Accepted' ? 'Request accepted successfully!' : 'Request rejected.');
                setTimeout(() => setMessage(''), 3000);
            }
        } catch (error) {
            console.error('Error updating status:', error);
        }
    };

    const filtered = appointments.filter(a =>
        a.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        a.symptoms.toLowerCase().includes(searchTerm.toLowerCase()) ||
        a.phone.includes(searchTerm)
    );

    const getInitials = (name: string) => {
        return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
    };

    return (
        <div className="notifications-ios-wrapper">
            {message && <div className="ios-toast">{message}</div>}

            <header className="notifications-ios-header">
                <button className="ios-back-btn" onClick={() => navigate(-1)}>
                    <ChevronLeft size={24} />
                </button>
                <h1>Notifications</h1>
                <div className="header-spacer"></div>
            </header>

            <div className="search-container-ios">
                <Search size={18} className="search-icon" />
                <input
                    type="text"
                    placeholder="Search requests..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                />
            </div>

            <div className="notifications-list">
                {loading ? (
                    <div className="loading-state">
                        <div className="ios-spinner"></div>
                    </div>
                ) : filtered.length === 0 ? (
                    <div className="empty-state">
                        <div className="empty-icon">
                            <BellOff size={40} />
                        </div>
                        <p>{searchTerm ? 'No results found' : 'No new notifications'}</p>
                    </div>
                ) : (
                    filtered.map((item, index) => (
                        <div className="notification-card-ios" key={item.id} style={{ animationDelay: `${index * 0.05}s` }}>
                            <div className="card-top">
                                <div className="patient-avatar">
                                    <span>{getInitials(item.name)}</span>
                                </div>
                                <div className="patient-main-info">
                                    <h3>{item.name}</h3>
                                    <p>Age: {item.age} • {item.gender} • {item.phone}</p>
                                </div>
                            </div>

                            {item.symptoms && (
                                <div className="symptoms-box">
                                    <span className="symptom-label">Symptoms:</span>
                                    <p>{item.symptoms}</p>
                                </div>
                            )}

                            <div className="appointment-meta">
                                <div className="meta-item">
                                    <Calendar size={14} />
                                    <span>{item.preferred_date} • {item.preferred_time}</span>
                                </div>
                            </div>

                            <div className="card-actions-ios">
                                <button className="reject-btn" onClick={() => handleStatusUpdate(item.id, 'Rejected')}>
                                    <X size={18} />
                                    Reject
                                </button>
                                <button className="details-btn" onClick={() => setSelectedAppt(item)}>
                                    <Eye size={18} />
                                    Details
                                </button>
                                <button className="accept-btn" onClick={() => handleStatusUpdate(item.id, 'Accepted')}>
                                    <Check size={18} />
                                    Accept
                                </button>
                            </div>
                        </div>
                    ))
                )}
            </div>

            {/* Clinical Case Details Modal */}
            {selectedAppt && (
                <div className="ccd-overlay" onClick={(e) => e.target === e.currentTarget && setSelectedAppt(null)}>
                    <div className="ccd-modal">
                        {/* Modal Header */}
                        <div className="ccd-header">
                            <h2>Clinical Case Details</h2>
                            <button className="ccd-close" onClick={() => setSelectedAppt(null)}>
                                <X size={20} />
                            </button>
                        </div>

                        {/* Hero Profile */}
                        <div className="ccd-hero">
                            <div className="ccd-avatar">
                                <span>{getInitials(selectedAppt.name)}</span>
                            </div>
                            <h3>{selectedAppt.name}</h3>
                            <p>{selectedAppt.age} Years • {selectedAppt.gender}</p>
                        </div>

                        {/* Info Groups */}
                        <div className="ccd-body">
                            {/* Patient Info */}
                            <div className="ccd-group">
                                <div className="ccd-group-title">
                                    <Phone size={16} />
                                    <span>Patient Info</span>
                                </div>
                                <div className="ccd-group-card">
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><Phone size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">Phone</span>
                                            <span className="ccd-value">{selectedAppt.phone || 'Not provided'}</span>
                                        </div>
                                    </div>
                                    <div className="ccd-divider"></div>
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><Mail size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">Email</span>
                                            <span className="ccd-value">{selectedAppt.email || 'Not provided'}</span>
                                        </div>
                                    </div>
                                    <div className="ccd-divider"></div>
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><MapPin size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">Residential Address</span>
                                            <span className="ccd-value">{selectedAppt.address || 'Not provided'}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {/* Medical Status */}
                            <div className="ccd-group">
                                <div className="ccd-group-title medical">
                                    <Stethoscope size={16} />
                                    <span>Medical Status</span>
                                </div>
                                <div className="ccd-group-card">
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><Stethoscope size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">COPD Diagnosis</span>
                                            <span className="ccd-value">{selectedAppt.copd_confirmed}</span>
                                        </div>
                                    </div>
                                    <div className="ccd-divider"></div>
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><FileText size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">Primary Symptoms</span>
                                            <span className="ccd-value">{selectedAppt.symptoms || 'Not provided'}</span>
                                        </div>
                                    </div>
                                    <div className="ccd-divider"></div>
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><Wind size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">Smoking History</span>
                                            <span className="ccd-value">{selectedAppt.smoking_status || 'Not provided'}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {/* Scheduling */}
                            <div className="ccd-group">
                                <div className="ccd-group-title scheduling">
                                    <Calendar size={16} />
                                    <span>Scheduling</span>
                                </div>
                                <div className="ccd-group-card">
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><Calendar size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">Preferred Date</span>
                                            <span className="ccd-value">{selectedAppt.preferred_date || 'Not provided'}</span>
                                        </div>
                                    </div>
                                    <div className="ccd-divider"></div>
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><Clock size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">Preferred Time</span>
                                            <span className="ccd-value">{selectedAppt.preferred_time || 'Not provided'}</span>
                                        </div>
                                    </div>
                                    <div className="ccd-divider"></div>
                                    <div className="ccd-row">
                                        <div className="ccd-row-icon"><Video size={18} /></div>
                                        <div className="ccd-row-content">
                                            <span className="ccd-label">Consultation Type</span>
                                            <span className="ccd-value">{selectedAppt.consultation_mode || 'Not provided'}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Modal Footer Actions */}
                        <div className="ccd-footer">
                            <button className="ccd-reject" onClick={() => handleStatusUpdate(selectedAppt.id, 'Rejected')}>
                                <X size={18} /> Reject
                            </button>
                            <button className="ccd-accept" onClick={() => handleStatusUpdate(selectedAppt.id, 'Accepted')}>
                                <Check size={18} /> Accept
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default DoctorNotifications;
