import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/finder_colors.dart';
import '../widgets/custom_rounded_button.dart';

/// Email Verification (OTP) Screen
class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    this.email = "user@example.com", // Default for testing/preview
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  final int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  int _remainingSeconds = 30;
  Timer? _timer;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _hasError = false;
  String _errorMessage = '';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (index) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (index) => FocusNode());

    _startTimer();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: const ElasticInCurve(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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

  void _onResendCode() {
    if (_remainingSeconds == 0) {
      // Trigger API call to resend OTP
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent successfully!')),
      );
      _startTimer();
    }
  }

  void _onCodeChanged(String value, int index) {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    if (value.isNotEmpty) {
      // Move to next input
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Unfocus if it's the last box
        _focusNodes[index].unfocus();
      }
    } else {
      // Move to previous input on backspace (when current is empty)
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    final otp = _getOtp();
    if (otp.length != _otpLength) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (otp == "123456") { // Example correct code
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Navigate to Home after success animation
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Incorrect verification code. Please try again.';
      });
      _shakeController.forward(from: 0.0);
      
      // Clear inputs
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVerifyEnabled = _getOtp().length == _otpLength && !_isLoading;

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

              // Title
              const Text(
                'Verify Your Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: FinderColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'We sent a 6-digit verification code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: FinderColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              // Edit Email Option
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

              const SizedBox(height: 48),

              // OTP Input
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _hasError ? (sin(_shakeAnimation.value * pi) * 10) : 0,
                      0,
                    ),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    _otpLength,
                    (index) => _buildOtpBox(index),
                  ),
                ),
              ),

              if (_hasError) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Timer / Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _remainingSeconds > 0
                        ? 'Resend code in ${_remainingSeconds}s'
                        : 'Didn\'t receive the code?',
                    style: const TextStyle(
                      fontSize: 14,
                      color: FinderColors.textSecondary,
                    ),
                  ),
                  if (_remainingSeconds == 0) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _onResendCode,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                          fontSize: 14,
                          color: FinderColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                ],
              ),

              const SizedBox(height: 48),

              // Verify Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? Colors.green
                      : (isVerifyEnabled
                          ? FinderColors.primaryBlue
                          : Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomRoundedButton(
                  text: _isLoading ? 'Verifying...' : (_isSuccess ? 'Verified!' : 'Verify'),
                  onPressed: isVerifyEnabled ? _verifyOtp : () {},
                  backgroundColor: Colors.transparent,
                  height: 54,
                  prefixWidget: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    bool isFocused = _focusNodes[index].hasFocus;
    bool hasValue = _controllers[index].text.isNotEmpty;

    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasError
              ? Colors.redAccent
              : (isFocused ? FinderColors.primaryBlue : Colors.grey.shade300),
          width: isFocused || _hasError ? 2 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: FinderColors.primaryBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Center(
        child: RawKeyboardListener(
          focusNode: FocusNode(), // Dummy focus node for intercepting raw keys
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                _controllers[index].text.isEmpty &&
                index > 0) {
              _focusNodes[index - 1].requestFocus();
              _controllers[index - 1].clear();
            }
          },
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isSuccess ? Colors.green : FinderColors.textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onCodeChanged(value, index),
          ),
        ),
      ),
    );
  }
}
