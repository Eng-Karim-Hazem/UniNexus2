import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../settings_screen.dart';
import 'faculty_id_screen.dart';
import '../Faculty/qa_screen.dart';
import '../profile_screen.dart';
import 'halls_screen.dart';
import 'attendance_session_screen.dart';

class FacultyHomeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;

  const FacultyHomeScreen({
    super.key,
    this.firstName = "Faculty",
    this.lastName = "",
  });

  @override
  State<FacultyHomeScreen> createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen> {
  int _selectedIndex = -1;
  String _storedFirstName = "";
  String _storedLastName = "";
  String _storedUserID = "";

  // Subjects are still loaded in the background for filtering
  List<String> _facultySubjects = [];

  // Constants & Styles
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _textIndigo = const Color(0xFF5C5C80);
  final Color _darkText = const Color(0xFF1A1A1A);
  final Color _dateBlue = const Color(0xFF5BA4F5);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _storedFirstName = widget.firstName;
    _storedLastName = widget.lastName;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _storedFirstName = prefs.getString('fName') ?? "Faculty";
        _storedLastName = prefs.getString('lName') ?? "";
        _storedUserID = prefs.getString('ID') ?? "No ID";
        // We still need these to filter the notifications automatically
        _facultySubjects = prefs.getStringList('facultySubjects') ?? [];
      });
    }
  }

  String _getCurrentDate() {
    return DateFormat('MMMM d, yyyy').format(DateTime.now());
  }

  bool _isNoticeForFaculty(Map<String, dynamic> data) {
    final String userId = _storedUserID.trim();
    final List<String> specializations = _facultySubjects.map((e) => e.trim().toLowerCase()).toList();

    final List<String> recipientIds = (data['recipientIds'] as List<dynamic>? ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (userId.isNotEmpty && recipientIds.contains(userId)) {
      return true;
    }

    final String targetType = (data['type'] ?? '').toString().trim().toLowerCase();
    final String targetValue = (data['targetValue'] ?? '').toString().trim().toLowerCase();

    if (targetType == 'individual' && userId.isNotEmpty && targetValue == userId.toLowerCase()) {
      return true;
    }

    if (targetType == 'group' && (targetValue == 'faculty' || targetValue == 'all')) {
      return true;
    }

    if (targetType == 'specialization' && specializations.contains(targetValue)) {
      return true;
    }

    // Backward compatibility for legacy notices with only targetValue.
    if (targetType.isEmpty) {
      if (targetValue == 'faculty' || targetValue == 'all') {
        return true;
      }
      if (specializations.contains(targetValue)) {
        return true;
      }
      if (userId.isNotEmpty && targetValue == userId.toLowerCase()) {
        return true;
      }
    }

    return false;
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

    if (mounted) {
      setState(() => _selectedIndex = -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grab screen dimensions for perfect proportions
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildFab(),
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
          child: SingleChildScrollView(
            // Master padding for the entire screen!
            padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                SizedBox(height: sh * 0.03),
                _buildGreetingCard(sw, sh),
                SizedBox(height: sh * 0.03),
                _buildActionButtons(sw, sh),
                SizedBox(height: sh * 0.03),
                _buildNotificationsArea(sw, sh),
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
        ),
        Text("Home",
            style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(double sw, double sh) {
    return Container(
      width: double.infinity,
      // Dynamic padding
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.025),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi Dr. $_storedFirstName $_storedLastName!",
            style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 26, fontWeight: FontWeight.w900, color: _darkText),
          ),
          const SizedBox(height: 8),
          Text(_getCurrentDate(),
              style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14, color: _dateBlue, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double sw, double sh) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
              "Halls",
              'assets/images/classroom_1.png',
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HallsScreen())),
              sh
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
              "Attendance",
              'assets/images/user-check_1.png',
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceSessionScreen())),
              sh
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String iconPath, VoidCallback onTap, double sh) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Dynamic height based on screen size
        height: sh * 0.15 > 125 ? sh * 0.15 : 125,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: _mainPurple.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 38, height: 38, color: _textIndigo),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsArea(double sw, double sh) {
    return Container(
      width: double.infinity,
      // Large bottom margin to ensure content doesn't get hidden behind the floating button
      margin: EdgeInsets.only(bottom: sh * 0.15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: _primaryBlue.withOpacity(0.12), blurRadius: 25, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Notifications')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.all(sw * 0.05),
                child: Center(child: CircularProgressIndicator(color: _mainPurple)),
              );
            }

            if (snapshot.hasError) return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Error.')));

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No announcements.')));
            }

            final List<QueryDocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _isNoticeForFaculty(data);
            }).toList();

            docs.sort((a, b) {
              final timeA = (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
              final timeB = (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
              if (timeA != null && timeB != null) return timeB.compareTo(timeA);
              return 0;
            });

            if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No relevant notices.')));

            return ListView.builder(
              padding: EdgeInsets.all(sw * 0.04),
              // --- MAGIC TRICK: ShrinkWrap allows list inside ScrollView ---
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final sender = data['sentBy'] ?? 'Management';
                final message = data['description'] ?? '';
                final timestamp = data['date'] as Timestamp?;
                String timeStr = timestamp != null ? DateFormat('MMM d, h:mm a').format(timestamp.toDate()) : '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNotifyItem(sender, message, timeStr),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotifyItem(String title, String msg, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: _mainPurple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TextStyle(fontFamily: MobileAppFonts.heading, fontWeight: FontWeight.bold, color: _mainPurple)),
              ),
              if (time.isNotEmpty)
                Text(time, style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(msg, style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.6), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))]),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FacultyIDScreen())),
        elevation: 0, backgroundColor: Colors.transparent, shape: const CircleBorder(),
        child: Container(decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient), child: Padding(padding: const EdgeInsets.all(18.0), child: Image.asset('assets/icons/QR_Icon.png', color: Colors.white))),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, -6))]),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(), notchMargin: 9.0, color: Colors.white, height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildNavBarItem('assets/images/solidarity_1.png', "Community", 0), _buildNavBarItem('assets/images/classroom_1.png', "Halls", 1)])),
            const SizedBox(width: 72),
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildNavBarItem('assets/images/qa.png', "Q&A", 2), _buildNavBarItem('assets/images/user.png', "Profile", 3)])),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade500;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index), behavior: HitTestBehavior.opaque,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 28, height: 28, color: itemColor),
            const SizedBox(height: 5),
            // Flexible wrapper added here!
            Flexible(
              child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 12, color: isSelected ? _mainPurple : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600)
              ),
            )
          ]
      ),
    );
  }
}