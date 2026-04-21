const { DataTypes } = require('sequelize');
const sequelize = require('../db/Sequelize');

const Message = sequelize.define('messages', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
        allowNull: false
    },
    chat_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'chats',
            key: 'id'
        },
        onDelete: 'CASCADE'
    },
    sender_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'users',
            key: 'id'
        },
        onDelete: 'CASCADE'
    },
    content: {
        type: DataTypes.TEXT,
        allowNull: false
    }
}, {
    tableName: 'messages',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false
});

module.exports = Message;
