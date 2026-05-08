const ChatRepo = require('../Repository/chat.repo');

class ChatService {

    /**
     * Create or get existing chat between current user and another user
     */
    async createOrGetChat(currentUserId, otherUserId) {
        try {
            // Validate user IDs
            if (!otherUserId || currentUserId === otherUserId) {
                return {
                    success: false,
                    message: 'Cannot create chat with yourself or invalid user'
                };
            }

            const result = await ChatRepo.createOrGetChat(currentUserId, otherUserId);
            
            return {
                success: true,
                message: result.created ? 'Chat created successfully' : 'Chat already exists',
                data: result.chat,
                isNew: result.created
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Get chat by ID (with security check done in controller/middleware)
     */
    async getChatById(chatId) {
        try {
            const chat = await ChatRepo.getChatById(chatId);
            
            if (!chat) {
                return {
                    success: false,
                    message: 'Chat not found'
                };
            }
            
            return {
                success: true,
                message: 'Chat retrieved successfully',
                data: chat
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Get all chats for a user — returns flat objects with other_user_name resolved
     */
    async getUserChats(userId, limit = 10, offset = 0) {
        try {
            const result = await ChatRepo.getUserChats(userId, limit, offset);

            // Map each chat: determine which user is "the other one"
            const mapped = result.rows.map(chat => {
                const raw = chat.toJSON ? chat.toJSON() : chat;
                const isUser1 = raw.user_1 === userId;
                const otherUser = isUser1 ? raw.secondUser : raw.firstUser;

                return {
                    id: raw.id,
                    other_user_id: otherUser?.id || null,
                    other_user_name: otherUser?.name || 'Unknown',
                    other_user_email: otherUser?.email || null,
                    last_message: raw.last_message || null,
                    updated_at: raw.updated_at || raw.created_at,
                    unread_count: raw.unread_count || 0,
                    is_online: false, // real-time status handled by socket.io
                };
            });

            return {
                success: true,
                message: 'Chats retrieved successfully',
                data: mapped,
                pagination: {
                    total: result.count,
                    limit,
                    offset,
                    hasMore: offset + limit < result.count
                }
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Send a message in a chat (security check done in controller/middleware)
     */
    async sendMessage(chatId, senderId, content) {
        try {
            // Validate content
            if (!content || content.trim().length === 0) {
                return {
                    success: false,
                    message: 'Message content cannot be empty'
                };
            }

            const message = await ChatRepo.sendMessage(chatId, senderId, content.trim());
            
            return {
                success: true,
                message: 'Message sent successfully',
                data: message
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Get messages for a chat (security check done in controller/middleware)
     */
    async getChatMessages(chatId, limit = 50, offset = 0) {
        try {
            const result = await ChatRepo.getMessagesByChatId(chatId, limit, offset);
            
            return {
                success: true,
                message: 'Messages retrieved successfully',
                data: result.rows,
                pagination: {
                    total: result.count,
                    limit,
                    offset,
                    hasMore: offset + limit < result.count
                }
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Get chat between two users
     */
    async getChatBetweenUsers(userId1, userId2) {
        try {
            const chat = await ChatRepo.getChatBetweenUsers(userId1, userId2);
            
            if (!chat) {
                return {
                    success: false,
                    message: 'No chat found between these users'
                };
            }
            
            return {
                success: true,
                message: 'Chat found',
                data: chat
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Delete a chat (security check done in controller/middleware)
     */
    async deleteChat(chatId) {
        try {
            const result = await ChatRepo.deleteChat(chatId);
            
            if (result === 0) {
                return {
                    success: false,
                    message: 'Chat not found'
                };
            }
            
            return {
                success: true,
                message: 'Chat deleted successfully'
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Check if user is participant in chat
     */
    async isUserInChat(chatId, userId) {
        try {
            return await ChatRepo.isUserInChat(chatId, userId);
        } catch (err) {
            throw err;
        }
    }
}

module.exports = new ChatService();
