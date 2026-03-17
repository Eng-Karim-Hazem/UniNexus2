import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  // National ID field.
  final _nationalIdController = TextEditingController();
  // Email / ID field.
  final _emailController      = TextEditingController();
  // Password field.
  final _passwordController   = TextEditingController();

  @override
  void initState() {
    super.initState();
    // entry animation
    initPageAnimation(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Replays the animation
    replayPageAnimation();
  }

  @override
  void dispose() {
    disposePageAnimation(); // Clean up the animation controller from the mixin
    _nationalIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

          // Animated page content (slide-up + fade-in)
          animatedPageContent(
            child: Stack(
              children: [

                // Back button – returns to WelcomePage
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

                // Page title - subtitle
                Positioned(
                  left: sw * 0.18, top: sh * 0.31,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Register to UniNexus',
                          style: AppTextStyles.heading.copyWith(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text('Start your smart campus journey',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),

                // National ID field
                Positioned(
                  left: sw * 0.14, right: sw * 0.64, top: sh * 0.42,
                  child: animatedField(
                    anim: field1Anim,
                    child: AppLabeledField(
                      label: 'National ID',
                      controller: _nationalIdController,
                      hint: 'Enter Your National ID',
                    ),
                  ),
                ),

                // ── Email / ID field
                Positioned(
                  left: sw * 0.14, right: sw * 0.64, top: sh * 0.57,
                  child: animatedField(
                    anim: field2Anim,
                    child: AppLabeledField(
                      label: 'Email / ID',
                      controller: _emailController,
                      hint: 'Enter Your Email/ID',
                    ),
                  ),
                ),

                // Password field
                Positioned(
                  left: sw * 0.14, right: sw * 0.64, top: sh * 0.72,
                  child: animatedField(
                    anim: field3Anim,
                    child: AppLabeledField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: 'Enter Your Password',
                      obscure: true,
                    ),
                  ),
                ),

                // Register button
                Positioned(
                  left: sw * 0.18, right: sw * 0.65, top: sh * 0.86,
                  child: animatedField(
                    anim: checkAnim,
                    child: AppAuthButton(
                      text: 'Register',
                      onTap: () {
                      },
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