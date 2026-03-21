import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/request_submitted_page.dart';
import 'package:uninexus/services/firebase/signup_service.dart'; // Ensure path is correct

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  final _nationalIdController = TextEditingController();
  final _emailController      = TextEditingController();
  final _passwordController   = TextEditingController();

  bool _isLoading = false; // Added loading state

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
    _passwordController.dispose();
    super.dispose();
  }

  // --- INTEGRATED SIGNUP LOGIC ---
  Future<void> _handleRegister() async {
    final nId = _nationalIdController.text.trim();
    final uId = _emailController.text.trim(); // User enters ID here
    final email = _emailController.text.trim(); // Or separate email logic

    if (nId.isEmpty || uId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Using the universal service that checks Students, Faculty, and Staff
    bool success = await SignupService().registerUser(
      nationalId: nId,
      universityId: uId,
      email: email,
    );

    if (mounted) setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RequestSubmittedPage()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID not found in our records. Please contact administration.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

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
                  left: sw * 0.10, width: sw * 0.30, top: sh * 0.08, bottom: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset('assets/images/uni.jpeg', width: sw * 0.12, height: sw * 0.12, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 20),
                        Text('Register to UniNexus', style: AppTextStyles.heading.copyWith(fontSize: 26)),
                        const Text('Start your smart campus journey', style: AppTextStyles.caption),
                        const SizedBox(height: 40),

                        animatedField(anim: field1Anim, child: AppLabeledField(label: 'National ID', controller: _nationalIdController, hint: 'Enter Your National ID')),
                        const SizedBox(height: 20),
                        animatedField(anim: field2Anim, child: AppLabeledField(label: 'Email / ID', controller: _emailController, hint: 'Enter Your Email/ID')),
                        const SizedBox(height: 20),
                        animatedField(anim: field3Anim, child: AppLabeledField(label: 'Password', controller: _passwordController, hint: 'Enter Your Password', obscure: true)),

                        const SizedBox(height: 40),

                        animatedField(
                          anim: checkAnim,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : AppAuthButton(text: 'Register', onTap: _handleRegister),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
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