import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/model/community_model.dart';
import 'package:uninexus/services/firebase/community_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import '../settings_screen.dart';
import 'edit_community_post_screen.dart';
import 'stu_schedule.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import 'create_community_post_screen.dart';
import 'community_post_detail_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';

class StuCommunity extends StatefulWidget {
  const StuCommunity({super.key});

  @override
  State<StuCommunity> createState() => _StuCommunityState();
}

class _StuCommunityState extends State<StuCommunity> {
  final _communityService = CommunityService();

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _textIndigo = const Color(0xFF5C5C80);

  bool _isStudent = true;
  String _currentUserId = ""; // --- TRACK LOGGED IN USER ---

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String id = prefs.getString('ID') ?? "";
      if (mounted) {
        setState(() {
          _currentUserId = id; // --- STORE LOCAL ID FOR COMPARISON ---
          _isStudent = !id.toUpperCase().startsWith('FA');
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _goHome() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';

    Widget targetHome;
    if (userId.toUpperCase().startsWith('FA')) {
      targetHome = const FacultyHomeScreen();
    } else {
      targetHome = const StuHomeScreen();
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetHome),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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
            image: AssetImage('assets/images/Phone_Background.png'),
            fit: BoxFit.cover,
          ),
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
                    SizedBox(height: sh * 0.03),
                    Expanded(
                      child: StreamBuilder<List<CommunityPostModel>>(
                        stream: _communityService.getPostsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: _mainPurple));
                          }

                          if (snapshot.hasError) {
                            return const Center(child: Text("Error loading posts", style: TextStyle(color: Colors.red, fontFamily: MobileAppFonts.body)));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text(
                                    "No questions yet. Be the first to ask!",
                                    style: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey)
                                )
                            );
                          }

                          final posts = snapshot.data!;

                          return ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 180),
                            itemCount: posts.length,
                            separatorBuilder: (_, __) => SizedBox(height: sh * 0.02),
                            itemBuilder: (context, i) => _buildPostCard(posts[i], sw),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                // --- THE FIX ---
                // 80 (Bottom Bar Height) + System Padding (Nav Buttons) + 20 (Margin gap)
                bottom: 80.0 + MediaQuery.of(context).padding.bottom + 20.0,
                right: (sw * 0.06).clamp(20.0, 35.0),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityPostScreen())),
                  child: Container(
                    width: (sw * 0.20).clamp(70.0, 85.0),
                    height: (sw * 0.20).clamp(70.0, 85.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular((sw * 0.05).clamp(16.0, 24.0)),
                      boxShadow: [
                        BoxShadow(
                            color: _mainPurple.withValues(alpha: 0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 6)
                        )
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/solidarity.png',
                        width: (sw * 0.20).clamp(30.0, 50.0),
                        height: (sw * 0.20).clamp(30.0, 50.0),
                        fit: BoxFit.contain,
                        color: _mainPurple,
                      ),
                    ),
                  ),
                ),
              ),
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
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          },
          child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
        ),
        const Text(
            "Community",
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

  Widget _buildPostCard(CommunityPostModel post, double sw) {
    // --- OWNERSHIP RULES ---
    // If user is Faculty, they can delete anything. If student, only their own userId works.
    bool canModify = !_isStudent || (_currentUserId.isNotEmpty && _currentUserId.toUpperCase() == post.userId.toUpperCase());

    return Dismissible(
      key: Key(post.id),
      // Allow swiping both ways if they own the post
      direction: canModify ? DismissDirection.horizontal : DismissDirection.none,

      // --- BACKGROUND: EDIT (Swipe Left to Right) ---
      background: Container(
        padding: const EdgeInsets.only(left: 25),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _primaryBlue.withValues(alpha: 0.8), // Solid blue at the start
              _primaryBlue.withValues(alpha: 0.0), // Fading to transparent
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 32),
      ),

      // --- SECONDARY BACKGROUND: DELETE (Swipe Right to Left) ---
      secondaryBackground: Container(
        padding: const EdgeInsets.only(right: 25),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.withValues(alpha: 0.0), // Transparent start
              Colors.redAccent.withValues(alpha: 0.9), // Fading to solid red at the end
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 32),
      ),

      confirmDismiss: (direction) async {
        // --- THE NEW EDIT ACTION ---
        if (direction == DismissDirection.startToEnd) {
          // Launch the edit screen and pass the specific post data to it
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditCommunityPostScreen(post: post))
          );
          // Return false so the card snaps back to its original position in the list
          return false;
        }

        // --- EXISTING DELETE ACTION ---
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Delete Post", style: TextStyle(color: _mainPurple, fontWeight: FontWeight.bold)),
            content: const Text("Are you sure you want to delete this post? This will delete all attached replies."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _communityService.deletePost(post.id);
        }
      },
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityPostDetailScreen(post: post))),
        child: Container(
          // --- THE GRADIENT BORDER WRAPPER ---
          // This padding dictates the border thickness (2.5 pixels)
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // The shadow stays on the outer wrapper
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
            // Draw the dual-color affordance border if they own the post
            gradient: canModify
                ? LinearGradient(
              colors: [
                _primaryBlue.withValues(alpha: 0.8), // Blue on the left
                _mainPurple.withValues(alpha: 0.25), // Fades to default purple
                _mainPurple.withValues(alpha: 0.25),
                Colors.redAccent.withValues(alpha: 0.8), // Red on the right
              ],
              stops: const [0.0, 0.20, 0.80, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
                : null,
            // Fallback to solid standard border if they don't own it
            color: canModify ? null : _mainPurple.withValues(alpha: 0.15),
          ),
          child: Container(
            // --- THE INNER CARD CONTENT ---
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95), // Solid white reading background
              // Inner radius must be smaller to keep corners perfectly rounded inside the border
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: _mainPurple, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                post.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 15, fontWeight: FontWeight.bold, color: _primaryBlue)
                            ),
                            Text(
                              "${post.userRole} • ${post.userName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                    ),
                    if (post.replyCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: _mainPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text("${post.replyCount}", style: TextStyle(color: _mainPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(width: 5),
                    Icon(Icons.keyboard_arrow_right_rounded, color: _mainPurple),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 13, color: _textIndigo, height: 1.4)
                ),
              ],
            ),
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
        onPressed: _goHome,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [_primaryBlue, _mainPurple])),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  // --- REPLACED PUSH WITH PUSHREPLACEMENT FOR PROPER NAV INHERITANCE ---
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
                _navItem('assets/images/qa.png', 'Q&A', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StuQAScreen()))),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/calendar.png', 'Schedule', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StuSchedule()))),
                _navItem('assets/images/user.png', 'Profile', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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
                _navItem('assets/images/classroom_1.png', 'Halls', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HallsScreen()))),
              ],
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', 'Q&A', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QAScreen()))),
                _navItem('assets/images/user.png', 'Profile', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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