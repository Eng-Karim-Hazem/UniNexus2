import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/request_submitted_page.dart';
import 'package:uninexus/services/firebase/Forpass_service.dart'; // Ensure path is correct

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  final _emailController      = TextEditingController();
  final _nationalIdController = TextEditingController();

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
    super.dispose();
  }

  // --- INTEGRATED FORGOT PASS LOGIC ---
  Future<void> _handleSubmit() async {
    final emailOrId = _emailController.text.trim();
    final nId = _nationalIdController.text.trim();

    if (emailOrId.isEmpty || nId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    setState(() => _isLoading = true);

    // This service now checks across all 3 user collections
    bool success = await ForpassService().sendRenewalRequest(
      emailOrId: emailOrId,
      nationalId: nId,
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
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          /// BACKGROUND SHAPES (Inherited from your original UI)
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
                Positioned(left: sw * 0.02, top: sh * 0.04, child: AppBackButton(width: sw * 0.12)),

                Positioned(
                  left: sw * 0.10, width: sw * 0.30, top: sh * 0.08, bottom: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/images/uni.jpeg', width: sw * 0.12, height: sw * 0.12, fit: BoxFit.cover)),
                        const SizedBox(height: 20),
                        Text('Forgotten Password', style: AppTextStyles.heading.copyWith(fontSize: 26)),
                        const Text('Enter your details to renew your credentials', style: AppTextStyles.caption),
                        const SizedBox(height: 40),

                        animatedField(anim: field1Anim, child: AppLabeledField(label: 'Email / ID', controller: _emailController, hint: 'Enter Your Email/ID')),
                        const SizedBox(height: 20),
                        animatedField(anim: field2Anim, child: AppLabeledField(label: 'National ID', controller: _nationalIdController, hint: 'Enter Your National ID')),

                        const SizedBox(height: 40),

                        animatedField(
                          anim: checkAnim,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : AppAuthButton(text: 'Submit', onTap: _handleSubmit),
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