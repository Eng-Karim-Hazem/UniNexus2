import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';

import 'login_screen.dart';

class RequestSubmittedScreen extends StatefulWidget {
  const RequestSubmittedScreen({super.key});

  @override
  State<RequestSubmittedScreen> createState() => _RequestSubmittedScreenState();
}

class _RequestSubmittedScreenState extends State<RequestSubmittedScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _contentController;
  late Animation<Offset> _contentIntro;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _topRectIntro;
  late Animation<Offset> _bottomRectIntro;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentIntro = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnim = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _topRectIntro = Tween<Offset>(
      begin: const Offset(1.4, -1.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _bottomRectIntro = Tween<Offset>(
      begin: const Offset(-1.4, 1.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Grab screen dimensions for perfect proportions
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                position: _topRectIntro,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset(
                      "assets/images/Rectangle.png",
                      width: 550,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -260,
              left: -210,
              child: SlideTransition(
                position: _bottomRectIntro,
                child: IgnorePointer(
                  child: Hero(
                    tag: 'shared-rectangle',
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        "assets/images/Rectangle.png",
                        width: 550,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SlideTransition(
                position: _contentIntro,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      // Dynamic padding so it breathes perfectly
                      padding: EdgeInsets.fromLTRB(sw * 0.08, sh * 0.1, sw * 0.08, sh * 0.05),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              "assets/images/uni.jpeg",
                              // Scale image dynamically
                              width: sw * 0.45 > 180 ? 180 : sw * 0.45,
                              fit: BoxFit.cover,
                            ),
                          ),

                          SizedBox(height: sh * 0.03), // Replaced 20

                          const Text(
                            "Request Submitted",
                            style: TextStyle(
                              fontFamily: MobileAppFonts.heading,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: sh * 0.05), // Replaced 50

                          const Text(
                            "Your request was sent successfully",
                            style: TextStyle(
                              fontFamily: MobileAppFonts.body,
                              color: Colors.black54,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: sh * 0.03), // Replaced 24

                          const Text(
                            "For further questions or if there is any delay in processing your request, please contact the university department.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: MobileAppFonts.body,
                              color: Colors.black54,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),

                          // THE FIX: Replaced the massive 210 gap with a dynamic proportional spacer
                          SizedBox(height: sh * 0.25),

                          _mainButton(
                            text: "Back to Login",
                            sw: sw, // Pass screen width
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
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
      ),
    );
  }

  Widget _mainButton({
    required String text,
    required VoidCallback onTap,
    required double sw,
  }) {
    return Container(
      // Keep button from overflowing narrow screens
      width: sw * 0.75 > 280 ? 280 : sw * 0.75,
      height: 65,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFA78BFA),
            Color(0xFF67E8F9),
          ],
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
            fontFamily: MobileAppFonts.heading,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}