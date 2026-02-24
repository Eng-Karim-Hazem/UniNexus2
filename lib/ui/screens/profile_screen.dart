import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/Student/stu_community.dart';
import 'Student/stu_schedule.dart';
import 'Faculty/qa_screen.dart';
import 'Faculty/halls_screen.dart';

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
  final Color _textIndigo = const Color(0xFF5C5C80);

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

      setState(() {
        _displayID = id;
        _isStudent = id.toUpperCase().startsWith('ST');
        _displayFirstName = prefs.getString('fName') ?? prefs.getString('userFirstName') ?? "User";
        _displayLastName = prefs.getString('lName') ?? prefs.getString('userLastName') ?? "";
        _displayEmail = prefs.getString('email') ?? "N/A";
        _displayPhone = prefs.getString('pNum') ?? "N/A";
        _displayFaculty = prefs.getString('faculty') ?? "N/A";
        _displayNID = prefs.getString('nationalID') ?? "N/A";

        if (_isStudent) {
          _displayYear = prefs.getString('year') ?? "N/A";
          _displaySection = prefs.getString('section') ?? "N/A";
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // Fixed: Both use the same Home Button design now
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
                _buildHeader(),
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

  // --- UI COMPONENTS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
        ),
        Text("Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/uni.jpeg', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: _mainPurple,
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 15),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$_displayFirstName $_displayLastName",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_displayID,
                    style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.4), width: 1.5),
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
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Divider(color: _mainPurple.withOpacity(0.1), thickness: 1),
        ],
      ),
    );
  }

  // --- NAVIGATION (SYNCED HOME BUTTON) ---

  Widget _buildHomeFab() {
    return Container(
      height: 70, width: 70,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: _mainPurple.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8)
            )
          ]
      ),
      child: FloatingActionButton(
        // Returns to the first screen (Home) regardless of role
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
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildStudentBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/images/solidarity_1.png', "Community", false,onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
          }),
          _navItem('assets/images/calendar.png', "Schedule", false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
          }),
          const SizedBox(width: 48), // Gap for Home FAB
          _navItem('assets/images/qa.png', "Q&A", false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QAScreen()));
          }),
          _navItem('assets/images/user.png', "Profile", true),
        ],
      ),
    );
  }

  Widget _buildFacultyBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/images/classroom_1.png', "Halls", false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HallsScreen()));
          }),
          _navItem('assets/images/qa.png', "Q&A", false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QAScreen()));
          }),
          const SizedBox(width: 48), // Gap for Home FAB
          _navItem('assets/images/notification.png', "Alerts", false),
          _navItem('assets/images/user.png', "Profile", true),
        ],
      ),
    );
  }

  Widget _navItem(String path, String label, bool sel, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 24, color: sel ? _mainPurple : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: sel ? _mainPurple : Colors.grey, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}