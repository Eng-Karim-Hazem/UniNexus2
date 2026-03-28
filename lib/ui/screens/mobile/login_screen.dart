import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:uninexus/ui/screens/mobile/signup_screen.dart';

import 'Faculty/faculty_home_screen.dart';
import 'Student/stu_home.dart';
import 'forget_password_screen.dart';


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
  bool _isLoading = false;
  bool _rememberMe = false;

  late AnimationController _contentController;
  late Animation<Offset> _contentIntro;
  late Animation<double> _field1Anim;
  late Animation<double> _field2Anim;
  late Animation<double> _checkAnim;

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
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _field1Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    );

    _field2Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
    );

    _checkAnim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _contentController.forward();
    });

    _codeController.addListener(_validate);
    _passwordController.addListener(_validate);
  }

  Future<void> _handleLogin() async {
    final idInput = _codeController.text.trim();
    final passwordInput = _passwordController.text.trim();

    if (idInput.isEmpty || passwordInput.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      String collectionName;
      Widget nextScreen;

      if (idInput.toUpperCase().startsWith("ST")) {
        collectionName = 'students';
        nextScreen = const StuHomeScreen();
      } else if (idInput.toUpperCase().startsWith("FA")) {
        collectionName = 'faculty';
        nextScreen = const FacultyHomeScreen();
      } else {
        throw "Invalid ID format. ID must start with 'ST' or 'FA'.";
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('ID', isEqualTo: idInput)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw "User ID not found in $collectionName records.";
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final storedPassword = userData['pass'];

      if (storedPassword == passwordInput) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('rememberMe', _rememberMe);
        if (_rememberMe) {
          await prefs.setString('rememberedID', idInput);
        } else {
          await prefs.remove('rememberedID');
        }

        await prefs.setString('ID', idInput);
        await prefs.setString('fName', userData['fName'] ?? "User");
        await prefs.setString('lName', userData['lName'] ?? "");
        await prefs.setString('email', userData['email'] ?? "N/A");
        await prefs.setString('pNum', userData['pNum'] ?? "N/A");
        await prefs.setString('faculty', userData['faculty'] ?? "N/A");
        await prefs.setString('nID', userData['nID'] ?? "N/A");
        await prefs.setString('photo', userData['photo'] ?? "N/A");

        if (collectionName == 'students') {
          await prefs.setString('year', userData['year'] ?? "N/A");
          await prefs.setString('section', userData['section'] ?? "N/A");
        } else if (collectionName == 'faculty') {
          List<dynamic> subjectsData = userData['subjects'] ?? [];
          List<String> subjectsList = subjectsData.map((e) => e.toString()).toList();
          await prefs.setStringList('facultySubjects', subjectsList);
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      } else {
        throw "Incorrect Password.";
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll("Exception:", ""),
              style: MobileAppTextStyles.bodyText,
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _validate() {
    setState(() {
      _isFormValid = _codeController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
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
            position: Tween<Offset>(begin: begin, end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/images/WelcomeBackground.png", fit: BoxFit.cover),
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
                      child: Image.asset("assets/images/Rectangle.png", width: 550, fit: BoxFit.contain),
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
                              width: MobileAppDimensions.heroImageWidth,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Log in to UniNexus",
                            style: MobileAppTextStyles.screenTitle,
                          ),

                          const Text(
                            "Access your campus services securely",
                            style: MobileAppTextStyles.screenSubtitle,
                          ),

                          const SizedBox(height: 50),

                          _animatedItem(
                            anim: _field1Anim,
                            child: _modernField(
                              label: "Email / ID",
                              hint: "Enter Your Email/ID",
                              controller: _codeController,
                            ),
                          ),

                          const SizedBox(height: 40),

                          _animatedItem(
                            anim: _field2Anim,
                            child: _modernField(
                              label: "Password",
                              hint: "Enter Your Password",
                              controller: _passwordController,
                              obscure: _obscurePassword,
                              icon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          _animatedItem(
                            anim: _checkAnim,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      activeColor: MobileAppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                    ),
                                    const Text(
                                      "Remember Me",
                                      style: MobileAppTextStyles.bodyTextMedium,
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                  ),
                                  child: const Text("Forgot Password?", style: TextStyle(fontFamily: MobileAppFonts.body)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 240),

                          _mainButton(
                            text: "Log In",
                            enabled: _isFormValid && !_isLoading,
                            isLoading: _isLoading,
                            onTap: _handleLogin,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: MobileAppTextStyles.bodyText,
                              ),
                              TextButton(
                                onPressed: () => _slideTo(const SignUpScreen(), fromRight: true),
                                child: const Text(
                                  "Register now",
                                  style: MobileAppTextStyles.textButtonHeading,
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

  Widget _animatedItem({required Animation<double> anim, required Widget child}) {
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
    bool obscure = false,
    Widget? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 1),
          child: Text(label, style: MobileAppTextStyles.fieldLabel),
        ),
        Container(
          height: MobileAppDimensions.inputHeight,
          decoration: MobileAppDecorations.inputBox,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: MobileAppTextStyles.fieldText,
            decoration: MobileAppInputStyles.fieldDecoration(
              hint: hint,
              suffixIcon: icon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainButton({
    required String text,
    required bool enabled,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      width: MobileAppDimensions.primaryButtonWidth,
      height: MobileAppDimensions.primaryButtonHeight,
      decoration: MobileAppDecorations.primaryButtonBox,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: MobileAppButtonStyles.transparentElevated,
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(
          text,
          style: MobileAppTextStyles.buttonText,
        ),
      ),
    );
  }
}