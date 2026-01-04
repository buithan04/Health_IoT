// HealthAI_Server/tests/api.test.js
const request = require('supertest');
const express = require('express');
const cors = require('cors');

// Mock app setup (simplified version)
const app = express();
app.use(cors());
app.use(express.json());

// Mock routes
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Server is running' });
});

app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password required' });
    }

    // Mock successful login
    if (email === 'test@example.com' && password === 'password123') {
        return res.json({
            token: 'mock_jwt_token',
            user: {
                id: 1,
                email: 'test@example.com',
                fullName: 'Test User'
            }
        });
    }

    return res.status(401).json({ error: 'Invalid credentials' });
});

app.get('/api/users/profile', (req, res) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized' });
    }

    // Mock profile response
    res.json({
        id: 1,
        email: 'test@example.com',
        fullName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg'
    });
});

describe('API Endpoint Tests', () => {
    describe('GET /api/health', () => {
        test('Should return server health status', async () => {
            const response = await request(app).get('/api/health');

            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('status', 'ok');
            expect(response.body).toHaveProperty('message');
        });
    });

    describe('POST /api/auth/login', () => {
        test('Should login successfully with valid credentials', async () => {
            const response = await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'test@example.com',
                    password: 'password123'
                });

            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('token');
            expect(response.body).toHaveProperty('user');
            expect(response.body.user.email).toBe('test@example.com');
        });

        test('Should fail with invalid credentials', async () => {
            const response = await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'wrong@example.com',
                    password: 'wrongpassword'
                });

            expect(response.status).toBe(401);
            expect(response.body).toHaveProperty('error');
        });

        test('Should fail with missing fields', async () => {
            const response = await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'test@example.com'
                });

            expect(response.status).toBe(400);
            expect(response.body).toHaveProperty('error');
        });
    });

    describe('GET /api/users/profile', () => {
        test('Should return user profile with valid token', async () => {
            const response = await request(app)
                .get('/api/users/profile')
                .set('Authorization', 'Bearer mock_token');

            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('id');
            expect(response.body).toHaveProperty('email');
            expect(response.body).toHaveProperty('fullName');
        });

        test('Should fail without authorization header', async () => {
            const response = await request(app)
                .get('/api/users/profile');

            expect(response.status).toBe(401);
        });

        test('Should fail with invalid token format', async () => {
            const response = await request(app)
                .get('/api/users/profile')
                .set('Authorization', 'InvalidToken');

            expect(response.status).toBe(401);
        });
    });
});

describe('CORS Tests', () => {
    test('Should allow cross-origin requests', async () => {
        const response = await request(app)
            .get('/api/health')
            .set('Origin', 'http://localhost:3000');

        expect(response.headers['access-control-allow-origin']).toBe('*');
    });
});

describe('Error Handling Tests', () => {
    test('Should handle 404 for unknown routes', async () => {
        const response = await request(app).get('/api/unknown/route');
        expect(response.status).toBe(404);
    });

    test('Should handle malformed JSON', async () => {
        const response = await request(app)
            .post('/api/auth/login')
            .send('invalid json')
            .set('Content-Type', 'application/json');

        expect(response.status).toBe(400);
    });
});
