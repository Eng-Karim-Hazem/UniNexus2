import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _communityService = CommunityService();
  final TextEditingController _replyController = TextEditingController();

  bool _isReplying = false;
  bool _isSending = false;
  bool _isStudent = true;
  bool _isLoading = true;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _textIndigo = const Color(0xFF5C5C80);
  final Color _primaryBlue = const Color(0xFF237ABA);

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

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _checkUserType() async {
    // Prevent re-triggering loading state if already loaded
    if (!_isLoading) return;

    try {
      final prefs = await SharedPreferences.getInstance();
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

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;
    setState(() => _isSending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userCode') ?? prefs.getString('ID') ?? '';
      bool isFaculty = userId.toUpperCase().startsWith('FA');
      String fName = prefs.getString('fName') ?? prefs.getString('userFirstName') ?? '';
      String lName = prefs.getString('lName') ?? prefs.getString('userLastName') ?? '';

      String displayName = "$fName $lName".trim();
      if (displayName.isEmpty) {
        displayName = isFaculty ? 'Faculty Member' : 'Student';
      } else if (isFaculty) {
        displayName = "Dr. $displayName";
      }

      CommunityReplyModel reply = CommunityReplyModel(
        userId: userId,
        userName: displayName,
        content: _replyController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _communityService.addReply(widget.post.id, reply);
      _replyController.clear();
      setState(() => _isReplying = false);
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildPermanentBottomBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/Phone_Background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
                child: Column(
                  children: [
                    _buildTopHeader(),
                    SizedBox(height: sh * 0.02),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? keyboardHeight + 30 : sh * 0.15),
                        child: Column(
                          children: [
                            _buildPostCard(),
                            SizedBox(height: sh * 0.02),
                            _buildRepliesSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCreatePostFab(sw, sh),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermanentBottomBar() {
    if (_isLoading) return _bottomNavWrapper(child: const SizedBox.shrink());
    return _isStudent ? _buildStudentBottomBar() : _buildFacultyBottomBar();
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
          ),
        ),
        Text("Community", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/LOGO.png', width: 36, height: 36)),
      ],
    );
  }

  Widget _buildPostCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.12), blurRadius: 25, offset: const Offset(0, 8))],
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
                    Text(widget.post.title, style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple)),
                    Text("${widget.post.userName} • ${DateFormat('MMM d').format(widget.post.timestamp)}", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.post.content, style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildRepliesSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.12), blurRadius: 25, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Replies", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 18, fontWeight: FontWeight.bold, color: _mainPurple)),
              GestureDetector(
                onTap: () => setState(() => _isReplying = !_isReplying),
                child: Icon(_isReplying ? Icons.close_rounded : Icons.add_rounded, color: _mainPurple, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isReplying) _buildReplyInput(),
          StreamBuilder<List<CommunityReplyModel>>(
            stream: _communityService.getRepliesStream(widget.post.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: _mainPurple));
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No replies yet.", style: TextStyle(fontFamily: MobileAppFonts.body)));
              }
              final replies = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                          Text(reply.userName, style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 14, fontWeight: FontWeight.bold, color: _mainPurple)),
                          // UPDATED: Displays both Date and Time
                          Text(DateFormat('MMM d, h:mm a').format(reply.timestamp), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(reply.content, style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14, color: Colors.black)),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(24)),
      child: TextField(
        controller: _replyController,
        autofocus: true,
        style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Type your reply...",
          hintStyle: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: _isSending
              ? Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: _mainPurple)))
              : IconButton(onPressed: _submitReply, icon: Icon(Icons.send_rounded, color: _mainPurple)),
        ),
      ),
    );
  }

  Widget _buildCreatePostFab(double sw, double sh) {
    return Positioned(
      bottom: sh * 0.12,
      right: sw * 0.06,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityPostScreen())),
        child: Container(
          width: 75, height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 6))],
          ),
            child: Center(
              child: Image.asset(
                'assets/icons/solidarity.png',
                // Scales icon perfectly alongside the button bounds
                width: (sw * 0.20).clamp(30.0, 50.0),
                height: (sw * 0.20).clamp(30.0, 50.0),
                fit: BoxFit.contain,
                color: _mainPurple,
              ),
            )
        ),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.6), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))]),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent, elevation: 0, shape: const CircleBorder(),
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
          Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _navItem('assets/images/solidarity_1.png', 'Community', true),
            _navItem('assets/images/calendar.png', 'Schedule', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StuSchedule()))),
          ])),
          const SizedBox(width: 72),
          Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _navItem('assets/images/qa.png', 'Q&A', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StuQAScreen()))),
            _navItem('assets/images/user.png', 'Profile', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          ])),
        ],
      ),
    );
  }

  Widget _buildFacultyBottomBar() {
    return _bottomNavWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _navItem('assets/images/solidarity_1.png', 'Community', true),
            _navItem('assets/images/classroom_1.png', 'Halls', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HallsScreen()))),
          ])),
          const SizedBox(width: 72),
          Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _navItem('assets/images/qa.png', 'Q&A', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QAScreen()))),
            _navItem('assets/images/user.png', 'Profile', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          ])),
        ],
      ),
    );
  }

  Widget _bottomNavWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, -6))]),
      child: BottomAppBar(clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(), notchMargin: 9.0, color: Colors.white, height: 80, child: child),
    );
  }

  Widget _navItem(String path, String label, bool sel, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(path, width: 28, height: 28, color: sel ? _mainPurple : Colors.grey.shade500),
          const SizedBox(height: 5),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 12, color: sel ? _mainPurple : Colors.grey.shade600, fontWeight: sel ? FontWeight.w900 : FontWeight.w600))),
        ],
      ),
    );
  }
}