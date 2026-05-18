const { Report, User, Post } = require('../models');

class ReportRepository {
    async createReport(data) {
        return await Report.create(data);
    }

    async getReportById(id) {
        return await Report.findByPk(id, {
            include: [
                { model: User, as: 'reporter', attributes: ['id', 'name', 'email'] },
                { model: User, as: 'reportedUser', attributes: ['id', 'name', 'email'] },
                { model: Post, as: 'reportedPost', attributes: ['id', 'title', 'post_type', 'status', 'moderation_status'] }
            ]
        });
    }

    async getAllReports(limit, offset, status) {
        const whereClause = status ? { status } : {};
        return await Report.findAndCountAll({
            where: whereClause,
            limit,
            offset,
            order: [['created_at', 'DESC']],
            include: [
                { model: User, as: 'reporter', attributes: ['id', 'name', 'email'] },
                { model: User, as: 'reportedUser', attributes: ['id', 'name', 'email'] },
                { model: Post, as: 'reportedPost', attributes: ['id', 'title', 'post_type', 'status', 'moderation_status'] }
            ]
        });
    }

    async updateReportStatus(id, status) {
        return await Report.update({ status }, {
            where: { id },
            returning: true
        });
    }

    async updateReport(id, data) {
        const allowedUpdates = {};
        if (data.status) allowedUpdates.status = data.status;
        if (data.reason) allowedUpdates.reason = data.reason;
        if (data.note !== undefined) allowedUpdates.note = data.note;

        return await Report.update(allowedUpdates, {
            where: { id },
            returning: true
        });
    }

    async checkDuplicateReport(reporter_id, target) {
        return await Report.findOne({
            where: {
                reporter_id,
                ...target,
                status: 'pending'
            }
        });
    }
}

module.exports = new ReportRepository();
