import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../Faculty/halls_screen.dart';
import '../Faculty/qa_screen.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';

class FacultyIDScreen extends StatefulWidget {
  const FacultyIDScreen({super.key});

  @override
  State<FacultyIDScreen> createState() => _FacultyIDScreenState();
}

class _FacultyIDScreenState extends State<FacultyIDScreen> {
  String _userID = "";
  String _userName = "";
  bool _isLoading = true;
  int _selectedIndex = -1;

  // Track punch state
  bool _isPunchedIn = false;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _secondaryPurple = const Color(0xFF9C2CF3);

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

                // --- WIDE PUNCH BUTTON ---
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildWidePunchButton(),
                ),
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
        // --- ADDED NAVIGATION HERE ---
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen())
            );
          },
          child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
        ),

        const Text(
            "ID",
            style: TextStyle(
                fontFamily: 'Batangas',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C5C80)
            )
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    // Gradient Logic
    final List<Color> qrColors = _isPunchedIn
        ? [_secondaryPurple, _primaryBlue]
        : [_primaryBlue, _secondaryPurple];

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

          // --- STACK APPROACH: Layer Logo ON TOP of Gradient QR ---
          Stack(
            alignment: Alignment.center,
            children: [
              // Layer 1: The QR Code with Gradient (No Image Here)
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
                  // IMPORTANT: Set Error Correction to HIGH so covering the center is safe
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  // We remove the embeddedImage from here so it doesn't get tinted
                ),
              ),

              // Layer 2: The Logo (Untouched colors)
              Container(
                width: 45,
                height: 45,
                // Optional: Add a white background behind the logo for better visibility
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
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
                fontWeight: _isPunchedIn ? FontWeight.bold : FontWeight.normal
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDE PUNCH BUTTON ---
  Widget _buildWidePunchButton() {
    final Color activeColor = _isPunchedIn ? _primaryBlue : _mainPurple;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isPunchedIn = !_isPunchedIn;
        });
      },
      child: Container(
        width: 240,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: activeColor,
              width: 2
          ),
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
    width: 12, height: 12,
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
            color: _mainPurple.withOpacity(0.6),
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
            color: Colors.black.withOpacity(0.18),
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

  Widget _navItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () async {
        setState(() => _selectedIndex = index);

        if (index == 0) {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StuCommunity()));
        } else if (index == 1) {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HallsScreen()));
        } else if (index == 2) {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QAScreen()));
        } else if (index == 3) {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }

        if (mounted) setState(() => _selectedIndex = -1);
      },
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
              fontFamily: 'SpaceGrotesk',
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