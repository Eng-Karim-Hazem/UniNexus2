import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:uninexus/ui/screens/mobile/request_submitted_screen.dart';
import '../../../services/firebase/signup_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();

  bool _isFormValid = false;
  bool _isLoading = false;

  late AnimationController _contentController;
  late Animation<Offset> _contentIntro;

  late Animation<double> _field1Anim;
  late Animation<double> _field2Anim;
  late Animation<double> _field3Anim;
  late Animation<Offset> _sideRectangleAnim;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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

    _sideRectangleAnim = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    ));

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
      universityId: _studentIdController.text,
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
        const SnackBar(
          content: Text(
            "Registration failed. Please try again.",
            style: MobileAppTextStyles.bodyText,
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 120),
        ),
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
    // Grab screen dimensions for perfect proportions
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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
            top: sh * 0.25,
            right: -200,
            child: SlideTransition(
              position: _sideRectangleAnim,
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
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(sw * 0.08, 25, sw * 0.08, 20),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                "assets/images/uni.jpeg",
                                width: MobileAppDimensions.heroImageWidth,
                                height: sh * 0.15,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Text("Register to UniNexus", style: MobileAppTextStyles.screenTitle),
                            const Text("Start your smart campus journey", style: MobileAppTextStyles.screenSubtitle),
                            const Spacer(flex: 1),
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
                            const Spacer(flex: 5),
                            _mainButton(
                              text: _isLoading ? "Processing..." : "Register",
                              enabled: _isFormValid && !_isLoading,
                              onTap: _handleSignUp,
                              sw: sw,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text("Already have an account?", style: MobileAppTextStyles.bodyText),
                                TextButton(
                                  onPressed: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  ),
                                  child: const Text("Login now", style: MobileAppTextStyles.textButtonHeading),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
            style: MobileAppTextStyles.fieldLabel,
          ),
        ),
        Container(
          height: MobileAppDimensions.inputHeight,
          decoration: MobileAppDecorations.inputBox,
          child: TextField(
            controller: controller,
            style: MobileAppTextStyles.fieldText,
            decoration: MobileAppInputStyles.fieldDecoration(
              hint: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: MobileAppDimensions.inputHorizontalPadding,
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
    required double sw,
  }) {
    return Container(
      // Responsive button width based on screen size, falling back to dimensions if there's enough room
      width: sw * 0.75 > MobileAppDimensions.primaryButtonWidth ? MobileAppDimensions.primaryButtonWidth : sw * 0.75,
      height: MobileAppDimensions.primaryButtonHeight,
      decoration: MobileAppDecorations.primaryButtonBox,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: MobileAppButtonStyles.transparentElevated,
        child: Text(
          text,
          style: MobileAppTextStyles.buttonText,
        ),
      ),
    );
  }
}