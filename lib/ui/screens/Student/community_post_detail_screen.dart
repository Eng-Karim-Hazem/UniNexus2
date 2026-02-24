import 'package:flutter/material.dart';
import 'stu_schedule.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/Faculty/qa_screen.dart';
import 'create_community_post_screen.dart';
import 'stu_community.dart'; // Import to access CommunityPost and PostReply models

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

  // --- STATE FOR REPLY INPUT ---
  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    if (_replyController.text.trim().isEmpty) return;

    setState(() {
      // Add the text to the replies list to reflect in the UI immediately
      widget.post.replies.add(PostReply(author: "Me", text: _replyController.text.trim()));
      _replyController.clear();
      _isReplying = false; // Hide input field after submission
    });
    FocusScope.of(context).unfocus(); // Close the keyboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    // --- Header ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context), // Pops back to list
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
                          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Main Post Card ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _mainPurple.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                                  border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
                                ),
                                child: Icon(Icons.help_outline_rounded, size: 18, color: _mainPurple),
                              ),
                              const SizedBox(width: 10),
                              Container(width: 1.5, height: 30, color: _mainPurple.withOpacity(0.3)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.post.title,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _mainPurple),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.post.body,
                            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Replies Section ---
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _mainPurple.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Replies Header with Toggle Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Replies",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _mainPurple),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isReplying = !_isReplying; // Toggle visibility of the text box
                                    });
                                  },
                                  child: Icon(
                                      _isReplying ? Icons.close_rounded : Icons.add_rounded,
                                      color: _mainPurple,
                                      size: 28
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // --- Animated Reply Input Field ---
                            if (_isReplying) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TextField(
                                  controller: _replyController,
                                  decoration: InputDecoration(
                                    hintText: "Type your reply...",
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: GestureDetector(
                                        onTap: _submitReply,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _mainPurple,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // --- List of Replies ---
                            Expanded(
                              child: widget.post.replies.isEmpty
                                  ? const Center(child: Text("No replies yet."))
                                  : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: widget.post.replies.length,
                                separatorBuilder: (context, index) => const Divider(height: 24, thickness: 1),
                                itemBuilder: (context, index) {
                                  final reply = widget.post.replies[index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reply.author,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _mainPurple),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        reply.text,
                                        style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Spacing for bottom bar
                  ],
                ),
              ),

              // ── Hover Button ──
              Positioned(
                bottom: 110,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateCommunityPostScreen()),
                    );
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _mainPurple.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset('assets/images/solidarity_1.png', width: 32, color: _mainPurple),
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

  Widget _buildHomeFab() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: _mainPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/images/solidarity_1.png', 'Community', 0),
          _navItem('assets/images/calendar.png', 'Schedule', 1),
          const SizedBox(width: 48),
          _navItem('assets/images/qa.png', 'Q&A', 2),
          _navItem('assets/images/profile.png', 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == _selectedIndex) return;
        if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const StuSchedule()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const QAScreen()));
        if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
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