import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
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
  final Color _inactiveGrey = const Color(0xFFC1C1D4); // Matching Profile Nav

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

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedFirstName = prefs.getString('fName') ?? "Faculty";
      _storedLastName = prefs.getString('lName') ?? "";
      _storedUserID = prefs.getString('ID') ?? "No ID";
    });
  }

  String _getCurrentDate() {
    return DateFormat('MMMM d, yyyy').format(DateTime.now());
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    // Navigation Logic
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const QAScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else {
      setState(() => _selectedIndex = index);
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
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                const SizedBox(height: 30),
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

  // --- TOP HEADER ---
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
        const Text("Home", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/uni.jpeg', width: 36, height: 36),
        ),
      ],
    );
  }

  // --- GREETING CARD ---
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi Dr. $_storedFirstName $_storedLastName!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          const Text("Welcome back to your dashboard", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(_getCurrentDate(), style: const TextStyle(fontSize: 14, color: Color(0xFF5BA4F5), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- ACTION BUTTONS ---
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildActionCard("Halls", 'assets/images/classroom_1.png', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HallsScreen())))),
        const SizedBox(width: 16),
        Expanded(child: _buildActionCard("Attendance", 'assets/images/user-check_1.png', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceSessionScreen())))),
      ],
    );
  }

  Widget _buildActionCard(String title, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 38, height: 38, color: const Color(0xFF5C5C80)),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple)),
          ],
        ),
      ),
    );
  }

  // --- NOTIFICATIONS ---
  Widget _buildNotificationsArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildNotifyItem("Management", "Faculty meeting today at 12:30 PM"),
          const SizedBox(height: 12),
          _buildNotifyItem("System Update", "Student portal maintenance scheduled"),
        ],
      ),
    );
  }

  Widget _buildNotifyItem(String title, String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEAF4FF).withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.notifications_active_outlined, color: _mainPurple, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: _mainPurple)),
          ]),
          const SizedBox(height: 4),
          Text(msg, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  // --- MODERN NAVIGATION BAR (MATCHES PROFILE) ---
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,
        color: Colors.white,
        elevation: 0,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavBarItem('assets/images/classroom_1.png', "Community", 0),
            _buildNavBarItem('assets/images/calendar.png', "Schedule", 1),
            const SizedBox(width: 48), // FAB Space
            _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
            _buildNavBarItem('assets/images/user.png', "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: isSelected ? _mainPurple : _inactiveGrey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? _mainPurple : _inactiveGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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
            padding: const EdgeInsets.all(18.0),
            child: Image.asset('assets/images/qr_code.png', color: Colors.white),
          ),
        ),
      ),
    );
  }
}