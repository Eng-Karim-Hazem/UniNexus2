import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:uninexus/ui/screens/mobile/request_submitted_screen.dart';

import '/../../services/firebase/for_pass_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {

  final _idController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isFormValid = false;
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late AnimationController _contentController;
  late Animation<Offset> _contentIntro;

  late Animation<double> _field1Anim;
  late Animation<double> _field2Anim;
  late Animation<double> _field3Anim;
  late Animation<double> _field4Anim;
  late Animation<Offset> _topRectIntro;
  late Animation<Offset> _bottomRectIntro;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _contentIntro = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
    _field1Anim = CurvedAnimation(parent: _contentController, curve: const Interval(0.25, 0.6, curve: Curves.easeOut));
    _field2Anim = CurvedAnimation(parent: _contentController, curve: const Interval(0.45, 0.8, curve: Curves.easeOut));
    _field3Anim = CurvedAnimation(parent: _contentController, curve: const Interval(0.55, 0.85, curve: Curves.easeOut));
    _field4Anim = CurvedAnimation(parent: _contentController, curve: const Interval(0.65, 0.95, curve: Curves.easeOut));
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

    _idController.addListener(_validate);
    _nationalIdController.addListener(_validate);
    _newPasswordController.addListener(_validate);
    _confirmPasswordController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      _isFormValid = _idController.text.isNotEmpty &&
          _nationalIdController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _newPasswordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.", style: TextStyle(fontFamily: MobileAppFonts.body))),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await ForpassService().sendRenewalRequest(
      universityId: _idController.text,
      nationalId: _nationalIdController.text,
      newPassword: _confirmPasswordController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RequestSubmittedScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending renewal request.", style: TextStyle(fontFamily: MobileAppFonts.body))),
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _idController.dispose();
    _nationalIdController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset("assets/images/WelcomeBackground.png", fit: BoxFit.cover)),
            Positioned(
              top: -130,
              right: -260,
              child: SlideTransition(
                position: _topRectIntro,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset("assets/images/Rectangle.png", width: 550, fit: BoxFit.contain),
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
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(sw * 0.08, sh * 0.04, sw * 0.08, sh * 0.05),
                      child: Column(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset("assets/images/uni.jpeg", width: 90, fit: BoxFit.cover)),
                          SizedBox(height: sh * 0.015),

                          const Text("Forgotten Password", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 30, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          const Text("Enter your details to renew your credentials", style: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.black54, fontSize: 15), textAlign: TextAlign.center),

                          SizedBox(height: sh * 0.04),

                          FadeTransition(
                            opacity: _field1Anim,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(_field1Anim),
                              child: _modernField(label: "ID", hint: "Enter Your ID", controller: _idController),
                            ),
                          ),
                          const SizedBox(height: 20),

                          FadeTransition(
                            opacity: _field2Anim,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(_field2Anim),
                              child: _modernField(label: "National ID", hint: "Enter Your National ID", controller: _nationalIdController),
                            ),
                          ),
                          const SizedBox(height: 20),

                          FadeTransition(
                            opacity: _field3Anim,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(_field3Anim),
                              child: _passwordField(
                                label: "New Password",
                                hint: "Enter Your New Password",
                                controller: _newPasswordController,
                                obscure: _obscureNew,
                                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          FadeTransition(
                            opacity: _field4Anim,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(_field4Anim),
                              child: _passwordField(
                                label: "Confirm Password",
                                hint: "Confirm Your New Password",
                                controller: _confirmPasswordController,
                                obscure: _obscureConfirm,
                                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ),

                          SizedBox(height: sh * 0.06),

                          _mainButton(
                            text: _isLoading ? "Submitting..." : "Submit",
                            enabled: _isFormValid && !_isLoading,
                            onTap: _submit,
                            sw: sw,
                          ),

                          SizedBox(height: sh * 0.02),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Back to ", style: TextStyle(fontFamily: MobileAppFonts.body)),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                                child: const Text("Login",
                                    style: TextStyle(
                                      fontFamily: MobileAppFonts.heading,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7B61FF), // Matches your _mainPurple
                                    )
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

  Widget _modernField({required String label, required String hint, required TextEditingController controller}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 10, bottom: 1), child: Text(label, style: const TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 16, fontWeight: FontWeight.bold))),
      Container(
        height: 50,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.4)),
        child: TextField(
            controller: controller,
            style: const TextStyle(fontFamily: MobileAppFonts.body),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontFamily: MobileAppFonts.body),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10)
            )
        ),
      ),
    ]);
  }

  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 10, bottom: 1), child: Text(label, style: const TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 16, fontWeight: FontWeight.bold))),
      Container(
        height: 50,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.4)),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontFamily: MobileAppFonts.body),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: MobileAppFonts.body),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
              onPressed: onToggle,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _mainButton({required String text, required bool enabled, required VoidCallback onTap, required double sw}) {
    return Container(
      width: sw * 0.75 > 280 ? 280 : sw * 0.75,
      height: 65,
      decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5), gradient: const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF67E8F9)]), borderRadius: BorderRadius.circular(24)),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, elevation: 0),
        child: Text(text, style: const TextStyle(color: Colors.white, fontFamily: MobileAppFonts.heading, fontSize: 22)),
      ),
    );
  }
}