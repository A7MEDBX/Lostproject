const chatService = require('../../services/chat.service');

module.exports = (io, socket) => {
    socket.on('join_chat', async ({ chatId }) => {
        try {
            const isParticipant = await chatService.isUserInChat(chatId, socket.user.id);
            if (!isParticipant) {
                return socket.emit('error', { message: 'Not authorized to join this chat' });
            }
            socket.join(`chat:${chatId}`);
        } catch (error) {
            socket.emit('error', { message: error.message });
        }
    });

    socket.on('send_message', async ({ chatId, content }) => {
        try {
            const isParticipant = await chatService.isUserInChat(chatId, socket.user.id);
            if (!isParticipant) {
                return socket.emit('error', { message: 'Not authorized to send messages in this chat' });
            }

            const result = await chatService.sendMessage(chatId, socket.user.id, content);
            if (result.success) {
                io.to(`chat:${chatId}`).emit('new_message', result.data);
            } else {
                socket.emit('error', { message: result.message });
            }
        } catch (error) {
            socket.emit('error', { message: error.message });
        }
    });

    socket.on('leave_chat', ({ chatId }) => {
        socket.leave(`chat:${chatId}`);
    });
};