const PostService = require('../services/post.service');
const response = require('../utils/response.util');

class PostController {

    // Create a new post
    async createPost(req, res) {
        try {
            const userId = req.user.id; // Database UUID, not firebase_uid
            const postData = req.body;

            const result = await PostService.createPost(userId, postData);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 201);
        } catch (error) {
            console.error('Error creating post:', error);
            return response.ErrorResponse(res, error.message, null, 400);
        }
    }

    // Get all posts by logged-in user
    async getMyPosts(req, res) {
        try {
            const userId = req.user.id; // Database UUID
            const result = await PostService.getUserPosts(userId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error getting posts:', error);
            return response.ErrorResponse(res, error.message, null, 500);
        }
    }

    // Get a specific post by ID
    async getPostById(req, res) {
        try {
            const { postId } = req.params;
            const result = await PostService.getPostById(postId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error getting post:', error);
            return response.ErrorResponse(res, error.message, null, 404);
        }
    }

    // Get all posts with dynamic filtering via query parameters
    // Example: GET /api/posts?type=lost&location=Cairo&category=Electronics&limit=20
    async getAllPosts(req, res) {
        try {
            // Extract query parameters
            const {
                type,           // 'lost' or 'found'
                category,       // Search string
                status,         // 'active', 'matched', 'resolved'
                userId,
                country,         // Filter by specific user
                state,
                city,
                latitude,
                longitude,
                limit = 50,
                offset = 0
            } = req.query;

            // Build filter object
            const filters = {
                type,
                country,
                state,
                city,
                latitude,
                longitude,
                category,
                status: status || 'active', // Default to active
                userId,
                limit: parseInt(limit),
                offset: parseInt(offset)
            };

            const result = await PostService.getFilteredPosts(filters);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error getting posts:', error);
            return response.ErrorResponse(res, error.message, null, 500);
        }
    }

    // Get posts by type (lost or found)
  
    // Update user's post
    async updatePost(req, res) {
        try {
            const userId = req.user.id; // Database UUID
            const { postId } = req.params;
            const updateData = req.body;

            const result = await PostService.updateUserPost(userId, postId, updateData);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, null, 200);
        } catch (error) {
            console.error('Error updating post:', error);
            return response.ErrorResponse(res, error.message, null, 400);
        }
    }

    // Delete user's post
    async deletePost(req, res) {
        try {
            const userId = req.user.id; // Database UUID
            const { postId } = req.params;

            const result = await PostService.deleteUserPost(userId, postId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, null, 200);
        } catch (error) {
            console.error('Error deleting post:', error);
            return response.ErrorResponse(res, error.message, null, 400);
        }
    }

    // Update post status
    async updatePostStatus(req, res) {
        try {
            const { postId } = req.params;
            const { status } = req.body;

            const result = await PostService.updatePostStatus(postId, status);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 200);
        } catch (error) {
            console.error('Error updating status:', error);
            return response.ErrorResponse(res, error.message, null, 400);
        }
    }
}

module.exports = new PostController();
