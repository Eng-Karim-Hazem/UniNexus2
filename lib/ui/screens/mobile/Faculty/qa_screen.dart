import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/services/firebase/qna_service.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/who_sent_this_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final QnAService _qnaService = QnAService();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isEditing = {};
  final Map<String, ExpansionTileController> _expansionControllers = {};

  int _selectedIndex = 2;
  List<String> _mySubjects = [];
  String _facultyFullName = "Faculty";
  bool _isInit = false;

  // --- NEW: FILTER STATE ---
  String _selectedFilter = 'Pending';

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _textIndigo = const Color(0xFF5C5C80);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _accentBlue = const Color(0xFF5C7CFA);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFacultyData() async {
    if (_isInit) return;

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _mySubjects = prefs.getStringList('facultySubjects') ?? [];
        String fName = prefs.getString('fName') ?? "Faculty";
        String lName = prefs.getString('lName') ?? "";
        _facultyFullName = "$fName $lName".trim();
        _isInit = true;
      });
    }
  }

  Future<bool> _confirmDelete(BuildContext context, String docId) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Question", style: TextStyle(fontFamily: MobileAppFonts.heading, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this question? This cannot be undone.", style: TextStyle(fontFamily: MobileAppFonts.body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              try {
                await _qnaService.deleteQuestion(docId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Question deleted"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to delete question"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
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
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userID: userID,
              firstName: _facultyFullName.split(' ')[0],
              lastName: _facultyFullName.contains(' ') ? _facultyFullName.split(' ')[1] : "",
            ),
          ),
        );
      }
    }
    if (mounted) setState(() => _selectedIndex = 2);
  }

  Future<void> _goHome() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';
    Widget targetHome = userId.toUpperCase().startsWith('FA') ? const FacultyHomeScreen() : const StuHomeScreen();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => targetHome), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/Phone_Background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              // --- NEW: INJECT THE FILTER ROW ---
              _buildFilterRow(),
              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  // --- THE FIX: Use the new stream that fetches ALL questions ---
                  stream: _qnaService.streamAllQnAForSubjects(_mySubjects),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !_isInit) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No questions found.", style: TextStyle(fontFamily: MobileAppFonts.heading, color: Colors.black54)),
                      );
                    }

                    // --- NEW: FILTER LOGIC ---
                    final allQna = snapshot.data!;
                    final filteredQna = allQna.where((q) {
                      bool hasAnswer = q['answer'] != null && q['answer'].toString().trim().isNotEmpty;
                      if (_selectedFilter == 'Pending') return !hasAnswer;
                      if (_selectedFilter == 'Responded') return hasAnswer;
                      return true;
                    }).toList();

                    if (filteredQna.isEmpty) {
                      return Center(
                        child: Text("No ${_selectedFilter.toLowerCase()} questions.", style: const TextStyle(fontFamily: MobileAppFonts.heading, color: Colors.black54)),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, keyboardHeight > 0 ? keyboardHeight + 20 : 150),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredQna.length,
                      itemBuilder: (context, index) {
                        final q = filteredQna[index];
                        final docId = q['docId'];

                        // Initialize controllers if they don't exist yet
                        if (!_controllers.containsKey(docId)) {
                          _controllers[docId] = TextEditingController();
                        }
                        // --- NEW: Initialize the expansion controller ---
                        if (!_expansionControllers.containsKey(docId)) {
                          _expansionControllers[docId] = ExpansionTileController();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildQuestionCard(q, docId),
                        );
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
            child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
          ),
          Text("Q&A", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/LOGO.png', width: 36, height: 36)),
        ],
      ),
    );
  }

  // --- NEW: FILTER ROW WIDGET ---
  Widget _buildFilterRow() {
    final List<String> options = ['Pending', 'Responded'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: options.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _mainPurple : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _mainPurple, width: 1.5),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontFamily: MobileAppFonts.body,
                  color: isSelected ? Colors.white : _mainPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> item, String docId) {
    String studentId = item['ID'] ?? "";
    bool hasAnswer = item['answer'] != null && item['answer'].toString().trim().isNotEmpty;

    // --- NEW: Check if this specific card is in edit mode ---
    bool isEditing = _isEditing[docId] ?? false;

    Widget cardUI = Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            _primaryBlue.withOpacity(0.8),
            _mainPurple.withOpacity(0.25),
            _mainPurple.withOpacity(0.25),
            Colors.redAccent.withOpacity(0.8),
          ],
          stops: const [0.0, 0.20, 0.80, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            // If editing, force the tile to stay expanded so they see the text box!
            initiallyExpanded: isEditing,
            controller: _expansionControllers[docId],

            // You can remove initiallyExpanded now, the controller handles it!
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _textIndigo.withOpacity(0.3))),
              child: Image.asset('assets/images/help_1.png', width: 20, color: _textIndigo),
            ),
            title: Text(item['subject'] ?? "", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 18, fontWeight: FontWeight.bold, color: _accentBlue)),
            subtitle: Text(item['title'] ?? "", style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14, color: Colors.black87)),
            children: [
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    children: [
                      const TextSpan(text: "Q : ", style: TextStyle(fontFamily: MobileAppFonts.heading, fontWeight: FontWeight.w900)),
                      TextSpan(text: item['question'] ?? "", style: const TextStyle(fontFamily: MobileAppFonts.body, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Only show the static answer text if we are NOT currently editing
              if (hasAnswer && !isEditing) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      children: [
                        const TextSpan(text: "A : ", style: TextStyle(fontFamily: MobileAppFonts.heading, fontWeight: FontWeight.w900)),
                        TextSpan(text: item['answer'], style: const TextStyle(fontFamily: MobileAppFonts.body, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Show the text box if it's pending OR if they swiped right to edit
              if (!hasAnswer || isEditing)
                Container(
                  decoration: BoxDecoration(
                    // --- THE FIX: Reverted to the standard grey color always ---
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(30),
                    // Removed the amber border to keep it perfectly clean
                  ),
                  child: TextField(
                    controller: _controllers[docId],
                    style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isEditing ? "Edit your answer..." : "Submit an answer",
                      hintStyle: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

                      prefixIcon: isEditing
                          ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                        onPressed: () {
                          setState(() => _isEditing[docId] = false);
                          _controllers[docId]!.clear();
                        },
                      )
                          : null,

                      suffixIcon: GestureDetector(
                        onTap: () async {
                          if (_controllers[docId]!.text.trim().isNotEmpty) {
                            await _qnaService.submitAnswer(docId, _controllers[docId]!.text, _facultyFullName);
                            setState(() => _isEditing[docId] = false);
                            _controllers[docId]!.clear();
                            if (mounted) FocusScope.of(context).unfocus();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: isEditing ? Colors.green : _accentBlue,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Icon(isEditing ? Icons.check_rounded : Icons.send, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WhoSentThisScreen(senderId: studentId))),
                  child: Text("Who sent this?", style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 12, color: Colors.grey.shade600, decoration: TextDecoration.underline)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.horizontal,

      background: Container(
        padding: const EdgeInsets.only(left: 25),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _primaryBlue.withOpacity(0.8),
              _primaryBlue.withOpacity(0.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 32),
      ),

      secondaryBackground: Container(
        padding: const EdgeInsets.only(right: 25),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.withOpacity(0.0),
              Colors.redAccent.withOpacity(0.9),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 32),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!hasAnswer) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You haven't responded to this Q&A yet!"),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                )
            );
            return false;
          }

          // --- INLINE EDIT TRIGGER ---
          setState(() {
            _isEditing[docId] = true;
            _controllers[docId]!.text = item['answer']; // Pre-fill old answer
          });

          // --- THE FIX: Force the card to pop open automatically! ---
          _expansionControllers[docId]?.expand();

          return false; // Snap the card back
        }

        // --- TRIGGER DELETE ACTION ---
        return await _confirmDelete(context, docId);
      },
      child: cardUI,
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.6), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))]),
      child: FloatingActionButton(
        onPressed: _goHome,
        backgroundColor: Colors.transparent, elevation: 0, shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, -6))]),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(), notchMargin: 9.0, color: Colors.white,
        surfaceTintColor: Colors.transparent, elevation: 0, shadowColor: Colors.transparent, height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavSection([_buildNavBarItem('assets/images/solidarity_1.png', "Community", 0), _buildNavBarItem('assets/images/classroom_1.png', "Halls", 1)]),
            const SizedBox(width: 72),
            _buildNavSection([_buildNavBarItem('assets/images/qa.png', "Q&A", 2), _buildNavBarItem('assets/images/user.png', "Profile", 3)]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavSection(List<Widget> items) => Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade500;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 28, height: 28, color: itemColor),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontFamily: MobileAppFonts.body, fontSize: 12, color: itemColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600)),
        ],
      ),
    );
  }
}