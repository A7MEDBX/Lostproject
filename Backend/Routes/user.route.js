const authController = require('../Controllers/auth.controller');
const UserController = require('../Controllers/User.controller');
const {verfyFirebaseToken} = require('../Middlewares/auth.middleware');
const { requireAuthentication } = require('../Middlewares/isVerfied.middleware');
const { createUserValidator } = require('../validators/user.validator');
const { submitVerificationValidator } = require('../validators/verification.validator');
const validate = require('../Middlewares/validation');
const express =require('express');
const Router = express.Router();

Router.use(verfyFirebaseToken);
Router.use(requireAuthentication); 

/**
 * @route   POST /api/v1/user/login
 * @desc    Login or register user after Firebase authentication
 * @access  Public (requires Firebase token)
 * @body    { name, email }
 */
Router.post('/login',
      createUserValidator, 
      validate,
       authController.login);

/**
 * @route   GET /api/v1/user/me
 * @desc    Get current user profile
 * @access  Private (requires authentication)
 */
Router.get('/me',      
       UserController.getprofile);

/**
 * @route   PUT /api/v1/user/me
 * @desc    Update current user profile
 * @access  Private (requires authentication)
 * @body    { name }
 */
Router.put('/me',
       createUserValidator,
       validate,
       UserController.editprofile);

/**
 * @route   DELETE /api/v1/user/me
 * @desc    Delete current user account
 * @access  Private (requires authentication)
 */
Router.delete('/me',
       UserController.deleteprofile);

/**
 * @route   POST /api/v1/user/verification/submit
 * @desc    Submit identity verification documents
 * @access  Private (requires authentication)
 * @body    { national_id, phone_number, id_image_url }
 */
Router.post('/verification/submit',
    submitVerificationValidator,
    validate,
    UserController.submitVerification);

/**
 * @route   GET /api/v1/user/verification/status
 * @desc    Get current user's verification status
 * @access  Private (requires authentication)
 */
Router.get('/verification/status', UserController.getVerificationStatus);

       module.exports=Router;
