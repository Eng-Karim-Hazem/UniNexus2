import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import screens
import '../Faculty/faculty_home_screen.dart';
import '../Faculty/halls_screen.dart';
import '../profile_screen.dart';
import 'faculty_id_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final int _selectedIndex = 2; // Q&A is Index 2

  // Colors
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sample Data with State (To handle answers)
  // We use a List of Maps to store the question and the "local" answer
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'title': "IOT Arch.",
      'subtitle': "GPIO pins on raspberry pi usage",
      'question': "How do I use the GPIO pins on raspberry pi and should i use an ADC for the project??",
      'answer': null, // Initially no answer
      'isExpanded': true, // First one open by default
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

  // Controllers for text fields (mapped by Question ID)
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers
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

  // --- NAVIGATION LOGIC ---
  void _onNavBarTapped(int index) async {
    if (index == 0) {
      // Community -> Go Home
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    else if (index == 1) {
      // Schedule -> Halls
      Navigator.push(context, MaterialPageRoute(builder: (context) => const HallsScreen()));
    }
    else if (index == 2) {
      // Already on Q&A
    }
    else if (index == 3) {
      // Profile
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString('userCode') ?? "No ID";
      final fName = prefs.getString('userFirstName') ?? "Faculty";
      final lName = prefs.getString('userLastName') ?? "";

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userID: userID,
              firstName: fName,
              lastName: lName,
            )
        ));
      }
    }
  }

  // --- QR BUTTON LOGIC ---
  void _openQRScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userCode') ?? "No ID";
    final fName = prefs.getString('userFirstName') ?? "Faculty";
    final lName = prefs.getString('userLastName') ?? "";

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FacultyIDScreen(

          ),
        ),
      );
    }
  }

  // --- SUBMIT ANSWER LOGIC ---
  void _submitAnswer(int id, String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      final index = _questions.indexWhere((q) => q['id'] == id);
      if (index != -1) {
        _questions[index]['answer'] = text; // Update the answer in our list
        _controllers[id]?.clear(); // Clear the text field
      }
    });
    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // --- FAB (Gradient) ---
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _mainPurple.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openQRScreen,
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _fabGradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/images/qr_code.png', color: Colors.white),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
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
          notchMargin: 10.0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
              _buildNavBarItem('assets/images/calendar.png', "Schedule", 1),
              const SizedBox(width: 48),
              _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
              _buildNavBarItem('assets/images/profile.png', "Profile", 3),
            ],
          ),
        ),
      ),

      // --- MAIN BODY ---
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
                    ),
                    const Text(
                      "Q&A",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C5C80),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/uni.jpeg', width: 36, height: 36),
                    ),
                  ],
                ),
              ),

              // 2. Questions List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildQuestionCard(q),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildQuestionCard(Map<String, dynamic> item) {
    int id = item['id'];
    bool hasAnswer = item['answer'] != null;

    return Container(
      decoration: BoxDecoration(
        // Glassy Effect
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: item['isExpanded'],
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

          // Leading Icon (Using help_1.png)
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5C5C80).withOpacity(0.3)),
            ),
            child: Image.asset(
              'assets/images/help_1.png', // UPDATED ICON
              width: 20,
              color: const Color(0xFF5C5C80),
              errorBuilder: (c,o,s) => const Icon(Icons.help_outline, color: Color(0xFF5C5C80), size: 20),
            ),
          ),

          title: Text(
            item['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C7CFA), // Purple-Blue
            ),
          ),
          subtitle: Text(
            item['subtitle'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          iconColor: const Color(0xFF1A1A1A),
          collapsedIconColor: const Color(0xFF1A1A1A),

          // --- EXPANDED CONTENT ---
          children: [
            const Divider(),

            // The Question
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    const TextSpan(text: "Q : ", style: TextStyle(fontWeight: FontWeight.w900)),
                    TextSpan(text: item['question'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // The Answer (Only visible if submitted)
            if (hasAnswer) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    children: [
                      TextSpan(
                          text: "A : ",
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green.shade700)
                      ),
                      TextSpan(
                          text: item['answer'],
                          style: const TextStyle(fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],

            // Input Field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controllers[id],
                decoration: InputDecoration(
                  hintText: "Submit an answer",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () {
                        _submitAnswer(id, _controllers[id]!.text);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C7CFA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // "Who sent this?"
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Who sent this?",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: itemColor,
            errorBuilder: (c,o,s) => Icon(Icons.circle, size: 24, color: itemColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: itemColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}