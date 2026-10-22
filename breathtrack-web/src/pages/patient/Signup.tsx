import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { User, Lock, ArrowRight, Calendar, ChevronLeft, Phone, Ruler, Scale, Activity, HeartPulse, CheckCircle, Briefcase } from 'lucide-react';
import { apiCall } from '../../api/apiService';
import BTInputField from '../../components/BTInputField';
import BTPrimaryButton from '../../components/BTPrimaryButton';
import './Login.css';

const PatientSignup: React.FC = () => {
    const [formData, setFormData] = useState({
        name: '',
        age: '',
        gender: 'Male',
        occupation: '',
        phone_number: '',
        height: '',
        weight: '',
        diagnosis: '',
        password: '',
        confirmPassword: '',
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [successId, setSuccessId] = useState('');
    const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

    const navigate = useNavigate();

    // Handlers
    const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const val = e.target.value;
        const cleanVal = val.replace(/[^A-Za-z\s]/g, '');
        setFormData(prev => ({ ...prev, name: cleanVal }));
        if (cleanVal.trim().length > 0 && cleanVal.trim().length < 3) {
            setFieldErrors(prev => ({ ...prev, name: 'Full Name must be at least 3 characters' }));
        } else {
            setFieldErrors(prev => {
                const { name, ...rest } = prev;
                return rest;
            });
        }
    };

    const handleAgeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const val = e.target.value;
        const cleanVal = val.replace(/\D/g, '').slice(0, 3);
        setFormData(prev => ({ ...prev, age: cleanVal }));
        const num = parseInt(cleanVal, 10);
        if (cleanVal && (isNaN(num) || num < 1 || num > 120)) {
            setFieldErrors(prev => ({ ...prev, age: 'Age must be between 1 and 120' }));
        } else {
            setFieldErrors(prev => {
                const { age, ...rest } = prev;
                return rest;
            });
        }
    };

    const handleOccupationChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const val = e.target.value;
        const cleanVal = val.replace(/[^A-Za-z\s]/g, '');
        setFormData(prev => ({ ...prev, occupation: cleanVal }));
        if (cleanVal.trim().length > 0 && cleanVal.trim().length < 2) {
            setFieldErrors(prev => ({ ...prev, occupation: 'Occupation must be at least 2 characters' }));
        } else {
            setFieldErrors(prev => {
                const { occupation, ...rest } = prev;
                return rest;
            });
        }
    };

    const handlePhoneNumberChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const val = e.target.value;
        const cleanVal = val.replace(/\D/g, '').slice(0, 10);
        setFormData(prev => ({ ...prev, phone_number: cleanVal }));
        if (cleanVal && cleanVal.length !== 10) {
            setFieldErrors(prev => ({ ...prev, phone_number: 'Phone number must be exactly 10 digits' }));
        } else {
            setFieldErrors(prev => {
                const { phone_number, ...rest } = prev;
                return rest;
            });
        }
    };

    const handleHeightChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        let val = e.target.value;
        val = val.replace(/[^0-9.]/g, '');
        const parts = val.split('.');
        if (parts.length > 2) {
            val = parts[0] + '.' + parts.slice(1).join('');
        }
        val = val.slice(0, 5);
        setFormData(prev => ({ ...prev, height: val }));
        const num = parseFloat(val);
        if (val && (isNaN(num) || num < 30 || num > 300)) {
            setFieldErrors(prev => ({ ...prev, height: 'Height must be between 30 and 300 cm' }));
        } else {
            setFieldErrors(prev => {
                const { height, ...rest } = prev;
                return rest;
            });
        }
    };

    const handleWeightChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        let val = e.target.value;
        val = val.replace(/[^0-9.]/g, '');
        const parts = val.split('.');
        if (parts.length > 2) {
            val = parts[0] + '.' + parts.slice(1).join('');
        }
        val = val.slice(0, 5);
        setFormData(prev => ({ ...prev, weight: val }));
        const num = parseFloat(val);
        if (val && (isNaN(num) || num < 2 || num > 300)) {
            setFieldErrors(prev => ({ ...prev, weight: 'Weight must be between 2 and 300 kg' }));
        } else {
            setFieldErrors(prev => {
                const { weight, ...rest } = prev;
                return rest;
            });
        }
    };

    const handleDiagnosisChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const val = e.target.value;
        setFormData(prev => ({ ...prev, diagnosis: val }));
        if (val.trim().length > 0 && val.trim().length < 3) {
            setFieldErrors(prev => ({ ...prev, diagnosis: 'Diagnosis must be at least 3 characters' }));
        } else {
            setFieldErrors(prev => {
                const { diagnosis, ...rest } = prev;
                return rest;
            });
        }
    };

    const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const val = e.target.value;
        setFormData(prev => ({ ...prev, password: val }));
        if (val.length > 0 && val.length < 6) {
            setFieldErrors(prev => ({ ...prev, password: 'Password must be at least 6 characters' }));
        } else {
            setFieldErrors(prev => {
                const { password, ...rest } = prev;
                return rest;
            });
        }
    };

    const handleConfirmPasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const val = e.target.value;
        setFormData(prev => ({ ...prev, confirmPassword: val }));
        if (val && val !== formData.password) {
            setFieldErrors(prev => ({ ...prev, confirmPassword: 'Passwords do not match' }));
        } else {
            setFieldErrors(prev => {
                const { confirmPassword, ...rest } = prev;
                return rest;
            });
        }
    };

    const handleSignup = async (e: React.FormEvent) => {
        e.preventDefault();

        const nameVal = formData.name.trim();
        const ageVal = formData.age.trim();
        const phoneVal = formData.phone_number.trim();
        const heightVal = formData.height.trim();
        const weightVal = formData.weight.trim();
        const diagVal = formData.diagnosis.trim();
        const occVal = formData.occupation.trim();

        if (!nameVal || !ageVal || !phoneVal || !heightVal || !weightVal || !diagVal || !occVal || !formData.password || !formData.confirmPassword) {
            setError('Please fill in all fields');
            return;
        }

        if (nameVal.length < 3) {
            setError('Full Name must be at least 3 characters');
            return;
        }

        const ageNum = parseInt(ageVal, 10);
        if (isNaN(ageNum) || ageNum < 1 || ageNum > 120) {
            setError('Age must be between 1 and 120');
            return;
        }

        if (occVal.length < 2) {
            setError('Occupation must be at least 2 characters');
            return;
        }

        if (phoneVal.length !== 10) {
            setError('Phone number must be exactly 10 digits');
            return;
        }

        const hNum = parseFloat(heightVal);
        if (isNaN(hNum) || hNum < 30 || hNum > 300) {
            setError('Height must be between 30 and 300 cm');
            return;
        }

        const wNum = parseFloat(weightVal);
        if (isNaN(wNum) || wNum < 2 || wNum > 300) {
            setError('Weight must be between 2 and 300 kg');
            return;
        }

        if (diagVal.length < 3) {
            setError('Diagnosis must be at least 3 characters');
            return;
        }

        if (formData.password.length < 6) {
            setError('Password must be at least 6 characters');
            return;
        }

        if (formData.password !== formData.confirmPassword) {
            setError('Passwords do not match');
            return;
        }

        setLoading(true);
        setError('');

        const result = await apiCall('patient_signup.php', 'POST', {
            name: nameVal,
            age: ageVal,
            gender: formData.gender,
            occupation: occVal,
            phone_number: phoneVal,
            height: heightVal,
            weight: weightVal,
            diagnosis: diagVal,
            password: formData.password
        });

        if (result.status === 'success') {
            setSuccessId(result.patient_id);
            setLoading(false);
        } else {
            setError(result.message || 'Signup failed');
            setLoading(false);
        }
    };

    if (successId) {
        return (
            <div className="login-page-web">
                <div className="login-form-side" style={{ flex: 1 }}>
                    <div className="login-card-web success-card">
                        <div className="success-icon-animation">
                            <CheckCircle size={80} color="#34C98A" />
                        </div>
                        <h1>Account Created!</h1>
                        <p>Your unique Patient ID is your key to BreathTrack.</p>

                        <div className="id-reveal-box">
                            <span className="id-label">YOUR PATIENT ID</span>
                            <div className="id-value">{successId}</div>
                        </div>

                        <p className="id-note">Please save this ID safely. You will need it to log in next time.</p>

                        <BTPrimaryButton onClick={() => navigate('/patient/login')} className="login-btn-web">
                            Go to Login
                        </BTPrimaryButton>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="login-page-web">
            <div className="login-side-banner">
                <div className="banner-content">
                    <div className="banner-logo">
                        <HeartPulse size={40} color="white" />
                        <span>BreathTrack</span>
                    </div>
                    <h1>Start Your Journey to Better Breathing.</h1>
                    <p>Join thousands of patients managing their health effectively with professional tools and doctor connectivity.</p>
                </div>
                <div className="banner-overlay"></div>
            </div>

            <div className="login-form-side signup-side">
                <div className="login-card-web signup-card">
                    <header className="login-header-web">
                        <Link to="/patient/login" className="back-link-web">
                            <ChevronLeft size={16} /> Back to Login
                        </Link>
                        <h2>Create Account</h2>
                        <p>Join the BreathTrack community today</p>
                    </header>

                    <form onSubmit={handleSignup} className="login-form-web signup-form-grid">
                        <div className="form-group-web full-width">
                            <label>Full Name</label>
                            <BTInputField icon={<User size={18} />} placeholder="Enter your full name" value={formData.name}
                                onChange={handleNameChange} error={fieldErrors.name} />
                        </div>

                        <div className="form-group-web">
                            <label>Age</label>
                            <BTInputField icon={<Calendar size={18} />} placeholder="Age" type="text" value={formData.age}
                                onChange={handleAgeChange} error={fieldErrors.age} />
                        </div>

                        <div className="form-group-web">
                            <label>Gender</label>
                            <div className="bt-input-wrapper">
                                <select className="bt-input-field select-field" value={formData.gender}
                                    onChange={(e) => setFormData({ ...formData, gender: e.target.value })}>
                                    <option>Male</option>
                                    <option>Female</option>
                                    <option>Other</option>
                                </select>
                            </div>
                        </div>

                        <div className="form-group-web">
                            <label>Height (cm)</label>
                            <BTInputField icon={<Ruler size={18} />} placeholder="175" type="text" value={formData.height}
                                onChange={handleHeightChange} error={fieldErrors.height} />
                        </div>

                        <div className="form-group-web">
                            <label>Weight (kg)</label>
                            <BTInputField icon={<Scale size={18} />} placeholder="70" type="text" value={formData.weight}
                                onChange={handleWeightChange} error={fieldErrors.weight} />
                        </div>

                        <div className="form-group-web full-width">
                            <label>Phone Number</label>
                            <BTInputField icon={<Phone size={18} />} placeholder="Enter 10-digit number" value={formData.phone_number}
                                onChange={handlePhoneNumberChange} error={fieldErrors.phone_number} />
                        </div>

                        <div className="form-group-web full-width">
                            <label>Occupation</label>
                            <BTInputField icon={<Briefcase size={18} />} placeholder="e.g. Teacher, Nurse" value={formData.occupation}
                                onChange={handleOccupationChange} error={fieldErrors.occupation} />
                        </div>

                        <div className="form-group-web full-width">
                            <label>Diagnosis</label>
                            <BTInputField icon={<Activity size={18} />} placeholder="e.g. COPD, Asthma" value={formData.diagnosis}
                                onChange={handleDiagnosisChange} error={fieldErrors.diagnosis} />
                        </div>

                        <div className="form-group-web">
                            <label>Password</label>
                            <BTInputField icon={<Lock size={18} />} type="password" placeholder="••••••••" value={formData.password}
                                onChange={handlePasswordChange} error={fieldErrors.password} />
                        </div>

                        <div className="form-group-web">
                            <label>Confirm Password</label>
                            <BTInputField icon={<Lock size={18} />} type="password" placeholder="••••••••" value={formData.confirmPassword}
                                onChange={handleConfirmPasswordChange} error={fieldErrors.confirmPassword} />
                        </div>

                        {error && <div className="error-alert full-width">{error}</div>}

                        <BTPrimaryButton type="submit" loading={loading} icon={<ArrowRight size={20} />} className="login-btn-web full-width">
                            Register & Get My ID
                        </BTPrimaryButton>
                    </form>
                </div>
            </div>
        </div>
    );
};

export default PatientSignup;
