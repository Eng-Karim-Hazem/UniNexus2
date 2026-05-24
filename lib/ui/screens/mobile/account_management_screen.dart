import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_schedule.dart';
import 'package:uninexus/ui/screens/mobile/profile_screen.dart';

// --- NEW IMPORTS FOR DYNAMIC HOME ROUTING ---
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';

import 'Faculty/halls_screen.dart';
import 'Faculty/qa_screen.dart';


class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isFaculty = false; // Add this
  bool _isLoadingRole = true; // Add this
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
    if (_isFaculty) {
      // Faculty routes
      if (index == 0) await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuCommunity()));
      else if (index == 1) await Navigator.push(context, MaterialPageRoute(builder: (_) => const HallsScreen())); // Import needed
      else if (index == 2) await Navigator.push(context, MaterialPageRoute(builder: (_) => const QAScreen())); // Faculty Q&A
      else if (index == 3) await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    } else {
      // Student routes
      if (index == 0) await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuCommunity()));
      else if (index == 1) await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuSchedule()));
      else if (index == 2) await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuQAScreen()));
      else if (index == 3) await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }
  @override
  void initState() {
    super.initState();
    _loadUserRole(); // Call the role loader
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';
    if (mounted) {
      setState(() {
        _isFaculty = userId.toUpperCase().startsWith('FA');
        _isLoadingRole = false;
      });
    }
  }
  // Helper for showing error SnackBars cleanly
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: MobileAppFonts.body)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- NEW: DYNAMIC HOME ROUTING ---
  Future<void> _goHome() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';

    Widget targetHome;

    // Check if the user is Faculty or Student
    if (userId.toUpperCase().startsWith('FA')) {
      targetHome = const FacultyHomeScreen();
    } else {
      targetHome = const StuHomeScreen(); // Default to Student
    }

    if (!mounted) return;

    // pushAndRemoveUntil clears the navigation stack so the back button behaves properly
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetHome),
          (route) => false,
    );
  }

  Future<void> _updateContactInfo() async {
    final newPhone = _phoneController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newPhone.isEmpty && newEmail.isEmpty) {
      _showError("Please enter a new phone number or email.");
      return;
    }

    if (newPhone.isNotEmpty) {
      if (newPhone.length != 11 || !newPhone.startsWith('01')) {
        _showError("Please enter a valid 11-digit phone number starting with '01'.");
        return;
      }
    }

    if (newEmail.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(newEmail)) {
        _showError("Please enter a valid email address.");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('ID') ?? '';

      if (userId.isEmpty) throw Exception("User ID not found.");

      String targetCollection = 'students';
      final prefix = userId.toUpperCase();

      if (prefix.startsWith('FA')) {
        targetCollection = 'faculty';
      } else if (prefix.startsWith('ST')) {
        targetCollection = 'students';
      }

      final query = await FirebaseFirestore.instance
          .collection(targetCollection)
          .where('ID', isEqualTo: prefix)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Could not find your profile in the database.");
      }

      final docRef = query.docs.first.reference;

      Map<String, dynamic> updates = {};
      if (newPhone.isNotEmpty) updates['pNum'] = newPhone;
      if (newEmail.isNotEmpty) updates['email'] = newEmail;

      await docRef.update(updates);

      if (newPhone.isNotEmpty) await prefs.setString('pNum', newPhone);
      if (newEmail.isNotEmpty) await prefs.setString('email', newEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Contact info updated successfully!", style: TextStyle(fontFamily: MobileAppFonts.body)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _phoneController.clear();
        _emailController.clear();
      }

    } catch (e) {
      if (mounted) {
        _showError("Error: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
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
                    padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? keyboardHeight + 20 : sh * 0.15),
                    child: Column(
                      children: [
                        _buildFormCard(sw),
                        SizedBox(height: sh * 0.04),
                        _buildUpdateButton(sw),
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
          "Account Man.",
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
            "This feature is used to updating only your contact information for further updates contact the university department",
            style: TextStyle(
              fontFamily: MobileAppFonts.body,
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),
          _buildLabel("New Phone No."),
          const SizedBox(height: 8),
          _buildTextField(
              controller: _phoneController,
              hint: "Enter the new Phone no.",
              keyboardType: TextInputType.phone,
              isPhone: true
          ),
          const SizedBox(height: 16),
          _buildLabel("New E-mail"),
          const SizedBox(height: 8),
          _buildTextField(
              controller: _emailController,
              hint: "Enter the new Email",
              keyboardType: TextInputType.emailAddress
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    bool isPhone = false,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: isPhone ? 11 : null,
        inputFormatters: isPhone
            ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)]
            : null,
        style: const TextStyle(fontFamily: MobileAppFonts.body),
        decoration: InputDecoration(
          hintText: hint,
          counterText: "",
          hintStyle: TextStyle(
              fontFamily: MobileAppFonts.body,
              color: Colors.grey.shade400,
              fontSize: 13
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 5),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(double sw) {
    return SizedBox(
      width: sw * 0.5 > 200 ? 200 : sw * 0.5,
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
        // --- UPDATED FAB ACTION ---
        onPressed: _goHome,
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
                    _navItem('assets/images/solidarity_1.png', "Community", 0),
                    // --- DYNAMIC SWITCH ---
                    _isFaculty
                        ? _navItem('assets/images/classroom_1.png', "Halls", 1)
                        : _navItem('assets/images/calendar.png', "Schedule", 1),
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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: MobileAppFonts.body,
                fontSize: 12,
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