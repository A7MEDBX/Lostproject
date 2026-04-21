const Post = require('../models/post.model');
const User = require('../models/User.model');
const { Op } = require('sequelize'); 
class PostRepository {

    async getUserPosts(userId) {
        try {
            return await Post.findAll({
                where: { user_id: userId },
                order: [['created_at', 'DESC']]
            });
        } catch (error) {
            throw error;
        }
    }

    async getPostById(postId) {
        try {
            return await Post.findByPk(postId, {
                include: { model: User, as: 'owner', attributes: ['id', 'name', 'email'] }
            });
        } catch (error) {
            throw error;
        }
    }

    async getAllActivePosts(limit = 50, offset = 0) {
        try {
            return await Post.findAndCountAll({
                where: { status: 'active' },
                order: [['created_at', 'DESC']],
                limit: limit,
                offset: offset,
                include: { model: User, as: 'owner', attributes: ['id', 'name'] }
            });
        } catch (error) {
            throw error;
        }
    }
    async getPostsByIds(ids){
        try{
            return await Post.findAll({
                where:{id:{
                    [Op.in]: ids
                }},
                include:{
                    model:User,
                    as:'owner',
                    attributes:['id','name','verified']
                }
            });
        } catch (error){
            throw error;
        }
    }
        
    
    // Get posts with dynamic filters
    async getFilteredPosts(filters) {
     
        const { type, country,state, city, category, status, userId, limit, offset, latitude, longitude } = filters;
        
        try {
            // Build WHERE clause dynamically
            const whereClause = {};
            
            // Always filter by status (default 'active')
            whereClause.status = status || 'active';
            
            // Add filters only if provided
            if (type) whereClause.post_type = type;
            if (category) whereClause.category = { [Op.iLike]: `%${category}%` };
            if (userId) whereClause.user_id = userId;
            if(country) whereClause.country = { [Op.iLike]: `%${country}%` };
            if(state) whereClause.state = { [Op.iLike]: `%${state}%` };
            if(city) whereClause.city = { [Op.iLike]: `%${city}%` };
            // Note: latitude/longitude removed from SQL filters (used for distance calculation in service)
           
            return await Post.findAndCountAll({
                where: whereClause,
                order: [['created_at', 'DESC']],
                limit: limit || 50,
                offset: offset || 0,
                include: { 
                    model: User, 
                    as: 'owner', 
                    attributes: ['id', 'name', 'trust_score', 'verified'] 
                }
            });
        } catch (error) {
            throw error;
        }
    }

    async createPost(data) {
        try {
            return await Post.create(data);
        } catch (err) {
            throw err;
        }
    }

    async updatePost(userid, postid, data) {
        try {
            const allowedUpdates = {};
            
            if (data.title) allowedUpdates.title = data.title;
            if (data.description !== undefined) allowedUpdates.description = data.description; 
            if (data.category) allowedUpdates.category = data.category;
            if (data.country) allowedUpdates.country = data.country;
            if (data.state) allowedUpdates.state = data.state;
            if (data.city) allowedUpdates.city = data.city;
            if (data.latitude) allowedUpdates.latitude = data.latitude;
            if (data.longitude) allowedUpdates.longitude = data.longitude;

            return await Post.update(
                allowedUpdates,
                { 
                    where: { 
                        id: postid,
                        user_id:userid
                    } 
                }
            );
        } catch (error) {
            throw error;
        }
    }
    async getPostsByType(postType, limit = 50, offset = 0) {
    try {
        return await Post.findAndCountAll({
            where: { 
                post_type: postType,
                status: 'active'
            },
            order: [['created_at', 'DESC']],
            limit: limit,
            offset: offset,
            include: { model: User, as: 'owner', attributes: ['id', 'name'] }
        });
    } catch (error) {
        throw error;
    }
}

    async adminUpdatePost(postid, data) {
    try {
        const allowedUpdates = {};
        
        if (data.title) allowedUpdates.title = data.title;
        if (data.description !== undefined) allowedUpdates.description = data.description; 
        if (data.category) allowedUpdates.category = data.category;
        if (data.status) allowedUpdates.status = data.status; 
        if(data.country) allowedUpdates.country = data.country;
        if(data.state) allowedUpdates.state = data.state;
        if(data.city) allowedUpdates.city = data.city;
        if(data.latitude) allowedUpdates.latitude = data.latitude;
        if(data.longitude) allowedUpdates.longitude = data.longitude;
        return await Post.update(
            allowedUpdates,
            { where: { id: postid } } 
        );
    } catch (error) {
        throw error;
    }
}
    async adminDeletePost(postId) {
    try {
        return await Post.destroy({
            where: { id: postId }  // No user_id check
        });
    } catch (error) {
        throw error;
    }
}
    async updatePostStatus(postId, newStatus) {
        try {
            return await Post.update(
                { status: newStatus },
                { where: { id: postId } }
            );
        } catch (error) {
            throw error;
        }
    }

    /**
     * Update vector_id after Pinecone storage
     */
    async updateVectorId(postId, vectorId) {
        try {
            return await Post.update(
                { vector_id: vectorId },
                { where: { id: postId } }
            );
        } catch (error) {
            throw error;
        }
    }

    async deletePost(userid, postId) {
        try {
            return await Post.destroy({
                where: {
                    user_id: userid,
                    id: postId
                }
            });
        } catch (error) {
            throw error;
        }
    }
}

module.exports = new PostRepository();