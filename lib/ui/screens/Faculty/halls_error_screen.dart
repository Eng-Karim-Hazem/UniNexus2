import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import screens for navigation
import 'faculty_home_screen.dart';
import 'qa_screen.dart';
import '../profile_screen.dart';
import '../Faculty/halls_screen.dart';
import 'faculty_id_screen.dart';

class HallErrorScreen extends StatefulWidget {
  const HallErrorScreen({super.key});

  @override
  State<HallErrorScreen> createState() => _HallErrorScreenState();
}

class _HallErrorScreenState extends State<HallErrorScreen> {
  // Controllers
  final TextEditingController _hallNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedErrorType;

  // Active Index 1 (Since this is accessed from Halls/Schedule area)
  final int _selectedIndex = 1;

  // Colors
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final List<String> _errorTypes = [
    'Projector Issue',
    'Air Conditioner',
    'Lighting',
    'Furniture/Desk',
    'Other'
  ];

  // --- NAVIGATION LOGIC ---
  void _onNavBarTapped(int index) async {
    if (index == 0) {
      // Community -> Home
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    else if (index == 1) {
      // Schedule -> Go back to Halls list?
      // Or stay here? Usually tapping "Schedule" again takes you to the main schedule list.
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HallsScreen()));
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
                      onTap: () => Navigator.pop(context), // Back button
                      child: Image.asset('assets/images/menu.png', width: 28, color: _mainPurple),
                    ),
                    const Text(
                      "Hall Error",
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

                const SizedBox(height: 30),

                // 2. The Form Card (GLASSY + PURPLE BORDER)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // Glassy Effect
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(24),
                    // Purple Border
                    border: Border.all(color: _mainPurple.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF237ABA).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- Field 1: Hall Name --
                      _buildLabel("Hall name"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _hallNameController,
                        hint: "Submit the errored hall's name",
                        icon: Icons.send_rounded,
                        isButton: true,
                      ),

                      const SizedBox(height: 20),

                      // -- Field 2: Error Type (Dropdown) --
                      _buildLabel("Error Type"),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedErrorType,
                            hint: Text("Choose the error type", style: TextStyle(color: Colors.grey.shade400)),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5C5C80), size: 30),
                            items: _errorTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedErrorType = newValue;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // -- Field 3: Description --
                      _buildLabel("Description"),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration.collapsed(
                            hintText: "Submit your problem details",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // -- Field 4: Attachment --
                      _buildLabel("Attachment"),
                      const SizedBox(height: 8),
                      _buildTextField(
                          controller: TextEditingController(),
                          hint: "Attach a photo if possible",
                          icon: Icons.add_rounded,
                          isButton: true,
                          onIconTap: () {
                            // TODO: Open Gallery
                          }
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 3. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error Report Submitted!")),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _mainPurple, width: 2), // Purple Border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C5C80),
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

  // --- Helpers ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool isButton = false,
    VoidCallback? onIconTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        readOnly: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: icon != null
              ? GestureDetector(
            onTap: onIconTap,
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _mainPurple.withOpacity(0.8), // Purple Icon Bg
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          )
              : null,
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