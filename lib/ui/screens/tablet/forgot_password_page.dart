import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/request_submitted_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  // Email / ID field.
  final _emailController      = TextEditingController();
  // National ID field.
  final _nationalIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPageAnimation(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // REMOVED replayPageAnimation() so the keyboard doesn't restart the animation!
  }

  @override
  void dispose() {
    disposePageAnimation(); // Clean up the animation controller from the mixin
    _emailController.dispose();
    _nationalIdController.dispose();
    super.dispose();
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

          /// TOP RIGHT SHAPE (Animated)
          Positioned(
            right: -sw * 0.2,
            top: -sh * 0.27,
            child: FadeTransition(
              opacity: pageAnimController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.3, -0.3), end: Offset.zero)
                    .animate(CurvedAnimation(parent: pageAnimController, curve: Curves.easeOutCubic)),
                child: Image.asset(
                  'assets/images/Rectangle1.png',
                  width: sw * 0.55,
                  height: sw * 0.65,
                ),
              ),
            ),
          ),

          /// BOTTOM RIGHT SHAPE (Animated)
          Positioned(
            right: -sw * 0.001,
            bottom: -sh * 0.46,
            child: FadeTransition(
              opacity: pageAnimController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.3, 0.3), end: Offset.zero)
                    .animate(CurvedAnimation(parent: pageAnimController, curve: Curves.easeOutCubic)),
                child: Image.asset(
                  'assets/images/Rectangle1.png',
                  width: sw * 0.55,
                  height: sw * 0.65,
                ),
              ),
            ),
          ),

          // Animated page content
          animatedPageContent(
            child: Stack(
              children: [

                /// BACK BUTTON
                Positioned(
                  left: sw * 0.02,
                  top: sh * 0.04,
                  child: AppBackButton(width: sw * 0.12),
                ),

                /// THE UNIFIED CENTERED FORM
                Positioned(
                  left: sw * 0.10,    // Shifts the whole block from the left
                  width: sw * 0.30,   // Determines how wide the text fields are
                  top: sh * 0.08,     // Distance from the top of the screen
                  bottom: 0,
                  child: SingleChildScrollView( // Prevents keyboard overflow errors!
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Centers everything
                      children: [

                        /// LOGO
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/uni.jpeg',
                            width: sw * 0.12,
                            height: sw * 0.12,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: sh * 0.03),

                        /// TITLE & SUBTITLE
                        Text(
                          'Forgotten Password',
                          style: AppTextStyles.heading.copyWith(fontSize: 26),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter your details to renew your credentials',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: sh * 0.05),

                        /// EMAIL / ID FIELD
                        animatedField(
                          anim: field1Anim,
                          child: AppLabeledField(
                            label: 'Email / ID',
                            controller: _emailController,
                            hint: 'Enter Your Email/ID',
                          ),
                        ),

                        SizedBox(height: sh * 0.03),

                        /// NATIONAL ID FIELD
                        animatedField(
                          anim: field2Anim,
                          child: AppLabeledField(
                            label: 'National ID',
                            controller: _nationalIdController,
                            hint: 'Enter Your National ID',
                          ),
                        ),

                        SizedBox(height: sh * 0.05),

                        /// SUBMIT BUTTON
                        animatedField(
                          anim: checkAnim,
                          child: AppAuthButton(
                            text: 'Submit',
                            // navigate to the confirmation page
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RequestSubmittedPage()),
                            ),
                          ),
                        ),

                        SizedBox(height: sh * 0.05), // Extra padding for the bottom
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