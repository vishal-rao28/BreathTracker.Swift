import React, { useState, useEffect } from 'react';
import {
    Bell, BellOff, Syringe, Calendar, Clock,
    Trash2, X, CheckCircle, XCircle, Wind, AlertTriangle
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { apiCall } from '../../api/apiService';
import type { VaccineReminder } from './Vaccination';
import './Reminders.css';

const REMINDER_KEY = 'bt_vaccine_reminders';


function saveReminders(patientId: string, reminders: VaccineReminder[]) {
    const all = JSON.parse(localStorage.getItem(REMINDER_KEY) || '{}');
    all[patientId] = reminders;
    localStorage.setItem(REMINDER_KEY, JSON.stringify(all));
}

function formatDueDate(dueDate: string): string {
    if (!dueDate) return '';
    const d = new Date(dueDate);
    return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
}

function getDaysUntil(dueDate: string): number {
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const due = new Date(dueDate);
    return Math.ceil((due.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
}

function formatTime12h(time24: string): string {
    if (!time24) return '';
    try {
        const [hourStr, minuteStr] = time24.split(':');
        let hour = parseInt(hourStr, 10);
        const ampm = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        hour = hour ? hour : 12; // the hour '0' should be '12'
        return `${hour}:${minuteStr} ${ampm}`;
    } catch {
        return time24;
    }
}

const ReminderCard: React.FC<{
    reminder: VaccineReminder;
    index: number;
    onCancel: () => void;
}> = ({ reminder, index, onCancel }) => {
    const [appeared, setAppeared] = useState(false);
    const days = getDaysUntil(reminder.dueDate);
    const isOverdue = days < 0;
    const isSoon = days >= 0 && days <= 30;

    useEffect(() => {
        const t = setTimeout(() => setAppeared(true), index * 80);
        return () => clearTimeout(t);
    }, [index]);

    const renderIcon = () => {
        if (reminder.id === 'inhaler_daily_alarm' || reminder.icon === 'wind') return <Wind size={22} color={reminder.color} />;
        if (reminder.id === 'inhaler_refill' || reminder.icon === 'alert-triangle') return <AlertTriangle size={22} color={reminder.color} />;
        return <Syringe size={22} color={reminder.color} />;
    };

    return (
        <div className={`reminder-card ${appeared ? 'appeared' : ''}`}>
            <div className="reminder-icon-box" style={{ background: `${reminder.color}18` }}>
                {renderIcon()}
            </div>
            <div className="reminder-info">
                <h4>{reminder.title}</h4>
                <p>{reminder.body}</p>
                <div className="reminder-meta">
                    <Clock size={12} />
                    <span className={isOverdue ? 'overdue' : isSoon ? 'soon' : ''}>
                        {formatTime12h(reminder.alarmTime)} •{' '}
                        {reminder.id === 'inhaler_daily_alarm'
                            ? 'Every day'
                            : isOverdue
                                ? `Overdue by ${Math.abs(days)} day${Math.abs(days) !== 1 ? 's' : ''}`
                                : days === 0
                                    ? 'Due today'
                                    : `Due in ${days} day${days !== 1 ? 's' : ''} (${formatDueDate(reminder.dueDate)})`}
                    </span>
                </div>
            </div>
            <button className="reminder-cancel-btn" onClick={onCancel} title="Remove reminder">
                <X size={14} />
            </button>
        </div>
    );
};

const Reminders: React.FC = () => {
    const { user } = useAuth();
    const [reminders, setReminders] = useState<VaccineReminder[]>([]);
    const [appointment, setAppointment] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [appeared, setAppeared] = useState(false);
    const [showClearConfirm, setShowClearConfirm] = useState(false);

    useEffect(() => {
        setAppeared(true);
        if (!user) { setLoading(false); return; }

        setLoading(true);
        // Fetch reminders and appointment details in parallel
        Promise.all([
            apiCall('get_reminders.php', 'POST', { patient_id: user.id }),
            apiCall('get_appointment.php', 'POST', { patient_id: user.id })
        ])
            .then(([remindersRes, apptRes]) => {
                if (remindersRes.status === 'success' && Array.isArray(remindersRes.reminders)) {
                    const loaded = remindersRes.reminders;
                    loaded.sort((a: any, b: any) => new Date(a.dueDate).getTime() - new Date(b.dueDate).getTime());
                    setReminders(loaded);
                }
                if (apptRes.status === 'success' && apptRes.appointment) {
                    setAppointment(apptRes.appointment);
                }
            })
            .catch((err) => {
                console.error("Failed to load reminders or appointments details", err);
            })
            .finally(() => setLoading(false));
    }, [user]);

    const cancelReminder = async (id: string) => {
        if (!user) return;
        const updated = reminders.filter(r => r.id !== id);
        setReminders(updated);
        try {
            await apiCall('delete_reminder.php', 'POST', { patient_id: user.id, id });
            saveReminders(user.id, updated);
        } catch (err) {
            console.error("Failed to delete reminder from server", err);
        }
    };

    const clearAll = async () => {
        if (!user) return;
        setReminders([]);
        setShowClearConfirm(false);
        try {
            await apiCall('clear_reminders.php', 'POST', { patient_id: user.id });
            saveReminders(user.id, []);
        } catch (err) {
            console.error("Failed to clear reminders from server", err);
        }
    };

    const hasContent = reminders.length > 0 || appointment?.status?.toLowerCase() === 'accepted' || appointment?.status?.toLowerCase() === 'rejected';

    return (
        <div className={`reminders-page ${appeared ? 'appeared' : ''}`}>
            {/* Header */}
            <header className="reminders-header">
                <div className="reminders-header-text">
                    <h1>My Reminders</h1>
                    <p>Your scheduled vaccine and appointment alerts</p>
                </div>
                {reminders.length > 0 && (
                    <button className="reminders-clear-btn" onClick={() => setShowClearConfirm(true)} title="Clear all">
                        <Trash2 size={18} />
                    </button>
                )}
            </header>

            {/* Clear confirm dialog */}
            {showClearConfirm && (
                <div className="reminders-dialog-overlay" onClick={() => setShowClearConfirm(false)}>
                    <div className="reminders-dialog" onClick={e => e.stopPropagation()}>
                        <h3>Cancel All Reminders?</h3>
                        <p>Are you sure you want to remove all scheduled reminders?</p>
                        <div className="reminders-dialog-actions">
                            <button className="dialog-btn keep" onClick={() => setShowClearConfirm(false)}>Keep</button>
                            <button className="dialog-btn cancel-all" onClick={clearAll}>Cancel All</button>
                        </div>
                    </div>
                </div>
            )}

            <div className="reminders-scroll">
                {loading ? (
                    <div className="reminders-loading">
                        <div className="reminders-spinner" />
                    </div>
                ) : !hasContent ? (
                    /* Empty State */
                    <div className="reminders-empty">
                        <div className="empty-icon-circle">
                            <BellOff size={44} color="#3b82f6" opacity={0.5} />
                        </div>
                        <h3>No Reminders Set</h3>
                        <p>Set alarms from the <strong>Vaccination History</strong> page to track your next doses here.</p>
                    </div>
                ) : (
                    <div className="reminders-list">
                        {/* Appointment accepted notification */}
                        {appointment?.status?.toLowerCase() === 'accepted' && (
                            <div className="reminder-appt-card">
                                <div className="reminder-icon-box appt">
                                    <CheckCircle size={22} color="#10b981" />
                                </div>
                                <div className="reminder-info">
                                    <h4>Appointment Confirmed!</h4>
                                    <p>Your doctor has accepted your appointment on <strong>{formatDueDate(appointment.preferred_date)}</strong> at <strong>{appointment.preferred_time}</strong>.</p>
                                    <div className="reminder-meta">
                                        <Calendar size={12} />
                                        <span>Confirmed for {formatDueDate(appointment.preferred_date)}</span>
                                    </div>
                                </div>
                            </div>
                        )}

                        {/* Appointment rejected notification */}
                        {appointment?.status?.toLowerCase() === 'rejected' && (
                            <div className="reminder-appt-card rejected">
                                <div className="reminder-icon-box rejected-icon">
                                    <XCircle size={22} color="#ef4444" />
                                </div>
                                <div className="reminder-info">
                                    <h4>Appointment Rejected</h4>
                                    <p>Unfortunately, your doctor has declined your appointment request for <strong>{formatDueDate(appointment.preferred_date)}</strong> at <strong>{appointment.preferred_time}</strong>. Please reschedule or contact your clinic.</p>
                                    <div className="reminder-meta">
                                        <Calendar size={12} />
                                        <span className="overdue">Requested for {formatDueDate(appointment.preferred_date)}</span>
                                    </div>
                                </div>
                            </div>
                        )}

                        {/* Vaccine reminders */}
                        {reminders.length > 0 && (
                            <>
                                <div className="reminders-section-title">
                                    <Bell size={15} />
                                    <span>Scheduled Reminders ({reminders.length})</span>
                                </div>
                                {reminders.map((r, i) => (
                                    <ReminderCard
                                        key={r.id}
                                        reminder={r}
                                        index={i}
                                        onCancel={() => cancelReminder(r.id)}
                                    />
                                ))}
                            </>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
};

export default Reminders;
