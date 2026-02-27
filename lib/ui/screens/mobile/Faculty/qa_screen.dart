import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/who_sent_this_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';
import 'faculty_id_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  int _selectedIndex = 2; // Highlights Q&A

  final Color _mainPurple = const Color(0xFF7B61FF);
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
      'answer': null,
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
    {
      'id': 3,
      'title': "CCNA R&S",
      'subtitle': "Protocol mismatch issue",
      'question': "I am getting a protocol mismatch error on the router interface. OSPF is configured. Any ideas?",
      'answer': null,
      'isExpanded': false,
    },
  ];

  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var q in _questions) {
      _controllers[q['id']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNavBarTapped(int index) async {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    } else if (index == 1) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const HallsScreen()));
    } else if (index == 3) {
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString('userCode') ?? "No ID";
      final fName = prefs.getString('userFirstName') ?? "Faculty";
      final lName = prefs.getString('userLastName') ?? "";
      if (mounted) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userID: userID, firstName: fName, lastName: lName)));
      }
    }

    // Reset to Q&A when returning
    if (mounted) setState(() => _selectedIndex = 2);
  }

  void _submitAnswer(int id, String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      final index = _questions.indexWhere((q) => q['id'] == id);
      if (index != -1) {
        _questions[index]['answer'] = text;
        _controllers[id]?.clear();
      }
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/background.png'), fit: BoxFit.cover)),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                        child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple)),
                    const Text("Q&A",
                        style: TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('assets/images/LOGO.png', width: 36, height: 36)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 150), // Added bottom padding for FAB
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Padding(padding: const EdgeInsets.only(bottom: 16.0), child: _buildQuestionCard(q));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> item) {
    int id = item['id'];
    bool hasAnswer = item['answer'] != null;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mainPurple.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFF237ABA).withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
          ]),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: item['isExpanded'],
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF5C5C80).withOpacity(0.3))),
            child: Image.asset('assets/images/help_1.png', width: 20, color: const Color(0xFF5C5C80), errorBuilder: (c, o, s) => const Icon(Icons.help_outline, color: Color(0xFF5C5C80), size: 20)),
          ),
          title: Text(item['title'], style: const TextStyle(fontFamily: 'Batangas', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C7CFA))),
          subtitle: Text(item['subtitle'], style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, color: Colors.black87)),
          iconColor: const Color(0xFF1A1A1A),
          collapsedIconColor: const Color(0xFF1A1A1A),
          children: [
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    const TextSpan(text: "Q : ", style: TextStyle(fontFamily: 'Batangas', fontWeight: FontWeight.w900)),
                    TextSpan(text: item['question'], style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (hasAnswer) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    children: [
                      TextSpan(text: "A : ", style: TextStyle(fontFamily: 'Batangas', fontWeight: FontWeight.w900, color: Colors.green.shade700)),
                      TextSpan(text: item['answer'], style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _controllers[id],
                style: const TextStyle(fontFamily: 'SpaceGrotesk'),
                decoration: InputDecoration(
                  hintText: "Submit an answer",
                  hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () => _submitAnswer(id, _controllers[id]!.text),
                      child: Container(
                          decoration: BoxDecoration(color: const Color(0xFF5C7CFA), borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.send, color: Colors.white, size: 22 )),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                // --- NAVIGATE TO WHO SENT THIS SCREEN ---
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WhoSentThisScreen()),
                  );
                },
                child: Text(
                  "Who sent this?",
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
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
                  _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
                  _buildNavBarItem('assets/images/classroom_1.png', "Halls", 1),
                ],
              ),
            ),
            const SizedBox(width: 72), // Space for the FAB notch
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
                  _buildNavBarItem('assets/images/profile.png', "Profile", 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade500;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 28,
            height: 28,
            color: itemColor,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.circle, size: 28, color: itemColor),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 12,
              color: itemColor,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}