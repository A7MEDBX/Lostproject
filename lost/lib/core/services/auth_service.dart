import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Thrown when Firebase rate-limits verification email sending.
class TooManyRequestsException implements Exception {
  final String message;
  const TooManyRequestsException([this.message = 'Too many attempts. Please wait a few minutes before requesting another email.']);
  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Failed to create user.',
      );
    }

    if (displayName != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
    }

    return user;
  }

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'User not found.',
      );
    }

    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user found.',
      );
    }

    // Skip sending if already verified
    if (user.emailVerified) {
      debugPrint('[AuthService] User email is already verified.');
      return;
    }

    try {
      await user.sendEmailVerification();
      debugPrint('[AuthService] Verification email sent to ${user.email}');
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] sendEmailVerification error: ${e.code} — ${e.message}');
      if (e.code == 'too-many-requests') {
        throw const TooManyRequestsException();
      }
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Unexpected error in sendEmailVerification: $e');
      rethrow;
    }
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken();
  }
}
