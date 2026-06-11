import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- STUDENT SCREENS ---
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_schedule.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';

// --- FACULTY SCREENS ---
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/qa_screen.dart'; // Faculty Q&A
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart'; // Faculty Halls

// --- SHARED SCREENS ---
import 'package:uninexus/ui/screens/mobile/profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/welcome_screen.dart';

import 'account_management_screen.dart';
import 'app_info_screen.dart';
import 'feedback_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final int _selectedIndex = -1;
  final Color _mainPurple = const Color(0xFF7B61FF);

  // --- ROLE STATE ---
  bool _isFaculty = false;
  bool _isLoadingRole = true;

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // --- DETERMINE USER ROLE ON LOAD ---
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';

    if (mounted) {
      setState(() {
        _isFaculty = userId.toUpperCase().startsWith('FA');
        _isLoadingRole = false;
      });
    }
  }

  // --- DYNAMIC NAVIGATION BAR ROUTING ---
  void _onNavBarTapped(int index) async {
    if (_isFaculty) {
      // Faculty Routes
      if (index == 0) await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuCommunity()));
      else if (index == 1) await Navigator.push(context, MaterialPageRoute(builder: (_) => const HallsScreen()));
      else if (index == 2) await Navigator.push(context, MaterialPageRoute(builder: (_) => const QAScreen()));
      else if (index == 3) await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    } else {
      // Student Routes
      if (index == 0) await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuCommunity()));
      else if (index == 1) await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuQAScreen()));
      else if (index == 2) await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuSchedule()));
      else if (index == 3) await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  Future<void> _handleLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          "Logout",
          style: TextStyle(fontFamily: MobileAppFonts.heading, fontWeight: FontWeight.bold, color: _mainPurple),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600, fontFamily: MobileAppFonts.body)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontFamily: MobileAppFonts.body, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _goHome() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';

    Widget targetHome;
    if (userId.toUpperCase().startsWith('FA')) {
      targetHome = const FacultyHomeScreen();
    } else {
      targetHome = const StuHomeScreen();
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetHome),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Prevent layout from building with wrong nav bar briefly
    if (_isLoadingRole) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      extendBody: true,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Phone_Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 150),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildSettingsItem("Account management", 'assets/images/information_1.png'),
                _buildSettingsItem("Notification settings", 'assets/images/notify_1.png'),
                _buildSettingsItem("Feedback", 'assets/images/review_1.png'),
                _buildSettingsItem("App Information", 'assets/images/merge_1.png'),
                _buildSettingsItem("Logout", 'assets/images/logout_1.png', isLogout: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
          ),
        ),
        const Text(
          "Settings",
          style: TextStyle(
            fontFamily: MobileAppFonts.heading,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C5C80),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(String title, String iconPath, {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        if (title == "Account management") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountManagementScreen()));
        }
        else if (title == "Notification settings") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
        }
        else if (title == "Feedback") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()));
        }
        else if (title == "App Information") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AppInfoScreen()));
        }
        else if (isLogout) {
          _handleLogout();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isLogout ? Colors.red.withValues(alpha: 0.4) : _mainPurple.withValues(alpha: 0.3),
              width: 1
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF237ABA).withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 25,
              height: 25,
              color: isLogout ? Colors.red : _mainPurple,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: isLogout ? Colors.red : _mainPurple),
            ),
            const SizedBox(width: 15),
            Container(
              height: 35,
              width: 2.5,
              color: isLogout ? Colors.red.withValues(alpha: 0.3) : _mainPurple.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: MobileAppFonts.heading,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _mainPurple.withValues(alpha: 0.6),
            blurRadius: 25,
            spreadRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: FloatingActionButton(
        onPressed: _goHome,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _fabGradient,
          ),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        notchMargin: 9.0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem('assets/images/solidarity_1.png', "Community", 0),
                  // --- DYNAMIC NAV BAR ITEM ---
                  _isFaculty
                      ? _navItem('assets/images/classroom_1.png', "Halls", 1)
                      : _navItem('assets/images/qa.png', "Q&A", 1),
                ],
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _isFaculty
                      ? _navItem('assets/images/qa.png', "Q&A", 2)
                      : _navItem('assets/images/calendar.png', "Schedule", 2),
                  _navItem('assets/images/user.png', "Profile", 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            path,
            width: 28,
            height: 28,
            color: sel ? _mainPurple : Colors.grey.shade500,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: MobileAppFonts.body,
              fontSize: 12,
              color: sel ? _mainPurple : Colors.grey.shade600,
              fontWeight: sel ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}