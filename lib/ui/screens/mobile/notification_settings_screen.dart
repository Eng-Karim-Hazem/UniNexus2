import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_schedule.dart';
import 'package:uninexus/ui/screens/mobile/profile_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // State variables for dropdowns
  String? _selectedGeneral;
  String? _selectedQA;
  String? _selectedAnnouncements;

  bool _isLoading = false;

  final List<String> _alertModes = ['Sound', 'Vibrate', 'Silent', 'Priority'];

  final int _selectedIndex = -1;
  final Color _mainPurple = const Color(0xFF7B61FF);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedGeneral = prefs.getString('notif_general');
        _selectedQA = prefs.getString('notif_qa');
        _selectedAnnouncements = prefs.getString('notif_announcements');
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_selectedGeneral == null && _selectedQA == null && _selectedAnnouncements == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please make a selection to update.", style: TextStyle(fontFamily: MobileAppFonts.body))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('ID') ?? '';

      if (userId.isEmpty) throw Exception("User ID not found.");

      String targetCollection = 'students';
      final prefix = userId.toUpperCase();

      if (prefix.startsWith('FA')) {
        targetCollection = 'faculty';
      } else if (prefix.startsWith('ST')) {
        targetCollection = 'students';
      }

      final query = await FirebaseFirestore.instance
          .collection(targetCollection)
          .where('ID', isEqualTo: prefix)
          .limit(1)
          .get();

      if (query.docs.isEmpty) throw Exception("Could not find user profile in database.");

      final docRef = query.docs.first.reference;

      Map<String, dynamic> notifSettings = {};
      if (_selectedGeneral != null) notifSettings['general'] = _selectedGeneral;
      if (_selectedQA != null) notifSettings['qa'] = _selectedQA;
      if (_selectedAnnouncements != null) notifSettings['announcements'] = _selectedAnnouncements;

      await docRef.update({
        'notification_settings': notifSettings
      });

      if (_selectedGeneral != null) await prefs.setString('notif_general', _selectedGeneral!);
      if (_selectedQA != null) await prefs.setString('notif_qa', _selectedQA!);
      if (_selectedAnnouncements != null) await prefs.setString('notif_announcements', _selectedAnnouncements!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Notification Settings Updated!", style: TextStyle(fontFamily: MobileAppFonts.body)),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving settings: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onNavBarTapped(int index) async {
    if (index == 0) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    } else if (index == 1) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
    } else if (index == 2) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuQAScreen()));
    } else if (index == 3) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grab screen dimensions for perfect proportions
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            // Dynamic padding applied to the entire screen layout
            padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
            child: Column(
              children: [
                // 1. HEADER IS OUTSIDE THE SCROLL VIEW (Fixed at top)
                _buildHeader(),
                SizedBox(height: sh * 0.03),

                // 2. ONLY THE CONTENT BELOW THE HEADER IS SCROLLABLE
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    // Padding at the bottom so content doesn't get hidden behind the floating button
                    padding: EdgeInsets.only(bottom: sh * 0.15),
                    child: Column(
                      children: [
                        _buildFormCard(sw),
                        SizedBox(height: sh * 0.04),
                        _buildUpdateButton(sw),
                      ],
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
        ),

        const Text(
          "Notification",
          style: TextStyle(
            fontFamily: MobileAppFonts.heading,
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
    );
  }

  Widget _buildFormCard(double sw) {
    return Container(
      width: double.infinity,
      // Dynamic internal padding
      padding: EdgeInsets.all(sw * 0.06),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This feature is used to customize your notification and alerts priority and usage.",
            style: TextStyle(
              fontFamily: MobileAppFonts.body,
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),

          _buildLabel("General"),
          const SizedBox(height: 8),
          _buildDropdownField(
              value: _selectedGeneral,
              hint: "Choose the alert mode",
              onChanged: (val) => setState(() => _selectedGeneral = val)
          ),

          const SizedBox(height: 16),

          _buildLabel("Q&A"),
          const SizedBox(height: 8),
          _buildDropdownField(
              value: _selectedQA,
              hint: "Choose the alert mode",
              onChanged: (val) => setState(() => _selectedQA = val)
          ),

          const SizedBox(height: 16),

          _buildLabel("Announcements"),
          const SizedBox(height: 8),
          _buildDropdownField(
              value: _selectedAnnouncements,
              hint: "Choose the alert mode",
              onChanged: (val) => setState(() => _selectedAnnouncements = val)
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: MobileAppFonts.heading,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDropdownField({required String? value, required String hint, required Function(String?) onChanged}) {
    return Container(
      height: 50,
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
            style: TextStyle(
                fontFamily: MobileAppFonts.body,
                color: Colors.grey.shade400,
                fontSize: 13
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5C5C80), size: 28),
          isExpanded: true,
          items: _alertModes.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                  item,
                  style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14, color: Colors.black87)
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildUpdateButton(double sw) {
    return SizedBox(
      // Responsive button width so it doesn't overflow small screens
      width: sw * 0.5 > 200 ? 200 : sw * 0.5,
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _saveSettings,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        child: _isLoading
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2))
            : Text(
          "Update",
          style: TextStyle(
            fontFamily: MobileAppFonts.heading,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _mainPurple,
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
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _fabGradient,
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
          // Flexible added here to prevent horizontal layout explosions!
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}