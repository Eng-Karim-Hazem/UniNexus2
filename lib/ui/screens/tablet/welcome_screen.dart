import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uninexus/ui/screens/tablet/theme/app_theme.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _introController;
  late AnimationController _exitController;
  late AnimationController _contentInController;

  // Rectangle animations
  late Animation<Offset> _leftIntro;
  late Animation<Offset> _rightIntro;
  late Animation<Offset> _leftExit;
  late Animation<Offset> _rightExit;

  // Content animations
  late Animation<Offset> _contentExit;
  late Animation<double> _contentFade;
  late Animation<double> _contentFadeIn;
  late Animation<Offset> _contentSlideIn;

  // State flags
  bool _showGif = true;
  bool _isNavigating = false;

  // GIF timer
  Timer? _gifTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playIntro();
  }

  // Setup animations
  void _setupAnimations() {

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _leftIntro = Tween(begin: const Offset(-1.4, -1.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic));

    _rightIntro = Tween(begin: const Offset(1.4, 1.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic));

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _leftExit = Tween(begin: Offset.zero, end: const Offset(-1.6, -1.6))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic));

    _rightExit = Tween(begin: Offset.zero, end: const Offset(1.6, 1.6))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic));

    _contentExit = Tween(begin: Offset.zero, end: const Offset(0, -0.5))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic));

    _contentFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: const Interval(0.0, 0.5)),
    );

    _contentInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentFadeIn =
        CurvedAnimation(parent: _contentInController, curve: Curves.easeOut);

    _contentSlideIn = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentInController, curve: Curves.easeOutCubic));
  }

  // Play intro animation
  void _playIntro() {
    _introController.forward();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _contentInController.forward();
    });

    _gifTimer?.cancel();
    _gifTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showGif = false);
    });
  }

  // Reset animations when returning
  void _resetAndReplay() {
    _isNavigating = false;
    _exitController.reset();
    _introController.reset();
    _contentInController.reset();

    if (mounted) setState(() => _showGif = true);

    _playIntro();
  }

  // Navigate to another page
  Future<void> _navigateTo(Widget page) async {
    if (_isNavigating) return;

    _isNavigating = true;

    await _exitController.forward();

    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    ).then((_) {
      if (mounted) _resetAndReplay();
    });
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    _introController.dispose();
    _exitController.dispose();
    _contentInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [

          // Left decorative rectangle
          Positioned(
            left: -sw * 0.08,
            top: -sh * 0.12,
            child: SlideTransition(
              position: _leftIntro,
              child: SlideTransition(
                position: _leftExit,
                child: Image.asset(
                  'assets/images_tab/rectangle_left.png',
                  width: sw * 0.50,
                  height: sw * 0.60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Right decorative rectangle
          Positioned(
            right: -sw * 0.16,
            bottom: -sh * 0.16,
            child: SlideTransition(
              position: _rightIntro,
              child: SlideTransition(
                position: _rightExit,
                child: Image.asset(
                  'assets/images_tab/rectangle_right.png',
                  width: sw * 0.55,
                  height: sw * 0.65,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Main content
          SlideTransition(
            position: _contentExit,
            child: FadeTransition(
              opacity: _contentFade,
              child: Center(
                child: SlideTransition(
                  position: _contentSlideIn,
                  child: FadeTransition(
                    opacity: _contentFadeIn,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Logo
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          child: ClipRRect(
                            key: ValueKey(_showGif),
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              _showGif
                                  ? 'assets/images_tab/UniNexus.gif'
                                  : 'assets/images_tab/logo2.png',
                              width: sw * 0.20,
                              height: sw * 0.20,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Title
                        Text(
                          'Welcome to UniNexus',
                          style: AppTextStyles.heading.copyWith(fontSize: 26),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Your unified campus experience begins here.',
                          style: AppTextStyles.caption,
                        ),

                        const SizedBox(height: 36),

                        // Login button
                        AppGradientButton(
                          text: 'Log In',
                          onPressed: () => _navigateTo(const LoginPage()),
                        ),

                        const SizedBox(height: 14),

                        // Register button
                        AppGradientButton(
                          text: 'Register',
                          onPressed: () => _navigateTo(const RegisterPage()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}