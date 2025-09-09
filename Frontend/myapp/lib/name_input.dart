import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ModernNameScreen extends StatefulWidget {
  const ModernNameScreen({super.key});

  @override
  State<ModernNameScreen> createState() => _ModernNameScreenState();
}

class _ModernNameScreenState extends State<ModernNameScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

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
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
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
                  const SizedBox(height: 40),
                  // Floating animated icon
                  AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation.value * 10 - 5),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF537D5D), Color(0xFF73946B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF537D5D).withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 8 + _floatingAnimation.value * 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                  // Welcome message with animated text
                  const AnimatedWelcomeText(),
                  const SizedBox(height: 60),
                  // Name Input Form
                  const NameInputForm(),
                  const Spacer(),
                  // Progress indicator
                  const ProgressIndicator(),
                  const SizedBox(height: 20),
                  // Skip option
                  TextButton(
                    onPressed: () {
                      // Handle skip
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You can always add your name later!"),
                          backgroundColor: Color(0xFF9EBC8A),
                        ),
                      );
                    },
                    child: const Text(
                      "Skip for now",
                      style: TextStyle(
                        color: Color(0xFF537D5D),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedWelcomeText extends StatefulWidget {
  const AnimatedWelcomeText({super.key});

  @override
  State<AnimatedWelcomeText> createState() => _AnimatedWelcomeTextState();
}

class _AnimatedWelcomeTextState extends State<AnimatedWelcomeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textAnimation;
  
  final List<String> _welcomeMessages = [
    "What should we call you?",
    "Tell us your name!",
    "How do you like to be called?",
  ];
  
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _startTextAnimation();
  }

  void _startTextAnimation() async {
    while (mounted) {
      _textController.forward();
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        _textController.reverse();
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _welcomeMessages.length;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _textAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _textAnimation.value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * _textAnimation.value),
                child: Text(
                  _welcomeMessages[_currentIndex],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          "Help us personalize your experience by sharing your name",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class NameInputForm extends StatefulWidget {
  const NameInputForm({super.key});

  @override
  State<NameInputForm> createState() => _NameInputFormState();
}

class _NameInputFormState extends State<NameInputForm>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _arrowController;
  late AnimationController _successController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _arrowAnimation;
  late Animation<double> _successAnimation;
  
  bool _isValidName = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _nameController.addListener(_validateName);
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _arrowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _arrowController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _validateName() {
    final name = _nameController.text.trim();
    final isValid = name.length >= 2 && name.isNotEmpty;
    
    if (isValid != _isValidName) {
      setState(() {
        _isValidName = isValid;
      });
    }
  }

  void _completeSignup() async {
    if (!_isValidName) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final name = _nameController.text.trim();
    
    if (name.isNotEmpty) {
      // Success animation
      _successController.forward();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome, $name! 🎉"),
            backgroundColor: const Color(0xFF73946B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Navigate to main app after delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      }
    } else {
      // Error - shake animation
      _shakeController.forward().then((_) => _shakeController.reset());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid name"),
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
                "Your Name",
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
                child: TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(30),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter your full name",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9EBC8A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF537D5D),
                        size: 20,
                      ),
                    ),
                    suffixIcon: _nameController.text.isNotEmpty
                        ? AnimatedBuilder(
                            animation: _successAnimation,
                            builder: (context, child) {
                              return _isValidName
                                  ? Transform.scale(
                                      scale: 1 + (_successAnimation.value * 0.2),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF73946B),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        _nameController.clear();
                                      },
                                    );
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Continue Button
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isValidName && !_isLoading ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _isValidName
                            ? const LinearGradient(
                                colors: [Color(0xFF537D5D), Color(0xFF73946B)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: _isValidName ? null : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isValidName
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF537D5D).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isValidName && !_isLoading ? _completeSignup : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : AnimatedBuilder(
                                    animation: _arrowAnimation,
                                    builder: (context, child) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Complete Signup",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Transform.translate(
                                            offset: Offset(_arrowAnimation.value * 5, 0),
                                            child: Icon(
                                              Icons.check_circle_outline,
                                              size: 20,
                                              color: Colors.white.withOpacity(
                                                0.7 + (0.3 * _arrowAnimation.value),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Step 3 of 3",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              "Almost done!",
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF537D5D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF537D5D), Color(0xFF73946B)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}