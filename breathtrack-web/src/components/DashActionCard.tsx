import React from 'react';
import { ChevronRight } from 'lucide-react';
import { motion } from 'framer-motion';
import './DashActionCard.css';

interface DashActionCardProps {
    title: string;
    subtitle: string;
    icon: React.ReactNode;
    gradient: string;
    size?: 'large' | 'small';
    onClick?: () => void;
    index?: number;
}

const DashActionCard: React.FC<DashActionCardProps> = ({
    title,
    subtitle,
    icon,
    gradient,
    size = 'small',
    onClick,
    index = 0,
}) => {
    return (
        <motion.div
            className={`dash-action-card ${size} btn-press`}
            onClick={onClick}
            style={{ background: gradient }}
            initial={{ opacity: 0, scale: 0.88, y: 18 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            transition={{
                type: 'spring',
                damping: 15,
                stiffness: 100,
                delay: index * 0.1,
            }}
        >
            <div className="card-overlay">
                <div className="circle-decor circle-1"></div>
                <div className="circle-decor circle-2"></div>
            </div>

            <div className="card-content">
                <div className="icon-box">
                    {icon}
                </div>
                <div className="text-box">
                    <h3 className="card-title">{title}</h3>
                    <p className="card-subtitle">{subtitle}</p>
                </div>
                <ChevronRight className="chevron" size={24} />
            </div>
        </motion.div>
    );
};

export default DashActionCard;
