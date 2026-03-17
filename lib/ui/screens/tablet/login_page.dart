import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:uninexus/theme/app_theme.dart';

import 'package:uninexus/ui/screens/tablet/forgot_password_page.dart';
import 'package:uninexus/ui/screens/tablet/register_page.dart';

import 'package:uninexus/ui/screens/tablet/IT/it_shell.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPageAnimation(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    replayPageAnimation();
  }

  @override
  void dispose() {
    disposePageAnimation();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  /// LOGIN LOGIC
  ////////////////////////////////////////////////////////////

  void _handleLogin() {

    final id = _emailController.text.trim().toLowerCase();
    final pass = _passwordController.text.trim();

    if (pass != "123") {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong password")),
      );

      return;
    }

    /// IT LOGIN
    if (id == "it") {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ITShell(),
        ),
      );
    }

    /// SECURITY LOGIN
    else if (id == "sc") {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SecurityShell(),
        ),
      );
    }

    /// STAFF (NOT IMPLEMENTED YET)
    else if (id == "sf") {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Staff dashboard coming later")),
      );
    }

    else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unknown user role")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          /// TOP RIGHT SHAPE
          Positioned(
            right: -sw * 0.2,
            top: -sh * 0.27,
            child: Image.asset(
              'assets/images/Rectangle1.png',
              width: sw * 0.55,
              height: sw * 0.65,
            ),
          ),

          /// BOTTOM RIGHT SHAPE
          Positioned(
            right: -sw * 0.001,
            bottom: -sh * 0.46,
            child: Image.asset(
              'assets/images/Rectangle1.png',
              width: sw * 0.55,
              height: sw * 0.65,
            ),
          ),

          animatedPageContent(
            child: Stack(
              children: [

                /// BACK BUTTON
                Positioned(
                  left: sw * 0.02,
                  top: sh * 0.04,
                  child: AppBackButton(width: sw * 0.12),
                ),

                /// LOGO
                Positioned(
                  left: sw * 0.19,
                  top: sh * 0.09,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/uni.jpeg',
                      width: sw * 0.12,
                      height: sw * 0.12,
                    ),
                  ),
                ),

                /// TITLE
                Positioned(
                  left: sw * 0.18,
                  top: sh * 0.31,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'Log in to UniNexus',
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 22,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Access your campus services securely',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),

                /// EMAIL FIELD
                Positioned(
                  left: sw * 0.14,
                  right: sw * 0.64,
                  top: sh * 0.42,
                  child: animatedField(
                    anim: field1Anim,
                    child: AppLabeledField(
                      label: 'Email / ID',
                      controller: _emailController,
                      hint: 'Enter Your Email/ID',
                    ),
                  ),
                ),

                /// PASSWORD FIELD
                Positioned(
                  left: sw * 0.14,
                  right: sw * 0.64,
                  top: sh * 0.57,
                  child: animatedField(
                    anim: field2Anim,
                    child: AppLabeledField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: 'Enter Your Password',
                      obscure: true,
                    ),
                  ),
                ),

                /// LOGIN BUTTON
                Positioned(
                  left: sw * 0.18,
                  right: sw * 0.65,
                  top: sh * 0.72,
                  child: animatedField(
                    anim: checkAnim,
                    child: AppAuthButton(
                      text: 'Log In',
                      onTap: _handleLogin,
                    ),
                  ),
                ),

                /// FORGOT PASSWORD
                Positioned(
                  left: sw * 0.23,
                  top: sh * 0.82,
                  child: GestureDetector(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ),

                /// REGISTER
                Positioned(
                  left: sw * 0.18,
                  top: sh * 0.86,
                  child: Row(
                    children: [

                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.caption,
                      ),

                      GestureDetector(
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Register',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
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