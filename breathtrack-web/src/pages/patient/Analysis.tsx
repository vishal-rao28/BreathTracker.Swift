import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Info, Activity, TrendingUp, AlertCircle, ChevronRight, FileText } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { apiCall } from '../../api/apiService';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Title,
    Tooltip,
    Legend,
    Filler,
} from 'chart.js';
import { Line } from 'react-chartjs-2';
import './Analysis.css';

ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Title,
    Tooltip,
    Legend,
    Filler
);

const Analysis: React.FC = () => {
    const navigate = useNavigate();
    const { user } = useAuth();
    const [reportData, setReportData] = useState<any>(null);
    const [pftData, setPftData] = useState<any>(null);
    // const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchReports = async () => {
            if (!user) return;

            const [abgRes, pftRes] = await Promise.all([
                apiCall('get_abg.php', 'POST', { patient_id: user.id }),
                apiCall('get_pft.php', 'POST', { patient_id: user.id })
            ]);

            if (abgRes.status === 'success') setReportData(abgRes.data);
            if (pftRes.status === 'success') setPftData(pftRes.data);
        };

        fetchReports();
    }, [user]);

    const lineData = {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'], // Mock history for visualization
        datasets: [
            {
                label: 'SpO2 Level (%)',
                data: [94, 96, 95, 97, 96, reportData?.pao2 ? Math.min(99, reportData.pao2) : 96],
                borderColor: '#1A6B8A',
                backgroundColor: 'rgba(26, 107, 138, 0.08)',
                fill: true,
                tension: 0.4,
                pointRadius: 6,
                pointHoverRadius: 8,
                pointBackgroundColor: '#fff',
                pointBorderWidth: 3,
            },
        ],
    };

    const chartOptions: any = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { display: false },
            tooltip: {
                backgroundColor: '#18243A',
                titleFont: { size: 13 },
                bodyFont: { size: 14, weight: 'bold' },
                padding: 12,
                cornerRadius: 12,
                displayColors: false
            }
        },
        scales: {
            y: {
                beginAtZero: false,
                min: 80,
                max: 100,
                grid: { color: 'rgba(221, 232, 240, 0.5)', drawBorder: false },
                ticks: { font: { size: 12, color: '#9BAEBE' } }
            },
            x: {
                grid: { display: false },
                ticks: { font: { size: 12, color: '#9BAEBE' } }
            },
        },
    };

    return (
        <div className="analysis-view">
            <header className="view-header">
                <div className="header-text">
                    <h1>Health Analysis</h1>
                    <p>In-depth look at your respiratory trends and test results.</p>
                </div>
            </header>

            <div className="analysis-grid">
                <div className="analysis-main">
                    <section className="chart-card-large">
                        <div className="chart-header">
                            <div>
                                <h3>Oxygen Saturation Trend</h3>
                                <p>Last 6 measurements</p>
                            </div>
                            <div className="trend-badge positive">
                                <TrendingUp size={14} />
                                <span>Stable</span>
                            </div>
                        </div>
                        <div className="chart-wrapper">
                            <Line data={lineData} options={chartOptions} />
                        </div>
                    </section>

                    <div className="reports-dual-pane">
                        <section className="data-card abg-section">
                            <div className="card-title-row">
                                <Activity size={20} />
                                <h3>ABG Parameters</h3>
                            </div>
                            <div className="data-table">
                                <div className="data-row">
                                    <span className="label">pH Level</span>
                                    <span className="value">{reportData?.ph || '--'}</span>
                                    <span className="status-pill success">Normal</span>
                                </div>
                                <div className="data-row">
                                    <span className="label">PaO2</span>
                                    <span className="value">{reportData?.pao2 || '--'} <small>mmHg</small></span>
                                </div>
                                <div className="data-row">
                                    <span className="label">PaCO2</span>
                                    <span className="value">{reportData?.paco2 || '--'} <small>mmHg</small></span>
                                </div>
                                <div className="data-row">
                                    <span className="label">HCO3</span>
                                    <span className="value">{reportData?.hco3 || '--'} <small>mEq/L</small></span>
                                </div>
                            </div>
                        </section>

                        <section className="data-card pft-section">
                            <div className="card-title-row">
                                <FileText size={20} />
                                <h3>PFT Analysis</h3>
                            </div>
                            <div className="pft-summary">
                                <div className="gold-stage-box">
                                    <span className="mini-label">Classification</span>
                                    <div className="stage-value">
                                        {pftData?.condition ? `GOLD ${pftData.condition}` : 'Stage TBD'}
                                    </div>
                                </div>
                                <div className="remarks-box">
                                    <Info size={16} />
                                    <p>{pftData?.remarks || "No PFT analysis available yet. Consult your doctor for a lung function test."}</p>
                                </div>
                            </div>
                        </section>
                    </div>
                </div>

                <aside className="analysis-side">
                    <div className="info-promo-card">
                        <AlertCircle size={24} className="icon" />
                        <h3>Understanding Grades</h3>
                        <p>GOLD stages are used by doctors to categorize COPD severity from I (Mild) to IV (Very Severe).</p>
                        <button className="btn-text">Learn more</button>
                    </div>

                    <div className="action-list-card">
                        <h3>Quick Actions</h3>
                        <div className="action-row" onClick={() => navigate('/patient/checkup')}>
                            <span>Daily Vitals Log</span>
                            <ChevronRight size={16} />
                        </div>
                        <div className="action-row" onClick={() => navigate('/patient/questionnaire')}>
                            <span>CAT Assessment</span>
                            <ChevronRight size={16} />
                        </div>
                    </div>
                </aside>
            </div>
        </div>
    );
};

export default Analysis;
