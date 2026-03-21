import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/model/qna_model.dart';
import 'package:uninexus/services/firebase/qna_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_schedule.dart';
import 'package:uninexus/ui/screens/mobile/profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/settings_screen.dart';

class QARequestScreen extends StatefulWidget {
  const QARequestScreen({super.key});

  @override
  State<QARequestScreen> createState() => _QARequestScreenState();
}

class _QARequestScreenState extends State<QARequestScreen> {
  final QnAService _qnaService = QnAService();
  final _subjectController = TextEditingController();
  final _questionController = TextEditingController();

  String? _selectedCourse;
  int _studentYear = 1;
  bool _isInit = false;
  bool _isSubmitting = false;
  final int _selectedIndex = 2; // Fixed index for Q&A screen

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? storedYear = prefs.getString('year');
      _studentYear = int.tryParse(storedYear ?? '1') ?? 1;
      _isInit = true;
    });
  }

  // Handle Bottom Navigation Clicks
  void _onNavBarTapped(int index) {
    if (index == _selectedIndex) return; // Already on this screen

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const StuCommunity();
        break;
      case 1:
        nextScreen = const StuSchedule();
        break;
      case 3:
        nextScreen = const ProfileScreen();
        break;
      default:
        return;
    }

    // Use pushReplacement to avoid building a massive navigation stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedCourse == null || _subjectController.text.isEmpty || _questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete all fields")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();


      String firstName = prefs.getString('fName') ?? "";
      String lastName = prefs.getString('lName') ?? "";
      String fullName = "$firstName $lastName".trim();


      final qna = QnAModel(
        title: _subjectController.text,
        question: _questionController.text,
        subject: _selectedCourse!,
        sEmail: prefs.getString('email') ?? "",
        sName: fullName,
        id: prefs.getString('ID') ?? "",
      );

      await _qnaService.submitQuestion(qna);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to submit question.")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
            image: DecorationImage(image: AssetImage('assets/images/background.png'), fit: BoxFit.cover)),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildFormCard(),
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
                      const SizedBox(height: 100),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
            child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
          ),
          const Text(
            "Q&A",
            style: TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80)),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Course"),
          StreamBuilder<List<String>>(
            stream: _qnaService.streamSubjectsByYear(_studentYear),
            builder: (context, snapshot) {
              List<String> subjects = snapshot.data ?? [];
              return Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCourse,
                    hint: Text(snapshot.connectionState == ConnectionState.waiting ? "Loading..." : "Choose Course"),
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
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: 200,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.6), width: 1.5),
      ),
      child: TextButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        child: _isSubmitting
            ? CircularProgressIndicator(color: _mainPurple)
            : Text("Submit", style: TextStyle(color: _mainPurple, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _mainPurple.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 2))]),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))]),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_navItem('assets/images/solidarity_1.png', "Community", 0), _navItem('assets/images/calendar.png', "Schedule", 1)])),
            const SizedBox(width: 80),
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_navItem('assets/images/qa.png', "Q&A", 2), _navItem('assets/images/user.png', "Profile", 3)])),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String path, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 26, height: 26, color: isSelected ? _mainPurple : Colors.grey.shade400),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isSelected ? _mainPurple : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}