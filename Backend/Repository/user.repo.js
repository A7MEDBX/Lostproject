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
                if (data.verification_notes !== undefined) updateFields.verification_notes = data.verification_notes;
                
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
