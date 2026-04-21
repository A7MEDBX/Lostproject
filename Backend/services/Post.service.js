const PostRepo = require('../Repository/post.repo');
const AIService = require('../config/ai.config');
const pineconeIndex = require('../config/pinecone.config');

class PostService {

    /**
     * Create a new post with image embedding
     */
    async createPost(userId, postData) {
        try {
            // Validate required fields
            if (!postData.title || !postData.post_type || !postData.image_url) {
                return {
                    success: false,
                    message: 'Title, post type, and image are required'
                };
            }

            // Validate post_type enum
            if (!['lost', 'found'].includes(postData.post_type)) {
                return {
                    success: false,
                    message: 'Post type must be either "lost" or "found"'
                };
            }

            // Prepare data for database
            const data = {
                user_id: userId,
                title: postData.title,
                post_type: postData.post_type,
                country: postData.country,
                state: postData.state|| null,
                city: postData.city|| null,
                description: postData.description || null,
                category: postData.category || null,
                latitude:postData.latitude || null,
                longitude:postData.longitude || null,
                image_url: postData.image_url,
                status: 'active',
                vector_id: null
            };

            // Create post in database
            const newPost = await PostRepo.createPost(data);

            // Generate and store embedding asynchronously (don't block response)
            this.processEmbedding(newPost).catch(error => {
                console.error(`Failed to process embedding for post ${newPost.id}:`, error.message);
                // TODO: Add to retry queue
            });

            return {
                success: true,
                message: 'Post created successfully',
                data: newPost
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Generate embedding and store in Pinecone + Update Supabase
     * @private
     */
    async processEmbedding(post) {
        try {
            console.log(`Processing embedding for post ${post.id}`);
            
            // Generate 512-dimensional vector using CLIP
            const embedding = await AIService.generateEmbedding(post.image_url);
            
            // Store vector in Pinecone
            await pineconeIndex.upsert([{
                id: post.id,
                values: embedding,
                metadata: {
                    user_id: post.user_id,
                    post_type: post.post_type,
                    category: post.category || '',
                    country: post.country,
                    state: post.state || '',
                    city: post.city || '',
                    lat: post.latitude || null,
                    lng: post.longitude || null,
                    status: post.status,
                    created_at: post.created_at.toISOString()
                }
            }]);

            console.log(`Vector stored in Pinecone: ${post.id}`);
            
            // Update Supabase with vector_id
            await PostRepo.updateVectorId(post.id, post.id);
            
            console.log(`Supabase updated with vector_id: ${post.id}`);
            
        } catch (error) {
            console.error(`Embedding processing failed for post ${post.id}:`, error);
            throw error;
        }
    }

    // Get all posts by a specific user
    async getUserPosts(userId) {
        try {
            const posts = await PostRepo.getUserPosts(userId);
            
            return {
                success: true,
                message: 'User posts retrieved successfully',
                data: posts,
                count: posts.length
            };
        } catch (err) {
            throw err;
        }
    }

    // Get a single post by ID
    async getPostById(postId) {
        try {
            const post = await PostRepo.getPostById(postId);
            
            if (!post) {
                return {
                    success: false,
                    message: 'Post not found'
                };
            }
            
            return {
                success: true,
                message: 'Post retrieved successfully',
                data: post
            };
        } catch (err) {
            throw err;
        }
    }

    // Get all active posts (for browse page)
    async getAllActivePosts(limit = 50, offset = 0) {
        try {
            const result = await PostRepo.getAllActivePosts(limit, offset);
            
            return {
                success: true,
                message: 'Active posts retrieved successfully',
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
     * Get posts with dynamic filters
     */
    async  getFilteredPosts(filters) {
        try {
            const { type, country, state, city, category, status, userId, limit, offset, latitude, longitude } = filters;
            
            // Validate type if provided
            if (type && !['lost', 'found'].includes(type)) {
                return {
                    success: false,
                    message: 'Post type must be either "lost" or "found"'
                };
            }

            // Validate status if provided
            if (status && !['active', 'matched', 'closed', 'resolved'].includes(status)) {
                return {
                    success: false,
                    message: 'Invalid status value'
                };
            }
            
            const result = await PostRepo.getFilteredPosts({
                type,
                country,
                state,
                city,
                 latitude,
                 longitude,
                category,
                status: status || 'active',
                userId,
                limit: parseInt(limit) || 50,
                offset: parseInt(offset) || 0
            });
            
            return {
                success: true,
                message: 'Filtered posts retrieved successfully',
                data: result.rows,
                pagination: {
                    total: result.count,
                    limit: parseInt(limit) || 50,
                    offset: parseInt(offset) || 0,
                    hasMore: (parseInt(offset) || 0) + (parseInt(limit) || 50) < result.count
                }
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Update user's own post
     */
    async updateUserPost(userId, postId, updateData) {
        try {
            // Check ownership
            const post = await PostRepo.getPostById(postId);
            if (!post) {
                return {
                    success: false,
                    message: 'Post not found'
                };
            }

            if (post.user_id !== userId) {
                return {
                    success: false,
                    message: 'Unauthorized: You can only edit your own posts'
                };
            }

            const result = await PostRepo.updatePost(userId, postId, updateData);
            
            if (result[0] === 0) {
                return {
                    success: false,
                    message: 'Post not found or no changes made'
                };
            }

            return {
                success: true,
                message: 'Post updated successfully'
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Delete user's own post
     */
    async deleteUserPost(userId, postId) {
        try {
            // Check ownership
            const post = await PostRepo.getPostById(postId);
            if (!post) {
                return {
                    success: false,
                    message: 'Post not found'
                };
            }

            if (post.user_id !== userId) {
                return {
                    success: false,
                    message: 'Unauthorized: You can only delete your own posts'
                };
            }

            // Delete from Supabase
            const result = await PostRepo.deletePost(userId, postId);
          
            if (result === 0) {
                return {
                    success: false,
                    message: 'Post not found'
                };
            }

            // Delete vector from Pinecone if exists
            if (post.vector_id) {
                try {
                    await pineconeIndex.deleteOne(post.vector_id);
                    console.log(`Deleted vector from Pinecone: ${post.vector_id}`);
                } catch (error) {
                    console.error(`Failed to delete vector from Pinecone: ${error.message}`);
                }
            }

            return {
                success: true,
                message: 'Post deleted successfully'
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Update post status
     */
    async updatePostStatus(postId, status) {
        try {
            // Validate status
            if (!['active', 'matched', 'closed', 'resolved'].includes(status)) {
                return {
                    success: false,
                    message: 'Invalid status value'
                };
            }

            const post = await PostRepo.getPostById(postId);
            if (!post) {
                return {
                    success: false,
                    message: 'Post not found'
                };
            }

            const result = await PostRepo.updatePostStatus(postId, status);
            
            if (result[0] === 0) {
                return {
                    success: false,
                    message: 'Failed to update status'
                };
            }

            return {
                success: true,
                message: 'Status updated successfully',
                data: { status }
            };
        } catch (err) {
            throw err;
        }
    }

    // ========== ADMIN METHODS ==========

    /**
     * Admin: Update any post (no ownership check, role verified by middleware)
     */
    async adminUpdatePost(postId, updateData) {
        try {
            const post = await PostRepo.getPostById(postId);
            if (!post) {
                return {
                    success: false,
                    message: 'Post not found'
                };
            }

            const result = await PostRepo.adminUpdatePost(postId, updateData);
            
            if (result[0] === 0) {
                return {
                    success: false,
                    message: 'No changes made'
                };
            }

            return {
                success: true,
                message: 'Post updated by admin'
            };
        } catch (err) {
            throw err;
        }
    }

    /**
     * Admin: Delete any post (no ownership check, role verified by middleware)
     */
    async adminDeletePost(postId) {
        try {
            const post = await PostRepo.getPostById(postId);
            if (!post) {
                return {
                    success: false,
                    message: 'Post not found'
                };
            }

            // Delete from Supabase
            const result = await PostRepo.adminDeletePost(postId);
            
            if (result === 0) {
                return {
                    success: false,
                    message: 'Post not found'
                };
            }
         
            // Delete vector from Pinecone if exists
            if (post.vector_id) {
                try {
                    await pineconeIndex.deleteOne(post.vector_id);
                    console.log(`Admin deleted vector from Pinecone: ${post.vector_id}`);
                } catch (error) {
                    console.error(`Failed to delete vector from Pinecone: ${error.message}`);
                }
            }

            return {
                success: true,
                message: 'Post deleted by admin'
            };
        } catch (err) {
            throw err;
        }
    }
}

module.exports = new PostService();
