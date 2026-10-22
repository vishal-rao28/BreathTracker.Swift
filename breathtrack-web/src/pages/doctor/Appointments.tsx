import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Phone, CheckCircle, XCircle,
    ChevronRight, Search, Loader2,
    CalendarCheck, CalendarX, CalendarClock
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { apiCall } from '../../api/apiService';
import './Appointments.css';

type Status = 'Accepted' | 'Rejected' | 'Pending';

interface Appointment {
    appointment_id: number;
    patient_id: string;
    name: string;
    age: number;
    gender: string;
    preferred_date: string;
    preferred_time: string;
    status: string;
    symptoms: string;
    contact: string;
    email: string;
    consultation_mode: string;
}

const DoctorAppointments: React.FC = () => {
    const navigate = useNavigate();
    const [appointments, setAppointments] = useState<Appointment[]>([]);
    const [selectedStatus, setSelectedStatus] = useState<Status>('Accepted');
    const [searchText, setSearchText] = useState('');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchAppointments();
    }, []);

    const fetchAppointments = async () => {
        setLoading(true);
        try {
            const res = await apiCall('fetch_appointments.php');
            if (res.appointments && Array.isArray(res.appointments)) {
                // Ensure unique patients by choosing the latest appointment_id for each patient_id
                const uniqueMap = new Map();
                res.appointments.forEach((appt: Appointment) => {
                    const existing = uniqueMap.get(appt.patient_id);
                    if (!existing || appt.appointment_id > existing.appointment_id) {
                        uniqueMap.set(appt.patient_id, appt);
                    }
                });
                setAppointments(Array.from(uniqueMap.values()));
            }
        } catch (err) {
            console.error('Failed to fetch appointments', err);
        } finally {
            setLoading(false);
        }
    };

    const handleStatusUpdate = async (id: number, newStatus: string) => {
        try {
            const res = await apiCall('update_appointment_status.php', 'POST', {
                appointment_id: id,
                status: newStatus
            });
            if (res.status === 'success') {
                // Remove from current view or update status
                setAppointments(prev => prev.map(a =>
                    a.appointment_id === id ? { ...a, status: newStatus } : a
                ));
            }
        } catch (err) {
            console.error('Failed to update status', err);
        }
    };

    const filteredAppointments = appointments.filter(appt => {
        const matchesStatus = appt.status.toLowerCase() === selectedStatus.toLowerCase();
        const matchesSearch = appt.name.toLowerCase().includes(searchText.toLowerCase()) ||
            appt.contact.includes(searchText) ||
            appt.patient_id.toLowerCase().includes(searchText.toLowerCase());
        return matchesStatus && matchesSearch;
    });

    const statusConfig = {
        Accepted: { color: '#34C98A', icon: <CalendarCheck size={18} />, label: 'Confirmed' },
        Rejected: { color: '#FF9B42', icon: <CalendarX size={18} />, label: 'Cancelled' },
        Pending: { color: '#7B6CF6', icon: <CalendarClock size={18} />, label: 'Requests' }
    };

    return (
        <div className="appt-page-container">
            <header className="appt-header">
                <div className="appt-header-content">
                    <h1>Appointments</h1>
                    <p>Manage patient consultation requests and schedule</p>
                </div>
            </header>

            <div className="appt-controls">
                <div className="appt-search-wrapper">
                    <Search className="search-icon" size={20} />
                    <input
                        type="text"
                        placeholder="Search patient, ID or contact..."
                        value={searchText}
                        onChange={(e) => setSearchText(e.target.value)}
                    />
                </div>

                <div className="appt-segmented-control">
                    {(['Accepted', 'Rejected', 'Pending'] as Status[]).map((status) => (
                        <button
                            key={status}
                            className={`appt-segment ${selectedStatus === status ? 'active' : ''}`}
                            onClick={() => setSelectedStatus(status)}
                            style={selectedStatus === status ? { backgroundColor: statusConfig[status].color } : {}}
                        >
                            {status}
                        </button>
                    ))}
                </div>
            </div>

            <main className="appt-main">
                {loading ? (
                    <div className="appt-loading">
                        <Loader2 className="spinner" size={40} />
                        <p>Syncing schedule...</p>
                    </div>
                ) : filteredAppointments.length === 0 ? (
                    <div className="appt-empty">
                        <div className="empty-icon-wrapper" style={{ color: statusConfig[selectedStatus].color }}>
                            {statusConfig[selectedStatus].icon}
                        </div>
                        <h3>No {selectedStatus} Appointments</h3>
                        <p>When patients request consultations, they will appear here.</p>
                    </div>
                ) : (
                    <div className="appt-list">
                        <AnimatePresence mode='popLayout'>
                            {filteredAppointments.map((appt, idx) => (
                                <motion.div
                                    key={appt.appointment_id}
                                    className="appt-card-wrapper"
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    exit={{ opacity: 0, scale: 0.95 }}
                                    transition={{ delay: idx * 0.05 }}
                                >
                                    <div
                                        className={`appt-card ${appt.status.toLowerCase()}`}
                                        onClick={() => navigate(`/doctor/reports/${appt.patient_id}`)}
                                    >
                                        <div className="appt-card-left">
                                            <div className="appt-date-block">
                                                <span className="day">{new Date(appt.preferred_date).getDate() || appt.preferred_date.split('-').pop()}</span>
                                                <span className="month">{new Date(appt.preferred_date).toLocaleString('default', { month: 'short' })}</span>
                                            </div>
                                            <div className="appt-divider"></div>
                                            <div className="appt-info">
                                                <div className="appt-patient-name">
                                                    <h4>{appt.name}</h4>
                                                    <span className="time">{appt.preferred_time}</span>
                                                </div>
                                                <div className="appt-meta">
                                                    <div className="meta-item">
                                                        <Phone size={12} />
                                                        <span>{appt.contact}</span>
                                                    </div>
                                                    <div className="mode-badge">
                                                        {appt.consultation_mode || 'In-Person'}
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div className="appt-card-right">
                                            {appt.status.toLowerCase() === 'pending' ? (
                                                <div className="appt-actions">
                                                    <button
                                                        className="action-btn reject"
                                                        onClick={() => handleStatusUpdate(appt.appointment_id, 'Rejected')}
                                                    >
                                                        <XCircle size={18} />
                                                    </button>
                                                    <button
                                                        className="action-btn accept"
                                                        onClick={() => handleStatusUpdate(appt.appointment_id, 'Accepted')}
                                                    >
                                                        <CheckCircle size={18} />
                                                    </button>
                                                </div>
                                            ) : (
                                                <ChevronRight className="chevron" size={20} />
                                            )}
                                        </div>
                                    </div>

                                    {appt.status.toLowerCase() === 'pending' && appt.symptoms && (
                                        <div className="appt-symptoms-tray">
                                            <p><strong>Note:</strong> {appt.symptoms}</p>
                                        </div>
                                    )}
                                </motion.div>
                            ))}
                        </AnimatePresence>
                    </div>
                )}
            </main>
        </div>
    );
};

export default DoctorAppointments;
