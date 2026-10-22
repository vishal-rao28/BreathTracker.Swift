import React, { createContext, useContext, useState } from 'react';

interface CheckupData {
    temperature?: number;
    oxygen_level?: number;
    lung_function?: number;
}

interface CheckupContextType {
    data: CheckupData;
    updateData: (newData: Partial<CheckupData>) => void;
    resetData: () => void;
}

const CheckupContext = createContext<CheckupContextType | undefined>(undefined);

export const CheckupProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [data, setData] = useState<CheckupData>({});

    const updateData = (newData: Partial<CheckupData>) => {
        setData(prev => ({ ...prev, ...newData }));
    };

    const resetData = () => setData({});

    return (
        <CheckupContext.Provider value={{ data, updateData, resetData }}>
            {children}
        </CheckupContext.Provider>
    );
};

export const useCheckup = () => {
    const context = useContext(CheckupContext);
    if (!context) throw new Error('useCheckup must be used within CheckupProvider');
    return context;
};
