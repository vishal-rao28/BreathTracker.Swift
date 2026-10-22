import React, { createContext, useContext, useState } from 'react';
import { apiCall } from '../api/apiService';

interface User {
    id: string;
    name: string;
    email?: string;
    role: 'patient' | 'doctor';
    details?: any;
}

interface AuthContextType {
    user: User | null;
    login: (credentials: { id: string; password: string; role: 'patient' | 'doctor' }) => Promise<{ success: boolean; message: string }>;
    logout: () => void;
    isAuthenticated: boolean;
    updateUser: (newData: Partial<User>) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [user, setUser] = useState<User | null>(() => {
        const savedUser = localStorage.getItem('bt_session');
        return savedUser ? JSON.parse(savedUser) : null;
    });

    const login = async (credentials: { id: string; password: string; role: 'patient' | 'doctor' }) => {
        const endpoint = credentials.role === 'patient' ? 'patient_login.php' : 'doctor_login.php';
        const payload = credentials.role === 'patient'
            ? { patient_id: credentials.id, password: credentials.password }
            : { doctor_id: credentials.id, password: credentials.password };

        const response = await apiCall(endpoint, 'POST', payload);

        if (response.status === 'success') {
            const userData: User = {
                id: credentials.id,
                name: response.name,
                role: credentials.role,
                details: response
            };
            setUser(userData);
            localStorage.setItem('bt_session', JSON.stringify(userData));
            return { success: true, message: 'Login successful' };
        } else {
            return { success: false, message: response.message || 'Login failed' };
        }
    };

    const logout = () => {
        setUser(null);
        localStorage.removeItem('bt_session');
    };

    const updateUser = (newData: Partial<User>) => {
        if (!user) return;
        const updated = { ...user, ...newData };
        setUser(updated);
        localStorage.setItem('bt_session', JSON.stringify(updated));
    };

    const isAuthenticated = !!user;

    return (
        <AuthContext.Provider value={{ user, login, logout, isAuthenticated, updateUser }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (context === undefined) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};
