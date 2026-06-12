import 'dart:async'; // <-- ADDED: For Timer and Debounce
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_shell.dart';

import '../../../theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/forgot_password_page.dart';
import 'package:uninexus/ui/screens/tablet/register_page.dart';

// --- DASHBOARD IMPORTS ---
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
  bool _isLoading = false;
  bool _rememberMe = false;

  // --- Live Status Tracking Variables ---
  String _requestStatus = '';
  Timer? _debounce;
  String _lastSearchedId = ''; // <-- Local cache string to prevent unnecessary duplicate reads

  @override
  void initState() {
    super.initState();
    initPageAnimation(vsync: this);

    // Attach listener for the live request tracking
    _emailController.addListener(_onIdChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel timer to prevent leaks
    disposePageAnimation();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Live Monitoring Logic ---
  void _onIdChanged() {
    final currentText = _emailController.text.trim().toUpperCase();

    // 1. Prevent trigger on cursor blink or non-text modifications
    if (currentText == _lastSearchedId) return;

    // 2. Wipe state if the field is cleared out completely
    if (currentText.isEmpty) {
      if (_requestStatus.isNotEmpty) setState(() => _requestStatus = '');
      _lastSearchedId = '';
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 3. Keep the 1000ms delay window to limit read calls during active typing
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (currentText != _lastSearchedId) {
        _lastSearchedId = currentText;
        _fetchStatusFromDatabase(currentText);
      }
    });
  }

  Future<void> _fetchStatusFromDatabase(String inputId) async {
    try {
      // Look up cross-collection documents matching the input
      final regSnap = await FirebaseFirestore.instance
          .collection('registration_requests')
          .where('ID', isEqualTo: inputId)
          .get();

      final passSnap = await FirebaseFirestore.instance
          .collection('ForgotPass_request')
          .where('emailOrId', isEqualTo: inputId)
          .get();

      List<Map<String, dynamic>> allRequests = [];

      for (var doc in regSnap.docs) {
        allRequests.add(doc.data());
      }
      for (var doc in passSnap.docs) {
        allRequests.add(doc.data());
      }

      if (allRequests.isEmpty) {
        if (mounted) setState(() => _requestStatus = '');
        return;
      }

      // Sort collections locally by submission date descending
      allRequests.sort((a, b) {
        final timeA = a['requestDate'] as Timestamp?;
        final timeB = b['requestDate'] as Timestamp?;
        if (timeA != null && timeB != null) return timeB.compareTo(timeA);
        return 0;
      });

      final latestRequest = allRequests.first;
      final status = (latestRequest['status'] ?? 'pending').toString().toLowerCase();

      if (mounted) {
        setState(() {
          _requestStatus = status;
        });
      }
    } catch (e) {
      // Fail silently if device goes offline
    }
  }

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
      final bool isEmail = inputId.contains('@');
      final String queryField = isEmail ? 'email' : 'ID';
      final String searchValue = isEmail ? inputId : inputId;

      Map<String, dynamic>? userData;
      String userCode = "";

      final List<String> collections = ['staff'];

      for (String col in collections) {
        final query = await FirebaseFirestore.instance
            .collection(col)
            .where(queryField, isEqualTo: searchValue)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          userData = query.docs.first.data();
          userCode = userData['ID']?.toString().toUpperCase() ?? "";
          break;
        }
      }

      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account not found. Please check your ID/Email.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (userData['pass'] != pass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect password")),
        );
        setState(() => _isLoading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', _rememberMe);

      await prefs.setString('ID', userCode);
      await prefs.setString('fName', userData['fName'] ?? '');
      await prefs.setString('lName', userData['lName'] ?? '');
      await prefs.setString('email', userData['email'] ?? '');
      await prefs.setString('photo', userData['photo'] ?? '');
      await prefs.setString('pNum', userData['pNum'] ?? '');
      await prefs.setString('nID', userData['nID'] ?? '');
      await prefs.setString('department', userData['department'] ?? '');
      await prefs.setString('position', userData['position'] ?? '');

      if (userData.containsKey('faculty')) await prefs.setString('faculty', userData['faculty']);
      if (userData.containsKey('year')) await prefs.setString('year', userData['year'].toString());

      if (!mounted) return;

      if (userCode.startsWith('MN')) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ITShell()),
              (route) => false,
        );
      } else if (userCode.startsWith('SC')) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SecurityShell()),
              (route) => false,
        );
      } else if (userCode.startsWith('AD')) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminShell()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Access Denied: Please use the mobile app for Student/Faculty access.", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final sw = size.width;
    final sh = size.height;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final formWidth = (sw * 0.34).clamp(320.0, 520.0);
    final logoSize = (sw * 0.12).clamp(88.0, 140.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// TOP RIGHT SHAPE
          Positioned(
            right: -sw * 0.2,
            top: -sh * 0.27,
            child: FadeTransition(
              opacity: pageAnimController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.3, -0.3), end: Offset.zero)
                    .animate(CurvedAnimation(parent: pageAnimController, curve: Curves.easeOutCubic)),
                child: Image.asset('assets/images/Rectangle1.png', width: sw * 0.55, height: sw * 0.65),
              ),
            ),
          ),

          /// BOTTOM RIGHT SHAPE
          Positioned(
            right: -sw * 0.001,
            bottom: -sh * 0.46,
            child: FadeTransition(
              opacity: pageAnimController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.3, 0.3), end: Offset.zero)
                    .animate(CurvedAnimation(parent: pageAnimController, curve: Curves.easeOutCubic)),
                child: Image.asset('assets/images/Rectangle1.png', width: sw * 0.55, height: sw * 0.65),
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

                /// CENTERED FORM
                Positioned(
                  left: sw * 0.08,
                  width: formWidth,
                  top: sh * 0.08,
                  bottom: sh * 0.06,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset('assets/images/uni.jpeg', width: logoSize, height: logoSize, fit: BoxFit.cover),
                      ),
                      SizedBox(height: sh * 0.025),
                      Text('Log in to UniNexus', style: AppTextStyles.heading.copyWith(fontSize: 26), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text('Access your campus services securely', style: AppTextStyles.caption, textAlign: TextAlign.center),
                      SizedBox(height: sh * 0.03),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: keyboardInset + 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              animatedField(
                                anim: field1Anim,
                                child: AppLabeledField(
                                  label: 'Email / ID',
                                  controller: _emailController,
                                  hint: 'Enter Your Email/ID',
                                ),
                              ),
                              SizedBox(height: sh * 0.025),
                              animatedField(
                                anim: field2Anim,
                                child: AppLabeledField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  hint: 'Enter Your Password',
                                  obscure: true,
                                ),
                              ),
                              animatedField(
                                anim: field2Anim,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 24, width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: AppColors.primary,
                                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                                        child: Text(
                                            'Remember Me',
                                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: sh * 0.04),
                              animatedField(
                                anim: checkAnim,
                                child: _isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: (sw * 0.25).clamp(200.0, 350.0),
                                      child: AppAuthButton(text: 'Log In', onTap: _handleLogin),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: sh * 0.03),
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
                                  child: Text('Forgot Password?', style: AppTextStyles.caption),
                                ),
                              ),
                              SizedBox(height: sh * 0.015),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Don't have an account? ", style: AppTextStyles.caption),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                                    child: Text('Register', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              SizedBox(height: sh * 0.03),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- THE FLOATING STATUS INDICATOR (Frees UI layout from calculation shifts) ---
                Positioned(
                  top: sh * 0.04,
                  right: sw * 0.04,
                  child: _buildStatusIndicator(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FLOATING INDICATOR UI WIDGET ---
  Widget _buildStatusIndicator() {
    if (_requestStatus.isEmpty) return const SizedBox.shrink();

    Color bulbColor;
    String tooltipMsg;

    if (_requestStatus == 'accepted' || _requestStatus == 'processed') {
      bulbColor = Colors.greenAccent;
      tooltipMsg = "Request Approved! You can log in.";
    } else if (_requestStatus == 'rejected') {
      bulbColor = Colors.redAccent;
      tooltipMsg = "Request Rejected. Please contact IT.";
    } else {
      bulbColor = const Color(0xFFFFC107);
      tooltipMsg = "Your request is currently being processed.";
    }

    return Tooltip(
      message: tooltipMsg,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 3),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bulbColor,
          boxShadow: [
            BoxShadow(
              color: bulbColor.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}