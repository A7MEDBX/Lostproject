const { body } = require('express-validator');

const createReportValidator = [
    body('reported_user_id')
        .notEmpty().withMessage('Reported user ID is required')
        .isUUID(4).withMessage('Reported user ID must be a valid UUID'),
    body('reason')
        .notEmpty().withMessage('Reason is required')
        .isString().withMessage('Reason must be a string')
        .isLength({ min: 10, max: 1000 }).withMessage('Reason must be between 10 and 1000 characters')
];

const updateReportStatusValidator = [
    body('status')
        .notEmpty().withMessage('Status is required')
        .isIn(['pending', 'reviewed', 'resolved']).withMessage('Status must be pending, reviewed, or resolved')
];

module.exports = {
    createReportValidator,
    updateReportStatusValidator
};
