import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/services/firebase/qna_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_schedule.dart';
import 'package:uninexus/ui/screens/mobile/profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/settings_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';

class EditQARequestScreen extends StatefulWidget {
  final Map<String, dynamic> item; // Receive the existing Q&A data

  const EditQARequestScreen({super.key, required this.item});

  @override
  State<EditQARequestScreen> createState() => _EditQARequestScreenState();
}

class _EditQARequestScreenState extends State<EditQARequestScreen> {
  final QnAService _qnaService = QnAService();
  late TextEditingController _subjectController;
  late TextEditingController _questionController;

  String? _selectedCourse;
  int _studentYear = 1;
  bool _isInit = false;
  bool _isSubmitting = false;
  final int _selectedIndex = 2;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _textIndigo = const Color(0xFF5C5C80);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    // Pre-fill fields from the database record
    _selectedCourse = widget.item['subject'];
    _subjectController = TextEditingController(text: widget.item['title'] ?? "");
    _questionController = TextEditingController(text: widget.item['question'] ?? "");
    _loadStudentData();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        String? storedYear = prefs.getString('year');
        _studentYear = int.tryParse(storedYear ?? '1') ?? 1;
        _isInit = true;
      });
    }
  }

  void _onNavBarTapped(int index) {
    if (index == _selectedIndex) return;
    final Map<int, Widget> routes = {
      0: const StuCommunity(),
      1: const StuSchedule(),
      3: const ProfileScreen(),
    };
    if (routes.containsKey(index)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => routes[index]!),
      );
    }
  }

  Future<void> _handleUpdate() async {
    if (_selectedCourse == null || _subjectController.text.trim().isEmpty || _questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete all fields")));
      return;
    }

    // Stop execution if no edits were made
    if (_selectedCourse == widget.item['subject'] &&
        _subjectController.text.trim() == widget.item['title'] &&
        _questionController.text.trim() == widget.item['question']) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _qnaService.updateQuestion(
        widget.item['docId'],
        _selectedCourse!,
        _subjectController.text.trim(),
        _questionController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update question.")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _goHome() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';
    Widget targetHome = userId.toUpperCase().startsWith('FA') ? const FacultyHomeScreen() : const StuHomeScreen();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => targetHome), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/Phone_Background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(24, 40, 24, keyboardHeight > 0 ? keyboardHeight + 20 : 150),
                  child: Column(
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
            ),
          ),
          Text("Edit Q&A", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
          const SizedBox(width: 40), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // Matched community screen opacity
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Course"),
          StreamBuilder<List<String>>(
            stream: _qnaService.streamSubjectsByYear(_studentYear),
            builder: (context, snapshot) {
              final subjects = snapshot.data ?? [];
              // Safeguard if existing course is no longer in the list
              if (subjects.isNotEmpty && _selectedCourse != null && !subjects.contains(_selectedCourse)) {
                subjects.add(_selectedCourse!);
              }
              return Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2), // Matched community screen colors
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCourse,
                    hint: Text(snapshot.connectionState == ConnectionState.waiting ? "Loading..." : "Choose Course", style: const TextStyle(fontFamily: MobileAppFonts.body)),
                    isExpanded: true,
                    items: subjects.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (val) => setState(() => _selectedCourse = val),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildLabel("Subject"),
          _buildTextField("Enter topic", _subjectController),
          const SizedBox(height: 20),
          _buildLabel("Question"),
          _buildTextField("Type your question...", _questionController, maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 200, height: 55,
      child: OutlinedButton(
        onPressed: _isSubmitting ? null : _handleUpdate,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(color: _mainPurple)
            : Text("Save Changes", style: TextStyle(fontFamily: MobileAppFonts.heading, color: _mainPurple, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- STANDARD NAV BAR METHODS ---
  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 2))],
      ),
      child: FloatingActionButton(
        onPressed: _goHome, backgroundColor: Colors.transparent, elevation: 0, shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))]),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(), notchMargin: 8.0, color: Colors.white, height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem('assets/images/solidarity_1.png', "Community", 0),
                  _navItem('assets/images/qa.png', "Q&A", 2),

                ],
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem('assets/images/calendar.png', "Schedule", 1),
                  _navItem('assets/images/user.png', "Profile", 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String path, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 26, height: 26, color: isSelected ? _mainPurple : Colors.grey.shade400),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 11, color: isSelected ? _mainPurple : Colors.grey.shade600)),
        ],
      ),
    );
  }
}