import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'halls_screen.dart';
import 'qa_screen.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';

class FacultyIDScreen extends StatefulWidget {
  const FacultyIDScreen({super.key});

  @override
  State<FacultyIDScreen> createState() => _FacultyIDScreenState();
}

class _FacultyIDScreenState extends State<FacultyIDScreen> {
  // State Variables
  String _userID = "";
  String _userName = "";
  bool _isLoading = true;
  int _selectedIndex = -1;
  bool _isPunchedIn = false;

  // Constants & Styles
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _secondaryPurple = const Color(0xFF9C2CF3);
  final Color _textIndigo = const Color(0xFF5C5C80);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    if (mounted) {
      setState(() {
        _userID = prefs.getString('userCode') ?? prefs.getString('ID') ?? "N/A";
        String f = prefs.getString('userFirstName') ?? prefs.getString('fName') ?? "Faculty";
        String l = prefs.getString('userLastName') ?? prefs.getString('lName') ?? "";
        _userName = "$f $l".trim();
        _isLoading = false;
      });
    }
  }

  void _onNavBarTapped(int index) async {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    final Map<int, Widget> routes = {
      0: const StuCommunity(),
      1: const HallsScreen(),
      2: const QAScreen(),
      3: const ProfileScreen(),
    };

    if (routes.containsKey(index)) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => routes[index]!),
      );
    }

    if (mounted) {
      setState(() => _selectedIndex = -1);
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                _buildTopHeader(),
                const SizedBox(height: 30),
                _buildMainCard(),
                const SizedBox(height: 30),
                _buildWidePunchButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
          child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
        ),
        Text(
          "ID",
          style: TextStyle(
            fontFamily: 'Batangas',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _textIndigo,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    final List<Color> qrColors = _isPunchedIn
        ? [_secondaryPurple, _primaryBlue]
        : [_primaryBlue, _secondaryPurple];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(),
              const SizedBox(width: 15),
              Container(
                width: 60,
                height: 12,
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
          Text(
            _userName,
            style: TextStyle(
              fontFamily: 'Batangas',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _textIndigo,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "ID: $_userID",
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: qrColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: QrImageView(
                  data: _userID,
                  version: QrVersions.auto,
                  size: 240.0,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/LOGO.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            _isPunchedIn ? "Active Session - Scan to Punch Out" : "Scan for Identity Verification",
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              color: _isPunchedIn ? _primaryBlue : Colors.grey,
              fontSize: 14,
              fontWeight: _isPunchedIn ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidePunchButton() {
    final Color activeColor = _isPunchedIn ? _primaryBlue : _mainPurple;

    return GestureDetector(
      onTap: () => setState(() => _isPunchedIn = !_isPunchedIn),
      child: Container(
        width: 240,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: activeColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Center(
          child: Text(
            _isPunchedIn ? "Punch OUT" : "Punch IN",
            style: TextStyle(
              fontFamily: 'Batangas',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: activeColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot() => Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(color: Color(0xFFE0E0FF), shape: BoxShape.circle),
      );

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
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
                  _navItem('assets/images/solidarity_1.png', 'Community', 0),
                  _navItem('assets/images/classroom_1.png', 'Halls', 1),
                ],
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem('assets/images/qa.png', 'Q&A', 2),
                  _navItem('assets/images/user.png', 'Profile', 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 28, height: 28, color: itemColor),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 12,
              color: isSelected ? _mainPurple : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
