import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/model/schedule_model.dart';
import 'package:uninexus/services/firebase/schedule_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';

class StuSchedule extends StatefulWidget {
  const StuSchedule({super.key});

  @override
  State<StuSchedule> createState() => _StuScheduleState();
}

class _StuScheduleState extends State<StuSchedule> {
  int _selectedIndex = 1;
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _textIndigo = const Color(0xFF5C5C80);

  late String _selectedDay;

  final List<String> _weekdays = [
    "saturday", "sunday", "monday", "tuesday", "wednesday", "thursday", "friday"
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  }

  Future<ScheduleModel?> _fetchScheduleFromService() async {
    final prefs = await SharedPreferences.getInstance();
    String year = prefs.getString('year') ?? "4";
    String section = prefs.getString('section') ?? "4";

    final service = ScheduleService();
    try {
      final result = await service.getStudentSchedule(
        year: year,
        section: section,
        day: _selectedDay,
      );

      if (result != null && result.isNotEmpty) {
        return result.first;
      }
    } catch (e) {
      debugPrint("Schedule Service Error: $e");
    }
    return null;
  }

  Future<void> _goHome() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';

    Widget targetHome = userId.toUpperCase().startsWith('FA')
        ? const FacultyHomeScreen()
        : const StuHomeScreen();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetHome),
          (route) => false,
    );
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
            image: AssetImage('assets/images/Phone_Background.png'),
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
                const SizedBox(height: 24),
                _buildDateHeaderCard(),
                const SizedBox(height: 16),
                _buildDayFilterBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<ScheduleModel?>(
                    future: _fetchScheduleFromService(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(
                          child: Text(
                            "No schedule found for ${toBeginningOfSentenceCase(_selectedDay)}",
                            style: TextStyle(
                              fontFamily: MobileAppFonts.body,
                              color: _textIndigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return _buildDynamicSchedulePanel(snapshot.data!);
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
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          },
          child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
        ),
        const Text(
            "Schedule",
            style: TextStyle(
                fontFamily: MobileAppFonts.heading,
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.8 * 255).toInt()),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.1 * 255).toInt()), blurRadius: 24, offset: const Offset(0, -12)),
          BoxShadow(color: Colors.black.withAlpha((0.1 * 255).toInt()), blurRadius: 24, offset: const Offset(0, 7)),
        ],
      ),
      child: Column(
        children: [
          const Text("Timetable Matrix", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(DateFormat('MMMM d, yyyy').format(DateTime.now()),
              style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14, color: Color(0xFF5BA4F5), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDayFilterBar() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _weekdays.length,
        itemBuilder: (context, index) {
          final day = _weekdays[index];
          final bool isSelected = _selectedDay == day;
          final String shortLabel = day.substring(0, 3).toUpperCase();

          return GestureDetector(
            onTap: () {
              if (_selectedDay != day) {
                setState(() => _selectedDay = day);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _mainPurple : Colors.white.withAlpha((0.7 * 255).toInt()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _mainPurple : _mainPurple.withAlpha((0.2 * 255).toInt()),
                  width: 1,
                ),
                boxShadow: isSelected ? [BoxShadow(color: _mainPurple.withAlpha((0.3 * 255).toInt()), blurRadius: 8, offset: const Offset(0, 4))] : null,
              ),
              child: Center(
                child: Text(
                  shortLabel,
                  style: TextStyle(
                    fontFamily: MobileAppFonts.body,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? Colors.white : _textIndigo.withAlpha((0.8 * 255).toInt()),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Parses, orders, and merges matching continuous lecture frames seamlessly
  Widget _buildDynamicSchedulePanel(ScheduleModel schedule) {
    final facultyName = schedule.faculty.isNotEmpty ? schedule.faculty : 'N/A';
    final slots = schedule.timeSlots;

    if (slots.isEmpty) {
      return Center(
        child: Text(
          "No classes assigned.",
          style: TextStyle(fontFamily: MobileAppFonts.body, color: _textIndigo),
        ),
      );
    }

    // Master list structure reference from image_e9c927.png
    final List<String> masterTimeline = [
      '9:00-9:50',
      '9:50-10:40',
      '10:50-11:40',
      '11:40-12:30',
      '1:00-1:50',
      '1:50-2:40',
      '2:50-3:40',
      '3:40-4:30',
      '4:30-5:20',
      '5:20-6:10',
    ];

    int getMinutesFromField(String timeField) {
      try {
        final rawStart = timeField.split('-').first.trim();
        final timeParts = rawStart.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        if (hour >= 1 && hour <= 6) {
          hour += 12;
        }
        return (hour * 60) + minute;
      } catch (_) {
        return 9999;
      }
    }

    // 1. Sort the dynamic fields in temporal timeline sequence
    final sortedKeys = slots.keys.toList();
    sortedKeys.sort((a, b) {
      int indexA = masterTimeline.indexOf(a.trim());
      int indexB = masterTimeline.indexOf(b.trim());

      if (indexA != -1 && indexB != -1) {
        return indexA.compareTo(indexB);
      }
      return getMinutesFromField(a).compareTo(getMinutesFromField(b));
    });

    // 2. Linear pass execution to compress and join identical consecutive blocks
    final List<MapEntry<String, String>> mergedSlots = [];

    for (var currentKey in sortedKeys) {
      final currentSubject = slots[currentKey]!;

      if (mergedSlots.isEmpty) {
        mergedSlots.add(MapEntry(currentKey, currentSubject));
      } else {
        final lastEntry = mergedSlots.last;
        final lastKey = lastEntry.key;
        final lastSubject = lastEntry.value;

        // If the subject matches, merge the time boundaries
        if (lastSubject.trim().toLowerCase() == currentSubject.trim().toLowerCase()) {
          final lastStartTime = lastKey.split('-').first.trim();
          final currentEndTime = currentKey.split('-').last.trim();

          // Replace the last item with the updated merged time entry
          mergedSlots[mergedSlots.length - 1] = MapEntry("$lastStartTime-$currentEndTime", lastSubject);
        } else {
          mergedSlots.add(MapEntry(currentKey, currentSubject));
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.4 * 255).toInt()),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withAlpha((0.5 * 255).toInt()), width: 1.5),
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: mergedSlots.length,
        itemBuilder: (context, index) {
          final timeRangeKey = mergedSlots[index].key;
          final subjectName = mergedSlots[index].value;

          final parts = timeRangeKey.split('-');
          String startDisplay = parts[0].trim();
          String endDisplay = parts.length > 1 ? parts[1].trim() : '';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text(
                        "$startDisplay\n$endDisplay",
                        style: const TextStyle(
                          fontFamily: MobileAppFonts.body,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 1.5,
                      height: 40,
                      color: _mainPurple.withAlpha((0.3 * 255).toInt()),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subjectName,
                            style: const TextStyle(
                              fontFamily: MobileAppFonts.heading,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            facultyName,
                            style: const TextStyle(
                              fontFamily: MobileAppFonts.body,
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: _mainPurple.withAlpha((0.1 * 255).toInt())),
            ],
          );
        },
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
          BoxShadow(color: _mainPurple.withAlpha((0.6 * 255).toInt()), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: FloatingActionButton(
        onPressed: _goHome,
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

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.18 * 255).toInt()), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, -6)),
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
                  _navItem('assets/images/qa.png', "Q&A", 2),
                ],
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem('assets/images/calendar.png', "Schedule", 1),
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

        if (mounted) setState(() => _selectedIndex = 1);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, width: 28, height: 28, color: sel ? _mainPurple : Colors.grey.shade500),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: MobileAppFonts.body,
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