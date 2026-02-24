import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import 'stu_schedule.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import 'create_community_post_screen.dart';
import 'stu_community.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final int _selectedIndex = 0;
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _textIndigo = const Color(0xFF5C5C80);

  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();

  // Navigation Logic Variables matching ProfileScreen
  bool _isStudent = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  // Identity logic matching ProfileScreen.dart
  Future<void> _checkUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      String id = prefs.getString('ID') ?? prefs.getString('userCode') ?? "N/A";
      setState(() {
        _isStudent = id.toUpperCase().startsWith('ST');
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    if (_replyController.text.trim().isEmpty) return;

    setState(() {
      widget.post.replies.add(PostReply(author: "Me", text: _replyController.text.trim()));
      _replyController.clear();
      _isReplying = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Matches bottom navigation selection from ProfileScreen
      bottomNavigationBar: _isLoading
          ? const SizedBox(height: 80)
          : (_isStudent ? _buildStudentBottomBar() : _buildFacultyBottomBar()),
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    _buildTopHeader(),
                    const SizedBox(height: 20),
                    _buildPostCard(),
                    const SizedBox(height: 16),
                    _buildRepliesSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              _buildCreatePostFab(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Original UI Components ---

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
        ),
        Text(
          'Community',
          style: TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: _mainPurple),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildPostCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _mainPurple.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 24, color: _mainPurple),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.post.title,
                  style: TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.post.body,
            style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mainPurple.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Replies", style: TextStyle(fontFamily: 'Batangas', fontSize: 18, fontWeight: FontWeight.bold, color: _mainPurple)),
                GestureDetector(
                  onTap: () => setState(() => _isReplying = !_isReplying),
                  child: Icon(_isReplying ? Icons.close_rounded : Icons.add_rounded, color: _mainPurple, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isReplying) _buildReplyInput(),
            Expanded(
              child: widget.post.replies.isEmpty
                  ? const Center(child: Text("No replies yet.", style: TextStyle(fontFamily: 'SpaceGrotesk')))
                  : ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.post.replies.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final reply = widget.post.replies[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reply.author, style: TextStyle(fontFamily: 'Batangas', fontSize: 14, fontWeight: FontWeight.bold, color: _mainPurple)),
                      const SizedBox(height: 4),
                      Text(reply.text, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, color: Colors.black)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(24)),
      child: TextField(
        controller: _replyController,
        style: const TextStyle(fontFamily: 'SpaceGrotesk'),
        decoration: InputDecoration(
          hintText: "Type your reply...",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(onPressed: _submitReply, icon: Icon(Icons.send_rounded, color: _mainPurple)),
        ),
      ),
    );
  }

  Widget _buildCreatePostFab() {
    return Positioned(
      bottom: 110,
      right: 24,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityPostScreen())),
        child: Container(
          width: 65, height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Center(child: Image.asset('assets/images/solidarity_1.png', width: 32, color: _mainPurple)),
        ),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 70, width: 70,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [_primaryBlue, _mainPurple])),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 32)),
        ),
      ),
    );
  }

  // --- Dynamic Bottom Navigation Bars ---

  Widget _buildStudentBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/images/solidarity_1.png', 'Community', true),
          _navItem('assets/images/calendar.png', 'Schedule', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StuSchedule()))),
          const SizedBox(width: 48),
          _navItem('assets/images/qa.png', 'Q&A', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StuQAScreen()))),
          _navItem('assets/images/profile.png', 'Profile', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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
          _navItem('assets/images/solidarity_1.png', 'Community', true),
          _navItem('assets/images/classroom_1.png', 'Halls', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HallsScreen()))),
          const SizedBox(width: 48),
          _navItem('assets/images/qa.png', 'Q&A', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QAScreen()))),
          _navItem('assets/images/profile.png', 'Profile', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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
          Text(label, style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 10, color: sel ? _mainPurple : Colors.grey)),
        ],
      ),
    );
  }
}