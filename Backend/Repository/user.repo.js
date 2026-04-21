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

        async findUserById(id) {
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


        async edituser(userId, name){
            try{
                return await User.update(
                    { name: name },
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
    async submitVerification(userId, nationalId, phoneNumber, idImageUrl) {
        try {
            const [affectedRows] = await User.update(
                {
                    national_id: nationalId,
                    phone_number: phoneNumber,
                    id_image_url: idImageUrl,
                    verification_status: 'pending',
                    verification_submitted_at: new Date()
                },
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
                attributes: ['id', 'verification_status', 'verification_submitted_at', 'verification_reviewed_at', 'verification_notes', 'verified']
            });
            return user;
        } catch (error) {
            throw error;
        }
    }

    /**
     * Get all pending verifications (admin)
     */
    async getPendingVerifications(limit = 50, offset = 0) {
        try {
            const result = await User.findAndCountAll({
                where: { verification_status: 'pending' },
                attributes: ['id', 'name', 'email', 'national_id', 'phone_number', 'id_image_url', 'verification_submitted_at'],
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
            const [affectedRows] = await User.update(
                {
                    verification_status: 'approved',
                    verified: true,
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
