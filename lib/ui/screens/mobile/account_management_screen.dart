import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_schedule.dart';
import 'package:uninexus/ui/screens/mobile/profile_screen.dart';


class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false; // Added to manage loading state

  // No specific index highlighted
  final int _selectedIndex = -1;

  final Color _mainPurple = const Color(0xFF7B61FF);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
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

  // --- THE FIREBASE UPDATE LOGIC ---
  Future<void> _updateContactInfo() async {
    final newPhone = _phoneController.text.trim();
    final newEmail = _emailController.text.trim();

    // 1. Validate Input
    if (newPhone.isEmpty && newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a new phone number or email.", style: TextStyle(fontFamily: 'SpaceGrotesk'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Fetch the current User ID
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('ID') ?? '';

      if (userId.isEmpty) throw Exception("User ID not found.");

      // 3. The Prefix Trick: Determine which collection this user lives in!
      String targetCollection = 'students'; // default fallback
      final prefix = userId.toUpperCase();

      if (prefix.startsWith('FA')) {
        targetCollection = 'faculty';
      } else if (prefix.startsWith('ST')) {
        targetCollection = 'students';
      }

      // 4. Find their specific document
      final query = await FirebaseFirestore.instance
          .collection(targetCollection)
          .where('ID', isEqualTo: prefix)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Could not find your profile in the database.");
      }

      final docRef = query.docs.first.reference;

      // 5. Build the update package
      Map<String, dynamic> updates = {};
      if (newPhone.isNotEmpty) updates['pNum'] = newPhone;
      if (newEmail.isNotEmpty) updates['email'] = newEmail;

      // 6. Push to Firebase
      await docRef.update(updates);

      // 7. Update SharedPreferences so the app remembers the new info locally
      if (newPhone.isNotEmpty) await prefs.setString('pNum', newPhone);
      if (newEmail.isNotEmpty) await prefs.setString('email', newEmail);

      // 8. Success Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Contact info updated successfully!", style: TextStyle(fontFamily: 'SpaceGrotesk')),
            backgroundColor: Colors.green,
          ),
        );
        _phoneController.clear();
        _emailController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity, height: double.infinity,
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
                _buildFormCard(),
                const SizedBox(height: 40),
                _buildUpdateButton(),
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
          "Account Man.",
          style: TextStyle(
            fontFamily: 'Batangas',
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

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This feature is used to updating only your contact information for further updates contact the university department",
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),

          // Phone Input
          _buildLabel("New Phone No."),
          const SizedBox(height: 8),
          _buildTextField(_phoneController, "Enter the new Phone no.", TextInputType.phone),

          const SizedBox(height: 16),

          // Email Input
          _buildLabel("New E-mail"),
          const SizedBox(height: 8),
          _buildTextField(_emailController, "Enter the new Email", TextInputType.emailAddress),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Batangas',
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType keyboardType) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // Light grey background
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'SpaceGrotesk'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontFamily: 'SpaceGrotesk',
              color: Colors.grey.shade400,
              fontSize: 13
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 5), // Adjust text alignment
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: 200,
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _updateContactInfo,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        child: _isLoading
            ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2)
        )
            : Text(
          "Update",
          style: TextStyle(
            fontFamily: 'Batangas',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _mainPurple,
          ),
        ),
      ),
    );
  }

  // --- GLOWING HOME FAB ---
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

  // --- BOTTOM NAVIGATION BAR ---
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