import 'package:flutter/material.dart';
import '../../ui/screens/login_screen.dart';
import '../../ui/screens/request_submitted_screen.dart';
import '../../services/firebase/signup_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController(); // Replaced password controller

  bool _isFormValid = false;
  bool _isLoading = false;

  late AnimationController _contentController;
  late Animation<Offset> _contentIntro;

  late Animation<double> _field1Anim;
  late Animation<double> _field2Anim;
  late Animation<double> _field3Anim;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
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
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    );
    _field2Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );
    _field3Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _contentController.forward();
    });

    _nationalIdController.addListener(_validate);
    _emailController.addListener(_validate);
    _studentIdController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      _isFormValid = _nationalIdController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _studentIdController.text.isNotEmpty;
    });
  }

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);

    bool success = await SignupService().registerUser(
      nationalId: _nationalIdController.text,
      studentId: _studentIdController.text,
      email: _emailController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RequestSubmittedScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed. Please try again.")),
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

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
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: -200,
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
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset("assets/images/uni.jpeg", width: 90),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Register to UniNexus",
                          style: TextStyle(
                            fontFamily: 'Batangas',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Start your smart campus journey",
                          style: TextStyle(color: Colors.black54, fontSize: 17),
                        ),
                        const SizedBox(height: 40),
                        _animatedField(
                          anim: _field1Anim,
                          child: _modernField(
                            label: "National ID",
                            hint: "Enter Your National ID",
                            controller: _nationalIdController,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _animatedField(
                          anim: _field2Anim,
                          child: _modernField(
                            label: "University Email",
                            hint: "Enter Your Email",
                            controller: _emailController,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _animatedField(
                          anim: _field3Anim,
                          child: _modernField(
                            label: "University ID",
                            hint: "Enter Your ID",
                            controller: _studentIdController,
                          ),
                        ),
                        const SizedBox(height: 180),
                        _mainButton(
                          text: _isLoading ? "Processing..." : "Register",
                          enabled: _isFormValid && !_isLoading,
                          onTap: _handleSignUp,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
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
    );
  }

  Widget _animatedField({required Animation<double> anim, required Widget child}) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  Widget _modernField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 2),
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
              color: Colors.grey.withOpacity(0.3),
              width: 1.4,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
      ],
    );
  }

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
            color: Colors.white.withOpacity(0.3), width: 1.5),
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