class ApiEndpoints {
  // Backend base URL
  // For Android Emulator: use 'http://10.0.2.2:5000' or your PC's IP
  // For iOS Simulator: use 'http://localhost:5000'
  // For Real Device: use your computer's IP address (e.g., 'http://192.168.1.100:5000')
  //   To find your IP: Open CMD and type 'ipconfig', look for IPv4 Address

  static const String baseUrl =
      'http://192.168.1.6:5000'; // Using PC's actual IP address

  // API endpoints
  static const String health = '/api/health';
  static const String createPostWithMatching =
      '/api/posts/create-with-matching';
  static const String getPosts = '/api/posts';
  static String getPostById(String id) => '/api/posts/$id';
}
