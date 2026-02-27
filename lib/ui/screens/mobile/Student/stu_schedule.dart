import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/model/schedule_model.dart';
import 'package:uninexus/services/firebase/Schedule_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';


class StuSchedule extends StatefulWidget {
  const StuSchedule({super.key});

  @override
  State<StuSchedule> createState() => _StuScheduleState();
}

class _StuScheduleState extends State<StuSchedule> {
  int _selectedIndex = 1; // Highlights Schedule icon
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _textIndigo = const Color(0xFF5C5C80);

  final List<String> startTimes = ["9:00 AM", "9:50 AM", "10:50 AM", "11:40 AM", "1:00 PM", "1:50 PM", "2:50 PM", "3:40 PM", "4:30 PM", "5:20 PM"];
  final List<String> endTimes = ["9:50 AM", "10:40 AM", "11:40 AM", "12:30 PM", "1:50 PM", "2:40 PM", "3:40 PM", "4:30 PM", "5:20 PM", "6:10 PM"];

  Future<ScheduleModel?> _fetchMySchedule() async {
    final prefs = await SharedPreferences.getInstance();
    String year = prefs.getString('year') ?? "4";
    String section = prefs.getString('section') ?? "2";
    String today = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    final service = ScheduleService();
    List<ScheduleModel> results = await service.getStudentSchedule(
      year: year, section: section, day: today,
    );
    return results.isNotEmpty ? results.first : null;
  }

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                _buildTopHeader(),
                const SizedBox(height: 30),
                _buildDateHeaderCard(),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<ScheduleModel?>(
                    future: _fetchMySchedule(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData) return Center(child: Text("No schedule found", style: TextStyle(fontFamily: 'SpaceGrotesk', color: _textIndigo, fontWeight: FontWeight.bold)));
                      return _buildSchedulePanel(snapshot.data!);
                    },
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
            "Schedule",
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

  Widget _buildDateHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // INCREASED OPACITY TO 0.1
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 24, offset: const Offset(0, -12)),
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 24, offset: const Offset(0, 7)),
        ],
      ),
      child: Column(
        children: [
          const Text("Today's Schedule", style: TextStyle(fontFamily: 'Batangas', fontSize: 24, fontWeight: FontWeight.w900)),
          Text(DateFormat('MMMM d, yyyy').format(DateTime.now()),
              style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, color: Color(0xFF5BA4F5), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSchedulePanel(ScheduleModel schedule) {
    Set<int> handledIndices = {};
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, i) {
          if (handledIndices.contains(i) || schedule.periods[i].isEmpty) return const SizedBox.shrink();
          String currentSubject = schedule.periods[i];
          String startTime = startTimes[i];
          String endTime = endTimes[i];

          if (i + 1 < 10 && schedule.periods[i + 1] == currentSubject) {
            endTime = endTimes[i + 1];
            handledIndices.add(i + 1);
          }
          return _buildScheduleItem(startTime, endTime, currentSubject, schedule.faculty);
        },
      ),
    );
  }

  Widget _buildScheduleItem(String start, String end, String subject, String faculty) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              SizedBox(width: 75, child: Text("$start\n$end", style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold, fontSize: 13))),
              const SizedBox(width: 10),
              Container(width: 1.5, height: 40, color: _mainPurple.withOpacity(0.3)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject, style: const TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(faculty, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: _mainPurple.withOpacity(0.1)),
      ],
    );
  }

  // --- UPDATED GLOWING HOME FAB ---
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [_primaryBlue, _mainPurple]),
          ),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  // --- UPDATED BOTTOM NAVIGATION BAR WITH NATIVE CUTOUT SHADOW ---
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
      onTap: () async {
        if (index == _selectedIndex) return;

        setState(() => _selectedIndex = index);

        if (index == 0) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
        } else if (index == 2) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuQAScreen()));
        } else if (index == 3) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        }

        // Reset to highlight Schedule when returned here
        if (mounted) setState(() => _selectedIndex = 1);
      },
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