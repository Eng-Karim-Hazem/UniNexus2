import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/request_submitted_page.dart';
import 'package:uninexus/services/firebase/signup_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  final _nationalIdController   = TextEditingController();
  final _emailController        = TextEditingController();
  final _universityIdController = TextEditingController(); // Replaced password controller

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initPageAnimation(vsync: this);
  }

  @override
  void dispose() {
    disposePageAnimation();
    _nationalIdController.dispose();
    _emailController.dispose();
    _universityIdController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- RECONCILED SIGNUP SERVICE MANAGEMENT ---
  Future<void> _handleRegister() async {
    final nId = _nationalIdController.text.trim();
    final email = _emailController.text.trim();
    final uId = _universityIdController.text.trim();

    if (nId.isEmpty || email.isEmpty || uId.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (nId.length != 14) {
      _showError("Make sure of your national ID (must be exactly 14 digits).");
      return;
    }

    setState(() => _isLoading = true);

    // Call service which returns descriptive status codes
    String resultStatus = await SignupService().registerUser(
      nationalId: nId,
      universityId: uId,
      email: email,
    );

    if (mounted) setState(() => _isLoading = false);

    if (!mounted) return;

    switch (resultStatus) {
      case 'success':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RequestSubmittedPage()),
        );
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
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final sw = size.width;
    final sh = size.height;
    final formWidth = (sw * 0.34).clamp(320.0, 520.0);
    final logoSize = (sw * 0.12).clamp(88.0, 140.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          /// TOP RIGHT SHAPE
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

          /// BOTTOM RIGHT SHAPE
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
                Positioned(
                  left: sw * 0.02, top: sh * 0.04,
                  child: AppBackButton(width: sw * 0.12),
                ),

                Positioned(
                  left: sw * 0.08, width: formWidth, top: sh * 0.08, bottom: sh * 0.06,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset('assets/images/uni.jpeg', width: logoSize, height: logoSize, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 20),
                      Text('Register to UniNexus', style: AppTextStyles.heading.copyWith(fontSize: 26), textAlign: TextAlign.center),
                      const Text('Start your smart campus journey', style: AppTextStyles.caption, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom + 40),
                          child: Column(
                            children: [
                              // Removed the unsupported parameters to clear the IDE error
                              animatedField(
                                  anim: field1Anim,
                                  child: AppLabeledField(
                                    label: 'National ID',
                                    controller: _nationalIdController,
                                    hint: 'Enter Your National ID',
                                  )
                              ),
                              const SizedBox(height: 20),
                              animatedField(
                                  anim: field2Anim,
                                  child: AppLabeledField(
                                    label: 'University Email',
                                    controller: _emailController,
                                    hint: 'Enter Your Email',
                                  )
                              ),
                              const SizedBox(height: 20),
                              animatedField(
                                  anim: field3Anim,
                                  child: AppLabeledField(
                                    label: 'University ID',
                                    controller: _universityIdController,
                                    hint: 'Enter Your ID',
                                  )
                              ),
                              const SizedBox(height: 32),
                              animatedField(
                                anim: checkAnim,
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: (sw * 0.25).clamp(200.0, 350.0),
                                      child: AppAuthButton(text: 'Register', onTap: _handleRegister),
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