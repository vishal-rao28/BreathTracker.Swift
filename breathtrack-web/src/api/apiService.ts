export const BASE_URL = 'http://103.249.82.251:8080/breathtrack_%20192311084'; // Adjust this to your backend URL

export const apiCall = async (endpoint: string, method: string = 'GET', data?: any) => {
    try {
        const response = await fetch(`${BASE_URL}/${endpoint}`, {
            method,
            headers: {
                'Content-Type': 'application/json',
            },
            body: (method !== 'GET' && method !== 'HEAD' && data) ? JSON.stringify(data) : undefined,
        });
        return await response.json();
    } catch (error) {
        console.error(`API Call failed: ${endpoint}`, error);
        return { status: 'error', message: 'Connection failed. Please check if your XAMPP/Local server is running.' };
    }
};
