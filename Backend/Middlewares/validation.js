const { validationResult } = require('express-validator');
const response = require('../utils/response.util'); // Reuse your response util

const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        // Return only the first error message or the array, up to you
        return response.ErrorResponse(res, 'Validation Error', errors.array(), 422);
    }
    next();
};

module.exports = validate;