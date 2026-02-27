import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../settings_screen.dart';
import 'qa_request.dart';
import '../Student/stu_schedule.dart';
import 'student_id_screen.dart';
import '../profile_screen.dart';

class StuQAScreen extends StatefulWidget {
  const StuQAScreen({super.key});

  @override
  State<StuQAScreen> createState() => _StuQAScreenState();
}

class _StuQAScreenState extends State<StuQAScreen> {
  int _selectedIndex = 2; // Q&A selected by default

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'title': "IOT Arch.",
      'subtitle': "GPIO pins on raspberry pi usage",
      'question': "How do I use the GPIO pins on raspberry pi and should i use an ADC for the project??",
      'answer': "The Raspberry Pi's GPIO pins are digital-only and do not support analog input by default.",
      'isExpanded': true,
    },
    {
      'id': 2,
      'title': "Windows Programming",
      'subtitle': "Button linking problem",
      'question': "My button click event is not firing in WPF. I checked the XAML binding. What could be wrong?",
      'answer': null,
      'isExpanded': false,
    },
  ];

  void _onNavBarTapped(int index) async {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    } else if (index == 1) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
    } else if (index == 3) {
      if (mounted) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
      }
    }

    if (mounted) setState(() => _selectedIndex = 2); // Reset to Q&A when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // Central Home Button
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
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                    child: _buildTopHeader(),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 180), // Added padding for the FABs
                      physics: const BouncingScrollPhysics(),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) => _buildModernQACard(_questions[index]),
                    ),
                  ),
                ],
              ),

              // --- THE REVERTED RECTANGULAR QUESTION MARK FAB ---
              Positioned(
                right: 24,
                bottom: 130,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QARequestScreen()),
                    );
                  },
                  child: Container(
                    width: 80, // Reverted to the larger box size
                    height: 80, // Reverted to the larger box size
                    decoration: BoxDecoration(
                      color: _mainPurple,
                      borderRadius: BorderRadius.circular(22), // Soft rounded squircle corners
                      boxShadow: [
                        BoxShadow(
                          color: _mainPurple.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                          "?",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 45, // Reverted to the large, bold font size
                              fontFamily: 'Batangas',
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ),
                ),
              )
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
        // --- ADDED NAVIGATION HERE ---
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
            "Q&A",
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

  Widget _buildModernQACard(Map<String, dynamic> item) {
    bool isExpanded = item['isExpanded'] ?? false;
    return GestureDetector(
      onTap: () => setState(() => item['isExpanded'] = !isExpanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/help_1.png', width: 28, color: _mainPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: TextStyle(color: _mainPurple, fontWeight: FontWeight.bold, fontFamily: 'Batangas',  fontSize: 18)),
                      Text(item['subtitle'], style: const TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'Batangas', fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: _mainPurple, size: 30),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontFamily: 'Batangas', fontSize: 15, height: 1.4),
                  children: [
                    const TextSpan(text: "Q : ", style: TextStyle(fontFamily: 'Batangas', fontWeight: FontWeight.bold)),
                    TextSpan(text: item['question'], style: const TextStyle(fontFamily: 'Batangas', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (item['answer'] != null) ...[
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Batangas', height: 1.4),
                    children: [
                      const TextSpan(text: "A : ", style: TextStyle(fontFamily: 'Batangas', fontWeight: FontWeight.bold)),
                      TextSpan(text: item['answer'], style: const TextStyle(fontFamily: 'Batangas', fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ]
          ],
        ),
      ),
    );
  }

  // --- GLOWING HOME FAB ---
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
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  // --- BOTTOM NAVIGATION BAR WITH NATIVE CUTOUT SHADOW ---
  Widget _buildBottomBar() {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem('assets/images/solidarity_1.png', "Community", 0),
                  _navItem('assets/images/calendar.png', "Schedule", 1),
                ],
              ),
            ),
            const SizedBox(width: 72), // Space for the FAB notch
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem('assets/images/qa.png', "Q&A", 2),
                  _navItem('assets/images/user.png', "Profile", 3),
                ],
              ),
            ),
          ],
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