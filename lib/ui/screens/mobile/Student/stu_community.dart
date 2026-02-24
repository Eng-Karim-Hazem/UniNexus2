import 'package:flutter/material.dart';
import 'stu_schedule.dart';
import '../../profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/qa_screen.dart';
import 'create_community_post_screen.dart';
import 'community_post_detail_screen.dart';

class PostReply {
  final String author;
  final String text;

  PostReply({required this.author, required this.text});
}

class CommunityPost {
  final String title;
  final String body;
  final List<PostReply> replies;

  CommunityPost({
    required this.title,
    required this.body,
    this.replies = const [],
  });
}

class StuCommunity extends StatefulWidget {
  const StuCommunity({super.key});

  @override
  State<StuCommunity> createState() => _StuCommunityState();
}

class _StuCommunityState extends State<StuCommunity> {
  final int _selectedIndex = 0;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _textIndigo = const Color(0xFF5C5C80);

  final List<CommunityPost> _posts = [
    CommunityPost(
      title: 'GPIO pins usage on Raspberry Pi',
      body: 'How do I use GPIO pins and ADC on Raspberry Pi with Python? '
          'I need to read analog sensor values but the Pi only has digital pins.',
      replies: [
        PostReply(author: 'Dr. Ahmed', text: 'You need an external ADC chip like MCP3008.'),
      ],
    ),
    CommunityPost(
      title: 'CCNA R&S new task Protocols',
      body: 'Is there a way to find the ports and protocols currently open or being '
          'used by the ECS Fargate Services, so that we could specifically open only '
          'those ports and protocols in the NACL?\n\n'
          'We have a single VPC in our AWS account. This single VPC contains a number of ECS Fargate Services. The VPC network ACL allows all protocols and all ports from all ips. As a security best practise, we want to restrict the ports and protocols that are being allowed.',
      replies: [
        PostReply(author: 'Ammar Tarek', text: 'You should examine the ECS task definitions.'),
        PostReply(author: 'Karim Hazem', text: 'All the ports will be defined there.'),
        PostReply(author: 'Abd El-Rahman Mohamed', text: 'ECS/Fargate will only expose ports.'),
        PostReply(author: 'Moaz Osama', text: 'you can be sure to find them all there..'),
        PostReply(author: 'Youssef Salama', text: 'They are explicitly defined in the task.'),
      ],
    ),
    CommunityPost(
      title: 'RSA Key composition and process',
      body: "I still don't get the point of multiple prime factors in RSA. "
          'Can anyone explain the key generation steps simply?',
      replies: [],
    ),
  ];

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
                      child: Image.asset(
                        'assets/images/solidarity_1.png',
                        width: 32,
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
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
        ),
        Text(
          'Community',
          style: TextStyle(
            fontFamily: 'Batangas',
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
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CommunityPostDetailScreen(post: post)),
        );
      },
      child: Container(
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
                    border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
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
                      fontFamily: 'Batangas',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: _mainPurple, size: 26),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              post.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
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

  Widget _buildHomeFab() {
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
              fontFamily: 'SpaceGrotesk',
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