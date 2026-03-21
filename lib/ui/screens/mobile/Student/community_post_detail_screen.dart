import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for direct name fetching
import 'package:uninexus/model/community_model.dart';
import 'package:uninexus/services/firebase/community_service.dart';

import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import 'stu_schedule.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import 'create_community_post_screen.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final CommunityPostModel post;

  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  // Service
  final _communityService = CommunityService();

  final Color _mainPurple = const Color(0xFF7B61FF);

  bool _isReplying = false;
  bool _isSending = false;
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
          _isStudent = !id.toUpperCase().startsWith('FA');
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

  // --- UPDATED: ROBUST NAME FETCHING ---
  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the ID
      String userId = prefs.getString('userCode') ?? prefs.getString('ID') ?? '';

      // Check if user is Faculty based on ID prefix
      bool isFaculty = userId.toUpperCase().startsWith('FA');

      String fName = "";
      String lName = "";

      // 1. First, check local SharedPreferences (using your app's common keys)
      // Note: Adjust these keys if your login screen saves them differently
      fName = prefs.getString('fName') ?? prefs.getString('userFirstName') ?? '';
      lName = prefs.getString('lName') ?? prefs.getString('userLastName') ?? '';

      // 2. If missing locally, fetch from Firestore using YOUR EXACT FIELD NAMES
      if (fName.isEmpty && userId.isNotEmpty) {
        try {
          if (isFaculty) {
            var doc = await FirebaseFirestore.instance.collection('faculty').doc(userId).get();
            if (doc.exists) {
              // Using keys from your screenshot: fName, lName
              fName = doc.data()?['fName'] ?? '';
              lName = doc.data()?['lName'] ?? '';
            }
          } else {
            var doc = await FirebaseFirestore.instance.collection('students').doc(userId).get();
            if (doc.exists) {
              // Using keys from your screenshot: fName, lName
              fName = doc.data()?['fName'] ?? '';
              lName = doc.data()?['lName'] ?? '';
            }
          }
        } catch (e) {
          debugPrint("Error fetching user name: $e");
        }
      }

      // 3. Format the Display Name
      String displayName = "$fName $lName".trim();

      // Fallback
      if (displayName.isEmpty) {
        displayName = isFaculty ? 'Faculty Member' : 'Student';
      } else {
        // Add "Dr." prefix for faculty
        if (isFaculty) {
          displayName = "Dr. $displayName";
        }
      }

      // 4. Create and Send Reply
      CommunityReplyModel reply = CommunityReplyModel(
        userId: userId,
        userName: displayName,
        content: _replyController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _communityService.addReply(widget.post.id, reply);

      _replyController.clear();
      setState(() {
        _isReplying = false;
      });
      FocusScope.of(context).unfocus();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reply: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
              // Optional: FAB to create a NEW post
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
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
          ),
        ),

        const Text(
            "Community",
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

  Widget _buildPostCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withValues(alpha: 0.12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.title,
                      style: TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple),
                    ),
                    Text(
                      "${widget.post.userName} • ${DateFormat('MMM d').format(widget.post.timestamp)}",
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.post.content,
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
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _mainPurple.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF237ABA).withValues(alpha: 0.12),
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
              child: StreamBuilder<List<CommunityReplyModel>>(
                stream: _communityService.getRepliesStream(widget.post.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: _mainPurple));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No replies yet. Be the first!", style: TextStyle(fontFamily: 'SpaceGrotesk')));
                  }

                  final replies = snapshot.data!;

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: replies.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final reply = replies[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(reply.userName, style: TextStyle(fontFamily: 'Batangas', fontSize: 14, fontWeight: FontWeight.bold, color: _mainPurple)),
                              Text(DateFormat('h:mm a').format(reply.timestamp), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(reply.content, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, color: Colors.black)),
                        ],
                      );
                    },
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
          suffixIcon: _isSending
              ? Padding(padding: const EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: _mainPurple))
              : IconButton(onPressed: _submitReply, icon: Icon(Icons.send_rounded, color: _mainPurple)),
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
            boxShadow: [BoxShadow(color: _mainPurple.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Center(
              child: Image.asset(
                  'assets/images/solidarity_1.png',
                  width: 50,
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
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
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
                _navItem('assets/images/solidarity_1.png', 'Community', true),
                _navItem('assets/images/calendar.png', 'Schedule', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StuSchedule()))),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', 'Q&A', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StuQAScreen()))),
                _navItem('assets/images/user.png', 'Profile', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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
                _navItem('assets/images/solidarity_1.png', 'Community', true),
                _navItem('assets/images/classroom_1.png', 'Halls', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HallsScreen()))),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', 'Q&A', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QAScreen()))),
                _navItem('assets/images/user.png', 'Profile', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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
      onTap: onTap,
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