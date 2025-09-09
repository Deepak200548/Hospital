import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0, 0.2),
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
                  const SizedBox(height: 60),
                  // App Logo/Icon with gradient background
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7643), Color(0xFFFF9A56)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7643).withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.phone_android_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Welcome Title
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    "Enter your phone number to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Phone Input Form
                  const PhoneInputForm(),
                  const SizedBox(height: 40),
                  // Social Login ,
                  const Spacer(),
                  // Terms and Conditions
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        children: const [
                          TextSpan(text: "By signing up, you agree to our "),
                          TextSpan(
                            text: "Terms of Service",
                            style: TextStyle(
                              color: Color(0xFFFF7643),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              color: Color(0xFFFF7643),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

class PhoneInputForm extends StatefulWidget {
  const PhoneInputForm({super.key});

  @override
  State<PhoneInputForm> createState() => _PhoneInputFormState();
}

class _PhoneInputFormState extends State<PhoneInputForm>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  bool _isValidNumber = false;
  bool _isLoading = false;
  String _selectedCountryCode = "+1";
  String _selectedCountryFlag = "🇺🇸";

  final List<Map<String, String>> _countries = [
    {"code": "+1", "flag": "🇺🇸", "name": "United States"},
    {"code": "+91", "flag": "🇮🇳", "name": "India"},
    {"code": "+44", "flag": "🇬🇧", "name": "United Kingdom"},
    {"code": "+49", "flag": "🇩🇪", "name": "Germany"},
    {"code": "+33", "flag": "🇫🇷", "name": "France"},
    {"code": "+86", "flag": "🇨🇳", "name": "China"},
    {"code": "+81", "flag": "🇯🇵", "name": "Japan"},
  ];

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

    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final isValid = phone.length >= 10;
    
    if (isValid != _isValidNumber) {
      setState(() {
        _isValidNumber = isValid;
      });
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Select Country",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  return ListTile(
                    leading: Text(
                      country["flag"]!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country["name"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    trailing: Text(
                      country["code"]!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCountryCode = country["code"]!;
                        _selectedCountryFlag = country["flag"]!;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _sendOTP() async {
    if (!_isValidNumber) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Simulate phone validation
    if (phone.length >= 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP sent to $_selectedCountryCode ${_phoneController.text}"),
            backgroundColor: const Color(0xFFFF7643),
          ),
        );
        // Navigate to OTP screen
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ModernOtpScreen()));
      }
    } else {
      // Error - shake animation
      _shakeController.forward().then((_) => _shakeController.reset());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid phone number"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 10 * 
              (0.5 - ((_shakeAnimation.value * 4) % 1).abs()), 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Phone Number",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                child: Row(
                  children: [
                    // Country Code Selector
                    InkWell(
                      onTap: _showCountryPicker,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountryFlag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCountryCode,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Phone Number Input
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                          PhoneNumberFormatter(),
                        ],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter phone number",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          suffixIcon: _phoneController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _phoneController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Send OTP Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValidNumber && !_isLoading ? _sendOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidNumber
                        ? const Color(0xFFFF7643)
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    elevation: _isValidNumber ? 8 : 0,
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Send OTP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length <= 3) {
      return newValue.copyWith(text: digitsOnly);
    } else if (digitsOnly.length <= 6) {
      return newValue.copyWith(
        text: '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}',
        selection: TextSelection.collapsed(
          offset: digitsOnly.length + 1,
        ),
      );
    } else if (digitsOnly.length <= 10) {
      return newValue.copyWith(
        text: '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}',
        selection: TextSelection.collapsed(
          offset: digitsOnly.length + 2,
        ),
      );
    } else {
      return newValue.copyWith(
        text: '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 10)}',
        selection: TextSelection.collapsed(offset: 12),
      );
    }
  }
}