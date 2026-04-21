/// API Configuration Constants
class ApiConstants {
  // Base URL - 10.0.2.2 is used for Android Emulator to connect to localhost.
  // Use 'http://localhost:3500/api/v1' for iOS Simulator or Web.
  static const String baseUrl = 'http://10.0.2.2:3500/api/v1';

  // Auth Endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';

  // User Endpoints
  static const String userProfileEndpoint = '/user/profile';

  // Post Endpoints
  static const String createPostEndpoint = '/post/create';
  static const String allPostsEndpoint = '/post/all';
  static const String myPostsEndpoint = '/post/my-posts';
  static const String postDetailEndpoint = '/post'; // Used as /post/:id

  // Matching Endpoints
  static const String searchEndpoint = '/match/find-matches';

  // Contact Request Endpoints
  static const String sendContactRequestEndpoint = '/contact-request/send';
  static const String respondContactRequestEndpoint = '/contact-request'; // /:id/respond
  static const String receivedContactRequestsEndpoint = '/contact-request/received';

  // Chat Endpoints
  static const String createChatEndpoint = '/chat/create';
  static const String myChatsEndpoint = '/chat/my-chats';
  static const String chatEndpoint = '/chat'; // Used as /chat/:id and /chat/:id/messages

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
