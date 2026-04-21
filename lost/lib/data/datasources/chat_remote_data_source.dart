import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/chat_message_model.dart';

/// Remote Data Source for Chat operations
abstract class ChatRemoteDataSource {
  Future<String> startChat({
    required String otherUserId,
  });

  Future<List<ChatMessageModel>> getChatMessages(String chatId);

  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
  });

  Future<void> markAsRead(String chatId, String userId);
}

/// Implementation of ChatRemoteDataSource
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> startChat({
    required String otherUserId,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.createChatEndpoint,
        body: {'other_user_id': otherUserId},
      );
      return response['id'] as String; // Assuming backend returns chat object with 'id'
    } catch (e) {
      throw ServerException('Failed to start chat: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatMessages(String chatId) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.chatEndpoint}/$chatId/messages',
      );
      final List<dynamic> messagesJson = response['messages'] as List<dynamic>? ?? [];
      return messagesJson
          .map(
            (json) => ChatMessageModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw ServerException('Failed to get chat messages: $e');
    }
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
  }) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.chatEndpoint}/$chatId/send',
        body: {'content': message},
      );
      return ChatMessageModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to send message: $e');
    }
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await apiClient.post(
        '${ApiConstants.chatEndpoint}/$chatId/read',
        body: {'user_id': userId},
      );
    } catch (e) {
      throw ServerException('Failed to mark as read: $e');
    }
  }
}
