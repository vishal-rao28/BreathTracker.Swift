import React, { useState } from 'react';
import {
    Search, FileText, Image as ImageIcon, XCircle,
    Calendar, Clock, Wind, Droplets,
    Footprints, FolderOpen, AlertTriangle, X
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { apiCall, BASE_URL } from '../../api/apiService';
import './ReportSearch.css';

interface ConsolidatedReport {
    id: string;
    type: 'pft' | 'abg' | 'walk';
    condition: string;
    comments: string;
    walkDescription: string;
    imagePath: string | null;
    createdAt: string;
    dateTitle: string;
    timeTitle: string;
    timestamp: number;
}

interface ReportGroup {
    dateTitle: string;
    reports: ConsolidatedReport[];
}

const ReportSearch: React.FC = () => {
    const [searchText, setSearchText] = useState('');
    const [isSearching, setIsSearching] = useState(false);
    const [searchError, setSearchError] = useState<string | null>(null);
    const [groups, setGroups] = useState<ReportGroup[]>([]);
    const [totalFound, setTotalFound] = useState(0);
    const [selectedImage, setSelectedImage] = useState<string | null>(null);

    const performSearch = async () => {
        const query = searchText.trim();
        if (!query) return;

        setIsSearching(true);
        setSearchError(null);
        setGroups([]);

        try {
            const res = await apiCall('get_medical_reports.php', 'POST', { patient_id: query });

            if (res.status === 'error') {
                setSearchError(res.message || 'No history found.');
                return;
            }

            let allReports: ConsolidatedReport[] = [];

            // Parse PFT
            if (res.pft_history) {
                res.pft_history.forEach((item: any) => {
                    const dateObj = new Date(item.created_at);
                    allReports.push({
                        id: `pft-${item.id}`,
                        type: 'pft',
                        condition: item.condition,
                        comments: item.comments,
                        walkDescription: '',
                        imagePath: item.image_path,
                        createdAt: item.created_at,
                        dateTitle: dateObj.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }),
                        timeTitle: dateObj.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }),
                        timestamp: dateObj.getTime()
                    });
                });
            }

            // Parse ABG
            if (res.abg_history) {
                res.abg_history.forEach((item: any) => {
                    const dateObj = new Date(item.created_at);
                    allReports.push({
                        id: `abg-${item.id}`,
                        type: 'abg',
                        condition: item.condition,
                        comments: item.comments,
                        walkDescription: '',
                        imagePath: item.image_path,
                        createdAt: item.created_at,
                        dateTitle: dateObj.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }),
                        timeTitle: dateObj.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }),
                        timestamp: dateObj.getTime()
                    });
                });
            }

            // Parse Walk Test
            if (res.walk_test_history) {
                res.walk_test_history.forEach((item: any) => {
                    const dateObj = new Date(item.created_at);
                    allReports.push({
                        id: `walk-${item.id}`,
                        type: 'walk',
                        condition: '',
                        comments: '',
                        walkDescription: item.description,
                        imagePath: null,
                        createdAt: item.created_at,
                        dateTitle: dateObj.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }),
                        timeTitle: dateObj.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }),
                        timestamp: dateObj.getTime()
                    });
                });
            }

            if (allReports.length === 0) {
                setSearchError(`No reports found for Patient ID: ${query}`);
                return;
            }

            setTotalFound(allReports.length);

            // Group by date
            const groupedMap = new Map<string, ConsolidatedReport[]>();
            allReports.sort((a, b) => b.timestamp - a.timestamp); // Overall newest first

            allReports.forEach(report => {
                if (!groupedMap.has(report.dateTitle)) {
                    groupedMap.set(report.dateTitle, []);
                }
                groupedMap.get(report.dateTitle)!.push(report);
            });

            const groupedArray: ReportGroup[] = [];
            groupedMap.forEach((reports, dateTitle) => {
                groupedArray.push({ dateTitle, reports });
            });

            setGroups(groupedArray);

        } catch (err) {
            console.error('Search error:', err);
            setSearchError('Network error or invalid Patient ID.');
        } finally {
            setIsSearching(false);
        }
    };

    const conditionColor = (cond: string) => {
        switch (cond.toLowerCase()) {
            case 'normal': return '#34C98A';
            case 'mild': return '#5B4CF5';
            case 'moderate': return '#FF9B42';
            case 'severe': return '#FF6B6B';
            default: return '#64748B';
        }
    };

    return (
        <div className="rs-container">
            <header className="rs-header">
                <div className="rs-header-info">
                    <h1>Report Search</h1>
                    <p>Enter patient ID to unlock medical history timeline</p>
                </div>
            </header>

            <div className="rs-search-bar">
                <div className="search-input-group">
                    <Search className="s-icon" size={20} />
                    <input
                        type="text"
                        placeholder="Search Patient ID (e.g. pat_556)..."
                        value={searchText}
                        onChange={(e) => setSearchText(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && performSearch()}
                    />
                    {searchText && (
                        <button className="clear-btn" onClick={() => setSearchText('')}>
                            <XCircle size={18} />
                        </button>
                    )}
                </div>
                <button className="rs-search-btn" onClick={performSearch} disabled={isSearching}>
                    {isSearching ? <span className="loader"></span> : 'Search'}
                </button>
            </div>

            <main className="rs-results">
                {isSearching ? (
                    <div className="rs-status-view">
                        <div className="rs-loading-spinner" />
                        <p>Scanning medical records database...</p>
                    </div>
                ) : searchError ? (
                    <div className="rs-status-view error">
                        <AlertTriangle size={48} />
                        <h3>Search Failed</h3>
                        <p>{searchError}</p>
                    </div>
                ) : groups.length === 0 ? (
                    <div className="rs-status-view empty">
                        <FolderOpen size={56} />
                        <h3>No Records Displayed</h3>
                        <p>Enter a Patient ID above to retrieve chronologically grouped report logs.</p>
                    </div>
                ) : (
                    <div className="rs-timeline">
                        <div className="rs-timeline-summary">
                            <div className="summary-icon"><FileText size={20} /></div>
                            <div className="summary-text">
                                <strong>Timeline Overview</strong>
                                <span>Found {totalFound} medical reports on file</span>
                            </div>
                        </div>

                        {groups.map((group, gIdx) => (
                            <div key={gIdx} className="rs-date-group">
                                <div className="rs-date-header">
                                    <Calendar size={18} />
                                    <span>Reports from {group.dateTitle}</span>
                                </div>
                                <div className="rs-report-cards">
                                    {group.reports.map((report) => (
                                        <motion.div
                                            key={report.id}
                                            className="rs-card"
                                            initial={{ opacity: 0, x: -10 }}
                                            animate={{ opacity: 1, x: 0 }}
                                        >
                                            <div className="rs-card-top">
                                                <div className={`rs-type-icon ${report.type}`}>
                                                    {report.type === 'pft' && <Wind size={20} />}
                                                    {report.type === 'abg' && <Droplets size={20} />}
                                                    {report.type === 'walk' && <Footprints size={20} />}
                                                </div>
                                                <div className="rs-item-info">
                                                    <h4>
                                                        {report.type === 'pft' && 'PFT Analysis Report'}
                                                        {report.type === 'abg' && 'ABG Blood Gas Report'}
                                                        {report.type === 'walk' && '6 Min Walk Test'}
                                                    </h4>
                                                    <div className="rs-item-meta">
                                                        {report.condition && (
                                                            <span className="severity" style={{ color: conditionColor(report.condition) }}>
                                                                Severity: {report.condition}
                                                            </span>
                                                        )}
                                                        {report.condition && <span className="dot">•</span>}
                                                        <span className="time"><Clock size={12} /> {report.timeTitle}</span>
                                                    </div>
                                                </div>
                                            </div>

                                            {report.type === 'walk' ? (
                                                <p className="rs-walk-desc">{report.walkDescription}</p>
                                            ) : (
                                                <>
                                                    {report.comments && <p className="rs-comments">{report.comments}</p>}
                                                    {report.imagePath && (
                                                        <div
                                                            className="rs-image-preview"
                                                            onClick={() => setSelectedImage(`${BASE_URL}/${report.imagePath}`)}
                                                        >
                                                            <img src={`${BASE_URL}/${report.imagePath}`} alt="Report" />
                                                            <div className="img-overlay"><ImageIcon size={20} /> View Full Report</div>
                                                        </div>
                                                    )}
                                                </>
                                            )}
                                        </motion.div>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </main>

            <AnimatePresence>
                {selectedImage && (
                    <motion.div
                        className="rs-full-overlay"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                    >
                        <button className="close-overlay" onClick={() => setSelectedImage(null)}><X /></button>
                        <div className="overlay-content">
                            <img src={selectedImage} alt="Full Resolution" />
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default ReportSearch;
