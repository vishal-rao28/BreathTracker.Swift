import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    ChevronLeft, Activity, Send, Loader2,
    FileText, CheckCircle2, AlertCircle
} from 'lucide-react';
import { motion } from 'framer-motion';
import { apiCall } from '../../api/apiService';
import './SixMinWalkTest.css';

const SixMinWalkTest: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();

    const [description, setDescription] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [showSuccessPopup, setShowSuccessPopup] = useState(false);
    const [showErrorPopup, setShowErrorPopup] = useState(false);
    const [errorMessage, setErrorMessage] = useState('');

    const handleSubmit = async () => {
        if (!description.trim()) {
            setErrorMessage('Please enter the report description.');
            setShowErrorPopup(true);
            return;
        }

        setIsSubmitting(true);
        try {
            const res = await apiCall('submit_six_min_walk.php', 'POST', {
                patient_id: id,
                description: description
            });

            if (res.status === 'success') {
                setShowSuccessPopup(true);
            } else {
                setErrorMessage(res.message || 'Error occurred while saving walk test.');
                setShowErrorPopup(true);
            }
        } catch (err) {
            console.error('Submission failed', err);
            setErrorMessage('Failed to save report.');
            setShowErrorPopup(true);
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="smw-container">
            <header className="smw-header">
                <button className="smw-back-btn" onClick={() => navigate(`/doctor/patients/${id}`)}>
                    <ChevronLeft size={20} />
                </button>
                <h1>6 Min Walk Test</h1>
                <div style={{ width: 40 }} />
            </header>

            <div className="smw-content">
                <motion.section
                    className="smw-hero"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                >
                    <div className="smw-hero-icon">
                        <Activity size={40} />
                    </div>
                    <h2>Test Description</h2>
                    <p>Record observations and distance for Patient: {id}</p>
                </motion.section>

                <section className="smw-section">
                    <div className="smw-card">
                        <div className="smw-card-header">
                            <FileText size={16} />
                            <span>Report Details</span>
                        </div>
                        <textarea
                            className="smw-editor"
                            placeholder="Please enter the test results and observations..."
                            value={description}
                            onChange={(e) => setDescription(e.target.value)}
                        />
                    </div>
                </section>

                <button
                    className="smw-submit-btn btn-press"
                    disabled={isSubmitting}
                    onClick={handleSubmit}
                >
                    {isSubmitting ? (
                        <>
                            <Loader2 size={20} className="spinner" />
                            <span>Saving...</span>
                        </>
                    ) : (
                        <>
                            <Send size={20} />
                            <span>Save Report</span>
                        </>
                    )}
                </button>
            </div>

            {showSuccessPopup && (
                <div className="sr-popup-overlay">
                    <div className="sr-popup-card">
                        <div className="sr-popup-icon" style={{ backgroundColor: 'rgba(52, 201, 138, 0.12)', color: '#34C98A' }}>
                            <CheckCircle2 size={36} />
                        </div>
                        <h3>Save Successful!</h3>
                        <p>The 6-Minute Walk Test report has been recorded safely in the database.</p>
                        <div className="sr-popup-actions">
                            <button
                                className="sr-popup-btn confirm"
                                style={{ backgroundColor: '#1A6B8A' }}
                                onClick={() => {
                                    setShowSuccessPopup(false);
                                    navigate(`/doctor/patients/${id}`);
                                }}
                            >
                                Done
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {showErrorPopup && (
                <div className="sr-popup-overlay" onClick={() => setShowErrorPopup(false)}>
                    <div className="sr-popup-card" onClick={(e) => e.stopPropagation()}>
                        <div className="sr-popup-icon" style={{ backgroundColor: 'rgba(255, 107, 107, 0.12)', color: '#FF6B6B' }}>
                            <AlertCircle size={36} />
                        </div>
                        <h3>Action Required</h3>
                        <p>{errorMessage}</p>
                        <div className="sr-popup-actions">
                            <button
                                className="sr-popup-btn confirm"
                                style={{ backgroundColor: '#1A6B8A' }}
                                onClick={() => setShowErrorPopup(false)}
                            >
                                Dismiss
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default SixMinWalkTest;
