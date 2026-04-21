import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/post_model.dart';
import '../models/search_result_model.dart';

/// Remote Data Source for Post operations
abstract class PostRemoteDataSource {
  Future<PostModel> createPost({
    required String title,
    required String description,
    required String category,
    required String postType,
    required String imagePath,
    required String country,
    String? state,
    String? city,
    double? latitude,
    double? longitude,
  });

  Future<PostModel> getPostById(String postId);
  Future<List<PostModel>> getAllPosts();
  Future<List<PostModel>> getUserPosts(String userId);
  Future<List<SearchResultModel>> searchByImage({
    required String imagePath,
    required String type,
    required String country,
    required String city,
    String? category,
    String? state,
    double? latitude,
    double? longitude,
  });
  Future<PostModel> updatePost(PostModel post);
  Future<void> deletePost(String postId);
}

/// Implementation of PostRemoteDataSource
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient apiClient;

  PostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PostModel> createPost({
    required String title,
    required String description,
    required String category,
    required String postType,
    required String imagePath,
    required String country,
    String? state,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final fields = <String, String>{
        'title': title,
        'description': description,
        'category': category,
        'post_type': postType,
        'country': country,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final response = await apiClient.postMultipart(
        ApiConstants.createPostEndpoint,
        filePath: imagePath,
        fields: fields,
      );

      return PostModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create post: $e');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.postDetailEndpoint}/$postId',
      );
      return PostModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to get post: $e');
    }
  }

  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final response = await apiClient.get(ApiConstants.allPostsEndpoint);
      final List<dynamic> postsJson = response['posts'] as List<dynamic>;
      return postsJson
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      // The backend /post/my-posts relies on the auth token.
      final response = await apiClient.get(ApiConstants.myPostsEndpoint);
      final List<dynamic> postsJson = response['posts'] as List<dynamic>;
      return postsJson
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user posts: $e');
    }
  }

  @override
  Future<List<SearchResultModel>> searchByImage({
    required String imagePath,
    required String type,
    required String country,
    required String city,
    String? category,
    String? state,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final fields = <String, String>{
        'type': type,
        'country': country,
        'city': city,
        if (category != null) 'category': category,
        if (state != null) 'state': state,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final response = await apiClient.postMultipart(
        ApiConstants.searchEndpoint,
        filePath: imagePath,
        fields: fields,
      );

      final List<dynamic> resultsJson = response['matches'] as List<dynamic>? ?? [];
      return resultsJson
          .map(
            (json) => SearchResultModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw ServerException('Failed to search by image: $e');
    }
  }

  @override
  Future<PostModel> updatePost(PostModel post) async {
    try {
      final response = await apiClient.put(
        '${ApiConstants.postDetailEndpoint}/${post.id}',
        body: post.toJson(),
      );
      return PostModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await apiClient.delete('${ApiConstants.postDetailEndpoint}/$postId');
    } catch (e) {
      throw ServerException('Failed to delete post: $e');
    }
  }
}
