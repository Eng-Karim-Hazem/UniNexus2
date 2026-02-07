import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'student_id_screen.dart';
import 'profile_screen.dart';
import 'stu_schedule.dart';

class StuHomeScreen extends StatefulWidget {
  const StuHomeScreen({super.key});

  @override
  State<StuHomeScreen> createState() => _StuHomeScreenState();
}

class _StuHomeScreenState extends State<StuHomeScreen> {
  int _selectedIndex = 0;
  String _firstName = 'Student';
  String _lastName = '';
  bool _isLoading = true;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    setState(() {
      // Ensuring we pull both names from the keys set during login
      _firstName = prefs.getString('fName') ?? 'Student';
      _lastName = prefs.getString('lName') ?? '';
      _isLoading = false;
    });
  }

  String _getCurrentDate() {
    return DateFormat('MMMM d, yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(),
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                const SizedBox(height: 30),
                _buildGreetingCard(),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StuSchedule()),
                    );
                  },
                  child: _buildWhiteCard(
                    opacity: 0.4,
                    borderColor: _mainPurple.withOpacity(0.5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Want to check your\nschedule?',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Image.asset('assets/images/main_calender.png', width: 80, height: 80),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 100),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
                    ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildStudentNotification(
                          title: "Finance",
                          message: "Your tuition date is due",
                          icon: Icons.notifications_none_rounded,
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
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Updated to show full name
          Text(
              "Hi $_firstName $_lastName!".trim(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))
          ),
          const SizedBox(height: 8),
          const Text("Good morning", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Text(_getCurrentDate(), style: const TextStyle(fontSize: 14, color: Color(0xFF5BA4F5), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ... (rest of your existing helper widgets: _buildStudentNotification, _buildWhiteCard, _buildTopHeader, _buildFab, _buildBottomBar, _buildNavBarItem)

  Widget _buildStudentNotification({required String title, required String message, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _mainPurple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _mainPurple, size: 28),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _mainPurple)),
              const SizedBox(width: 12),
              Container(width: 1.5, height: 20, color: _mainPurple.withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWhiteCard({required Widget child, Color? borderColor, double opacity = 0.9}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: borderColor ?? _primaryBlue.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }

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

  Widget _buildFab() {
    return Container(
      height: 70, width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentIDScreen())),
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: Center(child: Image.asset('assets/images/qr_code.png', width: 30, height: 30, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      color: Colors.white,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
          _buildNavBarItem('assets/images/calendar.png', "Schedule", 1),
          const SizedBox(width: 48),
          _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
          _buildNavBarItem('assets/images/user.png', "Profile", 3),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 24, color: sel ? _mainPurple : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: sel ? _mainPurple : Colors.grey, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}