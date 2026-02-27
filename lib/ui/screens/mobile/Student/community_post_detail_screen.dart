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
  int _selectedIndex = -1;
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _textIndigo = const Color(0xFF5C5C80);

  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();

  bool _isStudent = true;
  bool _isLoading = true;

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      String id = prefs.getString('ID') ?? prefs.getString('userCode') ?? "N/A";
      if (mounted) {
        setState(() {
          _isStudent = id.toUpperCase().startsWith('ST');
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
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

  // --- UPDATED POST CARD ---
  Widget _buildPostCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // Glassy Opacity
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withOpacity(0.12), // Soft Tinted Shadow
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          )
        ],
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

  // --- UPDATED REPLIES SECTION ---
  Widget _buildRepliesSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6), // Glassy Opacity
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _mainPurple.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF237ABA).withOpacity(0.12),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ],
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
                      Text(reply.author, style: TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple)),
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
      bottom: 130,
      right: 24,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityPostScreen())),
        child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Center(
              child: Image.asset(
                  'assets/images/solidarity_1.png',
                  width: 50, // Increased size
                  height: 50,
                  fit: BoxFit.contain,
                  color: _mainPurple
              )
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
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)), // Increased size
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
                _navItem('assets/images/solidarity_1.png', 'Community', 0),
                _navItem('assets/images/calendar.png', 'Schedule', 1),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', 'Q&A', 2),
                _navItem('assets/images/user.png', 'Profile', 3),
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
                _navItem('assets/images/solidarity_1.png', 'Community', 0),
                _navItem('assets/images/classroom_1.png', 'Halls', 1),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', 'Q&A', 2),
                _navItem('assets/images/user.png', 'Profile', 3),
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
        child: child,
      ),
    );
  }

  Widget _navItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () async {
        setState(() => _selectedIndex = index);
        if (index == 0) {
          Navigator.of(context).pop();
        } else if (index == 1) {
          if (_isStudent) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuSchedule()));
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const HallsScreen()));
          }
        } else if (index == 2) {
          if (_isStudent) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const StuQAScreen()));
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const QAScreen()));
          }
        } else if (index == 3) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
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