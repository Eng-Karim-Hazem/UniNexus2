import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'halls_screen.dart';
import 'qa_screen.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';
import 'package:uninexus/services/qr_generator_service.dart'; // Import your QR Obfuscation Service class

class FacultyIDScreen extends StatefulWidget {
  const FacultyIDScreen({super.key});

  @override
  State<FacultyIDScreen> createState() => _FacultyIDScreenState();
}

class _FacultyIDScreenState extends State<FacultyIDScreen> {
  // State Variables
  String _userID = "";
  String _userName = "";
  String _qrPayload = ""; // Holds the HMAC signed and XOR obfuscated context string
  bool _isLoading = true;
  int _selectedIndex = -1;
  bool _isPunchedIn = false;
  Timer? _refreshTimer; // Periodically refreshes the dynamic token timestamp

  // Colors preserved from your design
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
    _loadDataAndGenerateToken();

    // Automatically refresh the dynamic obfuscated token every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_userID.isNotEmpty && _userID != "N/A") {
        _generateCryptoToken();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Terminate background loop safely to prevent memory leaks
    super.dispose();
  }

  Future<void> _loadDataFromPrefs() async {
    // Kept for structure compatibility, logical operations moved to _loadDataAndGenerateToken
  }

  Future<void> _loadDataAndGenerateToken() async {
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
      _generateCryptoToken();
    }
  }

  /// Evaluates context punch state and signs it via your encryption service pipeline
  void _generateCryptoToken() {
    if (_userID.isEmpty || _userID == "N/A") return;

    // Creates contextual baseline payload matching your state criteria
    final String rawContextData = _isPunchedIn ? "OUT_$_userID" : "IN_$_userID";

    setState(() {
      // Passes the conditional state string directly into the backend cryptosystem loop
      _qrPayload = QrGeneratorService.EmpgenerateQrData(rawContextData);
    });
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Dynamic color gradient selection based on state
    final List<Color> qrColors = _isPunchedIn
        ? [_secondaryPurple, _primaryBlue]
        : [_primaryBlue, _secondaryPurple];

    return Scaffold(
      extendBody: true,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Phone_Background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: _buildTopHeader(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildMainCard(qrColors),
                        const SizedBox(height: 30),
                        _buildWidePunchButton(),
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            fontFamily: MobileAppFonts.heading,
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

  Widget _buildMainCard(List<Color> qrColors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.1),
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MobileAppFonts.heading,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _textIndigo,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "ID: $_userID",
            style: const TextStyle(
              fontFamily: MobileAppFonts.body,
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
                  // Passes the obfuscated crypto payload to the QR UI view layout
                  data: _qrPayload.isNotEmpty ? _qrPayload : "Loading Identity...",
                  version: QrVersions.auto,
                  size: 240.0,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Scan for Identity Verification",
            style: TextStyle(
              fontFamily: MobileAppFonts.body,
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidePunchButton() {
    final Color activeColor = _isPunchedIn ? _primaryBlue : _mainPurple;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPunchedIn = !_isPunchedIn;
        });
        // Instantly recalculate the dynamic token payload structure upon toggling punch status
        _generateCryptoToken();
      },
      child: Container(
        width: 240,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: activeColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Center(
          child: Text(
            _isPunchedIn ? "Punch OUT" : "Punch IN",
            style: TextStyle(
              fontFamily: MobileAppFonts.heading,
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
    width: 12, height: 12,
    decoration: const BoxDecoration(color: Color(0xFFE0E0FF), shape: BoxShape.circle),
  );

  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.6), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))],
      ),
      child: FloatingActionButton(
        onPressed: _goHome,
        backgroundColor: Colors.transparent, elevation: 0, shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(),
        notchMargin: 9.0, color: Colors.white, height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem('assets/images/solidarity_1.png', 'Community', 0),
            _navItem('assets/images/classroom_1.png', 'Halls', 1),
            const SizedBox(width: 72),
            _navItem('assets/images/qa.png', 'Q&A', 2),
            _navItem('assets/images/user.png', 'Profile', 3),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 28, height: 28, color: itemColor),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: MobileAppFonts.body, fontSize: 12,
              color: isSelected ? _mainPurple : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => routes[index]!));
    }
    if (mounted) setState(() => _selectedIndex = -1);
  }
}