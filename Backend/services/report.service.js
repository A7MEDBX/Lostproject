const reportRepo = require('../Repository/report.repo');
const userRepo = require('../Repository/user.repo');

class ReportService {
    async createReport(reporter_id, reported_user_id, reason) {
        if (reporter_id === reported_user_id) {
            throw new Error('You cannot report yourself');
        }

        const reportedUser = await userRepo.getUserById(reported_user_id);
        if (!reportedUser) {
            throw new Error('Reported user not found');
        }

        const existingReport = await reportRepo.checkDuplicateReport(reporter_id, reported_user_id);
        if (existingReport) {
            throw new Error('You have already reported this user and it is pending review');
        }

        const report = await reportRepo.createReport({
            reporter_id,
            reported_user_id,
            reason
        });

        return report;
    }

    async getReportById(id) {
        const report = await reportRepo.getReportById(id);
        if (!report) {
            throw new Error('Report not found');
        }
        return report;
    }

    async getAllReports(limit, offset, status) {
        const parsedLimit = parseInt(limit) || 10;
        const parsedOffset = parseInt(offset) || 0;
        
        const reports = await reportRepo.getAllReports(parsedLimit, parsedOffset, status);
        
        return {
            total_items: reports.count,
            reports: reports.rows,
            current_page: Math.floor(parsedOffset / parsedLimit) + 1,
            total_pages: Math.ceil(reports.count / parsedLimit)
        };
    }

    async updateReportStatus(id, status) {
        const report = await reportRepo.getReportById(id);
        if (!report) {
            throw new Error('Report not found');
        }

        const [updatedRows, [updatedReport]] = await reportRepo.updateReportStatus(id, status);
        if (updatedRows === 0) {
            throw new Error('Failed to update report status');
        }
        
        return updatedReport || { ...report.toJSON(), status };
    }
}

module.exports = new ReportService();
