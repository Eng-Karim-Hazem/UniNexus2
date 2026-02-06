import 'package:flutter/material.dart';
import '../../ui/screens/ForgetPassword_Screen.dart';
import '../../ui/screens/SignUp_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isFormValid = false;

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

    _codeController.addListener(_validate);
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
          _codeController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
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
              top: MediaQuery.of(context).size.height * 0.25,
              right: -200,
              child: RepaintBoundary(
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
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Log in to UniNexus",
                            style: TextStyle(
                              fontFamily: 'Batangas',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 0.1),

                          const Text(
                            "Access your campus services securely",
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
                                controller: _codeController,
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
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6, top: 1),
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordScreen(),
                                  ),
                                ),
                                child: const Text("Forgot Password?"),
                              ),
                            ),
                          ),


                          const SizedBox(height: 240),

                          _mainButton(
                            text: "Log In",
                            enabled: _isFormValid,
                            onTap: () {},
                          ),

                          const SizedBox(height: 1),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () => _slideTo(const SignUpScreen(), fromRight: true),
                                child: const Text(
                                  "Register",
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
    bool obscure = false,
    Widget? icon,
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
        child: const Text(
          "Log In",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
