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

  late Animation<Offset> _topIntro;
  late Animation<Offset> _bottomIntro;

  late Animation<Offset> _topExit;
  late Animation<Offset> _bottomExit;
  late Animation<Offset> _contentExit;
  late Animation<double> _contentFade;

  bool _showGif = true;
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
      duration: const Duration(milliseconds: 1100),
    );

    _topExit = Tween(
      begin: Offset.zero,
      end: const Offset(1.6, -1.6),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic),
    );

    _bottomExit = Tween(
      begin: Offset.zero,
      end: const Offset(0.494, -0.72),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic),
    );

    _contentExit = Tween(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic),
    );

    _contentFade = Tween<double>(begin: 1, end: 0).animate(_exitController);

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
    await _exitController.forward();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _goToRegister() async {
    await _exitController.forward();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    _introController.dispose();
    _exitController.dispose();
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
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 90),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: ClipRRect(
                          key: ValueKey(_showGif),
                          borderRadius: BorderRadius.circular(23),
                          child: Image.asset(
                            _showGif
                                ? 'assets/images/UniNexus.gif'
                                : 'assets/images/uni.jpeg',
                            width: sw * 0.60,
                            height: sw * 0.60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 110),
                      const Text(
                        'Welcome to UniNexus',
                        style: MobileAppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Your unified campus experience begins here.',
                        style: MobileAppTextStyles.screenSubtitle,
                      ),
                      const SizedBox(height: 135),
                      _mainButton('Log In', _goToLogin),
                      const SizedBox(height: 15),
                      _mainButton('Register', _goToRegister),
                    ],
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