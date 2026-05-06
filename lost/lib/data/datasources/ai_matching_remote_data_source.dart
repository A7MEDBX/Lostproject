import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_constants.dart';

class AIMatchingRemoteDataSource {
  final http.Client client;
  final Future<String?> Function()? tokenProvider;

  AIMatchingRemoteDataSource({required this.client, this.tokenProvider});

  Future<Map<String, String>> _buildAuthHeaders() async {
    final token = await tokenProvider?.call();
    if (token == null || token.isEmpty) {
      return {};
    }
    return {'Authorization': 'Bearer $token'};
  }

  /// Check if backend is available
  Future<bool> checkHealth() async {
    try {
        final response = await client
            .get(
              Uri.parse('${ApiConstants.baseUrl}${ApiConstants.healthEndpoint}'),
              headers: await _buildAuthHeaders(),
            )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }

  /// Create post with AI matching
  Future<Map<String, dynamic>> createPostWithMatching({
    required File image,
    required String title,
    required String description,
    required String category,
    required String country,
    required String state,
    required String city,
    required String postType,
    double? latitude,
    double? longitude,
  }) async {
    try {
        final url =
          '${ApiConstants.baseUrl}${ApiConstants.createPostEndpoint}';
      print('🌐 API URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await _buildAuthHeaders());

      print('📷 Adding image file: ${image.path}');
      // Add image file
      var imageFile = await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: image.path.split('/').last,
      );
      request.files.add(imageFile);

      // Add form fields
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['country'] = country;
      request.fields['state'] = state;
      request.fields['city'] = city;
      request.fields['post_type'] = postType;

      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }

      print('📤 Sending request to backend...');
      // Send request with timeout (60 seconds for CPU processing)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      print('📥 Received response, status: ${streamedResponse.statusCode}');
      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('✅ Success! Response body: ${response.body}');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ Error response: ${response.body}');
        final error = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? error['error'] ?? 'Failed to create post');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Get all posts
  Future<List<Map<String, dynamic>>> getAllPosts({
    String? type,
    String? category,
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.allPostsEndpoint}');

      // Add query parameters
      Map<String, String> queryParams = {};
      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

          final response = await client
            .get(uri, headers: await _buildAuthHeaders())
            .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to fetch posts');
      }
    } catch (e) {
      throw Exception('Error fetching posts: ${e.toString()}');
    }
  }

  /// Get single post by ID
  Future<Map<String, dynamic>> getPostById(String postId) async {
    try {
      final response = await client
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}${ApiConstants.postDetailEndpoint}/$postId',
            ),
            headers: await _buildAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final payload = json.decode(response.body) as Map<String, dynamic>;
        return payload['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error fetching post: ${e.toString()}');
    }
  }
}
