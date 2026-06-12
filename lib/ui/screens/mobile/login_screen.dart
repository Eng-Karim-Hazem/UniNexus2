import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:uninexus/ui/screens/mobile/signup_screen.dart';

import '../../../../services/firebase/login_service.dart';

import 'Faculty/faculty_home_screen.dart';
import 'Student/stu_home.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  final LoginService _loginService = LoginService();

  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  // --- Live Status Tracking Variables ---
  String _requestStatus = '';
  Timer? _debounce;
  String _lastSearchedId = '';

  late AnimationController _contentController;
  late Animation<Offset> _contentIntro;
  late Animation<double> _field1Anim;
  late Animation<double> _field2Anim;
  late Animation<double> _checkAnim;
  late Animation<Offset> _topRectIntro;
  late Animation<Offset> _bottomRectIntro;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentIntro = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _field1Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    );

    _field2Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
    );

    _checkAnim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );

    _topRectIntro = Tween<Offset>(
      begin: const Offset(1.4, -1.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _bottomRectIntro = Tween<Offset>(
      begin: const Offset(-1.4, 1.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _contentController.forward();
    });

    _codeController.addListener(_onIdChanged);
    _passwordController.addListener(_validate);
  }

  void _onIdChanged() {
    _validate();

    final currentText = _codeController.text.trim().toUpperCase();

    if (currentText == _lastSearchedId) return;

    if (currentText.isEmpty) {
      if (_requestStatus.isNotEmpty) setState(() => _requestStatus = '');
      _lastSearchedId = '';
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (currentText != _lastSearchedId) {
        _lastSearchedId = currentText;
        _fetchStatusFromDatabase(currentText);
      }
    });
  }

  Future<void> _fetchStatusFromDatabase(String inputId) async {
    try {
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
      // Fail silently if offline
    }
  }

  Future<void> _handleLogin() async {
    final idInput = _codeController.text.trim();
    final passwordInput = _passwordController.text.trim();

    if (idInput.isEmpty || passwordInput.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await _loginService.login(idInput, passwordInput);

      switch (result['status']) {
        case LoginResult.signUpRequired:
          throw "Access Denied";
        case LoginResult.userNotFound:
          throw "User ID not found in our records.";
        case LoginResult.passwordMismatch:
          throw "Incorrect Password.";
        case LoginResult.invalidPrefix:
          throw "Invalid ID format";
        case LoginResult.error:
          throw "An error occurred while communicating with the server.";
        case LoginResult.success:
          final userData = result['userData'] as Map<String, dynamic>;
          final userType = result['userType'] as UserType;

          final prefs = await SharedPreferences.getInstance();

          await prefs.setBool('rememberMe', _rememberMe);
          if (_rememberMe) {
            await prefs.setString('rememberedID', idInput);
          } else {
            await prefs.remove('rememberedID');
          }

          await prefs.setString('ID', idInput);
          await prefs.setString('fName', userData['fName'] ?? "User");
          await prefs.setString('lName', userData['lName'] ?? "");
          await prefs.setString('email', userData['email'] ?? "N/A");
          await prefs.setString('pNum', userData['pNum'] ?? "N/A");
          await prefs.setString('faculty', userData['faculty'] ?? "N/A");
          await prefs.setString('nID', userData['nID'] ?? "N/A");
          await prefs.setString('photo', userData['photo'] ?? "N/A");

          Widget nextScreen;
          if (userType == UserType.student) {
            await prefs.setString('year', userData['year']?.toString() ?? "N/A");
            await prefs.setString('section', userData['section']?.toString() ?? "N/A");
            nextScreen = const StuHomeScreen();
          } else if (userType == UserType.faculty) {
            List<dynamic> subjectsData = userData['subjects'] ?? [];
            List<String> subjectsList = subjectsData.map((e) => e.toString()).toList();
            await prefs.setStringList('subjects', subjectsList);
            await prefs.setStringList('facultySubjects', subjectsList);
            nextScreen = const FacultyHomeScreen();
          } else {
            throw "Staff Users have no Access to Mobile dashboard.";
          }

          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
          break;
        default:
          throw "Unknown login response.";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception:", ""), style: MobileAppTextStyles.bodyText),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _validate() {
    setState(() {
      _isFormValid = _codeController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  void _slideTo(Widget page, {required bool fromRight}) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final begin = fromRight ? const Offset(1, 0) : const Offset(-1, 0);
          return SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _contentController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Get dynamic status properties ---
  Color? get _statusColor {
    if (_requestStatus == 'accepted' || _requestStatus == 'processed') return Colors.green.shade700;
    if (_requestStatus == 'rejected') return Colors.redAccent;
    if (_requestStatus == 'pending') return const Color(0xFFFFC107);
    return null;
  }

  String get _statusMessage {
    if (_requestStatus == 'accepted' || _requestStatus == 'processed') return "Request Approved! You can now log in.";
    if (_requestStatus == 'rejected') return "Request Rejected. Please contact IT.";
    if (_requestStatus == 'pending') return "Your request is currently being processed.";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/images/WelcomeBackground.png", fit: BoxFit.cover),
            ),
            Positioned(
              top: -130,
              right: -260,
              child: SlideTransition(
                position: _topRectIntro,
                child: RepaintBoundary(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset("assets/images/Rectangle.png", width: 550, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -260,
              left: -210,
              child: SlideTransition(
                position: _bottomRectIntro,
                child: RepaintBoundary(
                  child: IgnorePointer(
                    child: Hero(
                      tag: 'shared-rectangle',
                      child: Opacity(
                        opacity: 0.9,
                        child: Image.asset("assets/images/Rectangle.png", width: 550, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SlideTransition(
                position: _contentIntro,
                child: FadeTransition(
                  opacity: _contentController,
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(sw * 0.08, 25, sw * 0.08, 20),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  "assets/images/uni.jpeg",
                                  width: MobileAppDimensions.heroImageWidth,
                                  height: sh * 0.15,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),

                              const Text(
                                "Log in to UniNexus",
                                style: MobileAppTextStyles.screenTitle,
                                textAlign: TextAlign.center,
                              ),

                              const Text(
                                "Access your campus services securely",
                                style: MobileAppTextStyles.screenSubtitle,
                                textAlign: TextAlign.center,
                              ),

                              const Spacer(flex: 1),

                              // --- THE ID FIELD WITH FADED GRADIENT ---
                              _animatedItem(
                                anim: _field1Anim,
                                child: _modernField(
                                  label: "ID",
                                  hint: "Enter Your ID",
                                  controller: _codeController,
                                  statusColor: _statusColor,
                                  statusMessage: _statusMessage,
                                ),
                              ),
                              const SizedBox(height: 20),

                              _animatedItem(
                                anim: _field2Anim,
                                child: _modernField(
                                  label: "Password",
                                  hint: "Enter Your Password",
                                  controller: _passwordController,
                                  obscure: _obscurePassword,
                                  icon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                              ),

                              _animatedItem(
                                anim: _checkAnim,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            activeColor: MobileAppColors.primary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                          ),
                                          const Flexible(child: Text("Remember Me", style: MobileAppTextStyles.bodyTextMedium, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: TextButton(
                                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                                        child: const Text("Forgot Password?", style: TextStyle(fontFamily: MobileAppFonts.body), overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(flex: 2),

                              _mainButton(
                                text: "Log In",
                                enabled: _isFormValid && !_isLoading,
                                isLoading: _isLoading,
                                onTap: _handleLogin,
                              ),

                              const SizedBox(height: 10),

                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text("Don't have an account?", style: MobileAppTextStyles.bodyText),
                                  TextButton(
                                    onPressed: () => _slideTo(const SignUpScreen(), fromRight: true),
                                    child: const Text("Register now", style: MobileAppTextStyles.textButtonHeading),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedItem({required Animation<double> anim, required Widget child}) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(anim), child: child),
    );
  }

  // --- UPDATED _modernField TO SUPPORT THE QA-STYLE FADED GRADIENT ---
  Widget _modernField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? icon,
    Color? statusColor,
    String statusMessage = "",
  }) {
    Widget inputWidget = Container(
      height: MobileAppDimensions.inputHeight,
      decoration: MobileAppDecorations.inputBox,
      // Wrap the content in a ClipRRect so the gradient doesn't bleed out of your rounded borders
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 1. The Faded Gradient Layer
            if (statusColor != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.0),  // Transparent on the left
                        statusColor.withOpacity(0.15), // Starts to fade in
                        statusColor.withOpacity(0.6),  // Glows on the right edge
                      ],
                      stops: const [0.7, 0.85, 1.0], // Keeps the gradient pinned to the right 30% of the box
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

            // 2. The standard TextField on top
            TextField(
              controller: controller,
              obscureText: obscure,
              style: MobileAppTextStyles.fieldText,
              decoration: MobileAppInputStyles.fieldDecoration(
                hint: hint,
                suffixIcon: icon,
              ),
            ),
          ],
        ),
      ),
    );

    // If there is a status message, wrap the entire text field so they can tap it to read the message
    if (statusMessage.isNotEmpty) {
      inputWidget = Tooltip(
        message: statusMessage,
        triggerMode: TooltipTriggerMode.tap,
        showDuration: const Duration(seconds: 3),
        child: inputWidget,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 1),
            child: Text(label, style: MobileAppTextStyles.fieldLabel)
        ),
        inputWidget,
      ],
    );
  }

  Widget _mainButton({required String text, required bool enabled, required bool isLoading, required VoidCallback onTap}) {
    return Container(
      width: MobileAppDimensions.primaryButtonWidth,
      height: MobileAppDimensions.primaryButtonHeight,
      decoration: MobileAppDecorations.primaryButtonBox,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: MobileAppButtonStyles.transparentElevated,
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: MobileAppTextStyles.buttonText),
      ),
    );
  }
}