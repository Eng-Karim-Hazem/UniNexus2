import 'package:flutter/material.dart';
import '../../ui/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // 1. Import intl
import 'faculty_id_screen.dart';
import 'qa_screen.dart';
import 'profile_screen.dart';
import 'halls_screen.dart';
import 'attendance_session_screen.dart';

class FacultyHomeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;

  const FacultyHomeScreen({
    super.key,
    this.firstName = "Faculty",
    this.lastName = "",
  });

  @override
  State<FacultyHomeScreen> createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen> {
  int _selectedIndex = 0;
  String _storedFirstName = "";
  String _storedLastName = "";
  String _storedUserID = "";

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _storedFirstName = widget.firstName;
    _storedLastName = widget.lastName;
    _loadUserData();
  }

  // 2. Helper function to get current date (Matching student home)
  String _getCurrentDate() {
    return DateFormat('MMMM d, yyyy').format(DateTime.now());
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_storedFirstName == "Faculty" || _storedFirstName.isEmpty) {
        _storedFirstName = prefs.getString('userFirstName') ?? "Faculty";
      }
      if (_storedLastName.isEmpty) {
        _storedLastName = prefs.getString('userLastName') ?? "";
      }
      _storedUserID = prefs.getString('userCode') ?? "No ID";
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const QAScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ProfileScreen(
            userID: _storedUserID,
            firstName: _storedFirstName,
            lastName: _storedLastName,
          )
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                const SizedBox(height: 30),

                // Greeting Card with Dynamic Date
                _buildGreetingCard(),
                const SizedBox(height: 24),

                _buildActionButtons(),
                const SizedBox(height: 24),

                _buildNotificationsArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REFACTORED GREETING CARD ---
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _mainPurple.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi Dr. $_storedFirstName $_storedLastName!",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Good morning",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          // Dynamic Date injected here
          Text(
            _getCurrentDate(),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5BA4F5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- OTHER UI COMPONENTS (Keeping your logic intact) ---

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/menu.png', width: 28, color: _mainPurple,
            errorBuilder: (c,o,s) => Icon(Icons.menu, color: _mainPurple)),
        const Text("Home", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/uni.jpeg', width: 36, height: 36,
              errorBuilder: (c,o,s) => const Icon(Icons.school, size: 36)),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: "Halls",
            iconPath: 'assets/images/classroom_1.png',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HallsScreen())),
            fallbackIcon: Icons.meeting_room_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: "Attendance",
            iconPath: 'assets/images/user-check_1.png',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceSessionScreen())),
            fallbackIcon: Icons.co_present_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsArea() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildNotificationCard(
            title: "Management",
            message: "Meeting today on 12:30",
            icon: Icons.notifications_none_rounded,
          ),
          const SizedBox(height: 10),
          _buildNotificationCard(
            title: "System Update",
            message: "Maintenance scheduled for 10 PM",
            icon: Icons.settings_suggest_outlined,
          ),
        ],
      ),
    );
  }

  // ... (Keeping your existing _buildFab, _buildBottomBar, _buildNavBarItem, _buildActionCard, and _buildNotificationCard helpers) ...

  Widget _buildFab() {
    return Container(
      height: 70, width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FacultyIDScreen())),
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        child: Container(
          width: double.infinity, height: double.infinity,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/qr_code.png', color: Colors.white,
              errorBuilder: (c, o, s) => const Icon(Icons.qr_code, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 5, blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        color: Colors.white,
        elevation: 0,
        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0, Icons.people_alt_rounded),
            _buildNavBarItem('assets/images/calendar.png', "Schedule", 1, Icons.calendar_month_rounded),
            const SizedBox(width: 48),
            _buildNavBarItem('assets/images/qa.png', "Q&A", 2, Icons.question_answer_rounded),
            _buildNavBarItem('assets/images/profile.png', "Profile", 3, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String iconPath, String label, int index, IconData fallbackIcon) {
    final isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade400;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24, height: 24,
            child: Image.asset(iconPath, color: itemColor,
              errorBuilder: (context, error, stackTrace) => Icon(fallbackIcon, color: itemColor, size: 24),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: itemColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionCard({required String title, required String iconPath, required VoidCallback onTap, required IconData fallbackIcon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 38, height: 38, color: const Color(0xFF5C5C80),
              errorBuilder: (c, e, s) => Icon(fallbackIcon, size: 38, color: const Color(0xFF5C5C80)),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({required String title, required String message, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _mainPurple, size: 24),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple)),
              const SizedBox(width: 8),
              Container(width: 1, height: 16, color: Colors.grey.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}