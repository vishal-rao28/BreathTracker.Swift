import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    ChevronLeft, Send, Loader2,
    FileText, CheckCircle2, AlertCircle
} from 'lucide-react';
import { apiCall } from '../../api/apiService';
import './PftValues.css'; // Reusing PFT styles as they are essentially identical

const ABGReport: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();

    const [selectedImage, setSelectedImage] = useState<string | null>(null);
    const [severity, setSeverity] = useState<string>('Normal');
    const [comments, setComments] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [showSuccessPopup, setShowSuccessPopup] = useState(false);
    const [showErrorPopup, setShowErrorPopup] = useState(false);
    const [errorMessage, setErrorMessage] = useState('');

    const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            const reader = new FileReader();
            reader.onloadend = () => {
                setSelectedImage(reader.result as string);
            };
            reader.readAsDataURL(file);
        }
    };

    const handleSubmit = async () => {
        setIsSubmitting(true);
        try {
            const base64Image = selectedImage ? selectedImage.split(',')[1] : '';
            const payload = {
                patient_id: id,
                image: base64Image,
                comments,
                normal: severity === 'Normal' ? 'Yes' : 'No',
                mild: severity === 'Mild' ? 'Yes' : 'No',
                moderate: severity === 'Moderate' ? 'Yes' : 'No',
                severe: severity === 'Severe' ? 'Yes' : 'No'
            };

            const res = await apiCall('submit_abg.php', 'POST', payload);
            if (res.status === 'success') {
                setShowSuccessPopup(true);
            } else {
                setErrorMessage(res.message || 'Error from server.');
                setShowErrorPopup(true);
            }
        } catch (err) {
            console.error('Submission failed', err);
            setErrorMessage('Failed to submit report. Please try again.');
            setShowErrorPopup(true);
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="pft-container">
            <header className="pft-header">
                <button className="pft-back-btn" onClick={() => navigate(`/doctor/patients/${id}`)}>
                    <ChevronLeft size={20} />
                </button>
                <h1>ABG Report Entry</h1>
                <div style={{ width: 40 }} />
            </header>

            <div className="pft-content">
                <section className="pft-section">
                    <h3 className="section-title">Medical Report Document</h3>
                    <div className="pft-upload-card">
                        <input type="file" id="abg-image" accept="image/*" onChange={handleImageChange} hidden />
                        <label htmlFor="abg-image" className="pft-upload-label">
                            {selectedImage ? (
                                <img src={selectedImage} alt="ABG Report" className="pft-preview" />
                            ) : (
                                <div className="pft-upload-placeholder">
                                    <div className="pft-upload-icon">
                                        <FileText size={24} />
                                    </div>
                                    <span className="pft-upload-text">Upload Report Image</span>
                                    <span className="pft-upload-subtext">Capture or select from gallery</span>
                                </div>
                            )}
                        </label>
                    </div>
                </section>

                <section className="pft-section">
                    <h3 className="section-title">ABG Severity Level</h3>
                    <div className="pft-severity-list horizontal">
                        <div className="pft-segmented-control">
                            {['Normal', 'Mild', 'Moderate', 'Severe'].map((level) => (
                                <button
                                    key={level}
                                    className={`pft-segment ${severity === level ? 'active' : ''}`}
                                    onClick={() => setSeverity(level)}
                                >
                                    {level}
                                </button>
                            ))}
                        </div>
                    </div>
                </section>

                <section className="pft-section">
                    <h3 className="section-title">Physician Remarks</h3>
                    <textarea
                        className="pft-comments"
                        placeholder="Enter additional clinical observations..."
                        value={comments}
                        onChange={(e) => setComments(e.target.value)}
                    />
                </section>

                <button
                    className="pft-submit-btn btn-press"
                    disabled={isSubmitting}
                    onClick={handleSubmit}
                >
                    {isSubmitting ? (
                        <>
                            <Loader2 size={20} className="spinner" />
                            <span>Submitting...</span>
                        </>
                    ) : (
                        <>
                            <Send size={20} />
                            <span>Submit ABG Report</span>
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
                        <h3>ABG Submission Successful!</h3>
                        <p>Arterial blood gas values for this patient have been recorded safely.</p>
                        <div className="sr-popup-actions">
                            <button
                                className="sr-popup-btn confirm"
                                style={{ backgroundColor: '#FF6B6B' }}
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
                        <h3>Submission Failed</h3>
                        <p>{errorMessage}</p>
                        <div className="sr-popup-actions">
                            <button
                                className="sr-popup-btn confirm"
                                style={{ backgroundColor: '#FF6B6B' }}
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

export default ABGReport;
