const admin = require('../config/firebase.config');
const response = require('../utils/response.util');
const UserRepo = require('../Repository/user.repo');

const verfyFirebaseToken = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split('Bearer ')[1];
        
        if (!token) {
            return response.ErrorResponse(res, 'No token provided', null, 401);
        }

        // Verify Firebase token
        const decodedToken = await admin.auth().verifyIdToken(token);
        
        // Get user from database to include role
        const user = await UserRepo.findUserBy_firbase_id(decodedToken.uid);
        
        if (!user) {
            return response.ErrorResponse(res, 'User not found', null, 404);
        }

        // Attach user info to request (including role)
        req.user = {
            firebase_uid: decodedToken.uid,
            email: decodedToken.email,
            id: user.id,           // Supabase user ID
            role: user.role        // Important: Include role for isAdmin middleware
        };

        next();
    } catch (error) {
        console.error('Token verification error:', error);
        return response.ErrorResponse(res, 'Invalid or expired token', error.message, 401);
    }
};

module.exports = { verfyFirebaseToken };