import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/request_submitted_page.dart';
import 'package:uninexus/services/firebase/for_pass_service.dart'; // Ensure path is correct

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  final _emailController           = TextEditingController();
  final _nationalIdController      = TextEditingController();
  final _newPasswordController     = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initPageAnimation(vsync: this);
  }

  @override
  void dispose() {
    disposePageAnimation();
    _emailController.dispose();
    _nationalIdController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- INTEGRATED FORGOT PASS LOGIC ---
  Future<void> _handleSubmit() async {
    final emailOrId = _emailController.text.trim();
    final nId = _nationalIdController.text.trim();
    final newPass = _newPasswordController.text;
    final confPass = _confirmPasswordController.text;

    // 1. Check for empty fields
    if (emailOrId.isEmpty || nId.isEmpty || newPass.isEmpty || confPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    // 2. Check if passwords match
    if (newPass != confPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    // 3. Send request with the new password
    bool success = await ForpassService().sendRenewalRequest(
      universityId: emailOrId,
      nationalId: nId,
      newPassword: newPass, // <--- Passing the new password
    );

    if (mounted) setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RequestSubmittedPage()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details do not match our records.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final sw = size.width;
    final sh = size.height;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final formWidth = (sw * 0.34).clamp(320.0, 520.0);
    final logoSize = (sw * 0.11).clamp(84.0, 130.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          /// BACKGROUND SHAPES
          Positioned(
            right: -sw * 0.2, top: -sh * 0.27,
            child: FadeTransition(
              opacity: pageAnimController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.3, -0.3), end: Offset.zero).animate(CurvedAnimation(parent: pageAnimController, curve: Curves.easeOutCubic)),
                child: Image.asset('assets/images/Rectangle1.png', width: sw * 0.55, height: sw * 0.65),
              ),
            ),
          ),
          Positioned(
            right: -sw * 0.001, bottom: -sh * 0.46,
            child: FadeTransition(
              opacity: pageAnimController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.3, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: pageAnimController, curve: Curves.easeOutCubic)),
                child: Image.asset('assets/images/Rectangle1.png', width: sw * 0.55, height: sw * 0.65),
              ),
            ),
          ),

          animatedPageContent(
            child: Stack(
              children: [
                /// BACK BUTTON
                Positioned(left: sw * 0.02, top: sh * 0.04, child: AppBackButton(width: sw * 0.12)),

                /// FORM CONTENT
                Positioned(
                  left: sw * 0.08, width: formWidth, top: sh * 0.08, bottom: sh * 0.06,
                  child: Column(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/images/uni.jpeg', width: logoSize, height: logoSize, fit: BoxFit.cover)),
                      const SizedBox(height: 20),
                      Text('Forgotten Password', style: AppTextStyles.heading.copyWith(fontSize: 26)),
                      const Text('Enter your details to renew your credentials', style: AppTextStyles.caption),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: keyboardInset ),
                          child: Column(
                            children: [
                              animatedField(anim: field1Anim, child: AppLabeledField(label: 'Email / ID', controller: _emailController, hint: 'Enter Your Email/ID')),
                              const SizedBox(height: 12),
                              animatedField(anim: field2Anim, child: AppLabeledField(label: 'National ID', controller: _nationalIdController, hint: 'Enter Your National ID')),
                              const SizedBox(height: 12),
                              animatedField(anim: field3Anim, child: AppLabeledField(label: 'New Password', controller: _newPasswordController, hint: 'Enter Your New Password', obscure: true)),
                              const SizedBox(height: 12),
                              animatedField(anim: field3Anim, child: AppLabeledField(label: 'Confirm Password', controller: _confirmPasswordController, hint: 'Confirm Your New Password', obscure: true)),
                              const SizedBox(height: 32),
                              animatedField(
                                anim: checkAnim,
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : Row( // Using a Row guarantees it centers perfectly
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: (sw * 0.25).clamp(200.0, 350.0),
                                      child: AppAuthButton(text: 'Submit', onTap: _handleSubmit),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}