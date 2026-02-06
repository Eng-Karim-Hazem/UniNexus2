import 'package:flutter/material.dart';
import '../../ui/screens/login_screen.dart';

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

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

    Future.delayed(const Duration(milliseconds: 200), () {
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [

            // BACKGROUND
            Positioned.fill(
              child: Image.asset(
                "assets/images/WelcomeBackground.png",
                fit: BoxFit.cover,
              ),
            ),

            // HERO RECTANGLE (same layer feel)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              right: -200,
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

            // CONTENT
            SafeArea(
              child: SlideTransition(
                position: _contentIntro,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(40, 100, 40, 40),
                      child: Column(
                        children: [

                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              "assets/images/uni.jpeg",
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 50),

                          const Text(
                            "Request Submitted",
                            style: TextStyle(
                              fontFamily: 'Batangas',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Your request was sent successfully",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 17,
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            "For further questions or if there is any delay in processing your request, please contact the university department.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 230),

                          _mainButton(
                            text: "Back to Login",
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

  // -------- MODERN BUTTON --------

  Widget _mainButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 280,
      height: 65,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
