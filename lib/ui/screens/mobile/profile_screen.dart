import 'dart:convert'; // Required for base64Decode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/settings_screen.dart';

import 'Faculty/halls_screen.dart';
import 'Faculty/qa_screen.dart';
import 'Student/stu_qa_screen.dart';
import 'Student/stu_schedule.dart';

class ProfileScreen extends StatefulWidget {
  final String? userID;
  final String? firstName;
  final String? lastName;

  const ProfileScreen({
    super.key,
    this.userID,
    this.firstName,
    this.lastName,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);

  // Identity and Contact Variables
  String _displayFirstName = "User";
  String _displayLastName = "";
  String _displayID = "";
  String _displayEmail = "N/A";
  String _displayPhone = "N/A";
  String _displayFaculty = "N/A";
  String _displayNID = "N/A";
  String _displayYear = "N/A";
  String _displaySection = "N/A";

  // Photo Variable
  String? _base64Photo;

  bool _isStudent = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      String id = prefs.getString('ID') ?? prefs.getString('userCode') ?? widget.userID ?? "N/A";

      if (mounted) {
        setState(() {
          _displayID = id;
          _isStudent = id.toUpperCase().startsWith('ST');
          _displayFirstName = prefs.getString('fName') ?? prefs.getString('userFirstName') ?? "User";
          _displayLastName = prefs.getString('lName') ?? prefs.getString('userLastName') ?? "";
          _displayEmail = prefs.getString('email') ?? "N/A";
          _displayPhone = prefs.getString('pNum') ?? "N/A";
          _displayFaculty = prefs.getString('faculty') ?? "N/A";
          _displayNID = prefs.getString('nID') ?? "N/A";

          // Load the photo from SharedPreferences
          _base64Photo = prefs.getString('photo');

          if (_isStudent) {
            _displayYear = prefs.getString('year') ?? "N/A";
            _displaySection = prefs.getString('section') ?? "N/A";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _isStudent ? _buildStudentBottomBar() : _buildFacultyBottomBar(),
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
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: _mainPurple))
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                _buildTopHeader(),
                const SizedBox(height: 30),
                _buildIdentityCard(),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildScrollableDetailsCard(),
                ),
                const SizedBox(height: 110),
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
            "Profile",
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

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          // Updated Photo Logic
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _mainPurple.withValues(alpha: 0.1),
            ),
            child: ClipOval(
              child: _base64Photo != null && _base64Photo!.isNotEmpty
                  ? Image.memory(
                base64Decode(_base64Photo!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackIcon(),
              )
                  : _buildFallbackIcon(),
            ),
          ),
          const SizedBox(width: 15),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$_displayFirstName $_displayLastName",
                    style: const TextStyle(fontFamily: 'Batangas', fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_displayID,
                    style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fallback icon helper
  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(Icons.person, color: _mainPurple, size: 40),
    );
  }

  Widget _buildScrollableDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.4), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileField("Faculty :", _displayFaculty),
              if (_isStudent) ...[
                _buildProfileField("Academic Year :", _displayYear),
                _buildProfileField("Section :", _displaySection),
              ],
              _buildProfileField("E-mail :", _displayEmail),
              _buildProfileField("Phone no. :", _displayPhone),
              _buildProfileField("National ID :", _displayNID),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Batangas', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Divider(color: _mainPurple.withValues(alpha: 0.1), thickness: 1),
        ],
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
              color: _mainPurple.withValues(alpha: 0.6),
              blurRadius: 25,
              spreadRadius: 6,
              offset: const Offset(0, 2),
            )
          ]
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: double.infinity, height: double.infinity,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_primaryBlue, _mainPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  Widget _buildStudentBottomBar() {
    return _bottomNavWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem('assets/images/solidarity_1.png', "Community", false, onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
                }),
                _navItem('assets/images/calendar.png', "Schedule", false, onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
                }),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', "Q&A", false, onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StuQAScreen()));
                }),
                _navItem('assets/images/user.png', "Profile", true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyBottomBar() {
    return _bottomNavWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem('assets/images/solidarity_1.png', "Community", false, onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
                }),
                _navItem('assets/images/classroom_1.png', "Halls", false, onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HallsScreen()));
                }),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', "Q&A", false, onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const QAScreen()));
                }),
                _navItem('assets/images/user.png', "Profile", true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavWrapper({required Widget child}) {
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
        child: child,
      ),
    );
  }

  Widget _navItem(String path, String label, bool sel, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
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