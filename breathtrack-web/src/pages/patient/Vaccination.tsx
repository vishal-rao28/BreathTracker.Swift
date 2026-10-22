import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronLeft, ArrowRight, Info, BellOff, Bell, CheckCircle } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { apiCall } from '../../api/apiService';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Vaccination.css';

interface Vaccine {
    name: string;
    isTaken: boolean;
    date: string;
    alarmTime: string;
    alarmCancelled: boolean;
}

export interface VaccineReminder {
    id: string;
    title: string;
    body: string;
    dueDate: string;
    alarmTime: string;
    icon: string;
    color: string;
}

function calculateNextDueInfo(name: string, date: string): { label: string; dueDate: string } {
    if (!date) return { label: 'Rings when next dose is due', dueDate: '' };
    const d = new Date(date);
    let intervalYear = 0;
    let label = 'Next dose';
    if (name.includes('Flu')) { intervalYear = 1; label = 'Next shot'; }
    else if (name.includes('Pneumo')) { intervalYear = 5; label = 'Next checkup'; }
    else if (name.includes('Pertussis')) { intervalYear = 10; label = 'Next booster'; }
    if (intervalYear > 0) {
        const due = new Date(d);
        due.setFullYear(due.getFullYear() + intervalYear);
        const formatted = due.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
        return { label: `${label} due on ${formatted}`, dueDate: due.toISOString().split('T')[0] };
    }
    return { label: 'Rings when next dose is due', dueDate: '' };
}

const today = new Date().toISOString().split('T')[0];
const REMINDER_KEY = 'bt_vaccine_reminders';

function saveReminders(patientId: string, reminders: VaccineReminder[]) {
    const all = JSON.parse(localStorage.getItem(REMINDER_KEY) || '{}');
    all[patientId] = reminders;
    localStorage.setItem(REMINDER_KEY, JSON.stringify(all));
}

