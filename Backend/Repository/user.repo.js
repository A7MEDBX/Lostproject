const User = require('../models/User.model');
class userdb {

        async findUserBy_firbase_id(firebaseId){
            try {
                return await User.findOne({where:{firebase_uid: firebaseId}});
            } catch (error) {
                throw error;
            }
        }

        async createuser(firebaseId, name, email){
            try {
                return await User.create({
                    firebase_uid: firebaseId,
                    name: name,
                    email: email,
                });
            } catch (error) {
                throw error;
            }
        }

        async getUserById(id) {
            try {
                return await User.findByPk(id);
            } catch (error) {
                throw error;
            }
        }

        async getAllUsers(limit = 10, offset = 0) {
            try {
                return await User.findAndCountAll({
                    limit: limit,
                    offset: offset,
                    order: [['created_at', 'DESC']]
                });
            } catch (error) {
                throw error;
            }
    }


        async edituser(userId, data){
            try{
                const updateFields = {};
                if (data.name) updateFields.name = data.name;
                if (data.email) updateFields.email = data.email;
                if (data.role) updateFields.role = data.role;
                if (data.status) updateFields.status = data.status;
                if (data.verified !== undefined) updateFields.verified = data.verified;
                if (data.trust_score !== undefined) updateFields.trust_score = data.trust_score;
                if (data.verification_status) updateFields.verification_status = data.verification_status;
                if (data.national_id !== undefined) updateFields.national_id = data.national_id;
                if (data.phone) updateFields.phone_number = data.phone;
                if (data.phone_number) updateFields.phone_number = data.phone_number;
                if (data.country) updateFields.country = data.country;
                if (data.state) updateFields.state = data.state;
                if (data.city) updateFields.city = data.city;
                if (data.area) updateFields.area = data.area;
                if (data.profile_image_url) updateFields.profile_image_url = data.profile_image_url;
                if (data.selfie_image_url) updateFields.selfie_image_url = data.selfie_image_url;
                if (data.verification_location) updateFields.verification_location = data.verification_location;
                if (data.verification_notes !== undefined) updateFields.verification_notes = data.verification_notes;
                if (data.moderation_reason !== undefined) {
                    updateFields.moderation_reason = data.moderation_reason;
                    updateFields.moderated_at = new Date();
                }
                
                return await User.update(
                    updateFields,
                    { where: { id: userId } }
                );
            } catch (error) {
                throw error;
            }
        }
        async deletuser(userId){
            try{
                return await User.destroy({
                    where: { id: userId }
                });
            } catch (error) {
                throw error;
            }
        }

    /**
     * Submit verification documents
     */
    async submitVerification(userId, nationalId, phoneNumber, idImageUrl, selfieImageUrl = null, location = null) {
        try {
            const updateData = {
                national_id: nationalId,
                phone_number: phoneNumber,
                id_image_url: idImageUrl,
                verification_status: 'pending',
                verification_submitted_at: new Date()
            };

            if (selfieImageUrl) updateData.selfie_image_url = selfieImageUrl;
            if (location) updateData.verification_location = location;

            const [affectedRows] = await User.update(
                updateData,
                { where: { id: userId } }
            );
            return affectedRows;
        } catch (error) {
            throw error;
        }
    }

    /**
     * Get verification status for a user
     */
    async getVerificationStatus(userId) {
        try {
            const user = await User.findByPk(userId, {
                attributes: ['id', 'verification_status', 'verification_submitted_at', 'verification_reviewed_at', 'verification_notes', 'verified', 'selfie_image_url', 'id_image_url', 'verification_location']
            });
            return user;
        } catch (error) {
            throw error;
        }
    }

    /**
     * Get verifications by status (admin)
     */
    async getVerifications(status, limit = 50, offset = 0) {
        try {
            const sequelize = require('../db/Sequelize');
            const whereClause = {};
            if (status && status !== 'all') {
                whereClause.verification_status = status;
            } else {
                // Default to showing everything that HAS a submission
                const { Op } = require('sequelize');
                whereClause.verification_status = { [Op.ne]: 'not_submitted' };
            }

            const result = await User.findAndCountAll({
                where: whereClause,
                attributes: [
                    'id', 
                    'name', 
                    'email', 
                    'national_id', 
                    'phone_number', 
                    'id_image_url', 
                    'selfie_image_url', 
                    'profile_image_url',
                    'verification_location', 
                    'verification_submitted_at', 
                    'verification_reviewed_at',
                    'verification_status',
                    'verification_notes',
                    'trust_score',
                    'status',
                    'created_at',
                    [
                        sequelize.literal(`(
                            SELECT COUNT(*)
                            FROM reports AS report
                            WHERE
                                report.reported_user_id = users.id
                        )`),
                        'reports_count'
                    ]
                ],
                limit,
                offset,
                order: [['verification_submitted_at', 'DESC']]
            });
            return result;
        } catch (error) {
            throw error;
        }
    }

    /**
     * Get all pending verifications (admin)
     */
    async getPendingVerifications(limit = 50, offset = 0) {
        try {
            const sequelize = require('../db/Sequelize');
            const result = await User.findAndCountAll({
                where: { verification_status: 'pending' },
                attributes: [
                    'id', 
                    'name', 
                    'email', 
                    'national_id', 
                    'phone_number', 
                    'id_image_url', 
                    'selfie_image_url', 
                    'profile_image_url',
                    'verification_location', 
                    'verification_submitted_at', 
                    'trust_score',
                    'status',
                    'created_at',
                    [
                        sequelize.literal(`(
                            SELECT COUNT(*)
                            FROM reports AS report
                            WHERE
                                report.reported_user_id = users.id
                        )`),
                        'reports_count'
                    ]
                ],
                limit,
                offset,
                order: [['verification_submitted_at', 'ASC']]
            });
            return result;
        } catch (error) {
            throw error;
        }
    }

    /**
     * Approve verification (admin)
     */
    async approveVerification(userId, adminNotes = null) {
        try {
            // First get the user to increment trust score safely
            const user = await User.findByPk(userId);
            if (!user) return 0;
            
            const newTrustScore = user.trust_score + 10.0;

            const [affectedRows] = await User.update(
                {
                    verification_status: 'approved',
                    verified: true,
                    trust_score: newTrustScore,
                    verification_reviewed_at: new Date(),
                    verification_notes: adminNotes
                },
                { where: { id: userId } }
            );
            return affectedRows;
        } catch (error) {
            throw error;
        }
    }

    /**
     * Reject verification (admin)
     */
    async rejectVerification(userId, adminNotes) {
        try {
            const [affectedRows] = await User.update(
                {
                    verification_status: 'rejected',
                    verified: false,
                    verification_reviewed_at: new Date(),
                    verification_notes: adminNotes
                },
                { where: { id: userId } }
            );
            return affectedRows;
        } catch (error) {
            throw error;
        }
    }
}
module.exports = new userdb();
