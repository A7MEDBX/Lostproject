import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/finder_colors.dart';
import '../../core/services/auth_service.dart';

/// Email Verification Screen
class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    this.email = 'user@example.com',
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  int _remainingSeconds = 30;
  Timer? _timer;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _ensureAuthenticatedUser();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _ensureAuthenticatedUser() {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      _statusMessage = 'No signed-in user. Please log in again.';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  void _startTimer() {
    setState(() => _remainingSeconds = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onResendEmail() {
    if (_remainingSeconds == 0) {
      _resendVerificationEmail();
    }
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final verified = await AuthService.instance.reloadAndCheckEmailVerified();

    if (!mounted) return;

    if (verified) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _statusMessage = 'Email not verified yet. Please check your inbox.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await AuthService.instance.sendEmailVerification();
      if (!mounted) return;
      _startTimer();
      setState(() {
        _statusMessage = 'Verification email sent. Please check your inbox.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Failed to resend email: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinderColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FinderColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Verify Your Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: FinderColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: FinderColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Edit Email',
                  style: TextStyle(
                    fontSize: 14,
                    color: FinderColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _statusMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: FinderColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FinderColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLoading ? 'Checking...' : 'I Verified My Email',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _remainingSeconds == 0 ? _onResendEmail : null,
                child: Text(
                  _remainingSeconds == 0
                      ? 'Resend verification email'
                      : 'Resend email in $_remainingSeconds s',
                  style: TextStyle(
                    color: _remainingSeconds == 0
                        ? FinderColors.primaryBlue
                        : FinderColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
