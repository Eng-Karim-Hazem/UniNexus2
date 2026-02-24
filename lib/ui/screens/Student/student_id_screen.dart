import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Student/stu_schedule.dart';
import '../Student/stu_community.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/Faculty/qa_screen.dart';

class StudentIDScreen extends StatefulWidget {
  const StudentIDScreen({super.key});

  @override
  State<StudentIDScreen> createState() => _StudentIDScreenState();
}

class _StudentIDScreenState extends State<StudentIDScreen> {
  String _userID = "";
  String _userName = "";
  bool _isLoading = true;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    setState(() {
      _userID = prefs.getString('ID') ?? prefs.getString('userCode') ?? "N/A";
      String f = prefs.getString('fName') ?? "Student";
      String l = prefs.getString('lName') ?? "";
      _userName = "$f $l".trim();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
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
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 30),
                _buildMainCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/menu.png', width: 28, color: const Color(0xFF237ABA)),
          const Text(
            "Student ID",
            style: TextStyle(
              fontFamily: 'Batangas',
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
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(),
              const SizedBox(width: 15),
              Container(
                width: 60, height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 15),
              _buildDot(),
            ],
          ),
          const SizedBox(height: 30),

          Text(_userName, style: const TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
          const SizedBox(height: 5),
          Text("ID: $_userID", style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),

          const SizedBox(height: 40),

          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF237ABA), Color(0xFF9C2CF3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: QrImageView(
              data: _userID,
              version: QrVersions.auto,
              size: 240.0,
              embeddedImage: const AssetImage('assets/images/uni.jpeg'),
              embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(45, 45)),
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            "Scan for Identity Verification",
            style: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() => Container(
    width: 12, height: 12,
    decoration: const BoxDecoration(color: Color(0xFFE0E0FF), shape: BoxShape.circle),
  );

  Widget _buildHomeFab() {
    return Container(
      height: 70, width: 70,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
      ]),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        elevation: 0, backgroundColor: Colors.transparent, shape: const CircleBorder(),
        child: Container(
          width: double.infinity, height: double.infinity,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFF237ABA), Color(0xFF5C9CE0)]),
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0, color: Colors.white, elevation: 0, height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/images/solidarity_1.png', 'Community', 0),
          _navItem('assets/images/calendar.png', 'Schedule', 1),
          const SizedBox(width: 48),
          _navItem('assets/images/qa.png', 'Q&A', 2),
          _navItem('assets/images/user.png', 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StuCommunity()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StuSchedule()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const QAScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 24, height: 24,
              color: sel ? const Color(0xFF7B61FF) : Colors.grey.shade400),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 11,
            color: sel ? const Color(0xFF7B61FF) : Colors.grey.shade400,
            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    );
  }
}