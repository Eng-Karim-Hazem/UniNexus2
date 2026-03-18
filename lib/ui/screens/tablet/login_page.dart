import 'dart:ui';
import 'package:flutter/material.dart';

// --- NEW IMPORTS FOR FIREBASE & LOGIC ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_shell.dart';

import '../../../theme/app_theme.dart';


import 'package:uninexus/ui/screens/tablet/forgot_password_page.dart';
import 'package:uninexus/ui/screens/tablet/register_page.dart';

// --- DASHBOARD IMPORTS ---
import 'package:uninexus/ui/screens/tablet/IT/it_shell.dart';
import 'package:uninexus/ui/screens/tablet/Security/security_shell.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_dashboard_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Added to manage loading state

  @override
  void initState() {
    super.initState();
    initPageAnimation(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    disposePageAnimation();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  /// REAL FIREBASE LOGIN LOGIC
  ////////////////////////////////////////////////////////////

  Future<void> _handleLogin() async {
    final inputId = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (inputId.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both ID/Email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Determine if the user entered an email or an ID
      final bool isEmail = inputId.contains('@');
      final String queryField = isEmail ? 'email' : 'ID';

      // If it's an ID, convert to uppercase to match Firestore (e.g., ST2022...)
      final String searchValue = isEmail ? inputId.toLowerCase() : inputId.toUpperCase();

      Map<String, dynamic>? userData;
      String userCode = "";

      // Look for the user in all 3 primary collections
      final List<String> collections = ['students', 'faculty', 'staff'];

      for (String col in collections) {
        final query = await FirebaseFirestore.instance
            .collection(col)
            .where(queryField, isEqualTo: searchValue)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          userData = query.docs.first.data();
          userCode = userData['ID']?.toString().toUpperCase() ?? "";
          break; // Stop searching once found
        }
      }

      // User not found in any collection
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account not found. Please check your ID/Email.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Check Password
      if (userData['pass'] != pass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect password")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Login Successful! Save data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', true);
      await prefs.setString('ID', userCode);
      await prefs.setString('fName', userData['fName'] ?? '');
      await prefs.setString('lName', userData['lName'] ?? '');
      await prefs.setString('email', userData['email'] ?? '');
      await prefs.setString('photo', userData['photo'] ?? '');
      await prefs.setString('pNum', userData['pNum'] ?? '');

      // Save collection-specific data
      if (userData.containsKey('faculty')) await prefs.setString('faculty', userData['faculty']);
      if (userData.containsKey('year')) await prefs.setString('year', userData['year'].toString());

      if (!mounted) return;

      // Route the user based on their ID prefix
      if (userCode.startsWith('MN')) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ITShell()));
      } else if (userCode.startsWith('SC')) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SecurityShell()));
      } else if (userCode.startsWith('AD')) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminShell()));
      } else if (userCode.startsWith('FA')) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FacultyHomeScreen()));
      } else if (userCode.startsWith('ST')) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StuHomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown user role for ID: $userCode")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging in: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

                        /// TITLE
                        Text(
                          'Log in to UniNexus',
                          style: AppTextStyles.heading.copyWith(fontSize: 26),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Access your campus services securely',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: sh * 0.05),

                        /// EMAIL FIELD
                        animatedField(
                          anim: field1Anim,
                          child: AppLabeledField(
                            label: 'Email / ID',
                            controller: _emailController,
                            hint: 'Enter Your Email/ID',
                          ),
                        ),

                        SizedBox(height: sh * 0.03),

                        /// PASSWORD FIELD
                        animatedField(
                          anim: field2Anim,
                          child: AppLabeledField(
                            label: 'Password',
                            controller: _passwordController,
                            hint: 'Enter Your Password',
                            obscure: true,
                          ),
                        ),

                        SizedBox(height: sh * 0.05),

                        /// LOGIN BUTTON
                        animatedField(
                          anim: checkAnim,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : AppAuthButton(
                            text: 'Log In',
                            onTap: _handleLogin,
                          ),
                        ),

                        SizedBox(height: sh * 0.04),

                        /// FORGOT PASSWORD
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                            );
                          },
                          child: Text('Forgot Password?', style: AppTextStyles.caption),
                        ),

                        SizedBox(height: sh * 0.02),

                        /// REGISTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Centers the Row text
                          children: [
                            Text("Don't have an account? ", style: AppTextStyles.caption),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterPage()),
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