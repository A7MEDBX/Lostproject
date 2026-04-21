const express = require('express');
const Router = express.Router();
const adminController = require('../Controllers/admin.controller');
const { verfyFirebaseToken } = require('../Middlewares/auth.middleware');
const isAdmin = require('../Middlewares/isAdmin.middleware');
const { verificationResponseValidator } = require('../validators/verification.validator');
const validate = require('../Middlewares/validation');

// Apply authentication and admin check to ALL routes
Router.use(verfyFirebaseToken);
Router.use(isAdmin);

/**
 * @route   GET /api/v1/admin/users
 * @desc    Get all users with pagination
 * @access  Admin only
 * @query   ?limit=50&offset=0
 */
Router.get('/users', adminController.getAllUsers);

/**
 * @route   GET /api/v1/admin/users/:userId
 * @desc    Get specific user details by ID
 * @access  Admin only
 */
Router.get('/users/:userId', adminController.getUserById);

/**
 * @route   DELETE /api/v1/admin/users/:userId
 * @desc    Delete any user account (admin privilege)
 * @access  Admin only
 */
Router.delete('/users/:userId', adminController.deleteUser);

/**
 * @route   PUT /api/v1/admin/posts/:postId
 * @desc    Update any post (admin privilege)
 * @access  Admin only
 * @body    Post update data
 */
Router.put('/posts/:postId', adminController.updatePost);

/**
 * @route   DELETE /api/v1/admin/posts/:postId
 * @desc    Delete any post (admin privilege)
 * @access  Admin only
 */
Router.delete('/posts/:postId', adminController.deletePost);

/**
 * @route   GET /api/v1/admin/verifications/pending
 * @desc    Get all pending identity verifications
 * @access  Admin only
 * @query   ?limit=50&offset=0
 */
Router.get('/verifications/pending', adminController.getPendingVerifications);

/**
 * @route   POST /api/v1/admin/verifications/:userId/approve
 * @desc    Approve user's identity verification
 * @access  Admin only
 * @body    { notes?: string }
 */
Router.post('/verifications/:userId/approve',
    verificationResponseValidator,
    validate,
    adminController.approveVerification);

/**
 * @route   POST /api/v1/admin/verifications/:userId/reject
 * @desc    Reject user's identity verification
 * @access  Admin only
 * @body    { notes: string } (required)
 */
Router.post('/verifications/:userId/reject',
    verificationResponseValidator,
    validate,
    adminController.rejectVerification);

module.exports = Router;