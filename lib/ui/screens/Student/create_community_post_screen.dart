import 'package:flutter/material.dart';
import 'stu_schedule.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/Faculty/qa_screen.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() => _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final int _selectedIndex = 0;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  void _onNavBarTapped(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StuSchedule()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QAScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: Container(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
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
            _navItem('assets/images/profile.png',      'Profile',   3),
          ],
        ),
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _mainPurple.withOpacity(0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF237ABA).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Title", style: TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(fontFamily: 'SpaceGrotesk'),
                          decoration: InputDecoration(
                            hintText: "Submit a title max one sentence..",
                            hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Question", style: TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 8),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _questionController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(fontFamily: 'SpaceGrotesk'),
                          decoration: InputDecoration(
                            hintText: "Submit your Question maximum 250 letters...",
                            hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 220,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post Submitted!", style: TextStyle(fontFamily: 'SpaceGrotesk'))));
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _mainPurple, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontFamily: 'Batangas',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _mainPurple,
                      ),
                    ),
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

  Widget _navItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
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