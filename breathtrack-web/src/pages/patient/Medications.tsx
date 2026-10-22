import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
    ChevronLeft, Pill, CheckCircle2, Clock,
    AlertTriangle, Calendar, Check,
    Wind, FileText, Activity, PersonStanding
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { apiCall, BASE_URL } from '../../api/apiService';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Medications.css';


interface Report {
    id: string;
    type: 'PFT' | 'ABG' | 'Walk Test';
    condition?: string;
    comments?: string;
    description?: string;
    image_path?: string;
    created_at: string;
}

interface VaccineReminder {
    id: string;
    title: string;
    body: string;
    dueDate: string;
    alarmTime: string;
    icon: string;
    color: string;
}

// ── Success Popup ──────────────────────────────────────
const SuccessPopup: React.FC<{ title: string; message: string; onOk: () => void }> = ({ title, message, onOk }) => (
    <div className="vacc-popup-overlay" onClick={onOk}>
        <div className="vacc-popup-card" onClick={e => e.stopPropagation()}>
            <div className="vacc-popup-icon">
                <CheckCircle2 size={48} color="#10b981" />
            </div>
            <h2>{title}</h2>
            <p>{message}</p>
            <button className="vacc-popup-ok" onClick={onOk}>OK</button>
        </div>
    </div>
);

