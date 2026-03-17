import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/services/firebase/qna_service.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/who_sent_this_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final QnAService _qnaService = QnAService();
  int _selectedIndex = 2;
  List<String> _mySubjects = [];
  String _facultyFullName = "Faculty";
  bool _isInit = false;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  Future<void> _loadFacultyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 1. Get assigned subjects
      _mySubjects = prefs.getStringList('facultySubjects') ?? [];

      // 2. Build full name for rName field
      String fName = prefs.getString('fName') ?? "Faculty";
      String lName = prefs.getString('lName') ?? "";
      _facultyFullName = "$fName $lName".trim();

      _isInit = true;
    });
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
      if (mounted) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userID: userID, firstName: _facultyFullName.split(' ')[0], lastName: _facultyFullName.contains(' ') ? _facultyFullName.split(' ')[1] : "")));
      }
    }
    if (mounted) setState(() => _selectedIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
              _buildTopHeader(),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _qnaService.streamUnansweredQnA(_mySubjects),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("All questions answered!", style: TextStyle(fontFamily: 'Batangas', color: Colors.white70)));
                    }

                    final qnaList = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                      itemCount: qnaList.length,
                      itemBuilder: (context, index) {
                        final q = qnaList[index];
                        final docId = q['docId'];
                        if (!_controllers.containsKey(docId)) {
                          _controllers[docId] = TextEditingController();
                        }
                        return Padding(padding: const EdgeInsets.only(bottom: 16.0), child: _buildQuestionCard(q, docId));
                      },
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

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple)),
          const Text("Q&A", style: TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/LOGO.png', width: 36, height: 36)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> item, String docId) {
    // 1. EXTRACT THE SENDER ID
    // Replace 'sName' with the exact field name in your QnA collection that holds the student ID (e.g., "ST2022...")
    String studentId = item['ID'] ?? "";

    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mainPurple.withOpacity(0.6), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFF237ABA).withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF5C5C80).withOpacity(0.3))),
            child: Image.asset('assets/images/help_1.png', width: 20, color: const Color(0xFF5C5C80)),
          ),
          title: Text(item['subject'] ?? "", style: const TextStyle(fontFamily: 'Batangas', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C7CFA))),
          subtitle: Text(item['title'] ?? "", style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, color: Colors.black87)),
          children: [
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    const TextSpan(text: "Q : ", style: TextStyle(fontFamily: 'Batangas', fontWeight: FontWeight.w900)),
                    TextSpan(text: item['question'] ?? "", style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _controllers[docId],
                decoration: InputDecoration(
                  hintText: "Submit an answer",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  suffixIcon: GestureDetector(
                    onTap: () async {
                      if (_controllers[docId]!.text.trim().isNotEmpty) {
                        // SENDING ANSWER + Responder Name (rName)
                        await _qnaService.submitAnswer(docId, _controllers[docId]!.text, _facultyFullName);
                        _controllers[docId]!.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFF5C7CFA), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.send, color: Colors.white, size: 22)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    // Pass the extracted ID here. Removed 'const' because studentId is dynamic.
                    MaterialPageRoute(builder: (context) => WhoSentThisScreen(senderId: studentId))
                ),
                child: Text("Who sent this?", style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 12, color: Colors.grey.shade600, decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.6), blurRadius: 25, offset: const Offset(0, 2))]),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent, elevation: 0,
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, -6))]),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(), notchMargin: 9.0, color: Colors.white, height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_navItem('assets/images/solidarity_1.png', "Community", 0), _navItem('assets/images/classroom_1.png', "Halls", 1)])),
            const SizedBox(width: 72),
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_navItem('assets/images/qa.png', "Q&A", 2), _navItem('assets/images/profile.png', "Profile", 3)])),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String icon, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset(icon, width: 28, height: 28, color: sel ? _mainPurple : Colors.grey),
        Text(label, style: TextStyle(fontSize: 12, color: sel ? _mainPurple : Colors.grey)),
      ]),
    );
  }
}