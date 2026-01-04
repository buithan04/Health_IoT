export const API_BASE_URL = 'http://localhost:5000/api';

export async function apiCall(endpoint: string, method = 'GET', data: any = null) {
  // In a real app, you'd get the token from a secure storage or context
  // For now, we'll assume it's stored in localStorage if we were client-side
  // But since this might run server-side, we need to be careful.
  // For this migration, let's assume client-side fetching for simplicity or handle it later.
  
  let authToken = '';
  if (typeof window !== 'undefined') {
    authToken = localStorage.getItem('adminToken') || sessionStorage.getItem('adminToken') || '';
  }

  const options: RequestInit = {
    method,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${authToken}`
    }
  };

  if (data && method !== 'GET') {
    options.body = JSON.stringify(data);
  }

  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, options);

    if (response.status === 401 || response.status === 403) {
      // Handle unauthorized
      if (typeof window !== 'undefined') {
         window.location.href = '/auth/login';
      }
      return null;
    }

    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.error || result.message || 'Có lỗi xảy ra');
    }

    return result;
  } catch (error: any) {
    console.error('API Error:', error);
    throw error;
  }
}
