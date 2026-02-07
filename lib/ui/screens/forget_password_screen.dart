import 'package:flutter/material.dart';
import '../../ui/screens/login_screen.dart';
import '../../ui/screens/request_submitted_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {

  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();

  bool _isFormValid = false;
  bool _isLoading = false;

  late AnimationController _contentController;
  late Animation<Offset> _contentIntro;

  late Animation<double> _field1Anim;
  late Animation<double> _field2Anim;

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

    _field1Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );

    _field2Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _contentController.forward();
    });

    _emailController.addListener(_validate);
    _nationalIdController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      _isFormValid =
          _emailController.text.isNotEmpty &&
              _nationalIdController.text.isNotEmpty;
    });
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const RequestSubmittedScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
                  opacity: _contentController,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(40, 25, 40, 40),
                      child: Column(
                        children: [

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/images/uni.jpeg",
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Forgotten Password",
                            style: TextStyle(
                              fontFamily: 'Batangas',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 2),

                          const Text(
                            "Enter your details to renew your credintials",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 17,
                            ),
                          ),

                          const SizedBox(height: 40),

                          FadeTransition(
                            opacity: _field1Anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-0.3, 0),
                                end: Offset.zero,
                              ).animate(_field1Anim),
                              child: _modernField(
                                label: "Email / ID",
                                hint: "Enter Your Email/ID",
                                controller: _emailController,
                              ),
                            ),
                          ),

                          const SizedBox(height: 55),

                          FadeTransition(
                            opacity: _field2Anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-0.3, 0),
                                end: Offset.zero,
                              ).animate(_field2Anim),
                              child: _modernField(
                                label: "National ID",
                                hint: "Enter Your National ID",
                                controller: _nationalIdController,
                              ),
                            ),
                          ),

                          const SizedBox(height: 280),

                          _mainButton(
                            text: _isLoading ? "Submitting..." : "Submit",
                            enabled: _isFormValid && !_isLoading,
                            onTap: _submit,
                          ),

                          const SizedBox(height: 6),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("  Back to"),
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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

  // -------- MODERN FIELD --------

  Widget _modernField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 1),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Batangas',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1.4,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------- BUTTON --------

  Widget _mainButton({
    required String text,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 280,
      height: 65,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFFA78BFA), Color(0xFF67E8F9)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
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
          ),
        ),
      ),
    );
  }
}
