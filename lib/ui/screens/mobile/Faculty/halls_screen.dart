import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uninexus/model/hall_model.dart';
import 'package:uninexus/services/firebase/hall_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';

import '../settings_screen.dart';
import '../Faculty/qa_screen.dart';
import '../profile_screen.dart';
import 'halls_error_screen.dart';

class HallsScreen extends StatefulWidget {
  const HallsScreen({super.key});

  @override
  State<HallsScreen> createState() => _HallsScreenState();
}

class _HallsScreenState extends State<HallsScreen> {
  // Controllers & Services
  final HallService _hallService = HallService();
  final TextEditingController _searchController = TextEditingController();

  // State Variables
  String _searchQuery = "";
  int _selectedIndex = 1;

  // Constants & Styles
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _textIndigo = const Color(0xFF5C5C80);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _accentIndigo = const Color(0xFF5C7CFA);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Logic Methods ---

  String _getCurrentTimeSlot() {
    final now = DateTime.now();
    int totalMinutes = now.hour * 60 + now.minute;
    int toMin(int h, int m) => h * 60 + m;

    if (totalMinutes >= toMin(9, 0) && totalMinutes < toMin(9, 50)) return "9:00-9:50";
    if (totalMinutes >= toMin(9, 50) && totalMinutes < toMin(10, 40)) return "9:50-10:40";
    if (totalMinutes >= toMin(10, 50) && totalMinutes < toMin(11, 40)) return "10:50-11:40";
    if (totalMinutes >= toMin(11, 40) && totalMinutes < toMin(12, 30)) return "11:40-12:30";
    if (totalMinutes >= toMin(13, 0) && totalMinutes < toMin(13, 50)) return "1:00-1:50";
    if (totalMinutes >= toMin(13, 50) && totalMinutes < toMin(14, 40)) return "1:50-2:40";
    if (totalMinutes >= toMin(14, 50) && totalMinutes < toMin(15, 40)) return "2:50-3:40";
    if (totalMinutes >= toMin(15, 40) && totalMinutes < toMin(16, 30)) return "3:40-4:30";
    if (totalMinutes >= toMin(16, 30) && totalMinutes < toMin(17, 20)) return "4:30-5:20";
    if (totalMinutes >= toMin(17, 20) && totalMinutes < toMin(18, 10)) return "5:20-6:10";
    return "OFF_HOURS";
  }

  void _onNavBarTapped(int index) async {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    final Map<int, Widget> routes = {
      0: const StuCommunity(),
      2: const QAScreen(),
      3: const ProfileScreen(),
    };

    if (routes.containsKey(index)) {
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => routes[index]!));
    }

    if (mounted) setState(() => _selectedIndex = 1);
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    String currentSlotKey = _getCurrentTimeSlot();
    String todayName = DateFormat('EEEE').format(DateTime.now());

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
              Column(
                children: [
                  _buildHeader(),
                  _buildSearchField(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<List<HallModel>>(
                      stream: _hallService.streamHallsByToday(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text("No halls data for $todayName.",
                                style: const TextStyle(fontFamily: 'SpaceGrotesk')),
                          );
                        }

                        final filteredHalls = snapshot.data!.where((hall) {
                          return hall.displayName.toLowerCase().contains(_searchQuery);
                        }).toList();

                        if (filteredHalls.isEmpty) return const Center(child: Text("No matches found."));

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredHalls.length,
                          itemBuilder: (context, index) {
                            final hall = filteredHalls[index];
                            return _buildHallCard(hall.displayName, hall.isBusy(currentSlotKey));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              _buildErrorFab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
          ),
          Text("Halls",
              style: TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          style: const TextStyle(fontFamily: 'SpaceGrotesk'),
          decoration: InputDecoration(
            hintText: "Search Hall By Name",
            hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: _mainPurple.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHallCard(String name, bool isBusy) {
    Color statusColor = isBusy ? Colors.red : Colors.greenAccent.shade700;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mainPurple.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(color: _primaryBlue.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 5))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/classroom_1.png', width: 28, height: 28, color: _mainPurple),
              const SizedBox(width: 15),
              Container(height: 35, width: 2.5, color: _mainPurple.withValues(alpha: 0.3)),
              const SizedBox(width: 15),
              Text(name,
                  style: TextStyle(
                      fontFamily: 'Batangas', fontSize: 18, fontWeight: FontWeight.bold, color: _accentIndigo)),
            ],
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorFab() {
    return Positioned(
      bottom: 130,
      right: 24,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HallErrorScreen())),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: _mainPurple.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
            ],
          ),
          child: Center(child: Icon(Icons.warning_amber_rounded, color: _mainPurple, size: 40)),
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
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
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
        elevation: 0,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavSection([
              _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
              _buildNavBarItem('assets/images/classroom_1.png', "Halls", 1),
            ]),
            const SizedBox(width: 72),
            _buildNavSection([
              _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
              _buildNavBarItem('assets/images/user.png', "Profile", 3),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavSection(List<Widget> items) =>
      Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));

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
          Text(label,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12,
                color: itemColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
