const { User } = require('../models');
const Chat = require('../models/Chat.model');
const Message = require('../models/Message.model');
const { Op } = require('sequelize');

class ChatRepo {

    /**
     * Create or get existing chat between two users
     * Prevents duplicate chats by sorting user IDs
     */
    async createOrGetChat(userId1, userId2) {
        try {
            // Sort user IDs to ensure consistent chat lookup
            const [user1, user2] = userId1 < userId2 ? [userId1, userId2] : [userId2, userId1];
            
            const [chat, created] = await Chat.findOrCreate({
                where: {
                    user_1: user1,
                    user_2: user2
                },
                defaults: {
                    user_1: user1,
                    user_2: user2
                }
            });
            
            return { chat, created };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Get chat by ID with user details
     */
    async getChatById(chatId) {
        try {
            return await Chat.findOne({
                where: { id: chatId },
                include: [
                    {
                        model: User,
                        as: 'firstUser',
                        attributes: ['id', 'name', 'email']
                    },
                    {
                        model: User,
                        as: 'secondUser',
                        attributes: ['id', 'name', 'email']
                    }
                ]
            });
        } catch (err) {
            throw err;
        }
    }

    /**
     * Check if user is participant in chat
     */
    async isUserInChat(chatId, userId) {
        try {
            const chat = await Chat.findOne({
                where: {
                    id: chatId,
                    [Op.or]: [
                        { user_1: userId },
                        { user_2: userId }
                    ]
                }
            });
            return !!chat;
        } catch (err) {
            throw err;
        }
    }

    /**
     * Get all chats for a user with pagination
     */
    async getUserChats(userId, limit = 10, offset = 0) {
        try {
            const result = await Chat.findAndCountAll({
                where: {
                    [Op.or]: [
                        { user_1: userId },
                        { user_2: userId }
                    ]
                },
                include: [
                    {
                        model: User,
                        as: 'firstUser',
                        attributes: ['id', 'name', 'email']
                    },
                    {
                        model: User,
                        as: 'secondUser',
                        attributes: ['id', 'name', 'email']
                    }
                ],
                limit,
                offset,
                order: [['created_at', 'DESC']]
            });
            
            return result;
        } catch (err) {
            throw err;
        }
    }

    /**
     * Send a message in a chat
     */
    async sendMessage(chatId, senderId, content) {
        try {
            return await Message.create({
                chat_id: chatId,
                sender_id: senderId,
                content
            });
        } catch (err) {
            throw err;
        }
    }

    /**
     * Get messages for a chat with pagination
     */
    async getMessagesByChatId(chatId, limit = 50, offset = 0) {
        try {
            const result = await Message.findAndCountAll({
                where: { chat_id: chatId },
                include: [
                    {
                        model: User,
                        as: 'sender',
                        attributes: ['id', 'name', 'email']
                    }
                ],
                limit,
                offset,
                order: [['created_at', 'ASC']]
            });
            
            return result;
        } catch (err) {
            throw err;
        }
    }

    /**
     * Get chat between two specific users
     */
    async getChatBetweenUsers(userId1, userId2) {
        try {
            // Sort user IDs to ensure consistent lookup
            const [user1, user2] = userId1 < userId2 ? [userId1, userId2] : [userId2, userId1];
            
            return await Chat.findOne({
                where: {
                    user_1: user1,
                    user_2: user2
                },
                include: [
                    {
                        model: User,
                        as: 'firstUser',
                        attributes: ['id', 'name', 'email']
                    },
                    {
                        model: User,
                        as: 'secondUser',
                        attributes: ['id', 'name', 'email']
                    }
                ]
            });
        } catch (err) {
            throw err;
        }
    }

    /**
     * Delete a chat and all its messages (cascade handled by DB)
     */
    async deleteChat(chatId) {
        try {
            return await Chat.destroy({
                where: { id: chatId }
            });
        } catch (err) {
            throw err;
        }
    }
}

module.exports = new ChatRepo();

