import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_endpoints.dart';

class SocketService {
  IO.Socket? _socket;
  String? _authToken;

  // Set the auth token which should be retrieved from Firebase Auth
  void setAuthToken(String token) {
    _authToken = token;
  }

  void connect() {
    if (_authToken == null) {
      print('SocketService Error: Cannot connect without auth token');
      return;
    }

    _socket = IO.io(
      ApiEndpoints.baseUrl.replaceAll('/api/v1', ''), // Socket connects to root, not api/v1
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': _authToken}) // Pass token to backend socket middleware
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to Socket.io Server');
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from Socket.io Server');
    });

    _socket!.onError((data) {
      print('Socket Error: $data');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  void joinChat(String chatId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_chat', {'chatId': chatId});
    }
  }

  void leaveChat(String chatId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave_chat', {'chatId': chatId});
    }
  }

  void sendMessage(String chatId, String content) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_message', {'chatId': chatId, 'content': content});
    }
  }

  void sendTypingStart(String chatId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing_start', {'chatId': chatId});
    }
  }

  void sendTypingStop(String chatId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing_stop', {'chatId': chatId});
    }
  }

  void markMessageRead(String chatId, String messageId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('message_read', {'chatId': chatId, 'messageId': messageId});
    }
  }

  // Listeners
  void onNewMessage(Function(dynamic) callback) {
    _socket?.on('new_message', callback);
  }

  void onUserTyping(Function(dynamic) callback) {
    _socket?.on('user_typing', callback);
  }

  void onUserStoppedTyping(Function(dynamic) callback) {
    _socket?.on('user_stopped_typing', callback);
  }

  void onMessageRead(Function(dynamic) callback) {
    _socket?.on('message_read', callback);
  }

  void onUserStatus(Function(dynamic) callback) {
    _socket?.on('user_status', callback);
  }

  void onError(Function(dynamic) callback) {
    _socket?.on('error', callback);
  }

  // Dispose listeners
  void removeListeners() {
    _socket?.off('new_message');
    _socket?.off('user_typing');
    _socket?.off('user_stopped_typing');
    _socket?.off('message_read');
    _socket?.off('user_status');
    _socket?.off('error');
  }
}
