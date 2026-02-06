import 'package:flutter/material.dart';
import 'dart:async';
import '../../ui/screens/login_screen.dart';
import '../../ui/screens/SignUp_Screen.dart';

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

  bool showGif = true;

  @override
  void initState() {
    super.initState();

    // INTRO (rectangles come in)
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

    // EXIT (on tap)
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

    // 👇 ONLY move to middle (not top)
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

    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showGif = false);
    });
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
    _introController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Widget _rectangle() => Image.asset(
    "assets/images/Rectangle.png",
    width: 550,
    fit: BoxFit.contain,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              "assets/images/WelcomeBackground.png",
              fit: BoxFit.cover,
            ),
          ),

          // TOP RECTANGLE
          Positioned(
            top: -80,
            right: -245,
            child: SlideTransition(
              position: _topIntro,
              child: SlideTransition(
                position: _topExit,
                child: _rectangle(),
              ),
            ),
          ),

          // BOTTOM RECTANGLE (center focus motion)
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

          // CONTENT EXIT
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
                          borderRadius: BorderRadius.circular(26),
                          child: Image.asset(
                            showGif
                                ? "assets/images/UniNexus.gif"
                                : "assets/images/uni.jpeg",
                            key: ValueKey(showGif),
                            width: 270,
                            height: 270,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),

                      const SizedBox(height: 90),

                      const Text(
                        "Welcome to UniNexus",
                        style: TextStyle(
                          fontFamily: 'Batangas',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 1),

                      const Text(
                        "Your unified campus experience begins here.",
                        style: TextStyle(
                          fontFamily: 'Batangas',
                          fontSize: 19,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 120),

                      _mainButton("Log In", _goToLogin),

                      const SizedBox(height: 15),

                      _mainButton("Register", _goToRegister),
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
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 65),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.4),
        gradient: const LinearGradient(
          colors: [Color(0xFFA78BFA), Color(0xFF67E8F9)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
