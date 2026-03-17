import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_notices_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_profile_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_sentnotices_screen.dart';
import 'package:uninexus/ui/screens/tablet/Admin/admin_usersearch_screen.dart';
import 'package:uninexus/ui/screens/tablet/register_page.dart';
import 'package:uninexus/ui/screens/tablet/theme/app_theme.dart';
import '../../../admin_tab.dart';
import '../../../uninexus_tab.dart';
import '../../widgets/admin_sidebar_widget.dart';
import '../../widgets/it_sidebar_widget.dart';

// Import the existing home screens
import '../mobile/Faculty/faculty_home_screen.dart';
import '../mobile/Student/stu_home.dart';
import 'Admin/admin_dashboard_screen.dart';
import 'Admin/admin_requests_screen.dart';
import 'Admin/admin_settings_screen.dart';
import 'IT/it_announcements_screen.dart';
import 'IT/it_dashboard_screen.dart';
import 'IT/it_hall_error_screen.dart';
import 'IT/it_id_screen.dart';
import 'IT/it_logs_screen.dart';
import 'IT/it_profile_screen.dart';
import 'IT/it_requests_screen.dart';
import 'IT/it_settings_screen.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Integrated logic states
  bool _isLoading = false;
  bool _rememberMe = false; // Note: Tablet UI currently lacks the checkbox

  @override
  void initState() {
    super.initState();
    initPageAnimation(vsync: this);
  }

  // --- FIREBASE LOGIN LOGIC ---
  Future<void> _handleLogin() async {
    final idInput = _emailController.text.trim();
    final passwordInput = _passwordController.text.trim();

    if (idInput.isEmpty || passwordInput.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      String collectionName;
      Widget nextScreen;

      if (idInput.toUpperCase().startsWith("MN")) {
        collectionName = 'staff';
        nextScreen = const _ITShell();
      }
      else if(idInput.toUpperCase().startsWith("AD")){
        collectionName = 'staff';
        nextScreen = const _ADShell();
      }
      else if(idInput.toUpperCase().startsWith("SC")){
        collectionName = 'staff';
        nextScreen = const _ITShell();
      }
      else {
        throw "Invalid ID format. Must start with MN , AD or SC .";
      }

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

      if (storedPassword == passwordInput) {
        final prefs = await SharedPreferences.getInstance();

        // Store user preferences and data
        await prefs.setBool('rememberMe', _rememberMe);
        await prefs.setString('ID', idInput);
        await prefs.setString('fName', userData['fName'] ?? "User");
        await prefs.setString('lName', userData['lName'] ?? "");
        await prefs.setString('email', userData['email'] ?? "N/A");

        if (collectionName == 'faculty') {
          List<dynamic> subjectsData = userData['subjects'] ?? [];
          List<String> subjectsList = subjectsData.map((e) => e.toString()).toList();
          await prefs.setStringList('facultySubjects', subjectsList);
        }

        if (!mounted) return;

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
            content: Text(e.toString().replaceAll("Exception:", ""),
                style: const TextStyle(fontFamily: 'SpaceGrotesk')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    disposePageAnimation();
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
          // Background decorations (Unchanged UI)
          Positioned(
            right: -sw * 0.05, top: sh * 0.0,
            child: Image.asset('assets/images_tab/rectangle_down.png',
                width: sw * 0.45, height: sw * 0.45, fit: BoxFit.contain),
          ),
          Positioned(
            right: sw * 0.00, bottom: -sh * 0.10,
            child: Image.asset('assets/images_tab/Rectangle_up.png',
                width: sw * 0.45, height: sw * 0.45, fit: BoxFit.contain),
          ),

          animatedPageContent(
            child: Stack(
              children: [
                Positioned(
                  left: sw * 0.02, top: sh * 0.04,
                  child: AppBackButton(width: sw * 0.12),
                ),
                Positioned(
                  left: sw * 0.19, top: sh * 0.09,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/images_tab/logo2.png',
                        width: sw * 0.12, height: sw * 0.12, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  left: sw * 0.18, top: sh * 0.31,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Log in to UniNexus',
                          style: AppTextStyles.heading.copyWith(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text('Access your campus services securely',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),

                // Fields with animations
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
                Positioned(
                  left: sw * 0.14, right: sw * 0.64, top: sh * 0.57,
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

                // LOGIN BUTTON WITH LOADING STATE
                Positioned(
                  left: sw * 0.18, right: sw * 0.65, top: sh * 0.72,
                  child: animatedField(
                    anim: checkAnim,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : AppAuthButton(
                      text: 'Log In',
                      onTap: _handleLogin, // Linked to Firebase logic
                    ),
                  ),
                ),

                Positioned(
                  left: sw * 0.23, top: sh * 0.82,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    ),
                    child: Text('Forgot Password?', style: AppTextStyles.caption),
                  ),
                ),
                Positioned(
                  left: sw * 0.18, top: sh * 0.86,
                  child: Row(
                    children: [
                      Text("Don't have an account? ", style: AppTextStyles.caption),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        ),
                        child: Text('Register',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            )),
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

// --- IT SHELL (Remains Unchanged) ---
class _ITShell extends StatefulWidget {
  const _ITShell();
  @override
  State<_ITShell> createState() => _ITShellState();
}

class _ITShellState extends State<_ITShell> {
  UninexusTab _currentTab = UninexusTab.dashboard;
  void _navigate(UninexusTab tab) => setState(() => _currentTab = tab);

  Widget _buildScreen() {
    switch (_currentTab) {
      case UninexusTab.dashboard: return ITDashboardScreen(onNavigate: _navigate);
      case UninexusTab.logs: return ITLogsScreen(onNavigate: _navigate);
      case UninexusTab.announcements: return ITAnnouncementsScreen(onNavigate: _navigate);
      case UninexusTab.id: return ITIdScreen(onNavigate: _navigate);
      case UninexusTab.hallErrors: return ITHallErrorScreen(onNavigate: _navigate);
      case UninexusTab.requests: return ITRequestsScreen(onNavigate: _navigate);
      case UninexusTab.profile: return ITProfileScreen(onNavigate: _navigate);
      case UninexusTab.settings: return ITSettingsScreen(onNavigate: _navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          ITSidebar(current: _currentTab, onNavigate: _navigate),
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }
}


class _ADShell extends StatefulWidget {
  const _ADShell();

  @override
  State<_ADShell> createState() => _ADShellState();
}

class _ADShellState extends State<_ADShell> {
  AdminTab _currentTab = AdminTab.dashboard;
  void _navigator(AdminTab tab) => setState(() => _currentTab = tab);

  Widget _buildScreen() {
    switch (_currentTab) {
      case AdminTab.dashboard:
        return AdminDashboardScreen(onNavigate: _navigator);
      case AdminTab.id:
        return ITIdScreen(onNavigate: (_) => _navigator(AdminTab.dashboard));
      case AdminTab.requests:
        return AdminRequestsScreen(onNavigate: _navigator);
      case AdminTab.notices:
        return AdminNoticesScreen(onNavigate: _navigator);
      case AdminTab.profile:
        return AdminProfileScreen(onNavigate: _navigator);
      case AdminTab.settings:
        return AdminSettingsScreen(onNavigate: _navigator);
      case AdminTab.usersearch:
        return AdminUserSearchScreen(onNavigate: _navigator);
      case AdminTab.sentnotices:
        return AdminSentNoticesScreen(onNavigate: _navigator);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AdminSidebar(current: _currentTab, onNavigate: _navigator),
          Expanded(
            child: _buildScreen(),
          ),
        ],
      ),
    );
  }
}