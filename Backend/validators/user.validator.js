const { body } = require('express-validator');

exports.createUserValidator = [
    body('name')
        .notEmpty().withMessage('Name is required')
        .trim()
        .isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters')
        .matches(/^[a-zA-Z\s]+$/).withMessage('Name can only contain letters and spaces'),
    
    body('email')
        .notEmpty().withMessage('Email is required')
        .trim()
        .isEmail().withMessage('Invalid email format')
        .normalizeEmail()
];
