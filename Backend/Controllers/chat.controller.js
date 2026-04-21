const response = require('../utils/response.util');
const ChatService = require('../services/chat.service');

class ChatController {

    /**
     * Create or get existing chat with another user
     */
    async createOrGetChat(req, res) {
        try {
            const currentUserId = req.user.id;
            const { other_user_id } = req.body;

            if (!other_user_id) {
                return response.ErrorResponse(res, 'other_user_id is required', null, 400);
            }

            const result = await ChatService.createOrGetChat(currentUserId, other_user_id);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error in createOrGetChat:', error);
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Get chat by ID
     */
    async getChatById(req, res) {
        try {
            const { chatId } = req.params;
            const currentUserId = req.user.id;

            // Security check: Verify user is participant
            const isParticipant = await ChatService.isUserInChat(chatId, currentUserId);
            if (!isParticipant) {
                return response.ErrorResponse(res, 'Access denied: You are not a participant in this chat', null, 403);
            }

            const result = await ChatService.getChatById(chatId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error in getChatById:', error);
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Get all chats for current user
     */
    async getUserChats(req, res) {
        try {
            const userId = req.user.id;
            const limit = parseInt(req.query.limit) || 10;
            const offset = parseInt(req.query.offset) || 0;

            const result = await ChatService.getUserChats(userId, limit, offset);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error in getUserChats:', error);
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Send a message in a chat
     */
    async sendMessage(req, res) {
        try {
            const { chatId } = req.params;
            const currentUserId = req.user.id;
            const { content } = req.body;

            if (!content) {
                return response.ErrorResponse(res, 'Message content is required', null, 400);
            }

            // Security check: Verify user is participant
            const isParticipant = await ChatService.isUserInChat(chatId, currentUserId);
            if (!isParticipant) {
                return response.ErrorResponse(res, 'Access denied: You are not a participant in this chat', null, 403);
            }

            const result = await ChatService.sendMessage(chatId, currentUserId, content);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 201);
        } catch (error) {
            console.error('Error in sendMessage:', error);
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Get messages for a chat
     */
    async getChatMessages(req, res) {
        try {
            const { chatId } = req.params;
            const currentUserId = req.user.id;
            const limit = parseInt(req.query.limit) || 50;
            const offset = parseInt(req.query.offset) || 0;

            // Security check: Verify user is participant
            const isParticipant = await ChatService.isUserInChat(chatId, currentUserId);
            if (!isParticipant) {
                return response.ErrorResponse(res, 'Access denied: You are not a participant in this chat', null, 403);
            }

            const result = await ChatService.getChatMessages(chatId, limit, offset);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error in getChatMessages:', error);
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Get chat between current user and another user
     */
    async getChatWithUser(req, res) {
        try {
            const currentUserId = req.user.id;
            const { otherUserId } = req.params;

            const result = await ChatService.getChatBetweenUsers(currentUserId, otherUserId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error in getChatWithUser:', error);
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Delete a chat
     */
    async deleteChat(req, res) {
        try {
            const { chatId } = req.params;
            const currentUserId = req.user.id;

            // Security check: Verify user is participant
            const isParticipant = await ChatService.isUserInChat(chatId, currentUserId);
            if (!isParticipant) {
                return response.ErrorResponse(res, 'Access denied: You are not a participant in this chat', null, 403);
            }

            const result = await ChatService.deleteChat(chatId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, null, 200);
        } catch (error) {
            console.error('Error in deleteChat:', error);
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }
}

module.exports = new ChatController();
