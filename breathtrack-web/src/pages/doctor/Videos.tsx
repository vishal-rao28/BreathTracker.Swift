import React, { useState, useEffect, useRef } from 'react';
import { Play, Plus, Trash2, Globe, ExternalLink, X, PlayCircle, BookOpen, HardDrive, Upload, FileVideo, CheckCircle2, Link2 } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { BASE_URL } from '../../api/apiService';
import './Videos.css';

interface VideoItem {
    id: number;
    title: string;
    video_url: string;
    video_type: 'youtube' | 'local' | 'external';
    file_size?: number;
    upload_date?: string;
    uploaded_at?: string;
}

const getYouTubeId = (url: string): string => {
    const match = url.match(/(?:v=|\/embed\/|\.be\/)([a-zA-Z0-9_-]{11})/);
    return match ? match[1] : '';
};

const formatFileSize = (bytes: number): string => {
    if (!bytes) return '';
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
};

type UploadMode = 'youtube' | 'local';

const DoctorVideos: React.FC = () => {
    const [videos, setVideos] = useState<VideoItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [mode, setMode] = useState<UploadMode>('youtube');

    // YouTube form
    const [ytTitle, setYtTitle] = useState('');
    const [ytUrl, setYtUrl] = useState('');

    // Local upload form
    const [localTitle, setLocalTitle] = useState('');
    const [localFile, setLocalFile] = useState<File | null>(null);
    const [localPreviewSrc, setLocalPreviewSrc] = useState<string | null>(null);
    const [uploadProgress, setUploadProgress] = useState(0);

    const [submitting, setSubmitting] = useState(false);
    const [uploadDone, setUploadDone] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);

    useEffect(() => { fetchVideos(); }, []);

    const fetchVideos = async () => {
        setLoading(true);
        try {
            const res = await fetch(`${BASE_URL}/upload_video.php`);
            const data = await res.json();
            if (data.status === 'success') {
                setVideos(data.videos || []);
            }
        } catch (e) {
            console.error(e);
        }
        setLoading(false);
    };

    const resetModal = () => {
        setYtTitle(''); setYtUrl('');
        setLocalTitle(''); setLocalFile(null); setLocalPreviewSrc(null);
        setUploadProgress(0); setUploadDone(false); setSubmitting(false);
    };

    const openModal = () => { resetModal(); setShowModal(true); };
    const closeModal = () => { setShowModal(false); resetModal(); };

    const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;
        setLocalFile(file);
        const url = URL.createObjectURL(file);
        setLocalPreviewSrc(url);
        if (!localTitle) setLocalTitle(file.name.replace(/\.[^.]+$/, ''));
    };

    const handleYouTubeSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            const formData = new FormData();
            formData.append('action', 'add_url');
            formData.append('title', ytTitle);
            formData.append('video_url', ytUrl);
            const res = await fetch(`${BASE_URL}/upload_video.php`, { method: 'POST', body: formData });
            const data = await res.json();
            if (data.status === 'success') {
                setUploadDone(true);
                setTimeout(() => { closeModal(); fetchVideos(); }, 1200);
            }
        } catch (e) { console.error(e); }
        setSubmitting(false);
    };

    const handleLocalSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!localFile) return;
        setSubmitting(true);
        setUploadProgress(0);

        const formData = new FormData();
        formData.append('action', 'upload');
        formData.append('title', localTitle);
        formData.append('video', localFile);

        // XHR for upload progress
        const xhr = new XMLHttpRequest();
        xhr.open('POST', `${BASE_URL}/upload_video.php`, true);

        xhr.upload.onprogress = (event) => {
            if (event.lengthComputable) {
                setUploadProgress(Math.round((event.loaded / event.total) * 100));
            }
        };

        xhr.onload = () => {
            try {
                const data = JSON.parse(xhr.responseText);
                if (data.status === 'success') {
                    setUploadDone(true);
                    setTimeout(() => { closeModal(); fetchVideos(); }, 1200);
                }
            } catch (e) { console.error(e); }
            setSubmitting(false);
        };

        xhr.onerror = () => { setSubmitting(false); };
        xhr.send(formData);
    };

    const handleDelete = async (id: number) => {
        setVideos(v => v.filter(x => x.id !== id));
        try {
            const formData = new FormData();
            formData.append('action', 'delete');
            formData.append('video_id', String(id));
            await fetch(`${BASE_URL}/upload_video.php`, { method: 'POST', body: formData });
        } catch (e) {
            console.error('Failed to delete video:', e);
            fetchVideos(); // Re-fetch if delete failed
        }
    };

    return (
        <div className="vl-page">
            {/* Hero Header */}
            <motion.header className="vl-hero" initial={{ opacity: 0, y: -16 }} animate={{ opacity: 1, y: 0 }}>
                <div className="vl-hero-left">
                    <div className="vl-hero-icon"><PlayCircle size={28} /></div>
                    <div>
                        <h1>Video Library</h1>
                        <p>Share instructional content with your patients</p>
                    </div>
                </div>
                <div className="vl-hero-right">
                    <div className="vl-stat">
                        <span className="stat-num">{videos.length}</span>
                        <span className="stat-lbl">Videos</span>
                    </div>
                    <button className="vl-add-btn" onClick={openModal}>
                        <Plus size={18} /><span>Post New Video</span>
                    </button>
                </div>
            </motion.header>

            {/* Content */}
            <div className="vl-content">
                {loading ? (
                    <div className="vl-loading">
                        <div className="vl-spinner" /><p>Loading video library...</p>
                    </div>
                ) : videos.length === 0 ? (
                    <motion.div className="vl-empty" initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}>
                        <div className="empty-icon-wrap"><BookOpen size={48} /></div>
                        <h3>No Videos Yet</h3>
                        <p>Post YouTube videos or upload files from your desktop to educate your patients.</p>
                        <button className="vl-add-btn" onClick={openModal}><Plus size={18} /> Add First Video</button>
                    </motion.div>
                ) : (
                    <div className="vl-grid">
                        <AnimatePresence>
                            {videos.map((video, idx) => {
                                const isYT = video.video_type === 'youtube';
                                const isLocal = video.video_type === 'local';
                                const vid = isYT ? getYouTubeId(video.video_url) : '';
                                return (
                                    <motion.div
                                        key={video.id}
                                        className="vl-card"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, scale: 0.95 }}
                                        transition={{ delay: idx * 0.05 }}
                                        layout
                                    >
                                        <div className="vl-thumb">
                                            {isYT && vid && (
                                                <img src={`https://img.youtube.com/vi/${vid}/mqdefault.jpg`} alt={video.title} />
                                            )}
                                            {isLocal && (
                                                <div className="vl-local-thumb">
                                                    <video src={video.video_url} preload="metadata" />
                                                    <div className="local-thumb-icon"><HardDrive size={32} /></div>
                                                </div>
                                            )}
                                            <a href={video.video_url} target="_blank" rel="noreferrer" className="play-btn-overlay">
                                                <div className="play-circle"><Play size={26} fill="white" /></div>
                                            </a>
                                        </div>
                                        <div className="vl-card-body">
                                            <h3 className="vl-title">{video.title}</h3>
                                            <div className="vl-badges">
                                                <span className="vl-badge globe"><Globe size={12} /> Public</span>
                                                {isYT && <span className="vl-badge yt"><Link2 size={12} /> YouTube</span>}
                                                {isLocal && <span className="vl-badge local"><HardDrive size={12} /> Local {video.file_size ? `· ${formatFileSize(video.file_size)}` : ''}</span>}
                                            </div>
                                            <div className="vl-card-footer">
                                                <a href={video.video_url} target="_blank" rel="noreferrer" className="vl-view-btn">
                                                    <ExternalLink size={15} /> Open Video
                                                </a>
                                                <button className="vl-delete-btn" onClick={() => handleDelete(video.id)}><Trash2 size={15} /></button>
                                            </div>
                                        </div>
                                    </motion.div>
                                );
                            })}
                        </AnimatePresence>
                    </div>
                )}
            </div>

            {/* Modal */}
            <AnimatePresence>
                {showModal && (
                    <motion.div className="vl-modal-bg" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                        onClick={e => e.target === e.currentTarget && closeModal()}>
                        <motion.div className="vl-modal" initial={{ opacity: 0, scale: 0.9, y: 24 }} animate={{ opacity: 1, scale: 1, y: 0 }} exit={{ opacity: 0, scale: 0.9, y: 24 }}>

                            {/* Modal Header */}
                            <div className="modal-header">
                                <div className="modal-title-row">
                                    <div className="modal-icon"><Upload size={22} /></div>
                                    <div>
                                        <h2>Upload Video</h2>
                                        <p>Choose a source to add a video</p>
                                    </div>
                                </div>
                                <button className="modal-close" onClick={closeModal}><X size={20} /></button>
                            </div>

                            {/* Mode Toggle */}
                            <div className="mode-toggle">
                                <button
                                    className={`mode-btn ${mode === 'youtube' ? 'active-yt' : ''}`}
                                    onClick={() => setMode('youtube')}
                                >
                                    <Link2 size={18} /> Link via YouTube
                                </button>
                                <button
                                    className={`mode-btn ${mode === 'local' ? 'active-local' : ''}`}
                                    onClick={() => setMode('local')}
                                >
                                    <HardDrive size={18} /> Local Video File
                                </button>
                            </div>

                            {/* Success State */}
                            {uploadDone ? (
                                <motion.div className="upload-success" initial={{ scale: 0.8, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}>
                                    <CheckCircle2 size={52} />
                                    <h3>Video Published!</h3>
                                    <p>Your video has been added to the library.</p>
                                </motion.div>
                            ) : mode === 'youtube' ? (
                                /* YouTube Form */
                                <form onSubmit={handleYouTubeSubmit} className="modal-body">
                                    <div className="modal-field">
                                        <label>Video Title</label>
                                        <input required value={ytTitle} onChange={e => setYtTitle(e.target.value)} placeholder="e.g. Inhaler Usage Guide" />
                                    </div>
                                    <div className="modal-field">
                                        <label>YouTube URL</label>
                                        <input required value={ytUrl} onChange={e => setYtUrl(e.target.value)} placeholder="https://www.youtube.com/watch?v=..." />
                                    </div>
                                    {ytUrl && getYouTubeId(ytUrl) && (
                                        <div className="modal-preview">
                                            <img src={`https://img.youtube.com/vi/${getYouTubeId(ytUrl)}/mqdefault.jpg`} alt="Preview" />
                                            <div className="preview-label">Thumbnail Preview</div>
                                        </div>
                                    )}
                                    <div className="modal-actions">
                                        <button type="button" className="cancel-btn" onClick={closeModal}>Cancel</button>
                                        <button type="submit" className="publish-btn" disabled={submitting}>
                                            {submitting ? <span className="btn-spinner" /> : <><Plus size={16} /> Publish</>}
                                        </button>
                                    </div>
                                </form>
                            ) : (
                                /* Local Upload Form */
                                <form onSubmit={handleLocalSubmit} className="modal-body">
                                    <div className="modal-field">
                                        <label>Video Title</label>
                                        <input required value={localTitle} onChange={e => setLocalTitle(e.target.value)} placeholder="e.g. Breathing Exercise Demo" />
                                    </div>

                                    {/* Drop Zone */}
                                    <div className={`drop-zone ${localFile ? 'has-file' : ''}`} onClick={() => fileInputRef.current?.click()}>
                                        <input
                                            ref={fileInputRef}
                                            type="file"
                                            accept="video/mp4,video/avi,video/mov,video/mkv,video/wmv,video/flv,video/3gp"
                                            onChange={handleFileSelect}
                                            style={{ display: 'none' }}
                                        />
                                        {localFile ? (
                                            <div className="file-selected">
                                                <FileVideo size={32} />
                                                <div>
                                                    <strong>{localFile.name}</strong>
                                                    <span>{formatFileSize(localFile.size)}</span>
                                                </div>
                                            </div>
                                        ) : (
                                            <div className="drop-zone-inner">
                                                <div className="drop-icon"><Upload size={28} /></div>
                                                <p><strong>Click to select a video</strong></p>
                                                <span>MP4, MOV, AVI, MKV · Max 300MB</span>
                                            </div>
                                        )}
                                    </div>

                                    {/* Video Preview */}
                                    {localPreviewSrc && (
                                        <div className="local-video-preview">
                                            <video src={localPreviewSrc} controls />
                                        </div>
                                    )}

                                    {/* Progress Bar */}
                                    {submitting && (
                                        <div className="upload-progress-wrap">
                                            <div className="progress-bar-bg">
                                                <motion.div
                                                    className="progress-bar-fill"
                                                    initial={{ width: 0 }}
                                                    animate={{ width: `${uploadProgress}%` }}
                                                />
                                            </div>
                                            <span>{uploadProgress}%</span>
                                        </div>
                                    )}

                                    <div className="modal-actions">
                                        <button type="button" className="cancel-btn" onClick={closeModal}>Cancel</button>
                                        <button type="submit" className="publish-btn publish-local" disabled={submitting || !localFile}>
                                            {submitting ? <><span className="btn-spinner" /> Uploading…</> : <><Upload size={16} /> Upload Video</>}
                                        </button>
                                    </div>
                                </form>
                            )}
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default DoctorVideos;
