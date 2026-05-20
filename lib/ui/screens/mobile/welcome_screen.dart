import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:uninexus/ui/screens/mobile/signup_screen.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _exitController;
  late AnimationController _contentInController;

  late Animation<Offset> _topIntro;
  late Animation<Offset> _bottomIntro;

  late Animation<Offset> _topExit;
  late Animation<Offset> _bottomExit;
  late Animation<Offset> _contentExit;
  late Animation<double> _contentFade;
  late Animation<double> _contentFadeIn;
  late Animation<Offset> _contentSlideIn;

  bool _showGif = true;
  bool _isNavigating = false;
  Timer? _gifTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _topIntro = Tween(
      begin: const Offset(1.4, -1.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
    );

    _bottomIntro = Tween(
      begin: const Offset(-1.4, 1.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
    );

    _introController.forward();

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _topExit = Tween(
      begin: Offset.zero,
      end: const Offset(1.6, -1.6),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _bottomExit = Tween(
      begin: Offset.zero,
      end: const Offset(-1.6, 1.6),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _contentExit = Tween(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _contentFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: const Interval(0.0, 0.5)),
    );

    _contentInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentFadeIn = CurvedAnimation(
      parent: _contentInController,
      curve: Curves.easeOut,
    );

    _contentSlideIn = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentInController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _contentInController.forward();
    });

    _gifTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showGif = false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/uni.jpeg'), context);
  }

  Future<void> _goToLogin() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await _exitController.forward();
    if (!mounted) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    ).then((_) => _resetAndReplay());
  }

  Future<void> _goToRegister() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await _exitController.forward();
    if (!mounted) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignUpScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    ).then((_) => _resetAndReplay());
  }

  void _resetAndReplay() {
    _isNavigating = false;
    _exitController.reset();
    _introController.reset();
    _contentInController.reset();

    if (mounted) setState(() => _showGif = true);

    _introController.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _contentInController.forward();
    });

    _gifTimer?.cancel();
    _gifTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showGif = false);
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

  Widget _rectangle() => Image.asset(
    'assets/images/Rectangle.png',
    width: 550,
    fit: BoxFit.contain,
  );

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/WelcomeBackground.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -130,
            right: -260,
            child: SlideTransition(
              position: _topIntro,
              child: SlideTransition(
                position: _topExit,
                child: _rectangle(),
              ),
            ),
          ),
          Positioned(
            bottom: -260,
            left: -210,
            child: SlideTransition(
              position: _bottomIntro,
              child: SlideTransition(
                position: _bottomExit,
                child: Hero(
                  tag: 'shared-rectangle',
                  child: _rectangle(),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SlideTransition(
              position: _contentExit,
              child: FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlideIn,
                  child: FadeTransition(
                    opacity: _contentFadeIn,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  SizedBox(height: constraints.maxHeight * 0.10),

                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 700),
                                    child: ClipRRect(
                                      key: ValueKey(_showGif),
                                      borderRadius: BorderRadius.circular(23),
                                      child: Image.asset(
                                        _showGif
                                            ? 'assets/icons/UniNexus.gif'
                                            : 'assets/images/uni.jpeg',
                                        width: sw * 0.55,
                                        height: sw * 0.55,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: constraints.maxHeight * 0.05),

                                  const Text(
                                    'Welcome to UniNexus',
                                    style: MobileAppTextStyles.screenTitle,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'Your unified campus experience begins here.',
                                      style: MobileAppTextStyles.screenSubtitle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const Spacer(),

                                  _mainButton('Log In', _goToLogin),
                                  const SizedBox(height: 15),
                                  _mainButton('Register', _goToRegister),

                                  SizedBox(height: constraints.maxHeight * 0.05),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _mainButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: MobileAppDimensions.wideButtonHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: MobileAppDimensions.wideButtonHorizontalMargin,
      ),
      decoration: MobileAppDecorations.wideButtonBox,
      child: ElevatedButton(
        onPressed: onTap,
        style: MobileAppButtonStyles.transparentElevated,
        child: Text(text, style: MobileAppTextStyles.buttonText),
      ),
    );
  }
}