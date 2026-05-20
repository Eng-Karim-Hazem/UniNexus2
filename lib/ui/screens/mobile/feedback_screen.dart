import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_schedule.dart';
import 'package:uninexus/ui/screens/mobile/profile_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 4;
  bool _isLoading = false;

  final int _selectedIndex = -1;
  final Color _mainPurple = const Color(0xFF7B61FF);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('ID') ?? 'Unknown ID';
      final String fName = prefs.getString('fName') ?? '';
      final String lName = prefs.getString('lName') ?? '';
      final String fullName = '$fName $lName'.trim();

      await FirebaseFirestore.instance.collection('Feedback').add({
        'userId': userId,
        'userName': fullName.isEmpty ? 'Unknown User' : fullName,
        'rating': _rating,
        'message': feedbackText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Feedback Submitted! Thank you.", style: TextStyle(fontFamily: MobileAppFonts.body)),
            backgroundColor: Colors.green,
          ),
        );
        _feedbackController.clear();
        setState(() => _rating = 4);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onNavBarTapped(int index) async {
    if (index == 0) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    } else if (index == 1) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
    } else if (index == 2) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuQAScreen()));
    } else if (index == 3) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // FIXED: Prevents FAB and Bottom Bar from moving with the keyboard
      resizeToAvoidBottomInset: false,
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity, height: double.infinity,
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
                    // FIXED: Dynamic padding allows scrolling over the keyboard area
                    padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? keyboardHeight + 20 : sh * 0.15),
                    child: Column(
                      children: [
                        _buildFormCard(sw),
                        SizedBox(height: sh * 0.04),
                        _buildSubmitButton(sw),
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
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
        ),
        const Text(
          "Feedback",
          style: TextStyle(
            fontFamily: MobileAppFonts.heading,
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
    );
  }

  Widget _buildFormCard(double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.06),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This feature is used to express your experience with our system till this moment and maybe drop some notes to make the journey more smooth.",
            style: TextStyle(
              fontFamily: MobileAppFonts.body,
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),
          _buildLabel("Rate our app"),
          const SizedBox(height: 8),
          _buildStarRating(),
          const SizedBox(height: 20),
          _buildLabel("Question"),
          const SizedBox(height: 8),
          Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: 6,
              maxLength: 250,
              style: const TextStyle(fontFamily: MobileAppFonts.body),
              decoration: InputDecoration(
                hintText: "Submit your Question maximum 250 letters...",
                hintStyle: TextStyle(
                    fontFamily: MobileAppFonts.body,
                    color: Colors.grey.shade400,
                    fontSize: 13
                ),
                border: InputBorder.none,
                counterStyle: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: MobileAppFonts.heading,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _rating = index + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.star_rounded,
              size: 40,
              color: index < _rating ? const Color(0xFF7B61FF) : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton(double sw) {
    return SizedBox(
      width: sw * 0.5 > 200 ? 200 : sw * 0.5,
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _submitFeedback,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        child: _isLoading
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2))
            : Text(
          "Submit",
          style: TextStyle(
            fontFamily: MobileAppFonts.heading,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _mainPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: _mainPurple.withOpacity(0.6), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))
        ],
      ),
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
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, -6))
        ],
      ),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(),
        notchMargin: 9.0, color: Colors.white, height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem('assets/images/solidarity_1.png', "Community", 0),
                  _navItem('assets/images/calendar.png', "Schedule", 1),
                ],
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem('assets/images/qa.png', "Q&A", 2),
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
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 28, height: 28, color: sel ? _mainPurple : Colors.grey.shade500),
          const SizedBox(height: 5),
          Flexible(
            child: Text(
              label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: MobileAppFonts.body, fontSize: 12,
                color: sel ? _mainPurple : Colors.grey.shade600,
                fontWeight: sel ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}