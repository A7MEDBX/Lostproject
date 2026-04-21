const response = require('../utils/response.util');
const UserService = require('../services/user.service');
const PostService = require('../services/post.service');

class AdminController {

    /**
     * Get all users with pagination
     */
    async getAllUsers(req, res) {
        try {
            const limit = parseInt(req.query.limit) || 50;
            const offset = parseInt(req.query.offset) || 0;

            const result = await UserService.getAllUsers(limit, offset);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Get specific user by ID
     */
    async getUserById(req, res) {
        try {
            const { userId } = req.params;
            const result = await UserService.getUserById(userId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Delete any user (admin privilege)
     */
    async deleteUser(req, res) {
        try {
            const { userId } = req.params;
            const result = await UserService.adminDeleteUser(userId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, null, 200);
        } catch (error) {
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Update any post (admin privilege)
     */
    async updatePost(req, res) {
        try {
            const { postId } = req.params;
            const updateData = req.body;

            const result = await PostService.adminUpdatePost(postId, updateData);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, null, 200);
        } catch (error) {
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Delete any post (admin privilege)
     */
    async deletePost(req, res) {
        try {
            const { postId } = req.params;
            const result = await PostService.adminDeletePost(postId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, null, 200);
        } catch (error) {
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Get all pending identity verifications
     */
    async getPendingVerifications(req, res) {
        try {
            const limit = parseInt(req.query.limit) || 50;
            const offset = parseInt(req.query.offset) || 0;

            const result = await UserService.getPendingVerifications(limit, offset);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Approve identity verification
     */
    async approveVerification(req, res) {
        try {
            const { userId } = req.params;
            const { notes } = req.body;

            const result = await UserService.approveVerification(userId, notes);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, null, 200);
        } catch (error) {
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }

    /**
     * Reject identity verification
     */
    async rejectVerification(req, res) {
        try {
            const { userId } = req.params;
            const { notes } = req.body;

            const result = await UserService.rejectVerification(userId, notes);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, null, 200);
        } catch (error) {
            return response.ErrorResponse(res, 'Server Error', error.message, 500);
        }
    }
}

module.exports = new AdminController();