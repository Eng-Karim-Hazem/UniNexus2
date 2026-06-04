import 'dart:async'; // --- ADDED FOR TIMER ---
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import 'package:uninexus/services/AttendanceGeneratorService.dart';
import '../Student/stu_community.dart';
import '../settings_screen.dart';
import '../Faculty/qa_screen.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';

class AttendanceSessionScreen extends StatefulWidget {
  const AttendanceSessionScreen({super.key});

  @override
  State<AttendanceSessionScreen> createState() => _AttendanceSessionScreenState();
}

class _AttendanceSessionScreenState extends State<AttendanceSessionScreen> {
  // State Variables
  String? _selectedDuration;
  String? _selectedCourse;
  String? _selectedSessionType;
  String _qrData = "";
  int _selectedIndex = -1;

  bool _isGenerating = false;
  bool _isOpeningSheet = false;

  Timer? _refreshTimer; // --- ADDED: Manages the 30-second token rotation loop ---

  // Constants & Styles
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _darkIndigo = const Color(0xFF5C5C80);
  final Color _primaryBlue = const Color(0xFF237ABA);

  final Gradient _primaryGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  List<String> _courses = [];
  final List<String> _sessionTypes = ['Lecture', 'Section'];
  final List<String> _durationOptions = ['5 mins', '10 mins', '15 mins', '20 mins'];

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // --- ADDED: Cancel timer to preserve memory threads ---
    super.dispose();
  }

  // --- Logic Methods ---

  Future<void> _loadUserSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedSubjects = prefs.getStringList('subjects');

    if (savedSubjects != null && savedSubjects.isNotEmpty) {
      if (mounted) {
        setState(() {
          _courses = savedSubjects!;
        });
      }
      return;
    }

    try {
      final String userId = prefs.getString('ID') ?? '';
      if (userId.isEmpty) return;

      final query = await FirebaseFirestore.instance
          .collection('faculty')
          .where('ID', isEqualTo: userId.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (data.containsKey('subjects')) {
          savedSubjects = List<String>.from(data['subjects']);
          await prefs.setStringList('subjects', savedSubjects);

          if (mounted) {
            setState(() {
              _courses = savedSubjects!;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching fallback subjects: $e");
    }
  }

  /// Core calculation method extracted so the periodic loop can run it autonomously
  Future<void> _generateAndSetQRData() async {
    final prefs = await SharedPreferences.getInstance();
    final String instructorId = prefs.getString('ID') ?? 'UNKNOWN_FA';

    final querySnapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('subName', isEqualTo: _selectedCourse)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("Subject not found in database.");
    }

    final subjectData = querySnapshot.docs.first.data();
    final String subID = subjectData['subID']?.toString() ?? querySnapshot.docs.first.id;

    final String typeCode = _selectedSessionType == 'Lecture' ? 'L' : 'S';
    final String durationCode = _selectedDuration!.replaceAll(' mins', 'min');

    // 1. Construct the raw plain text sequence configuration block
    final String rawContextString = "${subID}_${typeCode}_${durationCode}_$instructorId";

    if (mounted) {
      setState(() {
        // 2. Feed context parameters to generation engine to lock down cryptosystem updates
        _qrData = AttendanceGeneratorService.generateAttendanceData(rawContextString);
      });
    }
  }

  /// Triggered manually when the user presses the 'Generate QR' UI button interface
  Future<void> _handleGenerateQR() async {
    if (_selectedCourse == null || _selectedSessionType == null || _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select all fields first", style: TextStyle(fontFamily: MobileAppFonts.body)),
        ),
      );
      return;
    }

    // Clean up any pre-existing loops running before rebuilding active workflows
    _refreshTimer?.cancel();

    setState(() => _isGenerating = true);

    try {
      // Perform structural setup and render the initial signed payload package
      await _generateAndSetQRData();

      // --- ADDED: Start an infinite background loop rotating token vectors every 30 seconds ---
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (_selectedCourse != null && _selectedSessionType != null && _selectedDuration != null) {
          await _generateAndSetQRData();
        } else {
          timer.cancel(); // Safety cleanup if parameters drop mid-session
        }
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error generating QR: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
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

  Future<void> _openGoogleSheet() async {
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Course to view its attendance sheet.", style: TextStyle(fontFamily: MobileAppFonts.body)),
        ),
      );
      return;
    }

    setState(() => _isOpeningSheet = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('subName', isEqualTo: _selectedCourse)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) throw "Subject not found in database.";

      final subjectData = querySnapshot.docs.first.data();
      final String? sheetUrl = subjectData['sheetUrl'];

      if (sheetUrl == null || sheetUrl.isEmpty) {
        throw "No Google Sheet linked to this subject yet.";
      }

      final Uri url = Uri.parse(sheetUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw "Could not open the link.";
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpeningSheet = false);
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
      await Navigator.push(context, MaterialPageRoute(builder: (context) => routes[index]!));
    }

    if (mounted) setState(() => _selectedIndex = -1);
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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
            image: AssetImage('assets/images/Phone_Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: sh * 0.03),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: sh * 0.15),
                    child: Column(
                      children: [
                        _buildQRContainer(sw),
                        SizedBox(height: sh * 0.03),
                        _buildFormContainer(sw),
                        SizedBox(height: sh * 0.04),
                        _buildActionButtons(sw),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
        ),
        Text("Attendance",
            style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: _darkIndigo)),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildQRContainer(double sw) {
    return Container(
      width: double.infinity,
      height: 270.0,
      padding: EdgeInsets.all(sw * 0.06),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: _primaryBlue.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Center(
        child: _qrData.isEmpty
            ? const Text("Generate a session to view QR", style: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey))
            : SizedBox(
          width: 200.0,
          height: 200.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => _primaryGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(3),
                child: Image.asset('assets/images/LOGO.png', fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.06),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.6), width: 2.5),
        boxShadow: [
          BoxShadow(color: _primaryBlue.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Course"),
          const SizedBox(height: 8),
          _buildDropdownField(
            value: _selectedCourse,
            hint: _courses.isEmpty ? "No subjects found" : "Choose the Course",
            items: _courses,
            // Cancel old workflows if the target metadata properties change
            onChanged: (val) => setState(() {
              _selectedCourse = val;
              _qrData = "";
              _refreshTimer?.cancel();
            }),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Session Type"),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      value: _selectedSessionType,
                      hint: "Type",
                      items: _sessionTypes,
                      onChanged: (val) => setState(() {
                        _selectedSessionType = val;
                        _qrData = "";
                        _refreshTimer?.cancel();
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Duration"),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      value: _selectedDuration,
                      hint: "Time",
                      items: _durationOptions,
                      onChanged: (val) => setState(() {
                        _selectedDuration = val;
                        _qrData = "";
                        _refreshTimer?.cancel();
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double sw) {
    return SizedBox(
      width: sw * 0.85 > 320 ? 320 : sw * 0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 55,
              child: OutlinedButton(
                onPressed: _isGenerating ? null : _handleGenerateQR,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _mainPurple, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.white,
                ),
                child: _isGenerating
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2))
                    : Text("Generate QR",
                    style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7B61FF))),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // --- GOOGLE SHEETS BUTTON ---
          SizedBox(
            height: 55,
            width: 65,
            child: OutlinedButton(
              onPressed: _isOpeningSheet ? null : _openGoogleSheet,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(color: _mainPurple, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
              ),
              child: _isOpeningSheet
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2))
                  : Icon(Icons.how_to_reg_rounded, color: _mainPurple, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87));

  Widget _buildDropdownField({required String? value, required String hint, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey.shade400, fontSize: 13), overflow: TextOverflow.ellipsis),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _darkIndigo, size: 28),
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _mainPurple.withValues(alpha: 0.6), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))],
      ),
      child: FloatingActionButton(
        onPressed: _goHome,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _primaryGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, -6))],
      ),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        notchMargin: 9.0,
        color: Colors.white,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavSection([
              _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
              _buildNavBarItem('assets/images/classroom_1.png', "Halls", 1),
            ]),
            const SizedBox(width: 72),
            _buildNavSection([
              _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
              _buildNavBarItem('assets/images/user.png', "Profile", 3),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavSection(List<Widget> items) => Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade500;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 28, height: 28, color: itemColor, errorBuilder: (_, __, ___) => Icon(Icons.circle, size: 28, color: itemColor)),
          const SizedBox(height: 5),
          Flexible(
            child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 12, color: itemColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600)
            ),
          ),
        ],
      ),
    );
  }
}