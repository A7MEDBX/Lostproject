const { Report, User } = require('../models');

class ReportRepository {
    async createReport(data) {
        return await Report.create(data);
    }

    async getReportById(id) {
        return await Report.findByPk(id, {
            include: [
                { model: User, as: 'reporter', attributes: ['id', 'name', 'email'] },
                { model: User, as: 'reportedUser', attributes: ['id', 'name', 'email'] }
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
                { model: User, as: 'reportedUser', attributes: ['id', 'name', 'email'] }
            ]
        });
    }

    async updateReportStatus(id, status) {
        return await Report.update({ status }, {
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
