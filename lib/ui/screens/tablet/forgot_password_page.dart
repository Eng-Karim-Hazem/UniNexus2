import 'package:flutter/material.dart';
import 'package:uninexus/ui/screens/tablet/IT/request_submitted_page.dart';
import 'package:uninexus/theme/app_theme.dart';

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
    // Replays the animation when the user returns from RequestSubmittedPage
    replayPageAnimation();
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

// Top-right rectangle
          Positioned(
            right: -sw * 0.2,
            top: -sh * 0.27,
            child: Image.asset(
              'assets/images/Rectangle1.png',
              width: sw * 0.55,
              height: sw * 0.65,
              fit: BoxFit.contain,
            ),
          ),


// Bottom-right rectangle
          Positioned(
            right: -sw * 0.001,
            bottom: -sh * 0.46,
            child: Image.asset(
              'assets/images/Rectangle1.png',
              width: sw * 0.55,
              height: sw * 0.65,
              fit: BoxFit.contain,
            ),
          ),

          // Animated page content
          animatedPageContent(
            child: Stack(
              children: [

                // Back button
                Positioned(
                  left: sw * 0.02, top: sh * 0.04,
                  child: AppBackButton(width: sw * 0.12),
                ),

                // UniNexus logo
                Positioned(
                  left: sw * 0.19, top: sh * 0.09,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/images/uni.jpeg',
                        width: sw * 0.12, height: sw * 0.12, fit: BoxFit.contain),
                  ),
                ),

                // Page title-subtitle
                Positioned(
                  left: sw * 0.18, top: sh * 0.31,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Forgotten Password',
                          style: AppTextStyles.heading.copyWith(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text('Enter your details to renew your credentials',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),

                // Email / ID field
                Positioned(
                  left: sw * 0.14, right: sw * 0.64, top: sh * 0.42,
                  child: animatedField(
                    anim: field1Anim,
                    child: AppLabeledField(
                      label: 'Email / ID',
                      controller: _emailController,
                      hint: 'Enter Your Email/ID',
                    ),
                  ),
                ),

                // National ID field
                Positioned(
                  left: sw * 0.14, right: sw * 0.64, top: sh * 0.57,
                  child: animatedField(
                    anim: field2Anim,
                    child: AppLabeledField(
                      label: 'National ID',
                      controller: _nationalIdController,
                      hint: 'Enter Your National ID',
                    ),
                  ),
                ),

                // Submit button
                Positioned(
                  left: sw * 0.18, right: sw * 0.65, top: sh * 0.72,
                  child: animatedField(
                    anim: checkAnim,
                    child: AppAuthButton(
                      text: 'Submit',
                      // navigate to the confirmation page
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RequestSubmittedPage()),
                      ),
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