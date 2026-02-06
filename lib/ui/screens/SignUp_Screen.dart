import 'package:flutter/material.dart';
import '../../ui/screens/dashboard_screen.dart';
import '../../ui/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {

  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isFormValid = false;
  bool _obscurePassword = true;

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
    _passwordController.addListener(_validate);
  }
  void _slideTo(Widget page, {required bool fromRight}) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final begin = fromRight ? const Offset(1, 0) : const Offset(-1, 0);

          return SlideTransition(
            position: Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _validate() {
    setState(() {
      _isFormValid =
          _nationalIdController.text.isNotEmpty &&
              _emailController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                          child: Image.asset(
                            "assets/images/uni.jpeg",
                            width: 90,
                          ),
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
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                          ),
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
                            label: "Email / ID",
                            hint: "Enter Your Email/ID",
                            controller: _emailController,
                          ),
                        ),

                        const SizedBox(height: 40),

                        _animatedField(
                          anim: _field3Anim,
                          child: _modernField(
                            label: "Password",
                            hint: "Enter Your Password",
                            controller: _passwordController,
                            obscure: _obscurePassword,
                            icon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),

                        const SizedBox(height: 180),

                        _mainButton(
                          text: "Register",
                          enabled: _isFormValid,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 6),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                              onPressed: () => _slideTo(const LoginScreen(), fromRight: false),
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

  // ---------- HELPERS ----------

  Widget _animatedField({
    required Animation<double> anim,
    required Widget child,
  }) {
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
    bool obscure = false,
    Widget? icon,
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
              color: Colors.grey.withOpacity(0.3), // soft light border
              width: 1.4,
            ),
          ),

          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: icon,
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
