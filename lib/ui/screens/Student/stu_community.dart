import 'package:flutter/material.dart';
import 'package:uninexus/ui/screens/Student/student_id_screen.dart';
import 'stu_schedule.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/Faculty/qa_screen.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────
class CommunityPost {
  final String title;
  final String body;
  bool isExpanded;

  CommunityPost({
    required this.title,
    required this.body,
    this.isExpanded = false,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class StuCommunity extends StatefulWidget {
  const StuCommunity({super.key});

  @override
  State<StuCommunity> createState() => _StuCommunityState();
}

class _StuCommunityState extends State<StuCommunity> {
  final int _selectedIndex = 0;

  final Color _mainPurple  = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _textIndigo  = const Color(0xFF5C5C80);

  final List<CommunityPost> _posts = [
    CommunityPost(
      title: 'GPIO pins usage on Raspberry Pi',
      body:  'How do I use GPIO pins and ADC on Raspberry Pi with Python? '
             'I need to read analog sensor values but the Pi only has digital pins.',
    ),
    CommunityPost(
      title: 'CCNA R&S new task Protocols',
      body:  'Is there a way to find the ports and protocols currently open or being '
             'used by the ECS Fargate Services, so that we could specifically open only '
             'those ports and protocols in the NACL? ...',
      isExpanded: true,
    ),
    CommunityPost(
      title: 'RSA Key composition and process',
      body:  "I still don't get the point of multiple prime factors in RSA. "
             'Can anyone explain the key generation steps simply?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildQrFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                _buildTopHeader(),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => _buildPostCard(_posts[i]),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top Header ────────────────────────────────────────────────────────────
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
        ),
        Text(
          'Community',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _mainPurple,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/uni.jpeg', width: 36, height: 36),
        ),
      ],
    );
  }

  // ── Post Card ─────────────────────────────────────────────────────────────
  Widget _buildPostCard(CommunityPost post) {
    return GestureDetector(
      onTap: () => setState(() => post.isExpanded = !post.isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _mainPurple.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(Icons.help_outline_rounded, size: 18, color: _mainPurple),
                ),
                const SizedBox(width: 10),
                Container(width: 1.5, height: 30, color: _mainPurple.withOpacity(0.3)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                    ),
                  ),
                ),
                Icon(
                  post.isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _mainPurple,
                  size: 26,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              post.body,
              maxLines: post.isExpanded ? null : 1,
              overflow: post.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: _textIndigo,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildQrFab() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _mainPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const StudentIDScreen()),
  );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [_primaryBlue, _mainPurple]),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // ── Bottom Navigation Bar ─────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/images/solidarity_1.png', 'Community', 0),
          _navItem('assets/images/calendar.png',     'Schedule',  1),
          const SizedBox(width: 48),
          _navItem('assets/images/qa.png',           'Q&A',       2),
          _navItem('assets/images/user.png',         'Profile',   3),
        ],
      ),
    );
  }

  Widget _navItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == _selectedIndex) return;

        if (index == 0) {
          // ✅ يرجع للهوم
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StuSchedule()),
          );
        }

        if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QAScreen()));
        }

        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 24, color: sel ? _mainPurple : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: sel ? _mainPurple : Colors.grey,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}