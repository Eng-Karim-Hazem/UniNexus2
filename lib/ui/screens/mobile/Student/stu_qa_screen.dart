import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/services/firebase/qna_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../settings_screen.dart';
import 'qa_request.dart';
import '../Student/stu_schedule.dart';
import '../profile_screen.dart';

class StuQAScreen extends StatefulWidget {
  const StuQAScreen({super.key});

  @override
  State<StuQAScreen> createState() => _StuQAScreenState();
}

class _StuQAScreenState extends State<StuQAScreen> {
  // Services & State
  final QnAService _qnaService = QnAService();
  final int _selectedIndex = 2;
  int _studentYear = 1;
  bool _isInit = false;

  // Constants & Styles
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
    _loadYearData();
  }

  // --- Logic Methods ---

  Future<void> _loadYearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (mounted) {
      setState(() {
        String? storedYear = prefs.getString('year');
        _studentYear = int.tryParse(storedYear ?? '1') ?? 1;
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

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadYearData,
                color: _mainPurple,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
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
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 180),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: qnaList.length,
                            itemBuilder: (context, index) => QACardItem(item: qnaList[index], mainPurple: _mainPurple),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildAddQuestionFab(),
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

  Widget _buildAddQuestionFab() {
    return Positioned(
      right: 24,
      bottom: 130,
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const QARequestScreen()));
          _loadYearData();
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _mainPurple,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _mainPurple.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Center(
              child: Text("?",
                  style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: MobileAppFonts.heading, fontWeight: FontWeight.bold))),
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
          Text(label,
              style: TextStyle(
                fontFamily: MobileAppFonts.body,
                fontSize: 12,
                color: sel ? _mainPurple : Colors.grey.shade600,
                fontWeight: sel ? FontWeight.w900 : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class QACardItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color mainPurple;
  const QACardItem({super.key, required this.item, required this.mainPurple});

  @override
  State<QACardItem> createState() => _QACardItemState();
}

class _QACardItemState extends State<QACardItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.mainPurple.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/help_1.png', width: 24, color: widget.mainPurple),
                Container(
                  height: 22,
                  width: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: Text(
                    widget.item['subject'] ?? "",
                    style: TextStyle(
                        color: widget.mainPurple,
                        fontWeight: FontWeight.bold,
                        fontFamily: MobileAppFonts.heading,
                        fontSize: 17),
                  ),
                ),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: widget.mainPurple, size: 26),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.item['title'] ?? "",
              style: const TextStyle(color: Colors.black87, fontSize: 14, fontFamily: MobileAppFonts.heading),
            ),
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
    );
  }
}