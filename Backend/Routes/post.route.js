const { verfyFirebaseToken } = require('../Middlewares/auth.middleware');
const { requireAuthentication, requireVerification } = require('../Middlewares/isVerfied.middleware');
const { createPostValidator } = require('../validators/post.validator');
const validate = require('../Middlewares/validation');
const postController = require('../Controllers/post.controller');
const {uploadToCloudinary,uploadMiddleware} = require('../Middlewares/multer.middleware');
const express = require('express');
const Router = express.Router();

// Apply auth to all routes
Router.use(verfyFirebaseToken);
Router.use(requireAuthentication); // All routes need authentication

/**
 * @route   POST /api/v1/post/create
 * @desc    Create a new lost or found post
 * @access  Private (requires verified identity)
 * @body    multipart/form-data - image, type, category, location fields
 */
Router.post('/create',
    requireVerification,
    uploadMiddleware,
    uploadToCloudinary,
    createPostValidator,
    validate,
    postController.createPost
);

/**
 * @route   GET /api/v1/post/my-posts
 * @desc    Get all posts created by current user
 * @access  Private (requires verified identity)
 * @query   ?limit=10&offset=0
 */
Router.get('/my-posts', requireVerification, postController.getMyPosts);

/**
 * @route   GET /api/v1/post
 * @desc    Browse all posts with optional filters
 * @access  Private (requires authentication only)
 * @query   ?type=lost&category=electronics&country=USA&state=CA&city=LA&limit=10&offset=0
 */
Router.get('/', postController.getAllPosts);

/**
 * @route   GET /api/v1/post/:id
 * @desc    Get single post details by ID
 * @access  Private (requires authentication only)
 */
Router.get('/:id', postController.getPostById);

/**
 * @route   PUT /api/v1/post/:id
 * @desc    Update own post
 * @access  Private (requires verified identity, post owner only)
 * @body    Post update data
 */
Router.put('/:id',
    requireVerification,
    createPostValidator,
    validate,
    postController.updatePost
);

/**
 * @route   DELETE /api/v1/post/:id
 * @desc    Delete own post
 * @access  Private (requires verified identity, post owner only)
 */
Router.delete('/:id', requireVerification, postController.deletePost);

/**
 * @route   PATCH /api/v1/post/:id/status
 * @desc    Update post status (e.g., mark as resolved)
 * @access  Private (requires verified identity, post owner only)
 * @body    { status: string }
 */
Router.patch('/:id/status', requireVerification, postController.updatePostStatus);

module.exports = Router;
