module.exports = (io, socket) => {
    // When a user connects, join their own user room
    socket.join(`user:${socket.user.id}`);
    
    // Broadcast status to their connections (can be enhanced to check actual connections)
    io.emit('user_status', { userId: socket.user.id, status: 'online' });

    socket.on('disconnect', () => {
        io.emit('user_status', { userId: socket.user.id, status: 'offline' });
    });
};