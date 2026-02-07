import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added for data persistence
import '../../ui/screens/forget_password_screen.dart';
import '../../ui/screens/signup_screen.dart';
import '../../ui/screens/stu_home.dart';
import '../../ui/screens/faculty_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _isLoading = false;

  late AnimationController _contentController;
  late Animation<Offset> _contentIntro;
  late Animation<double> _field1Anim;
  late Animation<double> _field2Anim;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );

    _field2Anim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _contentController.forward();
    });

    _codeController.addListener(_validate);
    _passwordController.addListener(_validate);
  }

  // --- AUTHENTICATION & SHARED PREFERENCES LOGIC ---
  Future<void> _handleLogin() async {
    final idInput = _codeController.text.trim();
    final passwordInput = _passwordController.text.trim();

    if (idInput.isEmpty || passwordInput.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      String collectionName;
      Widget nextScreen;

      // 1. Determine Role
      if (idInput.toUpperCase().startsWith("ST")) {
        collectionName = 'students';
        nextScreen = const StuHomeScreen();
      } else if (idInput.toUpperCase().startsWith("FA")) {
        collectionName = 'faculty';
        nextScreen = const FacultyHomeScreen();
      } else {
        throw "Invalid ID format. ID must start with 'ST' or 'FA'.";
      }

      // 2. Fetch User from Firebase
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('ID', isEqualTo: idInput)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw "User ID not found in $collectionName records.";
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final storedPassword = userData['pass'];

      // 3. Verify Password
      if (storedPassword == passwordInput) {

        // 4. Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();

        // Save Shared Info
        await prefs.setString('ID', idInput);
        await prefs.setString('fName', userData['fName'] ?? "User");
        await prefs.setString('lName', userData['lName'] ?? "");
        await prefs.setString('email', userData['email'] ?? "N/A");
        await prefs.setString('pNum', userData['pNum'] ?? "N/A");
        await prefs.setString('faculty', userData['faculty'] ?? "N/A");
        await prefs.setString('nationalID', userData['nationalID'] ?? "N/A");

        // Save Student-Specific Info
        if (collectionName == 'students') {
          await prefs.setString('year', userData['year'] ?? "N/A");
          await prefs.setString('section', userData['section'] ?? "N/A");
        }else if (collectionName == 'faculty') {
          // --- NEW: Save Subject List for Faculty ---
          // This assumes your Firestore field is called 'subjects' and is an Array
          List<dynamic> subjectsData = userData['subjects'] ?? [];
          List<String> subjectsList = subjectsData.map((e) => e.toString()).toList();
          await prefs.setStringList('facultySubjects', subjectsList);
        }

        if (!mounted) return;

        // 5. Navigate
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      } else {
        throw "Incorrect Password.";
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception:", "")),
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
    _contentController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/images/WelcomeBackground.png", fit: BoxFit.cover),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              right: -200,
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

            SafeArea(
              child: SlideTransition(
                position: _contentIntro,
                child: FadeTransition(
                  opacity: _contentController,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(40, 25, 40, 40),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset("assets/images/uni.jpeg", width: 90, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Log in to UniNexus",
                            style: TextStyle(fontFamily: 'Batangas', fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Access your campus services securely",
                            style: TextStyle(color: Colors.black54, fontSize: 17),
                          ),
                          const SizedBox(height: 40),

                          FadeTransition(
                            opacity: _field1Anim,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(_field1Anim),
                              child: _modernField(
                                label: "Email / ID",
                                hint: "Enter Your Email/ID",
                                controller: _codeController,
                              ),
                            ),
                          ),
                          const SizedBox(height: 55),

                          FadeTransition(
                            opacity: _field2Anim,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(_field2Anim),
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
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6, top: 1),
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                ),
                                child: const Text("Forgot Password?"),
                              ),
                            ),
                          ),

                          const SizedBox(height: 240),

                          _mainButton(
                            text: "Log In",
                            enabled: _isFormValid && !_isLoading,
                            isLoading: _isLoading,
                            onTap: _handleLogin,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () => _slideTo(const SignUpScreen(), fromRight: true),
                                child: const Text("Register", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 1),
          child: Text(label, style: const TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.4),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: icon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainButton({
    required String text,
    required bool enabled,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 280,
      height: 65,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        gradient: const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF67E8F9)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Batangas',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}