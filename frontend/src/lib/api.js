// frontend/src/lib/api.js
const API_BASE = import.meta.env.PUBLIC_API_URL || 'http://localhost:8080';

export async function apiCall(endpoint, options = {}) {
    const response = await fetch(`${API_BASE}${endpoint}`, {
        headers: {
            'Content-Type': 'application/json',
            ...options.headers
        },
        ...options
    });
    return response.json();
}