import 'package:flutter/foundation.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../domain/entities/user.dart';

/// Manages the currently authenticated backend user across the app.
///
/// Call [loadUser] right after login/signup to populate [backendUser].
/// Call [clear] on logout so the next user starts fresh.
class UserProvider with ChangeNotifier {
  final UserRemoteDataSource _remoteDataSource;

  UserProvider({required UserRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  // ── State ────────────────────────────────────────────────────
  User? _backendUser;
  bool _isLoading = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────────
  User? get backendUser => _backendUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Whether the backend user has been loaded successfully.
  bool get isLoaded => _backendUser != null;

  // ── Actions ──────────────────────────────────────────────────

  /// Fetches the authenticated user from GET /user/me and stores it.
  ///
  /// Errors are caught silently — callers can check [error] if needed.
  /// Screens should degrade gracefully (fall back to Firebase data) when
  /// [backendUser] is null.
  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _remoteDataSource.fetchMe();
      _backendUser = user;
      _error = null;
      debugPrint('[UserProvider] Loaded backend user: ${user.id} (${user.email})');
    } catch (e) {
      _error = e.toString();
      debugPrint('[UserProvider] Failed to load user: $e');
      // Non-fatal — backendUser stays null; screens will use Firebase fallback.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the stored user — call this on logout.
  void clear() {
    _backendUser = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
    debugPrint('[UserProvider] User state cleared.');
  }
}
