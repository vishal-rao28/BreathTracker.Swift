import React, { useState, useEffect } from 'react';
import { Calendar, Clock, User, CheckCircle } from 'lucide-react';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import { apiCall } from '../../api/apiService';
import { useAuth } from '../../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import './Appointments.css';

// ── Success Popup ──────────────────────────────────────
const SuccessPopup: React.FC<{ onOk: () => void }> = ({ onOk }) => (
    <div className="appt-popup-overlay" onClick={onOk}>
        <div className="appt-popup-card" onClick={e => e.stopPropagation()}>
            <div className="appt-popup-icon">
                <CheckCircle size={48} color="#10b981" />
            </div>
            <h2>Appointment Requested!</h2>
            <p>Your appointment request has been sent to your doctor. You will see a notification in your <strong>Reminders</strong> once it is accepted.</p>
            <button className="appt-popup-ok" onClick={onOk}>Great, Thanks!</button>
        </div>
    </div>
);

const Appointments: React.FC = () => {
    // Form State
    const [formData, setFormData] = useState({
        name: '',
        age: '',
        gender: '',
        contact: '',
        email: '',
        address: '',
        copdConfirmed: null as boolean | null,
        symptoms: [] as string[],
        smokingStatus: '',
        preferredDate: '',
        preferredTime: '',
        mode: ''
    });

    const [isSubmitting, setIsSubmitting] = useState(false);
    const [showSuccess, setShowSuccess] = useState(false);
    const { user } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
        const fetchPatientDetails = async () => {
            if (!user) return;
            try {
                const res = await apiCall('get_patient_details.php', 'POST', { patient_id: user.id });
                if (res.status === 'success' && res.patient) {
                    setFormData(prev => ({
                        ...prev,
                        name: res.patient.name || '',
                        age: res.patient.age ? String(res.patient.age) : '',
                        gender: res.patient.gender || '',
                        contact: res.patient.phone_number || ''
                    }));
                }
            } catch (error) {
                console.error("Failed to fetch patient details:", error);
            }
        };
        fetchPatientDetails();
    }, [user]);

    const symptomList = ["Shortness of breath", "Persistent cough", "Wheezing", "Chest tightness", "Fatigue"];

    const toggleSymptom = (s: string) => {
        setFormData(prev => ({
            ...prev,
            symptoms: prev.symptoms.includes(s)
                ? prev.symptoms.filter(x => x !== s)
                : [...prev.symptoms, s]
        }));
    };

    const handleSchedule = async () => {
        if (!user) return;
        if (!formData.name || !formData.contact || !formData.preferredDate) {
            alert("Please fill in Name, Contact and Preferred Date.");
            return;
        }

        setIsSubmitting(true);
        const payload = {
            patient_id: user.id,
            name: formData.name,
            age: formData.age,
            gender: formData.gender,
            contact: formData.contact,
            email: formData.email,
            address: formData.address,
            copd_confirmed: formData.copdConfirmed ? 1 : 0,
            symptoms: formData.symptoms, // PHP handles array
            preferred_date: formData.preferredDate,
            preferred_time: [formData.preferredTime], // PHP expects optional array
            consultation_mode: [formData.mode]
        };

        const result = await apiCall('submit_appointment.php', 'POST', payload);
        setIsSubmitting(false);

        if (result.status === 'success') {
            setShowSuccess(true);
        } else {
            alert("Error: " + (result.message || "Could not save appointment"));
        }
    };

    return (
        <div className="booking-form-view">
            {showSuccess && (
                <SuccessPopup
                    onOk={() => {
                        setShowSuccess(false);
                        navigate('/patient/dashboard');
                    }}
                />
            )}
            <header className="form-header">
                <div className="header-text">
                    <h1>Book Appointment</h1>
                    <p>Fill in the details below to schedule your consultation.</p>
                </div>
            </header>

            <div className="form-container-premium">
                <div className="form-grid">
                    {/* Left: Patient Details */}
                    <section className="form-section-ios">
                        <div className="section-title-ios">
                            <User size={18} />
                            <h3>Patient Details</h3>
                        </div>
                        <div className="input-group-ios">
                            <input type="text" placeholder="Full Name" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} />
                            <div className="row-inputs-ios">
                                <input type="number" placeholder="Age" value={formData.age} onChange={e => setFormData({ ...formData, age: e.target.value })} />
                                <select value={formData.gender} onChange={e => setFormData({ ...formData, gender: e.target.value })}>
                                    <option value="">Gender</option>
                                    <option value="Male">Male</option>
                                    <option value="Female">Female</option>
                                    <option value="Others">Others</option>
                                </select>
                            </div>
                            <input type="tel" placeholder="Contact Number" value={formData.contact} onChange={e => setFormData({ ...formData, contact: e.target.value })} />
                            <input type="email" placeholder="Email Address" value={formData.email} onChange={e => setFormData({ ...formData, email: e.target.value })} />
                            <textarea placeholder="Address" value={formData.address} onChange={e => setFormData({ ...formData, address: e.target.value })} />
                        </div>
                    </section>

                    {/* Right: Medical & Slot */}
                    <div className="form-right-col">
                        <section className="form-section-ios">
                            <div className="section-title-ios">
                                <Calendar size={18} />
                                <h3>Medical Information</h3>
                            </div>
                            <div className="diagnosis-check-ios">
                                <span>Confirmed diagnosis of COPD?</span>
                                <div className="chip-row-ios">
                                    <button className={formData.copdConfirmed === true ? 'active' : ''} onClick={() => setFormData({ ...formData, copdConfirmed: true })}>Yes</button>
                                    <button className={formData.copdConfirmed === false ? 'active' : ''} onClick={() => setFormData({ ...formData, copdConfirmed: false })}>No</button>
                                </div>
                            </div>
                            <div className="symptoms-list-ios">
                                <span>Current Symptoms</span>
                                <div className="symptom-grid-ios">
                                    {symptomList.map(s => (
                                        <button key={s} className={formData.symptoms.includes(s) ? 'active' : ''} onClick={() => toggleSymptom(s)}>{s}</button>
                                    ))}
                                </div>
                            </div>
                        </section>

                        <section className="form-section-ios">
                            <div className="section-title-ios">
                                <Clock size={18} />
                                <h3>Preferred Slot</h3>
                            </div>
                            <div className="slot-inputs-ios">
                                <input
                                    type="date"
                                    value={formData.preferredDate}
                                    min={new Date().toISOString().split('T')[0]}
                                    onChange={e => setFormData({ ...formData, preferredDate: e.target.value })}
                                />
                                <div className="chip-row-ios">
                                    {['Morning', 'Afternoon', 'Evening'].map(t => (
                                        <button key={t} className={formData.preferredTime === t ? 'active' : ''} onClick={() => setFormData({ ...formData, preferredTime: t })}>{t}</button>
                                    ))}
                                </div>
                                <div className="chip-row-ios">
                                    {['In-Person', 'Online / Tele'].map(m => (
                                        <button key={m} className={formData.mode === m ? 'active' : ''} onClick={() => setFormData({ ...formData, mode: m })}>{m}</button>
                                    ))}
                                </div>
                            </div>
                        </section>

                        <BTPrimaryButton
                            onClick={handleSchedule}
                            className="submit-booking-btn"
                            disabled={isSubmitting}
                        >
                            {isSubmitting ? "Scheduling..." : "Schedule Appointment"}
                        </BTPrimaryButton>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Appointments;
