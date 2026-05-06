import 'package:flutter/foundation.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_all_posts.dart';
import '../../core/errors/failures.dart';

/// Provider for managing posts state
class PostProvider with ChangeNotifier {
  final GetAllPostsUseCase getAllPostsUseCase;

  PostProvider({required this.getAllPostsUseCase});

  // State
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool _hasActiveFilters = false;

  // Getters
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveFilters => _hasActiveFilters;

  // Load all posts
  Future<void> loadPosts({
    String? postType,
    String? category,
    String? country,
    String? city,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    
    // Check if any filter is actually active
    _hasActiveFilters = (postType != null && postType.isNotEmpty) ||
                        (category != null && category.isNotEmpty && category != 'All Categories') ||
                        (country != null && country.isNotEmpty) ||
                        (city != null && city.isNotEmpty);

    notifyListeners();

    final result = await getAllPostsUseCase(
      postType: postType,
      category: category == 'All Categories' ? null : category,
      country: country,
      city: city,
    );

    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
      },
      (posts) {
        _isLoading = false;
        _posts = posts;
        notifyListeners();
      },
    );
  }

  // Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error. Please try again later.';
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Unexpected error occurred.';
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
