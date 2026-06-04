import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));

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

    _topRectIntro = Tween<Offset>(
      begin: const Offset(1.4, -1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));

    _bottomRectIntro = Tween<Offset>(
      begin: const Offset(-1.4, 1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _contentController.forward();
    });

    _nationalIdController.addListener(_validate);
    _emailController.addListener(_validate);
    _studentIdController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      // Allows the button to be interactive as long as fields have content
      _isFormValid = _nationalIdController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _studentIdController.text.isNotEmpty;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: MobileAppTextStyles.bodyText),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final nationalIdInput = _nationalIdController.text.trim();
    final emailInput = _emailController.text.trim();

    if (nationalIdInput.length != 14) {
      _showError("Make sure of your national ID (must be exactly 14 digits).");
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailInput)) {
      _showError("Please enter a valid university email format (e.g., user@uni.edu).");
      return; // Stops execution immediately without hitting Firebase
    }
    setState(() => _isLoading = true);

    String resultStatus = await SignupService().registerUser(
      nationalId: nationalIdInput,
      universityId: _studentIdController.text,
      email: _emailController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    if (!mounted) return;

    switch (resultStatus) {
      case 'success':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RequestSubmittedScreen()),
        );
        break;
    // --- NEW: Handle Duplicate Active Registration Account ---
      case 'already_registered':
        _showError("This account is already registered. Please go to the Login screen.");
        break;
      case 'user_not_found':
        _showError("University ID not found in our system.");
        break;
      case 'email_mismatch':
        _showError("The email provided does not match our records for this ID.");
        break;
      case 'national_id_mismatch':
        _showError("The National ID provided does not match our records for this ID.");
        break;
      case 'error':
      default:
        _showError("Registration failed. Please try again later.");
        break;
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
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/WelcomeBackground.png", fit: BoxFit.cover),
          ),
          Positioned(
            top: -130,
            right: -260,
            child: SlideTransition(
              position: _topRectIntro,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset("assets/images/Rectangle.png", width: 550, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            bottom: -260,
            left: -210,
            child: SlideTransition(
              position: _bottomRectIntro,
              child: Hero(
                tag: 'shared-rectangle',
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset("assets/images/Rectangle.png", width: 550, fit: BoxFit.contain),
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
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(sw * 0.08, sh * 0.04, sw * 0.08, sh * 0.04),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset("assets/images/uni.jpeg", width: MobileAppDimensions.heroImageWidth),
                        ),
                        SizedBox(height: sh * 0.015),
                        const Text(
                          "Register to UniNexus",
                          style: MobileAppTextStyles.screenTitle,
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          "Start your smart campus journey",
                          style: MobileAppTextStyles.screenSubtitle,
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: sh * 0.04),

                        _animatedField(
                          anim: _field1Anim,
                          child: _modernField(
                            label: "National ID",
                            hint: "Enter Your National ID",
                            controller: _nationalIdController,
                            isNumeric: true,
                          ),
                        ),

                        SizedBox(height: sh * 0.03),

                        _animatedField(
                          anim: _field2Anim,
                          child: _modernField(
                            label: "University Email",
                            hint: "Enter Your Email",
                            controller: _emailController,
                          ),
                        ),

                        SizedBox(height: sh * 0.03),

                        _animatedField(
                          anim: _field3Anim,
                          child: _modernField(
                            label: "University ID",
                            hint: "Enter Your ID",
                            controller: _studentIdController,
                          ),
                        ),

                        SizedBox(height: sh * 0.06),

                        _mainButton(
                          text: _isLoading ? "Processing..." : "Register",
                          enabled: _isFormValid && !_isLoading,
                          onTap: _handleSignUp,
                          sw: sw,
                        ),

                        SizedBox(height: sh * 0.02),

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
        position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }

  Widget _modernField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 2),
          child: Text(label, style: MobileAppTextStyles.fieldLabel),
        ),
        Container(
          height: MobileAppDimensions.inputHeight,
          decoration: MobileAppDecorations.inputBox,
          child: TextField(
            controller: controller,
            style: MobileAppTextStyles.fieldText,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            maxLength: isNumeric ? 14 : null,
            inputFormatters: isNumeric
                ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(14)]
                : null,
            decoration: MobileAppInputStyles.fieldDecoration(
              hint: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: MobileAppDimensions.inputHorizontalPadding,
              ),
            ).copyWith(counterText: ""),
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
      width: sw * 0.75 > MobileAppDimensions.primaryButtonWidth ? MobileAppDimensions.primaryButtonWidth : sw * 0.75,
      height: MobileAppDimensions.primaryButtonHeight,
      decoration: MobileAppDecorations.primaryButtonBox,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: MobileAppButtonStyles.transparentElevated,
        child: Text(text, style: MobileAppTextStyles.buttonText),
      ),
    );
  }
}