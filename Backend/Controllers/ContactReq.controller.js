const contactReqService = require('../services/contact_req.service');
const response = require('../utils/response.util');

class ContactReqController {
    async sendContactRequest(req, res) {
        try {
            const sender_id = req.user.id; // Database UUID, not firebase_uid
            const { receiver_id, post_id } = req.body;

            if (!receiver_id || !post_id) {
                return response.ErrorResponse(res, 'receiver_id and post_id are required', null, 400);
            }

            const result = await contactReqService.sendRequest(sender_id, receiver_id, post_id);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, result.data, 409);
            }

            return response.Success(res, result.message, result.data, 201);
        }
        catch(err) {
            console.error('Error in sendContactRequest:', err);
            return response.ErrorResponse(res, 'Internal Server Error', err.message, 500);
        }
    }
    async getContactRequests(req, res) {
        try {
            const receiver_id = req.user.id; // Database UUID
            const limit = parseInt(req.query.limit) || 10;
            const offset = parseInt(req.query.offset) || 0;
            
            const result = await contactReqService.getMyReceivedRequests(receiver_id, limit, offset);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message || 'Received requests retrieved', result.data, 200);
        }
        catch(err) {
            console.error('Error in getContactRequests:', err);
            return response.ErrorResponse(res, 'Internal Server Error', err.message, 500);
        }
    }
    async getSentRequests(req, res) {
        try {
            const sender_id = req.user.id; // Database UUID
            const limit = parseInt(req.query.limit) || 10;
            const offset = parseInt(req.query.offset) || 0;
            
            const result = await contactReqService.getMySentRequests(sender_id, limit, offset);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message || 'Sent requests retrieved', result.data, 200);
        }
        catch(err) {
            console.error('Error in getSentRequests:', err);
            return response.ErrorResponse(res, 'Internal Server Error', err.message, 500);
        }
    }
    async respondToRequest(req, res) {
        try {
            const requestId = req.params.requestId;
            const { status } = req.body;
            const receiver_id = req.user.id; // Database UUID
            
            if (!status) {
                return response.ErrorResponse(res, 'Status is required', null, 400);
            }
            
            const result = await contactReqService.respondToRequest(requestId, status, receiver_id);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, result.data, 200);
        }
        catch(err) {
            console.error('Error in respondToRequest:', err);
            return response.ErrorResponse(res, 'Internal Server Error', err.message, 500);
        }
    }
    async cancelRequest(req, res) {
        try {
            const requestId = req.params.requestId;
            const sender_id = req.user.id; // Database UUID
            
            const result = await contactReqService.cancelRequest(requestId, sender_id);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 400);
            }
            
            return response.Success(res, result.message, null, 200);
        }
        catch(err) {
            console.error('Error in cancelRequest:', err);
            return response.ErrorResponse(res, 'Internal Server Error', err.message, 500);
        }
    }
    async checkRequestStatus(req, res) {
        try {
            const user_id = req.user.id; // Database UUID
            const postId = req.params.postId;
            
            const result = await contactReqService.checkRequestStatus(user_id, postId);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, result.message, result.data, 200);
        }
        catch(err) {
            console.error('Error in checkRequestStatus:', err);
            return response.ErrorResponse(res, 'Internal Server Error', err.message, 500);
        }
    }
    async getPendingRequestsForPost(req, res) {
        try {
            const postId = req.params.postId;
            const receiver_id = req.user.id; // Database UUID
            
            const result = await contactReqService.getPendingRequestsForPost(postId, receiver_id);
            
            if (!result.success) {
                return response.ErrorResponse(res, result.message, null, 404);
            }
            
            return response.Success(res, 'Pending requests retrieved', result.data, 200);
        }
        catch(err) {
            console.error('Error in getPendingRequestsForPost:', err);
            return response.ErrorResponse(res, 'Internal Server Error', err.message, 500);
        }
    }
}

module.exports = new ContactReqController();
