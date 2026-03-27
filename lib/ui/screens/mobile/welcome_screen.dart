import 'package:flutter/material.dart';
import 'dart:async';
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

  bool _showGif = true;
  Timer? _gifTimer;

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

    // Timer to switch from GIF to Static Image
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showGif = false);
    });
  }

  // --- FIX: PRECACHE THE IMAGE ---
  // This loads the static image into memory BEFORE it is needed, eliminating the loading flicker.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage("assets/images/uni.jpeg"), context);
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

    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/WelcomeBackground.png",
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
                      // --- UPDATED ANIMATED SWITCHER ---
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
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 17,
                          color: Colors.black54,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 135),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.4),
        gradient: const LinearGradient(
          colors: [Color(0xFFA78BFA), Color(0xFF67E8F9)],
        ),
        borderRadius: BorderRadius.circular(22),
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
            fontFamily: 'Batangas',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}