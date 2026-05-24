import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:uninexus/model/hall_model.dart';
import 'package:uninexus/services/firebase/hall_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';
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
  final HallService _hallService = HallService();
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<HallModel>> _hallsStream;

  String _searchQuery = "";
  int _selectedIndex = 1;

  // 1. ADD FILTER STATE
  String _selectedFilter = 'All';

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _textIndigo = const Color(0xFF5C5C80);
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _accentIndigo = const Color(0xFF5C7CFA);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _hallsStream = _hallService.streamAllHalls();
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
  Future<void> _goHome() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';

    Widget targetHome;

    // Check the ID prefix to determine if they are Faculty or Student
    if (userId.toUpperCase().startsWith('FA')) {
      targetHome = const FacultyHomeScreen();
    } else {
      targetHome = const StuHomeScreen(); // Defaults to Student
    }

    if (!mounted) return;

    // pushAndRemoveUntil destroys the back-stack, preventing ghost screens
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetHome),
          (route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(sw),
                  _buildSearchField(sw),
                  const SizedBox(height: 16), // Spacing
                  _buildFilterRow(sw),        // 2. ADD FILTER ROW HERE
                  SizedBox(height: sh * 0.02),
                  Expanded(
                    child: StreamBuilder<List<HallModel>>(
                      stream: _hallsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("No halls data found.",
                                style: TextStyle(fontFamily: MobileAppFonts.body)),
                          );
                        }

                        final normalizedQuery = _searchQuery.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), "");

                        // 3. APPLY COMBINED FILTER LOGIC
                        final filteredHalls = snapshot.data!.where((hall) {
                          // Check Search Query
                          if (normalizedQuery.isNotEmpty) {
                            final normalizedHallName = hall.displayName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), "");
                            if (!normalizedHallName.contains(normalizedQuery)) return false;
                          }

                          // Check Filter Chips
                          if (_selectedFilter == 'Available') return hall.isAvailable;
                          if (_selectedFilter == 'Occupied') return hall.isBusy;
                          return true; // 'All'
                        }).toList();

                        // Sort the halls in ascending order
                        filteredHalls.sort((a, b) => a.displayName.compareTo(b.displayName));

                        if (filteredHalls.isEmpty) {
                          return const Center(child: Text("No matches found.", style: TextStyle(fontFamily: MobileAppFonts.body)));
                        }

                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(sw * 0.06, 0, sw * 0.06, 180),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredHalls.length,
                          itemBuilder: (context, index) {
                            final hall = filteredHalls[index];
                            return _buildHallCard(hall.displayName, hall.isBusy);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              _buildErrorFab(sw, sh),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple),
          ),
          Text("Halls",
              style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: TextField(
          controller: _searchController,
          maxLength: 4,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text;
              if (text.isEmpty) return newValue;
              if (text.length == 1) {
                return RegExp(r'^[a-zA-Z]$').hasMatch(text) ? newValue : oldValue;
              }
              if (text.length > 1) {
                return RegExp(r'^[a-zA-Z][0-9]{0,3}$').hasMatch(text) ? newValue : oldValue;
              }
              return oldValue;
            }),
          ],
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(fontFamily: MobileAppFonts.body),
          decoration: InputDecoration(
            counterText: "",
            hintText: "Search Hall (e.g. A303)",
            hintStyle: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey.shade400),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: _mainPurple.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  // 4. NEW FILTER ROW WIDGET
  Widget _buildFilterRow(double sw) {
    final List<String> options = ['All', 'Available', 'Occupied'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: Row(
        children: options.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
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

  Widget _buildHallCard(String name, bool isBusy) {
    Color statusColor = isBusy ? Colors.red : Colors.greenAccent.shade700;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mainPurple.withOpacity(0.7)),
          boxShadow: [
            BoxShadow(color: _primaryBlue.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/classroom_1.png', width: 28, height: 28, color: _mainPurple),
              const SizedBox(width: 15),
              Container(height: 35, width: 2.5, color: _mainPurple.withOpacity(0.3)),
              const SizedBox(width: 15),
              Text(name,
                  style: TextStyle(
                      fontFamily: MobileAppFonts.heading, fontSize: 18, fontWeight: FontWeight.bold, color: _accentIndigo)),
            ],
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              boxShadow: [BoxShadow(color: statusColor.withOpacity(0.4), blurRadius: 6, spreadRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorFab(double sw, double sh) {
    return Positioned(
      bottom: (sh * 0.12).clamp(110.0, 140.0),
      right: (sw * 0.06).clamp(20.0, 35.0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HallErrorScreen())),
        child: Container(
          width: (sw * 0.20).clamp(70.0, 85.0),
          height: (sw * 0.20).clamp(70.0, 85.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular((sw * 0.05).clamp(16.0, 24.0)),
            boxShadow: [
              BoxShadow(
                  color: _mainPurple.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8)
              )
            ],
          ),
          child: Center(
              child: Icon(
                  Icons.warning_amber_rounded,
                  color: _mainPurple,
                  size: (sw * 0.20).clamp(30.0, 50.0)
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
            color: _mainPurple.withOpacity(0.6),
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
          Flexible(
            child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MobileAppFonts.body,
                  fontSize: 12,
                  color: itemColor,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                )
            ),
          ),
        ],
      ),
    );
  }
}