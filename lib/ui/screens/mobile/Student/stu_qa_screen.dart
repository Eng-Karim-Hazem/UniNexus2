import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/services/firebase/qna_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../settings_screen.dart';
import 'edit_qa_request_screen.dart';
import 'qa_request.dart';
import '../Student/stu_schedule.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';

class StuQAScreen extends StatefulWidget {
  const StuQAScreen({super.key});

  @override
  State<StuQAScreen> createState() => _StuQAScreenState();
}

class _StuQAScreenState extends State<StuQAScreen> {
  final QnAService _qnaService = QnAService();
  final int _selectedIndex = 2;

  int _studentYear = 1;
  String _currentStudentId = ""; // Add a variable to hold the ID
  bool _isInit = false;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _textIndigo = const Color(0xFF5C5C80);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  // --- Logic Methods ---

  Future<void> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (mounted) {
      setState(() {
        String? storedYear = prefs.getString('year');
        _studentYear = int.tryParse(storedYear ?? '1') ?? 1;
        // Fetch the user's ID
        _currentStudentId = prefs.getString('ID') ?? "";
        _isInit = true;
      });
    }
  }

  void _onNavBarTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }

    Widget next;
    if (index == 0) {
      next = const StuCommunity();
    } else if (index == 1) {
      next = const StuSchedule();
    } else if (index == 3) {
      next = const ProfileScreen();
    } else {
      return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => next));
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

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
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
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadStudentData, // Triggers reload
                color: _mainPurple,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
                      child: _buildTopHeader(),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _qnaService.streamQnAByYear(_studentYear),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(child: Text("Error loading questions."));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return ListView(
                              children: const [
                                SizedBox(height: 100),
                                Center(child: Text("No questions found.", style: TextStyle(fontFamily: MobileAppFonts.heading))),
                              ],
                            );
                          }

                          final qnaList = snapshot.data!;
                          return ListView.builder(
                            padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.02, sw * 0.06, sh * 0.18),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: qnaList.length,
                            itemBuilder: (context, index) => QACardItem(
                              item: qnaList[index],
                              mainPurple: _mainPurple,
                              currentStudentId: _currentStudentId,
                              onRefresh: _loadStudentData, // --- 4. ADD THIS LINE ---
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildAddQuestionFab(sw, sh),
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
        ),
        Text("Q&A",
            style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/LOGO.png', width: 36, height: 36)),
      ],
    );
  }

  Widget _buildAddQuestionFab(double sw, double sh) {
    return Positioned(
      // --- THE FIX ---
      // 80 (Bottom Bar) + System Nav Bar Height + 20 (Margin)
      bottom: 80.0 + MediaQuery.of(context).padding.bottom + 20.0,
      right: (sw * 0.06).clamp(20.0, 35.0),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const QARequestScreen()));
          _loadStudentData();
        },
        child: Container(
          width: (sw * 0.20).clamp(70.0, 85.0),
          height: (sw * 0.20).clamp(70.0, 85.0),
          decoration: BoxDecoration(
            color: _mainPurple,
            borderRadius: BorderRadius.circular((sw * 0.05).clamp(16.0, 24.0)),
            boxShadow: [
              BoxShadow(
                color: _mainPurple.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Center(
              child: Text("?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: (sw * 0.12).clamp(35.0, 50.0),
                      fontFamily: MobileAppFonts.heading,
                      fontWeight: FontWeight.bold
                  )
              )
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
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, -6),
          )
        ],
      ),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        notchMargin: 9.0,
        color: Colors.white,
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
            const SizedBox(width: 72),
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
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 28, height: 28, color: sel ? _mainPurple : Colors.grey.shade500),
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
                )
            ),
          ),
        ],
      ),
    );
  }
}

class QACardItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color mainPurple;
  final String currentStudentId;
  final VoidCallback onRefresh; // --- 1. ADD THIS LINE ---

  const QACardItem({
    super.key,
    required this.item,
    required this.mainPurple,
    required this.currentStudentId,
    required this.onRefresh, // --- 2. ADD THIS LINE ---
  });

  @override
  State<QACardItem> createState() => _QACardItemState();
}
class _QACardItemState extends State<QACardItem> {
  bool isExpanded = false;

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
                await QnAService().deleteQuestion(docId);
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

  @override
  Widget build(BuildContext context) {
    bool isMyQuestion = widget.currentStudentId.toUpperCase() == (widget.item['ID']?.toString().toUpperCase() ?? "");
    const Color primaryBlue = Color(0xFF237ABA); // Added standard blue

    // --- MAIN CARD UI ---
    Widget cardUI = GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, spreadRadius: 2, offset: const Offset(0, 6)),
          ],
          gradient: isMyQuestion
              ? LinearGradient(
            colors: [
              primaryBlue.withValues(alpha: 0.8), // Reverted to Blue!
              widget.mainPurple.withValues(alpha: 0.25),
              widget.mainPurple.withValues(alpha: 0.25),
              Colors.redAccent.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.20, 0.80, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
              : null,
          color: isMyQuestion ? null : widget.mainPurple.withValues(alpha: 0.15),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(17)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/help_1.png', width: 24, color: widget.mainPurple),
                  Container(height: 22, width: 1.5, margin: const EdgeInsets.symmetric(horizontal: 12), color: Colors.grey.withValues(alpha: 0.3)),
                  Expanded(
                    child: Text(
                      widget.item['subject'] ?? "",
                      style: TextStyle(color: widget.mainPurple, fontWeight: FontWeight.bold, fontFamily: MobileAppFonts.heading, fontSize: 17),
                    ),
                  ),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: widget.mainPurple, size: 26),
                ],
              ),
              const SizedBox(height: 6),
              Text(widget.item['title'] ?? "", style: const TextStyle(color: Colors.black87, fontSize: 14, fontFamily: MobileAppFonts.heading)),
              if (isExpanded) ...[
                const SizedBox(height: 18),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontFamily: MobileAppFonts.heading, fontSize: 14, height: 1.5),
                    children: [
                      const TextSpan(text: "Q : ", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: widget.item['question'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (widget.item['answer'] != null && widget.item['answer'].toString().isNotEmpty) ...[
                  const SizedBox(height: 18),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontFamily: MobileAppFonts.heading, height: 1.5),
                      children: [
                        const TextSpan(text: "A : ", style: TextStyle(fontWeight: FontWeight.normal)),
                        TextSpan(text: widget.item['answer']),
                      ],
                    ),
                  ),
                ],
              ]
            ],
          ),
        ),
      ),
    );

    if (!isMyQuestion) return cardUI;

    // --- SWIPE LOGIC FOR OWNERS ---
    return Dismissible(
      key: Key(widget.item['docId'] ?? UniqueKey().toString()),
      direction: DismissDirection.horizontal,

      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(left: 25),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryBlue.withValues(alpha: 0.8), // Reverted to Blue!
              primaryBlue.withValues(alpha: 0.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 32),
      ),

      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 25),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent.withValues(alpha: 0.0), Colors.redAccent.withValues(alpha: 0.9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 32),
      ),

      confirmDismiss: (direction) async {
        // --- NEW EDIT ACTION ---
        if (direction == DismissDirection.startToEnd) {
          // 1. Send them to the edit screen and WAIT for them to come back
          await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditQARequestScreen(item: widget.item))
          );

          // --- 3. ADD THIS LINE: Force the UI to refresh immediately ---
          widget.onRefresh();

          return false; // Snap the card back without dismissing
        }

        // --- EXISTING DELETE ACTION ---
        return await _confirmDelete(context, widget.item['docId']);
      },
      child: cardUI,
    );
  }
}