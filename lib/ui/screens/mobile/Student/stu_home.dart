import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import '../settings_screen.dart';
import 'student_id_screen.dart' hide StuSchedule;
import '../profile_screen.dart';
import '../Student/stu_schedule.dart';
import 'stu_community.dart';

class StuHomeScreen extends StatefulWidget {
  const StuHomeScreen({super.key});

  @override
  State<StuHomeScreen> createState() => _StuHomeScreenState();
}

class _StuHomeScreenState extends State<StuHomeScreen> {
  int _selectedIndex = -1;
  String _firstName = 'Student';
  String _lastName = '';
  String _studentID = ''; // Added to track ID for notifications
  String _faculty = '';   // Added to track Faculty for notifications
  bool _isLoading = true;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (mounted) {
      setState(() {
        _firstName = prefs.getString('fName') ?? 'Student';
        _lastName = prefs.getString('lName') ?? '';
        _studentID = prefs.getString('ID') ?? ''; // Loading Student ID
        _faculty = prefs.getString('faculty') ?? ''; // Loading Faculty
        _isLoading = false;
      });
    }
  }

  String _getCurrentDate() {
    return DateFormat('MMMM d, yyyy').format(DateTime.now());
  }

  bool _isNoticeForStudent(Map<String, dynamic> data) {
    final String userId = _studentID.trim();
    final String userProgram = _faculty.trim().toLowerCase();

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

    if (targetType == 'group' && (targetValue == 'students' || targetValue == 'student' || targetValue == 'all')) {
      return true;
    }

    if (targetType == 'program' && userProgram.isNotEmpty && targetValue == userProgram) {
      return true;
    }

    // Backward compatibility for legacy notices with only targetValue.
    if (targetType.isEmpty) {
      if (targetValue == 'all' || targetValue == 'students' || targetValue == 'student') {
        return true;
      }
      if (userProgram.isNotEmpty && targetValue == userProgram) {
        return true;
      }
      if (userId.isNotEmpty && targetValue == userId.toLowerCase()) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(),
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                const SizedBox(height: 30),
                _buildGreetingCard(),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StuSchedule()),
                    );
                  },
                  child: _buildWhiteCard(
                    opacity: 0.4,
                    borderColor: _mainPurple.withValues(alpha: 0.5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Want to check your\nschedule?',
                            style: TextStyle(
                              fontFamily: MobileAppFonts.heading,
                              fontSize: 20,
                              color: Colors.black.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Image.asset('assets/images/main_calender.png', width: 80, height: 80),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- DYNAMIC NOTIFICATION SECTION ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 100),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Notifications')
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyNotices();
                        }

                        final List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _isNoticeForStudent(data);
                        }).toList();

                        // Sort by date (Assuming there is a 'date' field of type Timestamp)
                        filteredDocs.sort((a, b) {
                          final timeA = (a.data() as Map<String, dynamic>)['date'];
                          final timeB = (b.data() as Map<String, dynamic>)['date'];
                          if (timeA is Timestamp && timeB is Timestamp) {
                            return timeB.compareTo(timeA);
                          }
                          return 0;
                        });

                        if (filteredDocs.isEmpty) {
                          return _buildEmptyNotices();
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final data = filteredDocs[index].data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildStudentNotification(
                                title: data['sentBy'] ?? "University Notice",
                                message: data['description'] ?? "",
                                icon: Icons.notifications_none_rounded,
                              ),
                            );
                          },
                        );
                      },
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

  Widget _buildEmptyNotices() {
    return const Center(
      child: Text(
        "No notifications for you yet.",
        style: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.black54),
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, -12)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 7)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi $_firstName $_lastName!".trim(),
            style: const TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          const Text("Good morning", style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Text(_getCurrentDate(), style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14, color: Color(0xFF5BA4F5), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStudentNotification({required String title, required String message, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _mainPurple, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 18, fontWeight: FontWeight.bold, color: _mainPurple)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWhiteCard({required Widget child, Color? borderColor, double opacity = 0.9}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: borderColor ?? _primaryBlue.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: child,
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
            "Home",
            style: TextStyle(
                fontFamily: MobileAppFonts.heading,
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

  Widget _buildFab() {
    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _mainPurple.withValues(alpha: 0.6),
            blurRadius: 25,
            spreadRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentIDScreen()),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: Center(child: Image.asset('assets/images/qr_code.png', width: 38, height: 38, color: Colors.white)),
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
                  _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
                  _buildNavBarItem('assets/images/calendar.png', "Schedule", 1),
                ],
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
                  _buildNavBarItem('assets/images/user.png', "Profile", 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () async {
        setState(() => _selectedIndex = index);

        if (index == 0) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
        } else if (index == 1) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
        } else if (index == 2) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuQAScreen()));
        } else if (index == 3) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        }

        if (mounted) setState(() => _selectedIndex = -1);
      },
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
              fontFamily: MobileAppFonts.body,
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