import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // --- ADDED FOR FIRESTORE ---

import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import '../Student/stu_community.dart';
import '../settings_screen.dart';
import '../Faculty/qa_screen.dart';
import '../profile_screen.dart';

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
  bool _isGenerating = false; // --- NEW: To handle button loading state ---

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

  // --- Logic Methods ---

  Future<void> _loadUserSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedSubjects = prefs.getStringList('subjects');

    // 1. Try to load from Local Storage first (Fastest)
    if (savedSubjects != null && savedSubjects.isNotEmpty) {
      if (mounted) {
        setState(() {
          _courses = savedSubjects!;
        });
      }
      return; // Stop here if we found them!
    }

    // 2. FALLBACK: If local storage is empty, fetch from Firebase!
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

          // Save them locally so we don't have to fetch them again next time!
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

  // --- UPDATED: ASYNC FIREBASE QR GENERATION ---
  Future<void> _handleGenerateQR() async {
    if (_selectedCourse == null || _selectedSessionType == null || _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all fields first", style: TextStyle(fontFamily: 'SpaceGrotesk'))),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // 1. Fetch the subject document to get the subID
      // (Assuming your subjects collection has a field called 'name' that matches the course name)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('subName', isEqualTo: _selectedCourse)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Subject not found in database.");
      }

      // Grab the subID from the document (or use the document ID if that's how it's structured)
      final subjectData = querySnapshot.docs.first.data();
      final String subID = subjectData['subID']?.toString() ?? querySnapshot.docs.first.id;

      // 2. Format the Session Type (L or S)
      final String typeCode = _selectedSessionType == 'Lecture' ? 'L' : 'S';

      // 3. Format the Duration (e.g., '5 mins' -> '5min')
      final String durationCode = _selectedDuration!.replaceAll(' mins', 'min');

      // 4. Stitch it all together
      setState(() {
        _qrData = "${subID}_${typeCode}_$durationCode";
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
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 150),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildQRContainer(),
                const SizedBox(height: 24),
                _buildFormContainer(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
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
            style: TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: _darkIndigo)),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildQRContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
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
            ? const Text("Generate a session to view QR", style: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey))
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

  Widget _buildFormContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            onChanged: (val) => setState(() => _selectedCourse = val),
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
                      onChanged: (val) => setState(() => _selectedSessionType = val),
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
                      onChanged: (val) => setState(() => _selectedDuration = val),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 230,
      height: 55,
      child: OutlinedButton(
        // UPDATED: Disables button and triggers async function
        onPressed: _isGenerating ? null : _handleGenerateQR,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        child: _isGenerating
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2))
            : Text("Generate QR",
            style: TextStyle(fontFamily: 'Batangas', fontSize: 18, fontWeight: FontWeight.bold, color: _darkIndigo)),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(fontFamily: 'Batangas', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87));

  Widget _buildDropdownField({required String? value, required String hint, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400, fontSize: 13), overflow: TextOverflow.ellipsis),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _darkIndigo, size: 28),
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14)))).toList(),
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
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
          Text(label, style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 12, color: itemColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600)),
        ],
      ),
    );
  }
}