const VaccineRowCard: React.FC<{ vaccine: Vaccine; onChange: (v: Vaccine) => void }> = ({ vaccine, onChange }) => {
    const { label: nextDueLabel } = calculateNextDueInfo(vaccine.name, vaccine.date);
    return (
        <div className="vacc-card">
            <div className="vacc-card-header">
                <div className="vacc-card-info">
                    <h3 className="vacc-name">{vaccine.name}</h3>
                    <span className={`vacc-status ${vaccine.isTaken ? 'taken' : ''}`}>
                        {vaccine.isTaken ? 'Status: Recorded' : 'Status: Not Taken'}
                    </span>
                </div>
                <label className="bt-toggle">
                    <input type="checkbox" checked={vaccine.isTaken}
                        onChange={e => onChange({ ...vaccine, isTaken: e.target.checked, alarmCancelled: false })} />
                    <span className="toggle-slider" />
                </label>
            </div>
            {vaccine.isTaken && (
                <div className="vacc-expanded">
                    <div className="vacc-inputs-row">
                        <div className="vacc-input-group">
                            <label className="vacc-label"><span className="vacc-label-icon">📅</span>VACCINATION DATE</label>
                            <input type="date" className="vacc-date-input" value={vaccine.date} max={today}
                                onChange={e => onChange({ ...vaccine, date: e.target.value })} />
                        </div>
                        <div className="vacc-input-group">
                            <label className="vacc-label"><span className="vacc-label-icon">🔔</span>REMINDER ALARM</label>
                            <input type="time" className="vacc-time-input" value={vaccine.alarmTime}
                                onChange={e => onChange({ ...vaccine, alarmTime: e.target.value })} />
                        </div>
                    </div>
                    <div className={`vacc-alarm-row ${vaccine.alarmCancelled ? 'cancelled' : ''}`}>
                        <div className="vacc-alarm-icon">
                            {vaccine.alarmCancelled ? <BellOff size={16} /> : <Bell size={16} />}
                        </div>
                        <div className="vacc-alarm-text">
                            <span className="vacc-alarm-title">{vaccine.alarmCancelled ? 'Alarm Cancelled' : 'Reminder Alarm'}</span>
                            <span className="vacc-alarm-sub">
                                {vaccine.alarmCancelled ? 'You will not be notified' : nextDueLabel}
                            </span>
                        </div>
                        <button className={`vacc-alarm-btn ${vaccine.alarmCancelled ? 'restore' : 'cancel'}`}
                            onClick={() => onChange({ ...vaccine, alarmCancelled: !vaccine.alarmCancelled })}>
                            {vaccine.alarmCancelled ? 'Restore' : 'Cancel Alarm'}
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
};

// ── Success Popup ──────────────────────────────────────
const SuccessPopup: React.FC<{ onOk: () => void }> = ({ onOk }) => (
    <div className="vacc-popup-overlay" onClick={onOk}>
        <div className="vacc-popup-card" onClick={e => e.stopPropagation()}>
            <div className="vacc-popup-icon">
                <CheckCircle size={48} color="#10b981" />
            </div>
            <h2>Details Saved!</h2>
            <p>Your vaccination details have been safely recorded. Reminders have been set for your next doses.</p>
            <button className="vacc-popup-ok" onClick={onOk}>OK</button>
        </div>
    </div>
);

const Vaccination: React.FC = () => {
    const navigate = useNavigate();
    const { user } = useAuth();
    const [loading, setLoading] = useState(false);
    const [appeared, setAppeared] = useState(false);
    const [showSuccess, setShowSuccess] = useState(false);

    const makeVaccine = (name: string): Vaccine => ({
        name, isTaken: false, date: today, alarmTime: '09:00', alarmCancelled: false
    });

    const [pneumo, setPneumo] = useState<Vaccine>(makeVaccine('Pneumococcal Vaccination'));
    const [flu, setFlu] = useState<Vaccine>(makeVaccine('Flu Vaccine'));
    const [pertussis, setPertussis] = useState<Vaccine>(makeVaccine('Pertussis Vaccine'));
    const [shinglesTaken, setShinglesTaken] = useState(false);
    const [shinglesD1, setShinglesD1] = useState(today);
    const [shinglesD2Taken, setShinglesD2Taken] = useState(false);
    const [shinglesD2, setShinglesD2] = useState(today);
    const [shinglesAlarm, setShinglesAlarm] = useState('09:00');

    useEffect(() => {
        setAppeared(true);
        const fetchExisting = async () => {
            if (!user) return;

            // Load existing reminders from backend, fallback to localStorage
            let patientReminders: VaccineReminder[] = [];
            try {
                const remindersRes = await apiCall('get_reminders.php', 'POST', { patient_id: user.id });
                if (remindersRes.status === 'success' && Array.isArray(remindersRes.reminders)) {
                    patientReminders = remindersRes.reminders;
                }
            } catch (e) {
                console.error("Failed to fetch reminders from server", e);
            }

            if (patientReminders.length === 0) {
                const allReminders = JSON.parse(localStorage.getItem(REMINDER_KEY) || '{}');
                patientReminders = allReminders[user.id] || [];
            }

            const findStored = (idPrefix: string) => patientReminders.find(r => r.id.startsWith(idPrefix));

            const res = await apiCall('get_patient_details.php', 'POST', { patient_id: user.id });
            if (res.questionnaire) {
                const q = res.questionnaire;

                if (q.date_pneumococcal && q.date_pneumococcal !== 'N/A') {
                    const stored = findStored('vaccine_pneumococcal');
                    setPneumo({
                        name: 'Pneumococcal Vaccination',
                        isTaken: true,
                        date: q.date_pneumococcal,
                        alarmTime: stored?.alarmTime || '09:00',
                        alarmCancelled: !stored
                    });
                }

                if (q.date_flu && q.date_flu !== 'N/A') {
                    const stored = findStored('vaccine_flu');
                    setFlu({
                        name: 'Flu Vaccine',
                        isTaken: true,
                        date: q.date_flu,
                        alarmTime: stored?.alarmTime || '09:00',
                        alarmCancelled: !stored
                    });
                }

                if (q.date_pertussis && q.date_pertussis !== 'N/A') {
                    const stored = findStored('vaccine_pertussis');
                    setPertussis({
                        name: 'Pertussis Vaccine',
                        isTaken: true,
                        date: q.date_pertussis,
                        alarmTime: stored?.alarmTime || '09:00',
                        alarmCancelled: !stored
                    });
                }

                if (q.date_shingles1 && q.date_shingles1 !== 'N/A') {
                    setShinglesTaken(true);
                    setShinglesD1(q.date_shingles1);
                    const stored = findStored('vaccine_shingles');
                    if (stored) setShinglesAlarm(stored.alarmTime);
                }
                if (q.date_shingles2 && q.date_shingles2 !== 'N/A') {
                    setShinglesD2Taken(true);
                    setShinglesD2(q.date_shingles2);
                }
            }
        };
        fetchExisting();
    }, [user]);

    const buildReminders = (): VaccineReminder[] => {
        const reminders: VaccineReminder[] = [];
        const vaccines = [pneumo, flu, pertussis];
        for (const v of vaccines) {
            if (v.isTaken && !v.alarmCancelled) {
                const { label, dueDate } = calculateNextDueInfo(v.name, v.date);
                if (dueDate) {
                    reminders.push({
                        id: `vaccine_${v.name.replace(/\s+/g, '_').toLowerCase()}`,
                        title: `${v.name} Due 💉`,
                        body: label,
                        dueDate,
                        alarmTime: v.alarmTime,
                        icon: '💉',
                        color: '#10b981'
                    });
                }
            }
        }
        if (shinglesTaken) {
            let title = '', body = '', dueDate = '';
            if (!shinglesD2Taken) {
                const d = new Date(shinglesD1);
                d.setMonth(d.getMonth() + 6);
                dueDate = d.toISOString().split('T')[0];
                title = 'Shingles Dose 2 Due 💉';
                body = `Dose 2 due on ${d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}`;
            } else {
                const d = new Date(shinglesD2);
                d.setFullYear(d.getFullYear() + 5);
                dueDate = d.toISOString().split('T')[0];
                title = 'Shingles Immunity Review 💉';
                body = `Next review on ${d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}`;
            }
            reminders.push({ id: 'vaccine_shingles', title, body, dueDate, alarmTime: shinglesAlarm, icon: '💉', color: '#10b981' });
        }
        return reminders;
    };

    const handleSubmit = async () => {
        if (!user) return;
        setLoading(true);
        const payload = {
            patient_id: user.id,
            date_pneumococcal: pneumo.isTaken ? pneumo.date : 'N/A',
            date_flu: flu.isTaken ? flu.date : 'N/A',
            date_pertussis: pertussis.isTaken ? pertussis.date : 'N/A',
            date_shingles1: shinglesTaken ? shinglesD1 : 'N/A',
            date_shingles2: (shinglesTaken && shinglesD2Taken) ? shinglesD2 : 'N/A',
        };
        const res = await apiCall('save_vaccine_dates.php', 'POST', payload);
        if (res.status === 'success') {
            // Save reminders to backend
            const reminders = buildReminders();
            try {
                await apiCall('save_reminders.php', 'POST', {
                    patient_id: user.id,
                    reminders: reminders
                });
                // Also write locally as a cache fallback
                saveReminders(user.id, reminders);
            } catch (err) {
                console.error("Failed to save reminders to database", err);
            }
            setLoading(false);
            setShowSuccess(true);
        } else {
            setLoading(false);
            alert('Failed to save vaccination dates');
        }
    };

    const shinglesNextInfo = (): string => {
        if (!shinglesD2Taken) {
            const d2 = new Date(shinglesD1);
            d2.setMonth(d2.getMonth() + 6);
            return `Dose 2 due on ${d2.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}`;
        }
        const rev = new Date(shinglesD2);
        rev.setFullYear(rev.getFullYear() + 5);
        return `Next review on ${rev.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}`;
    };

    return (
        <div className={`vaccination-view ${appeared ? 'appeared' : ''}`}>
            {showSuccess && <SuccessPopup onOk={() => { setShowSuccess(false); navigate('/patient/questionnaire'); }} />}

            <header className="vacc-page-header">
                <button className="vacc-back-btn" onClick={() => navigate(-1)}><ChevronLeft size={24} /></button>
                <div>
                    <h1>Vaccination History</h1>
                    <p>Keep track of your respiratory vaccinations</p>
                </div>
            </header>

            <div className="vacc-scroll-content">
                <div className="vacc-intro-card">
                    <div className="vacc-intro-icon">💉</div>
                    <div>
                        <h3>Stay Protected</h3>
                        <p>Managing your vaccines is crucial for COPD care. We'll remind you when boosters are due.</p>
                    </div>
                </div>

                <div className="vacc-list">
                    <VaccineRowCard vaccine={pneumo} onChange={setPneumo} />
                    <VaccineRowCard vaccine={flu} onChange={setFlu} />
                    <VaccineRowCard vaccine={pertussis} onChange={setPertussis} />

                    {/* Shingles */}
                    <div className="vacc-card">
                        <div className="vacc-card-header">
                            <div className="vacc-card-info">
                                <h3 className="vacc-name">Shingles Vaccine</h3>
                                <span className={`vacc-status ${shinglesTaken ? 'taken' : ''}`}>
                                    {shinglesTaken ? 'Dose Entry Active' : 'Status: Not Taken'}
                                </span>
                            </div>
                            <label className="bt-toggle">
                                <input type="checkbox" checked={shinglesTaken} onChange={e => setShinglesTaken(e.target.checked)} />
                                <span className="toggle-slider" />
                            </label>
                        </div>
                        {shinglesTaken && (
                            <div className="vacc-expanded shingles-expanded">
                                <div className="vacc-input-group full-width">
                                    <label className="vacc-label"><span className="vacc-label-icon">📅</span>FIRST DOSE DATE</label>
                                    <input type="date" className="vacc-date-input" value={shinglesD1} max={today} onChange={e => setShinglesD1(e.target.value)} />
                                </div>
                                <div className="shingles-dose2-toggle">
                                    <span>Completed Dose 2?</span>
                                    <label className="bt-toggle small">
                                        <input type="checkbox" checked={shinglesD2Taken} onChange={e => setShinglesD2Taken(e.target.checked)} />
                                        <span className="toggle-slider" />
                                    </label>
                                </div>
                                {shinglesD2Taken && (
                                    <div className="vacc-input-group full-width animate-in">
                                        <label className="vacc-label"><span className="vacc-label-icon">📅</span>SECOND DOSE DATE</label>
                                        <input type="date" className="vacc-date-input" value={shinglesD2} max={today} onChange={e => setShinglesD2(e.target.value)} />
                                    </div>
                                )}
                                <div className="shingles-alarm-row">
                                    <div className="vacc-alarm-icon"><Bell size={16} /></div>
                                    <div className="vacc-alarm-text">
                                        <span className="vacc-alarm-title">Reminder Alarm</span>
                                        <span className="vacc-alarm-sub">{shinglesNextInfo()}</span>
                                    </div>
                                    <input type="time" className="vacc-time-input small" value={shinglesAlarm} onChange={e => setShinglesAlarm(e.target.value)} />
                                </div>
                            </div>
                        )}
                    </div>
                </div>

                <div className="vacc-footer">
                    <BTPrimaryButton onClick={handleSubmit} loading={loading} icon={<ArrowRight size={20} />}>
                        Confirm &amp; Continue
                    </BTPrimaryButton>
                    <p className="vacc-footer-note"><Info size={14} /> Next: COPD Health Assessment (CAT)</p>
                </div>
            </div>
        </div>
    );
};

export default Vaccination;
