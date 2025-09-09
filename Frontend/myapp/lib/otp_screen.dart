import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ModernOtpScreen extends StatefulWidget {
  const ModernOtpScreen({super.key});

  @override
  State<ModernOtpScreen> createState() => _ModernOtpScreenState();
}

class _ModernOtpScreenState extends State<ModernOtpScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xFF2D3748),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Icon with gradient background
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7643), Color(0xFFFF9A56)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7643).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.message_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  const Text(
                    "Verification Code",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF718096),
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: "Enter the 4-digit code sent to\n"),
                        TextSpan(
                          text: "+1 898 860 ***",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // OTP Form
                  const ModernOtpForm(),
                  const SizedBox(height: 32),
                  // Timer and Resend
                  const ResendSection(),
                  const Spacer(),
                  // Terms text
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      "By continuing, you agree to our Terms & Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernOtpForm extends StatefulWidget {
  const ModernOtpForm({super.key});

  @override
  State<ModernOtpForm> createState() => _ModernOtpFormState();
}

class _ModernOtpFormState extends State<ModernOtpForm>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isComplete = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    final isComplete = _controllers.every((controller) => controller.text.isNotEmpty);
    if (isComplete != _isComplete) {
      setState(() {
        _isComplete = isComplete;
      });
    }
  }

  void _verify() async {
    if (!_isComplete) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final otp = _controllers.map((c) => c.text).join();
    
    // Simulate verification
    if (otp == "1234") {
      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verification successful!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Error - shake animation
      _shakeController.forward().then((_) => _shakeController.reset());
      
      // Clear all fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid code. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isComplete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value * 10 * 
                  (0.5 - ((_shakeAnimation.value * 4) % 1).abs()), 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) => _onChanged(value, index),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "0",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isComplete && !_isLoading ? _verify : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isComplete
                    ? const Color(0xFFFF7643)
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                elevation: _isComplete ? 8 : 0,
                shadowColor: const Color(0xFFFF7643).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Verify Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class ResendSection extends StatefulWidget {
  const ResendSection({super.key});

  @override
  State<ResendSection> createState() => _ResendSectionState();
}

class _ResendSectionState extends State<ResendSection> {
  int _timer = 30;
  bool _canResend = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _timer = 30;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        setState(() {
          _timer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _resendCode() {
    if (_canResend) {
      // Simulate resend API call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verification code sent!"),
          backgroundColor: Color(0xFFFF7643),
        ),
      );
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_canResend)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7643).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Resend code in 00:${_timer.toString().padLeft(2, '0')}",
              style: const TextStyle(
                color: Color(0xFFFF7643),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (_canResend)
          TextButton.icon(
            onPressed: _resendCode,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: Color(0xFFFF7643),
            ),
            label: const Text(
              "Resend Code",
              style: TextStyle(
                color: Color(0xFFFF7643),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                // Handle change phone number
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Change number",
                style: TextStyle(
                  color: Color(0xFFFF7643),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}