const reportService = require('../services/report.service');
const { SuccessResponse, ErrorResponse } = require('../utils/response.util');

class ReportController {
    async createReport(req, res) {
        try {
            const reporter_id = req.user.id;
            const { reported_user_id, reason } = req.body;
            const report = await reportService.createReport(reporter_id, reported_user_id, reason);
            res.status(201).json(new SuccessResponse('Report submitted successfully', report));
        } catch (error) {
            if (error.message === 'You cannot report yourself' || 
                error.message === 'Reported user not found' || 
                error.message === 'You have already reported this user and it is pending review') {
                return res.status(400).json(new ErrorResponse(error.message));
            }
            res.status(500).json(new ErrorResponse('Internal server error', [error.message]));
        }
    }

    async getReportById(req, res) {
        try {
            const report = await reportService.getReportById(req.params.id);
            res.status(200).json(new SuccessResponse('Report retrieved successfully', report));
        } catch (error) {
            if (error.message === 'Report not found') {
                return res.status(404).json(new ErrorResponse(error.message));
            }
            res.status(500).json(new ErrorResponse('Internal server error', [error.message]));
        }
    }

    async getAllReports(req, res) {
        try {
            const { limit, offset, status } = req.query;
            const data = await reportService.getAllReports(limit, offset, status);
            res.status(200).json(new SuccessResponse('Reports retrieved successfully', data));
        } catch (error) {
            res.status(500).json(new ErrorResponse('Internal server error', [error.message]));
        }
    }

    async updateReportStatus(req, res) {
        try {
            const { status } = req.body;
            const report = await reportService.updateReportStatus(req.params.id, status);
            res.status(200).json(new SuccessResponse('Report status updated successfully', report));
        } catch (error) {
            if (error.message === 'Report not found') {
                return res.status(404).json(new ErrorResponse(error.message));
            }
            res.status(500).json(new ErrorResponse('Internal server error', [error.message]));
        }
    }
}

module.exports = new ReportController();
