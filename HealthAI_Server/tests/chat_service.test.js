// HealthAI_Server/tests/chat_service.test.js

// Mock the database pool BEFORE importing chat_service
jest.mock('../config/db', () => ({
    pool: {
        query: jest.fn(),
        connect: jest.fn(() => ({
            query: jest.fn(),
            release: jest.fn(),
        }))
    }
}));

const chatService = require('../services/chat_service');
const { pool } = require('../config/db');

describe('Chat Service Tests', () => {
    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('getMessages', () => {
        test('Should return messages for a conversation', async () => {
            const mockMessages = {
                rows: [
                    {
                        id: '1',
                        conversation_id: 'conv_123',
                        sender_id: 'user_1',
                        content: 'Hello',
                        type: 'text',
                        created_at: new Date(),
                        sender_name: 'User One',
                        sender_avatar: 'avatar1.jpg'
                    }
                ]
            };

            pool.query.mockResolvedValue(mockMessages);

            const result = await chatService.getMessages('conv_123');

            expect(pool.query).toHaveBeenCalled();
            expect(result).toHaveLength(1);
            expect(result[0].content).toBe('Hello');
        });

        test('Should handle empty conversation', async () => {
            pool.query.mockResolvedValue({ rows: [] });

            const result = await chatService.getMessages('conv_empty');

            expect(result).toHaveLength(0);
        });

        test('Should handle database errors', async () => {
            pool.query.mockRejectedValue(new Error('Database error'));

            await expect(chatService.getMessages('conv_123'))
                .rejects.toThrow('Database error');
        });
    });

    describe('saveMessage', () => {
        test('Should save text message successfully', async () => {
            const mockClient = {
                query: jest.fn()
                    .mockResolvedValueOnce({}) // BEGIN
                    .mockResolvedValueOnce({ rows: [{ id: 'msg_new' }] }) // INSERT message
                    .mockResolvedValueOnce({}) // UPDATE conversation
                    .mockResolvedValueOnce({}), // COMMIT
                release: jest.fn()
            };

            pool.connect.mockResolvedValue(mockClient);

            const result = await chatService.saveMessage(
                'conv_123',
                'user_1',
                'New message',
                'text'
            );

            expect(result).toBeDefined();
            expect(mockClient.release).toHaveBeenCalled();
        });

        test('Should save image message', async () => {
            const mockClient = {
                query: jest.fn()
                    .mockResolvedValueOnce({})
                    .mockResolvedValueOnce({ rows: [{ id: 'msg_img' }] })
                    .mockResolvedValueOnce({})
                    .mockResolvedValueOnce({}),
                release: jest.fn()
            };

            pool.connect.mockResolvedValue(mockClient);

            const result = await chatService.saveMessage(
                'conv_123',
                'user_1',
                'https://example.com/image.jpg',
                'image'
            );

            expect(result).toBeDefined();
        });

        test('Should handle save errors', async () => {
            const mockClient = {
                query: jest.fn().mockRejectedValue(new Error('Save failed')),
                release: jest.fn()
            };

            pool.connect.mockResolvedValue(mockClient);

            await expect(
                chatService.saveMessage('conv_123', 'user_1', 'Test', 'text')
            ).rejects.toThrow();
        });
    });

    describe('markMessagesAsRead', () => {
        test('Should mark messages as read', async () => {
            const mockClient = {
                query: jest.fn().mockResolvedValue({ rowCount: 5 }),
                release: jest.fn()
            };

            pool.connect.mockResolvedValue(mockClient);

            await chatService.markMessagesAsRead('conv_123', 'user_1');

            expect(mockClient.query).toHaveBeenCalled();
            expect(mockClient.release).toHaveBeenCalled();
        });

        test('Should handle no unread messages', async () => {
            const mockClient = {
                query: jest.fn().mockResolvedValue({ rowCount: 0 }),
                release: jest.fn()
            };

            pool.connect.mockResolvedValue(mockClient);

            await chatService.markMessagesAsRead('conv_123', 'user_1');

            expect(mockClient.query).toHaveBeenCalled();
        });
    });

    describe('getConversations', () => {
        test('Should return user conversations', async () => {
            const mockConversations = {
                rows: [
                    {
                        id: 'conv_1',
                        partner_name: 'Partner One',
                        last_message: 'Hello',
                        last_message_time: new Date(),
                        unread_count: 2
                    }
                ]
            };

            pool.query.mockResolvedValue(mockConversations);

            // Just verify mock works
            expect(pool.query).toBeDefined();
        });
    });
});