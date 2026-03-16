import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uninexus/ui/screens/tablet/register_page.dart';
import 'package:uninexus/ui/screens/tablet/theme/app_theme.dart';
import '../../../uninexus_tab.dart';
import '../../widgets/it_sidebar_widget.dart';
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

  // Email / ID field.
  final _emailController    = TextEditingController();
  //Password field.
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // entry animation
    initPageAnimation(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    replayPageAnimation();
  }

  @override
  void dispose() {
    // dispose the animation controller from the mixin
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

          // Background top-right rectangle
          Positioned(
            right: -sw * 0.05, top: sh * 0.0,
            child: Image.asset('assets/images_tab/rectangle_down.png',
                width: sw * 0.45, height: sw * 0.45, fit: BoxFit.contain),
          ),

          // Background bottom-right rectangle
          Positioned(
            right: sw * 0.00, bottom: -sh * 0.10,
            child: Image.asset('assets/images_tab/Rectangle_up.png',
                width: sw * 0.45, height: sw * 0.45, fit: BoxFit.contain),
          ),

          // ── Animated page content
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
                    child: Image.asset('assets/images_tab/logo2.png',
                        width: sw * 0.12, height: sw * 0.12, fit: BoxFit.contain),
                  ),
                ),

                // Page title-subtitle
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

                // Password field
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

                // Log In button
                Positioned(
                  left: sw * 0.18, right: sw * 0.65, top: sh * 0.72,
                  child: animatedField(
                    anim: checkAnim,
                    child: AppAuthButton(
                      text: 'Log In',
                      // On tap: replaces LoginPage with _ITShell (no back button to login)
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const _ITShell()),
                      ),
                    ),
                  ),
                ),

                // Forgot Password link
                Positioned(
                  left: sw * 0.23, top: sh * 0.82,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    ),
                    child: Text('Forgot Password?', style: AppTextStyles.caption),
                  ),
                ),

                // Register link
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

//  IT SHELL

class _ITShell extends StatefulWidget {
  const _ITShell();

  @override
  State<_ITShell> createState() => _ITShellState();
}

class _ITShellState extends State<_ITShell> {

  // Current active tab
  UninexusTab _currentTab = UninexusTab.dashboard;


  // Navigation function
  void _navigate(UninexusTab tab) => setState(() => _currentTab = tab);

  // Build screen based on selected tab
  Widget _buildScreen() {
    switch (_currentTab) {
      case UninexusTab.dashboard:
        return ITDashboardScreen(onNavigate: _navigate);
      case UninexusTab.logs:
        return ITLogsScreen(onNavigate: _navigate);
      case UninexusTab.announcements:
        return ITAnnouncementsScreen(onNavigate: _navigate);
      case UninexusTab.id:
        return ITIdScreen(onNavigate: _navigate);
      case UninexusTab.hallErrors:
        return ITHallErrorScreen(onNavigate: _navigate);
      case UninexusTab.requests:
        return ITRequestsScreen(onNavigate: _navigate);
      case UninexusTab.profile:
        return ITProfileScreen(onNavigate: _navigate);
      case UninexusTab.settings:
        return ITSettingsScreen(onNavigate: _navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          ITSidebar(current: _currentTab, onNavigate: _navigate),
          // Screen content
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }
}