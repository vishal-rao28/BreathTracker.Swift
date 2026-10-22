import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    ChevronLeft, Calendar as CalendarIcon, Check,
    AlertCircle, Loader2, User
} from 'lucide-react';
import { apiCall } from '../../api/apiService';
import './InhalerAdherence.css';

const InhalerAdherence: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();

    const [patientName, setPatientName] = useState('Patient');
    const [takenDates, setTakenDates] = useState<Set<string>>(new Set());
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            try {
                // Fetch Patient Info
                const pRes = await apiCall('get_patient_details.php', 'POST', { patient_id: id });
                if (pRes.status === 'success') {
                    setPatientName(pRes.patient.name);
                }

                // Fetch Adherence History
                const hRes = await apiCall('get_inhaler_history.php', 'POST', { patient_id: id });
                if (hRes.status === 'success' && hRes.taken_dates) {
                    setTakenDates(new Set(hRes.taken_dates));
                }
            } catch (err) {
                console.error('Failed to fetch adherence data', err);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, [id]);

    const isTaken = (date: Date) => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const dateStr = `${year}-${month}-${day}`;
        return takenDates.has(dateStr);
    };

    // Calendar generation logic
    const generateMonths = () => {
        const months = [];
        const today = new Date();
        // Generate last 6 months records
        for (let i = 0; i < 6; i++) {
            const d = new Date(today.getFullYear(), today.getMonth() - i, 1);
            months.push(d);
        }
        return months;
    };

    const getDaysInMonth = (monthDate: Date) => {
        const days = [];
        const firstDay = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1);
        const lastDay = new Date(monthDate.getFullYear(), monthDate.getMonth() + 1, 0);

        // Days from previous month to fill the first week
        const startOffset = firstDay.getDay();
        for (let i = 0; i < startOffset; i++) {
            days.push(null);
        }

        for (let i = 1; i <= lastDay.getDate(); i++) {
            days.push(new Date(monthDate.getFullYear(), monthDate.getMonth(), i));
        }
        return days;
    };

    const countTakenThisMonth = (monthDate: Date) => {
        const days = getDaysInMonth(monthDate).filter(d => d !== null) as Date[];
        return days.filter(d => isTaken(d)).length;
    };

    const getMissedThisMonth = () => {
        const today = new Date();
        const daysPassed = today.getDate();
        const taken = countTakenThisMonth(new Date(today.getFullYear(), today.getMonth(), 1));
        return Math.max(0, daysPassed - taken);
    };

    if (loading) {
        return (
            <div className="ia-loading">
                <Loader2 className="ia-spinner" size={40} />
                <p>Syncing adherence records...</p>
            </div>
        );
    }

    const missedCount = getMissedThisMonth();

    return (
        <div className="ia-container">
            <header className="ia-header">
                <button className="ia-back-btn" onClick={() => navigate(`/doctor/patients/${id}`)}>
                    <ChevronLeft size={20} />
                </button>
                <h1>Inhaler Adherence</h1>
                <div style={{ width: 40 }} />
            </header>

            <div className="ia-content">
                <section className="ia-hero-card">
                    <div className="ia-avatar-section">
                        <div className="ia-avatar">
                            <User size={32} />
                        </div>
                        <div className="ia-hero-info">
                            <h2>{patientName}</h2>
                            <p>History • Since First Dose</p>
                        </div>
                    </div>
                </section>

                <div className="ia-stats-row">
                    <div className="ia-stat-box">
                        <div className="ia-stat-icon primary">
                            <CalendarIcon size={16} />
                        </div>
                        <div className="ia-stat-val">
                            {countTakenThisMonth(new Date())}/{new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).getDate()}
                        </div>
                        <div className="ia-stat-label">Total Taken This Month</div>
                    </div>
                </div>

                {missedCount > 0 && (
                    <div className="ia-alert">
                        <AlertCircle size={18} />
                        <span>Patient missed {missedCount} {missedCount === 1 ? 'day' : 'days'} so far this month</span>
                    </div>
                )}

                <div className="ia-legend">
                    <div className="ia-legend-item">
                        <div className="legend-dot taken"></div>
                        <span>Taken</span>
                    </div>
                    <div className="ia-legend-item">
                        <div className="legend-dot empty"></div>
                        <span>Not Taken / No Data</span>
                    </div>
                </div>

                <div className="ia-calendars">
                    {generateMonths().map((monthDate, mIdx) => (
                        <div key={mIdx} className="ia-month-card">
                            <div className="ia-month-header">
                                <h3>{monthDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}</h3>
                                <span className="ia-month-stat">
                                    {countTakenThisMonth(monthDate)}/{new Date(monthDate.getFullYear(), monthDate.getMonth() + 1, 0).getDate()} taken
                                </span>
                            </div>

                            <div className="ia-weekday-headers">
                                {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map(d => <span key={d}>{d}</span>)}
                            </div>

                            <div className="ia-days-grid">
                                {getDaysInMonth(monthDate).map((date, dIdx) => {
                                    if (!date) return <div key={`empty-${dIdx}`} className="ia-day-empty"></div>;

                                    const taken = isTaken(date);
                                    const isFuture = date > new Date();

                                    return (
                                        <div
                                            key={dIdx}
                                            className={`ia-day ${taken ? 'taken' : ''} ${isFuture ? 'future' : ''}`}
                                        >
                                            {taken ? (
                                                <div className="ia-day-inner">
                                                    <Check size={12} strokeWidth={3} />
                                                    <span>{date.getDate()}</span>
                                                </div>
                                            ) : (
                                                <span>{date.getDate()}</span>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default InhalerAdherence;
