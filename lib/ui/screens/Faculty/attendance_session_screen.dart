import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import screens for navigation
import '../Student/stu_community.dart';
import 'faculty_home_screen.dart';
import '../Faculty/qa_screen.dart';
import '../profile_screen.dart';
import '../Faculty/faculty_id_screen.dart';

class AttendanceSessionScreen extends StatefulWidget {
  const AttendanceSessionScreen({super.key});

  @override
  State<AttendanceSessionScreen> createState() => _AttendanceSessionScreenState();
}

class _AttendanceSessionScreenState extends State<AttendanceSessionScreen> {
  // Form Controllers
  final TextEditingController _durationController = TextEditingController();
  String? _selectedCourse;
  String? _selectedSessionType;

  // The Active Index for this screen is technically not on the bar (it's a sub-screen)
  final int _selectedIndex = 1;

  // Colors
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final List<String> _courses = [
    'CCNA R&S II',
    'Network Security',
    'IOT Architecture',
    'Mobile Programming'
  ];

  final List<String> _sessionTypes = [
    'Lecture',
    'Section',
    'Lab'
  ];

  // --- NAVIGATION LOGIC ---
  void _onNavBarTapped(int index) async {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    }
    else if (index == 1) {
      // Already here or related area
    }
    else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const QAScreen()));
    }
    else if (index == 3) {
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
              gradient: _fabGradient, // Blue -> Purple
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
            child: Column(
              children: [
                // 1. Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
                    ),
                    const Text(
                      "Attendance",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C5C80),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 2. QR Code Display Card (GLASSY + LAYERED QR)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    // GLASSY EFFECT
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF237ABA).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // --- LAYERED QR CODE ---
                      // We use a Stack to place the original logo ON TOP of the gradient QR
                      SizedBox(
                        width: 200.0,
                        height: 200.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // LAYER 1: The Gradient QR Code (data dots only)
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xFF237ABA), Color(0xFF9C2CF3)], // Blue -> Purple
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: QrImageView(
                                data: "Session-Placeholder-123",
                                version: QrVersions.auto,
                                size: 200.0,
                                // Base color black, will be overridden by shader
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.circle,
                                  color: Colors.black,
                                ),
                                // IMPORTANT: No embeddedImage here!
                              ),
                            ),

                            // LAYER 2: The Original, Uncolored Logo centered on top
                            Container(
                              width: 45, // Size of the logo box
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white, // White background behind logo for cleanliness
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(3), // Slight padding for the white border effect
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset(
                                  'assets/images/LOGO.png',
                                  fit: BoxFit.cover,
                                  // No color property here, so it keeps original colors
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Form Card (GLASSY EFFECT)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // GLASSY EFFECT
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF237ABA).withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- Field 1: Course --
                      _buildLabel("Course"),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: _selectedCourse,
                        hint: "Choose the Course",
                        items: _courses,
                        onChanged: (val) => setState(() => _selectedCourse = val),
                      ),

                      const SizedBox(height: 16),

                      // -- Row: Session Type & Duration --
                      Row(
                        children: [
                          // Session Type
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Session Type"),
                                const SizedBox(height: 8),
                                _buildDropdownField(
                                  value: _selectedSessionType,
                                  hint: "Choose Type",
                                  items: _sessionTypes,
                                  onChanged: (val) => setState(() => _selectedSessionType = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Duration
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Duration"),
                                const SizedBox(height: 8),
                                Container(
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F2F2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: TextField(
                                    controller: _durationController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Duration",
                                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 4. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Session Created!")),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7B61FF), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C5C80),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5C5C80), size: 28),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
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