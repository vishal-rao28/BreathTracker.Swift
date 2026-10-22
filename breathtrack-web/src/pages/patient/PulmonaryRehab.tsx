import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronLeft, Play, Star } from 'lucide-react';
import { apiCall } from '../../api/apiService';
import './PulmonaryRehab.css';

interface Video {
    id: string;
    title: string;
    url: string;
    thumbnail: string;
    category: string;
}

const PulmonaryRehab: React.FC = () => {
    const navigate = useNavigate();
    const [videos, setVideos] = useState<Video[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchVideos = async () => {
            const res = await apiCall('upload_video.php', 'GET');
            if (res.status === 'success' && res.videos) {
                const parsed = res.videos.map((v: any) => {
                    const videoUrl: string = v.video_url || '';
                    const videoType: string = v.video_type || 'external';

                    // Extract YouTube ID for thumbnail (only for youtube type)
                    let thumbnail = 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600&auto=format&fit=crop';
                    if (videoType === 'youtube' && videoUrl) {
                        let youtubeId = '';
                        try {
                            const urlObj = new URL(videoUrl);
                            if (urlObj.hostname.includes('youtube.com')) {
                                youtubeId = urlObj.searchParams.get('v') || '';
                            } else {
                                // youtu.be short links
                                youtubeId = urlObj.pathname.slice(1);
                            }
                        } catch (e) {
                            youtubeId = videoUrl.split('v=')[1]?.split('&')[0] || '';
                        }
                        if (youtubeId) {
                            thumbnail = `https://img.youtube.com/vi/${youtubeId}/maxresdefault.jpg`;
                        }
                    }

                    return {
                        id: v.id,
                        title: v.title,
                        url: videoUrl,
                        thumbnail,
                        category: videoType === 'youtube' ? 'YouTube' : 'Video'
                    };
                });
                setVideos(parsed);
            }
            setLoading(false);
        };
        fetchVideos();
    }, []);

    return (
        <div className="rehab-view-p">
            <header className="page-header-p">
                <button className="back-btn-p" onClick={() => navigate(-1)}>
                    <ChevronLeft size={28} />
                </button>
                <div className="header-text-p">
                    <h1>Educational Resources</h1>
                    <p>Handpicked resources for your respiratory care</p>
                </div>
            </header>

            <div className="rehab-scroll-area">
                {loading ? (
                    <div className="rehab-loading-state">
                        <div className="loader-ios"></div>
                        <p>Fetching resources...</p>
                    </div>
                ) : videos.length === 0 ? (
                    <div className="empty-rehab-p">
                        <div className="empty-circle-p">📺</div>
                        <h3>No videos available</h3>
                        <p>Your doctor hasn't posted any rehab videos yet.</p>
                    </div>
                ) : (
                    <div className="video-list-premium">
                        {videos.map((video, idx) => (
                            <div
                                key={video.id}
                                className="video-card-premium btn-press"
                                style={{ animationDelay: `${idx * 0.1}s` }}
                                onClick={() => window.open(video.url, '_blank')}
                            >
                                <div className="video-preview-box">
                                    <img src={video.thumbnail} alt={video.title} />
                                    <div className="play-button-overlay">
                                        <Play size={24} fill="currentColor" />
                                    </div>
                                    <div className="video-duration-pill">Video</div>
                                </div>
                                <div className="video-details-p">
                                    <div className="v-main-info">
                                        <h3>{video.title}</h3>
                                        <div className="v-meta-row">
                                            <span className="v-brand">Video</span>
                                            <span className="v-dot">•</span>
                                            <span>Suggested</span>
                                        </div>
                                    </div>
                                    <button className="btn-save-p" onClick={(e) => e.stopPropagation()}>
                                        <Star size={18} />
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
};

export default PulmonaryRehab;