const Medications: React.FC = () => {
    const [meds, setMeds] = useState<any[]>([]);
    const [remarks, setRemarks] = useState('');
    const [reports, setReports] = useState<Report[]>([]);
    const [isTakenToday, setIsTakenToday] = useState(false);
    const [alarmTime, setAlarmTime] = useState("09:00");
    const [refillDate, setRefillDate] = useState("");
    const [showSuccess, setShowSuccess] = useState(false);
    const [loading, setLoading] = useState(true);
    const [popupContent, setPopupContent] = useState({ title: '', message: '' });
    const [showPopup, setShowPopup] = useState(false);

    const navigate = useNavigate();
    const { user } = useAuth();

    const getLocalDateString = () => {
        const d = new Date();
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    const today = getLocalDateString();

    useEffect(() => {
        const fetchData = async () => {
            if (!user) return;
            try {
                // Fetch Meds
                const medResult = await apiCall(`get_medication_diary.php`, 'POST', { patient_id: user.id });
                if (medResult.status === 'success') {
                    setMeds(medResult.medicines || []);
                    setRemarks(medResult.remarks || '');
                }

                // Fetch Reports
                const reportResult = await apiCall(`get_medical_reports.php`, 'POST', { patient_id: user.id });
                if (reportResult.status === 'success') {
                    const normaliseImagePath = (p?: string | null) => p ? p.replace(/^\/+/, '') : undefined;
                    const allReports: Report[] = [
                        ...(reportResult.pft_history || []).map((r: any) => ({ ...r, type: 'PFT', comments: r.comments || r.description, image_path: normaliseImagePath(r.image_path) })),
                        ...(reportResult.abg_history || []).map((r: any) => ({ ...r, type: 'ABG', comments: r.comments || r.description, image_path: normaliseImagePath(r.image_path) })),
                        ...(reportResult.walk_test_history || []).map((r: any) => ({ ...r, type: 'Walk Test', comments: r.description, image_path: normaliseImagePath(r.image_path) }))
                    ].sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
                    setReports(allReports);
                }

                // Sync status from server
                let isTaken = false;
                try {
                    const inhalerHistory = await apiCall('get_inhaler_history.php', 'POST', { patient_id: user.id });
                    if (inhalerHistory.status === 'success' && Array.isArray(inhalerHistory.taken_dates)) {
                        if (inhalerHistory.taken_dates.includes(today)) {
                            isTaken = true;
                            localStorage.setItem(`inhaler_taken_${user.id}_${today}`, 'true');
                        }
                    }
                } catch (historyErr) {
                    console.error("Failed to fetch inhaler history from server", historyErr);
                }

                // Try local state as fallback
                if (!isTaken) {
                    isTaken = localStorage.getItem(`inhaler_taken_${user.id}_${today}`) === 'true';
                }

                // Fetch Reminders to sync alarmTime and refillDate
                let serverAlarmTime = "09:00";
                let serverRefillDate = "";
                try {
                    const remindersResult = await apiCall('get_reminders.php', 'POST', { patient_id: user.id });
                    if (remindersResult.status === 'success' && Array.isArray(remindersResult.reminders)) {
                        const dailyAlarm = remindersResult.reminders.find((r: any) => r.id === 'inhaler_daily_alarm');
                        if (dailyAlarm) {
                            serverAlarmTime = dailyAlarm.alarmTime;
                            localStorage.setItem(`inhaler_alarm_${user.id}`, dailyAlarm.alarmTime);
                        } else {
                            serverAlarmTime = localStorage.getItem(`inhaler_alarm_${user.id}`) || "09:00";
                        }
                        const refillAlarm = remindersResult.reminders.find((r: any) => r.id === 'inhaler_refill');
                        if (refillAlarm) {
                            serverRefillDate = refillAlarm.dueDate;
                            localStorage.setItem(`inhaler_refill_${user.id}`, refillAlarm.dueDate);
                        } else {
                            serverRefillDate = localStorage.getItem(`inhaler_refill_${user.id}`) || "";
                        }
                    } else {
                        serverAlarmTime = localStorage.getItem(`inhaler_alarm_${user.id}`) || "09:00";
                        serverRefillDate = localStorage.getItem(`inhaler_refill_${user.id}`) || "";
                    }
                } catch (remindersErr) {
                    console.error("Failed to fetch reminders from server", remindersErr);
                    serverAlarmTime = localStorage.getItem(`inhaler_alarm_${user.id}`) || "09:00";
                    serverRefillDate = localStorage.getItem(`inhaler_refill_${user.id}`) || "";
                }

                setIsTakenToday(isTaken);
                setAlarmTime(serverAlarmTime);
                setRefillDate(serverRefillDate);

            } catch (error) {
                console.error("Failed to fetch data", error);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, [user]);

    useEffect(() => {
        const handleInhalerStatusUpdate = () => {
            if (!user) return;
            const updatedTaken = localStorage.getItem(`inhaler_taken_${user.id}_${today}`) === 'true';
            setIsTakenToday(updatedTaken);
        };
        window.addEventListener('inhaler-status-updated', handleInhalerStatusUpdate);
        return () => window.removeEventListener('inhaler-status-updated', handleInhalerStatusUpdate);
    }, [user, today]);

    const syncToGlobalReminders = async (reminder: VaccineReminder) => {
        if (!user) return;
        try {
            await apiCall('save_reminder.php', 'POST', {
                patient_id: user.id,
                ...reminder
            });
        } catch (err) {
            console.error("Failed to save reminder to server", err);
        }
    };

    const formatTime12h = (time24: string) => {
        if (!time24) return "";
        const [h, m] = time24.split(":");
        let hour = parseInt(h);
        const ampm = hour >= 12 ? "PM" : "AM";
        hour = hour % 12 || 12;
        return `${hour}:${m} ${ampm}`;
    };

    const handleUpdateAlarm = () => {
        if (!user) return;
        localStorage.setItem(`inhaler_alarm_${user.id}`, alarmTime);

        syncToGlobalReminders({
            id: 'inhaler_daily_alarm',
            title: 'Daily Inhaler Reminder 🫁',
            body: 'Time to take your daily inhaler dose for better breathing.',
            dueDate: today,
            alarmTime: alarmTime,
            icon: 'wind',
            color: '#3b82f6'
        });

        setPopupContent({
            title: 'Reminder Updated!',
            message: `Your daily inhaler alarm has been set for ${formatTime12h(alarmTime)}. You will be notified daily.`
        });
        setShowPopup(true);
    };

    const handleSetRefill = () => {
        if (!user || !refillDate) return;
        localStorage.setItem(`inhaler_refill_${user.id}`, refillDate);

        syncToGlobalReminders({
            id: 'inhaler_refill',
            title: 'Inhaler Refill Due ⚠️',
            body: 'Your inhaler is due for a refill. Please contact your pharmacy or doctor.',
            dueDate: refillDate,
            alarmTime: '09:00',
            icon: 'alert-triangle',
            color: '#f59e0b'
        });

        setPopupContent({
            title: 'Refill Alarm Set!',
            message: `We'll remind you on ${new Date(refillDate).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })} to refill your inhaler.`
        });
        setShowPopup(true);
    };

    const handleMarkAsTaken = async () => {
        if (!user) return;
        setShowSuccess(true);
        setIsTakenToday(true);
        localStorage.setItem(`inhaler_taken_${user.id}_${today}`, 'true');
        await apiCall('mark_inhaler_taken.php', 'POST', { patient_id: user.id, date_taken: today });
        setTimeout(() => setShowSuccess(false), 3000);
    };

    if (loading) return (
        <div className="meds-loading">
            <div className="loader"></div>
            <p>Syncing your medical data...</p>
        </div>
    );

    return (
        <div className="meds-view">
            <header className="page-header-p">
                <button className="back-btn-p" onClick={() => navigate(-1)}>
                    <ChevronLeft size={28} />
                </button>
                <div className="header-text-p">
                    <h1>Medical Records</h1>
                    <p>Clinical reports & medication tracker</p>
                </div>
            </header>

            <div className="meds-scroll-container">
                <div className="meds-grid-layout">
                    <main className="meds-main-col">
                        {/* Clinical Reports Section */}
                        <section className="reports-column">
                            <div className="section-header-row">
                                <FileText size={20} className="header-icon" />
                                <h3>Clinical Reports</h3>
                            </div>

                            {reports.length > 0 ? (
                                <div className="reports-grouped">
                                    {/* PFT & ABG — have condition badges and optional documents */}
                                    {(['PFT', 'ABG'] as const).map(type => {
                                        const group = reports.filter(r => r.type === type);
                                        if (group.length === 0) return null;
                                        return (
                                            <div key={type} className="report-group-block">
                                                <div className="report-group-title">
                                                    <Activity size={14} />
                                                    <span>{type} Reports</span>
                                                    <span className="report-group-count">{group.length}</span>
                                                </div>

                                                {group.map((report, idx) => (
                                                    <motion.div
                                                        key={report.id}
                                                        className="report-row"
                                                        initial={{ opacity: 0, x: -10 }}
                                                        animate={{ opacity: 1, x: 0 }}
                                                        transition={{ delay: idx * 0.04 }}
                                                    >
                                                        <div className="report-row-info">
                                                            <div className="report-row-top">
                                                                <span className="report-row-date">
                                                                    {new Date(report.created_at).toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' })}
                                                                </span>
                                                                {report.condition && (
                                                                    <span className={`condition-tag ${report.condition.toLowerCase()}`}>
                                                                        {report.condition}
                                                                    </span>
                                                                )}
                                                            </div>
                                                            <p className="report-row-remarks">
                                                                {report.comments || 'No remarks.'}
                                                            </p>
                                                        </div>

                                                        {report.image_path ? (
                                                            <button
                                                                className="doc-link-btn"
                                                                onClick={() => window.open(`${BASE_URL}/${report.image_path}`, '_blank')}
                                                            >
                                                                <FileText size={14} />
                                                                View Document
                                                            </button>
                                                        ) : (
                                                            <span className="no-doc-label">No document</span>
                                                        )}
                                                    </motion.div>
                                                ))}
                                            </div>
                                        );
                                    })}

                                    {/* 6-Min Walk Test — description only, no condition badge or document */}
                                    {(() => {
                                        const walkGroup = reports.filter(r => r.type === 'Walk Test');
                                        if (walkGroup.length === 0) return null;
                                        return (
                                            <div className="report-group-block">
                                                <div className="report-group-title walk-title">
                                                    <PersonStanding size={14} />
                                                    <span>6-Min Walk Test</span>
                                                    <span className="report-group-count">{walkGroup.length}</span>
                                                </div>

                                                {walkGroup.map((report, idx) => (
                                                    <motion.div
                                                        key={report.id}
                                                        className="walk-report-row"
                                                        initial={{ opacity: 0, x: -10 }}
                                                        animate={{ opacity: 1, x: 0 }}
                                                        transition={{ delay: idx * 0.04 }}
                                                    >
                                                        <div className="walk-report-header">
                                                            <PersonStanding size={16} className="walk-icon" />
                                                            <span className="report-row-date">
                                                                {new Date(report.created_at).toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' })}
                                                            </span>
                                                            <span className="walk-badge">Walk Test</span>
                                                        </div>
                                                        <div className="walk-desc-box">
                                                            <p>{report.description || 'No description provided.'}</p>
                                                        </div>
                                                    </motion.div>
                                                ))}
                                            </div>
                                        );
                                    })()}
                                </div>
                            ) : (
                                <div className="empty-reports-card">
                                    <FileText size={40} />
                                    <p>No clinical reports found in your record.</p>
                                </div>
                            )}
                        </section>

                        {/* Medications & Advice */}
                        <section className="meds-section-card premium-advice">
                            <div className="section-header-row mobile-style-header">
                                <Activity size={20} className="header-icon" />
                                <h3>Medication & Advice</h3>
                            </div>

                            <div className="prescription-card-content">
                                <div className="card-top-modern">
                                    <div className="titles">
                                        <h4>Prescribed Medicines</h4>
                                        <p>Follow the dosage strictly</p>
                                    </div>
                                    <div className="icon-wrap-modern pill-blue"><Pill size={24} /></div>
                                </div>

                                <div className="advice-inner-section">
                                    <h5>Active Prescription</h5>
                                    <div className="prescribed-plan-ios">
                                        {meds.length > 0 ? meds.map((med, i) => (
                                            <div key={i} className="med-row-ios">
                                                <div className="ios-check active">
                                                    <Check size={16} strokeWidth={3} />
                                                </div>
                                                <div className="med-info-ios">
                                                    <span className="med-name-ios">{typeof med === 'string' ? med : med.name}</span>
                                                </div>
                                            </div>
                                        )) : (
                                            <div className="empty-state">
                                                <p>No specific medicines listed currently.</p>
                                            </div>
                                        )}
                                    </div>
                                </div>

                                <div className="advice-inner-section">
                                    <h5>General Medical Advice</h5>
                                    <div className="advice-box-ios">
                                        <p>{remarks || "Use this medicine as directed by your physician."}</p>
                                    </div>
                                </div>
                            </div>
                        </section>

                        {/* Inhaler Tracking Section */}
                        <section className="meds-section-card tracking">
                            <div className="card-top">
                                <div className="titles">
                                    <h3>Inhaler Adherence</h3>
                                    <p>Daily dose tracking</p>
                                </div>
                                <div className="icon-wrap lungs"><Wind size={24} /></div>
                            </div>

                            <div className="tracking-action">
                                {isTakenToday ? (
                                    <div className="success-banner">
                                        <CheckCircle2 size={32} />
                                        <div className="banner-text">
                                            <h4>Inhaler Taken Today!</h4>
                                            <p>Great job staying consistent with your care.</p>
                                        </div>
                                    </div>
                                ) : (
                                    <button className="mark-taken-btn" onClick={handleMarkAsTaken}>
                                        <Wind size={20} />
                                        <span>Mark Inhaler as Taken</span>
                                    </button>
                                )}
                            </div>
                        </section>
                    </main>

                    <aside className="meds-side-col">
                        {/* Reminders Card */}
                        <section className="reminder-settings-card">
                            <div className="side-card-header">
                                <Clock size={18} />
                                <h4>Daily Reminders</h4>
                            </div>
                            <div className="reminder-row">
                                <label>Inhaler Alarm</label>
                                <input
                                    type="time"
                                    value={alarmTime}
                                    onChange={e => setAlarmTime(e.target.value)}
                                />
                            </div>
                            <BTPrimaryButton
                                onClick={handleUpdateAlarm}
                                className="btn-sm"
                            >
                                Update Alarm
                            </BTPrimaryButton>
                        </section>

                        {/* Refill Card */}
                        <section className="refill-card-premium">
                            <div className="refill-header">
                                <div className="refill-icon"><AlertTriangle size={18} /></div>
                                <h4>Refill Reminder</h4>
                            </div>
                            <p className="refill-desc">Set a date to be reminded about your inhaler refill.</p>
                            <div className="refill-input">
                                <Calendar size={16} />
                                <input
                                    type="date"
                                    value={refillDate}
                                    min={today}
                                    onChange={e => setRefillDate(e.target.value)}
                                />
                            </div>
                            <button className="refill-submit-btn" onClick={handleSetRefill}>
                                Set Refill Alarm
                            </button>
                        </section>
                    </aside>
                </div>
            </div>

            <AnimatePresence>
                {showPopup && (
                    <SuccessPopup
                        title={popupContent.title}
                        message={popupContent.message}
                        onOk={() => setShowPopup(false)}
                    />
                )}
                {showSuccess && (
                    <motion.div
                        className="meds-toast"
                        initial={{ opacity: 0, y: 50 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: 50 }}
                    >
                        <CheckCircle2 size={24} />
                        <span>Progress Synchronized!</span>
                    </motion.div>
                )}
            </AnimatePresence>
        </div >
    );
};

export default Medications;
