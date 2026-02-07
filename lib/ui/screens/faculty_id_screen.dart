import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacultyIDScreen extends StatefulWidget {
  const FacultyIDScreen({super.key});

  @override
  State<FacultyIDScreen> createState() => _FacultyIDScreenState();
}

class _FacultyIDScreenState extends State<FacultyIDScreen> {
  String _userID = "";
  String _userName = "";
  bool _isLoading = true;
  bool _isPunchedIn = false;

  // Light Blue Theme Color for Punch Out
  final Color _lightBlue = const Color(0xFF5BA4F5);
  final Color _primaryPurple = const Color(0xFF7B61FF);

  @override
  void initState() {
    super.initState();
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userID = prefs.getString('ID') ?? "N/A";
      String f = prefs.getString('fName') ?? "Faculty";
      String l = prefs.getString('lName') ?? "";
      _userName = "$f $l".trim();
      _isLoading = false;
    });
  }

  String get _qrData => _isPunchedIn ? "$_userID.out" : "$_userID.in";

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
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildPunchButton(),
                ),
                const SizedBox(height: 120),
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
          const Text("Faculty ID", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/uni.jpeg', width: 36, height: 36),
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
        boxShadow: [BoxShadow(color: const Color(0xFF237ABA).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
      ),
      child: Column(
        children: [
          _buildDecorativeTop(),
          const SizedBox(height: 30),
          _buildBadgeIcon(),
          const SizedBox(height: 15),
          Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
          const SizedBox(height: 30),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [const Color(0xFF237ABA), _isPunchedIn ? _primaryPurple : _lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 220.0,
              embeddedImage: const AssetImage('assets/images/uni.jpeg'),
              embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
            ),
          ),
          const SizedBox(height: 10),
          // Status text removed as requested
        ],
      ),
    );
  }

  Widget _buildPunchButton() {
    final Color currentColor = _isPunchedIn ? _lightBlue : _primaryPurple;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _isPunchedIn = !_isPunchedIn;
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: currentColor,
              width: 2
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.black12,
        ),
        child: Text(
          _isPunchedIn ? "Punch OUT" : "Punch IN",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: currentColor
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeTop() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildDot(), const SizedBox(width: 15),
      Container(width: 60, height: 12, decoration: BoxDecoration(color: const Color(0xFFE0E0FF), borderRadius: BorderRadius.circular(10))),
      const SizedBox(width: 15), _buildDot(),
    ],
  );

  Widget _buildDot() => Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFE0E0FF), shape: BoxShape.circle));

  Widget _buildBadgeIcon() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: _primaryPurple.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
    child: const Icon(Icons.badge_outlined, color: Colors.white, size: 40),
  );

  Widget _buildHomeFab() => Container(
    height: 70, width: 70,
    decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]),
    child: FloatingActionButton(
      onPressed: () => Navigator.pop(context),
      elevation: 0, backgroundColor: Colors.transparent, shape: const CircleBorder(),
      child: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF237ABA), Color(0xFF5C9CE0)])),
        child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
      ),
    ),
  );

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0, color: Colors.white, elevation: 0, height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _navItem('assets/images/menu.png', "Community"),
          _navItem('assets/images/calendar.png', "Schedule"),
          const SizedBox(width: 48),
          _navItem('assets/images/qa.png', "Q&A"),
          _navItem('assets/images/profile.png', "Profile"),
        ],
      ),
    );
  }

  Widget _navItem(String path, String label) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Image.asset(path, width: 24, height: 24, color: Colors.grey.shade400),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
    ]);
  }
}