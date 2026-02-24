import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
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
  final int _selectedIndex = 2;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);

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
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
    } else if (index == 3) {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // Central Home Button
      floatingActionButton: SizedBox(
        height: 73,
        width: 73,
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
              boxShadow: [
                BoxShadow(
                  color: _mainPurple.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                  offset: const Offset(0, 12),
                ),
              ],
              gradient: LinearGradient(
                colors: [_primaryBlue, _mainPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 48),
          ),
        ),
      ),
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
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopHeader(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 180), // Added padding for the FAB
                      physics: const BouncingScrollPhysics(),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) => _buildModernQACard(_questions[index]),
                    ),
                  ),
                ],
              ),

              // --- THE RECTANGULAR QUESTION MARK FAB ---
              Positioned(
                right: 10,
                bottom: 20, // Adjusted to sit above the navigation bar
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QARequestScreen()),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _mainPurple,
                      borderRadius: BorderRadius.circular(20),
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
                              fontSize: 50,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
          const Text("Q&A", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Batangas',  color: Color(
              0xFF6C6ED7))),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
          ),
        ],
      ),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Batangas', height: 1.4),
                      children: [
                        const TextSpan(text: "A : ", style: TextStyle(fontFamily: 'Batangas', fontWeight: FontWeight.bold)),
                        TextSpan(text: item['answer']),
                      ],
                    ),
                  ),
                ),
              ],
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,
        color: Colors.white,
        elevation: 0,
        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
            _buildNavBarItem('assets/images/calendar.png', "Schedule", 1),
            const SizedBox(width: 65),
            _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
            _buildNavBarItem('assets/images/user.png', "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String path, String label, int index) {
    final isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey;

    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 24, color: itemColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: itemColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}