import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Search, ChevronRight, Stethoscope,
    Calendar as CalendarIcon, User, Users,
    Loader2
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { apiCall } from '../../api/apiService';
import './PatientList.css';

interface Patient {
    id: string;
    patient_id: string;
    name: string;
    age: number;
    diagnosis: string;
    initials: string;
}

const PatientList: React.FC = () => {
    const navigate = useNavigate();
    const [patients, setPatients] = useState<Patient[]>([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchPatients = async () => {
            try {
                // iOS app uses fetch_appointments.php to derive the unique patient list
                const res = await apiCall('fetch_appointments.php');
                if (res.status === 'success' && res.appointments) {
                    const appointmentList = res.appointments;

                    const derivedPatientsMap = new Map<string, Patient>();

                    appointmentList.forEach((appt: any) => {
                        const status = (appt.status || '').toLowerCase();
                        // Match iOS app logic: accepted or rejected patients are shown
                        if (status === 'accepted' || status === 'approved' || status === 'rejected') {
                            if (!derivedPatientsMap.has(appt.patient_id)) {
                                const names = appt.name.split(' ');
                                const initials = names.map((n: string) => n[0]).join('').toUpperCase().slice(0, 2);

                                derivedPatientsMap.set(appt.patient_id, {
                                    id: appt.patient_id,
                                    patient_id: appt.patient_id,
                                    name: appt.name,
                                    age: parseInt(appt.age) || 0,
                                    diagnosis: appt.copd_confirmed === "1" ? "COPD" : "Awaiting Diagnosis",
                                    initials: initials || "?"
                                });
                            }
                        }
                    });

                    const uniquePatients = Array.from(derivedPatientsMap.values())
                        .sort((a, b) => a.name.localeCompare(b.name));

                    setPatients(uniquePatients);
                }
            } catch (err) {
                console.error('Failed to fetch patients', err);
            } finally {
                setLoading(false);
            }
        };
        fetchPatients();
    }, []);

    const filteredPatients = patients.filter(p =>
        p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.patient_id.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.diagnosis.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="pl-container">
            <header className="pl-header">
                <div className="pl-title-section">
                    <div className="pl-badge">
                        <Users size={14} />
                        <span>Patients Directory</span>
                    </div>
                    <h1>Your Patients</h1>
                    <p>Manage records and review respiratory reports</p>
                </div>

                <div className="pl-controls">
                    <div className="pl-search-wrapper">
                        <Search size={18} className="pl-search-icon" />
                        <input
                            type="text"
                            placeholder="Search by name or ID..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>
            </header>

            <div className="pl-content">
                {loading ? (
                    <div className="pl-loading-state">
                        <Loader2 className="pl-spinner" size={40} />
                        <p>Syncing patient records...</p>
                    </div>
                ) : (
                    <div className="pl-list">
                        <AnimatePresence>
                            {filteredPatients.map((patient, idx) => (
                                <motion.div
                                    key={patient.id}
                                    className="pl-card btn-press"
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ delay: idx * 0.05 }}
                                    onClick={() => navigate(`/doctor/patients/${patient.id}`)}
                                >
                                    <div className="pl-card-left">
                                        <div className="pl-avatar">
                                            {patient.initials}
                                        </div>
                                        <div className="pl-info">
                                            <h3>{patient.name}</h3>
                                            <div className="pl-meta">
                                                <div className="pl-tag diagnosis">
                                                    <Stethoscope size={12} />
                                                    <span>{patient.diagnosis}</span>
                                                </div>
                                                <div className="pl-tag age">
                                                    <CalendarIcon size={12} />
                                                    <span>{patient.age} yrs</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div className="pl-card-right">
                                        <span className="pl-id">ID: {patient.patient_id}</span>
                                        <ChevronRight size={20} className="pl-chevron" />
                                    </div>
                                </motion.div>
                            ))}
                        </AnimatePresence>

                        {filteredPatients.length === 0 && !loading && (
                            <motion.div
                                className="pl-empty-state"
                                initial={{ opacity: 0, scale: 0.9 }}
                                animate={{ opacity: 1, scale: 1 }}
                            >
                                <div className="pl-empty-icon">
                                    <User size={48} />
                                </div>
                                <h3>No Patients Found</h3>
                                <p>We couldn't find any patients matching "{searchTerm}"</p>
                            </motion.div>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
};

export default PatientList;
