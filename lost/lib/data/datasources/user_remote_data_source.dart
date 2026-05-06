import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for user-related backend endpoints.
abstract class UserRemoteDataSource {
  /// GET /user/me — fetch the currently authenticated backend user.
  Future<UserModel> fetchMe();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> fetchMe() async {
    try {
      final response = await apiClient.get(ApiConstants.userProfileEndpoint);
      // Backend returns: { success: true, data: { ...user } }
      final data = response['data'];
      if (data == null) {
        throw ServerException('Empty response from /user/me');
      }
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch user profile: $e');
    }
  }
}
