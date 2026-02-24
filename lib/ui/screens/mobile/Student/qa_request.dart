import 'package:flutter/material.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../profile_screen.dart';
import 'stu_schedule.dart';

class QARequestScreen extends StatefulWidget {
  const QARequestScreen({super.key});

  @override
  State<QARequestScreen> createState() => _QARequestScreenState();
}

class _QARequestScreenState extends State<QARequestScreen> {
  String? _selectedCourse;
  final _subjectController = TextEditingController();
  final _questionController = TextEditingController();

  final int _selectedIndex = 2; // Q&A index
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final List<String> _courses = ["IOT Arch.", "Windows Programming", "CCNA R&S"];

  void _onNavBarTapped(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
    } else if (index == 2) {
      Navigator.pop(context); // Returns to StuQAScreen
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,

      // --- EXACT HOME BUTTON FROM STU_QA_SCREEN ---
      floatingActionButton: SizedBox(
        height: 75,
        width: 75,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _mainPurple.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                  offset: const Offset(0, 12),
                ),
              ],
              gradient: LinearGradient(
                colors: [_primaryBlue, _mainPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 48),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- EXACT BOTTOM NAVIGATION BAR FROM STU_QA_SCREEN ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 5,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 12.0,
          color: Colors.white,
          elevation: 0,
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
              _buildNavBarItem('assets/images/calendar.png', "Schedule", 1),
              const SizedBox(width: 65), // Gap for the 75px button
              _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
              _buildNavBarItem('assets/images/user.png', "Profile", 3),
            ],
          ),
        ),
      ),

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
          child: Column(
            children: [
              _buildTopHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBalancedCard(),
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
                      const SizedBox(height: 80), // Space to keep it above the nav bar
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

  // --- CARD & FIELD STYLES ---

  Widget _buildBalancedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Course"),
          _buildDropdown(),
          const SizedBox(height: 20),
          _buildLabel("Subject"),
          _buildModernField(hint: "Enter topic", controller: _subjectController),
          const SizedBox(height: 20),
          _buildLabel("Question"),
          _buildModernField(
            hint: "Type your question...",
            controller: _questionController,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontFamily: 'Batangas',fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCourse,
          hint: const Text("Choose Course"),
          isExpanded: true,
          items: _courses.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (val) => setState(() => _selectedCourse = val),
        ),
      ),
    );
  }

  Widget _buildModernField({required String hint, required TextEditingController controller, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: 260,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: _mainPurple.withOpacity(0.6), width: 1.5),
      ),
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text("Submit", style: TextStyle(fontFamily: 'Batangas', color: _mainPurple, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.grid_view_rounded, size: 28, color: _mainPurple),
          const Text("Q&A", style: TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6C6ED7))),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(String path, String label, int index) {
    final isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey;

    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 24, color: itemColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Batangas',
              fontSize: 10,
              color: itemColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}