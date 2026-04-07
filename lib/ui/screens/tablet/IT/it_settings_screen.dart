import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // --- ADDED URL LAUNCHER ---

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

import '../welcome_screen_tablet.dart';

class ITSettingsScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;

  const ITSettingsScreen({super.key, required this.onNavigate});

  @override
  State<ITSettingsScreen> createState() => _ITSettingsScreenState();
}

class _ITSettingsScreenState extends State<ITSettingsScreen> {
  int? selectedSettingTab;

  // Controllers & State
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Notification States
  String? _selectedGeneral;
  String? _selectedQA;
  String? _selectedAnnouncements;
  final List<String> _alertModes = ['Sound', 'Vibrate', 'Silent', 'Priority'];

  int _rating = 4;
  bool _isBusy = false;

  static const List<Map<String, String>> _items = [
    {'icon': 'assets/icons/Information.png', 'label': 'Account management'},
    {'icon': 'assets/icons/Alarm_1.png',      'label': 'Notification settings'},
    {'icon': 'assets/icons/Export.png',      'label': 'Logs'}, // Changed label
    {'icon': 'assets/icons/Review.png',      'label': 'Feedback'},
    {'icon': 'assets/icons/About.png',       'label': 'App Information'},
    {'icon': 'assets/icons/Logout.png',      'label': 'Logout'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- LOGIC: Load Settings ---
  Future<void> _loadAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGeneral = prefs.getString('notif_general');
      _selectedQA = prefs.getString('notif_qa');
      _selectedAnnouncements = prefs.getString('notif_announcements');
    });
  }

  // --- LOGIC: Save Notification Settings (STAFF ONLY) ---
  Future<void> _saveNotificationSettings() async {
    if (_selectedGeneral == null && _selectedQA == null && _selectedAnnouncements == null) {
      showErrorSnackBar(context, "Please select at least one alert mode.");
      return;
    }

    setState(() => _isBusy = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('ID') ?? prefs.getString('userCode') ?? '';

      if (userId.isEmpty) throw Exception("User session not found.");

      // Strictly targeting the 'staff' collection
      final query = await FirebaseFirestore.instance
          .collection('staff')
          .where('ID', isEqualTo: userId.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) throw Exception("Staff profile not found in database.");

      Map<String, String> settingsMap = {};
      if (_selectedGeneral != null) settingsMap['general'] = _selectedGeneral!;
      if (_selectedQA != null) settingsMap['qa'] = _selectedQA!;
      if (_selectedAnnouncements != null) settingsMap['announcements'] = _selectedAnnouncements!;

      await query.docs.first.reference.update({
        'notification_preferences': settingsMap
      });

      // Save locally
      if (_selectedGeneral != null) await prefs.setString('notif_general', _selectedGeneral!);
      if (_selectedQA != null) await prefs.setString('notif_qa', _selectedQA!);
      if (_selectedAnnouncements != null) await prefs.setString('notif_announcements', _selectedAnnouncements!);

      if (mounted) showSuccessSnackBar(context, 'Staff notification preferences synced!');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // --- LOGIC: Account Management Update (STAFF ONLY) ---
  Future<void> _performAccountUpdate() async {
    final newPhone = _phoneController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newPhone.isEmpty && newEmail.isEmpty) {
      showErrorSnackBar(context, "Please enter at least one field to update.");
      return;
    }

    setState(() => _isBusy = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('ID') ?? prefs.getString('userCode') ?? '';

      // Strictly targeting the 'staff' collection
      final query = await FirebaseFirestore.instance
          .collection('staff')
          .where('ID', isEqualTo: userId.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) throw Exception("Staff profile not found.");

      Map<String, dynamic> updates = {};
      if (newPhone.isNotEmpty) updates['pNum'] = newPhone;
      if (newEmail.isNotEmpty) updates['email'] = newEmail;

      await query.docs.first.reference.update(updates);

      if (newPhone.isNotEmpty) await prefs.setString('pNum', newPhone);
      if (newEmail.isNotEmpty) await prefs.setString('email', newEmail);

      if (mounted) {
        showSuccessSnackBar(context, 'Staff account updated successfully!');
        _phoneController.clear();
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Update failed: $e");
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // --- LOGIC: Feedback Submission ---
  Future<void> _submitFeedback() async {
    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.isEmpty) {
      showErrorSnackBar(context, "Please write your feedback.");
      return;
    }

    setState(() => _isBusy = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('ID') ?? 'Unknown Staff';
      final String fName = prefs.getString('fName') ?? '';
      final String lName = prefs.getString('lName') ?? '';

      await FirebaseFirestore.instance.collection('Feedback').add({
        'userId': userId,
        'userName': '$fName $lName'.trim(),
        'role': 'Staff',
        'rating': _rating,
        'message': feedbackText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showSuccessSnackBar(context, 'Thank you for your feedback!');
        _feedbackController.clear();
        setState(() => _rating = 4);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Submission failed: $e");
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // --- LOGIC: Open Google Sheets ---
  Future<void> _openGoogleSheetLogs() async {
    // PASTE THE LINK TO YOUR GOOGLE SHEET HERE (Not the Webhook URL, the actual viewing URL)
    const String sheetUrl = 'https://docs.google.com/spreadsheets/d/18JxhVOoqC9p7NG_Bzr9M3dmYRA69PL2SDpt03sDAu00/edit?usp=sharing';

    final Uri url = Uri.parse(sheetUrl);

    try {
      // mode: LaunchMode.externalApplication forces it to open in the native browser or Google Sheets app
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) showErrorSnackBar(context, 'Could not launch Google Sheets.');
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Settings'),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: selectedSettingTab == null ? 1 : 0,
                    child: Center(
                      child: SizedBox(
                        width: selectedSettingTab == null ? 900 : 420,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: selectedSettingTab == null ? 3 : 2,
                            mainAxisSpacing: 25,
                            crossAxisSpacing: 25,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return SettingsCard(
                              iconPath: item['icon']!,
                              label: item['label']!,
                              onTap: () {
                                if (index == 5) {
                                  _logout();
                                } else {
                                  setState(() => selectedSettingTab = index);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  if (selectedSettingTab != null) ...[
                    const SizedBox(width: 30),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.primary, width: 2),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _getContentForTab(selectedSettingTab!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getContentForTab(int index) {
    switch (index) {
      case 0: return _buildAccountManagement();
      case 1: return _buildNotificationSettings();
      case 2: return _buildExportLogs(); // This now points to the new UI
      case 3: return _buildFeedback();
      case 4: return _buildAppInfo();
      default: return const SizedBox();
    }
  }

  Widget _buildAccountManagement() {
    // Dynamic width: 20% of screen, clamped between 200 and 280 pixels
    final buttonWidth = (MediaQuery.of(context).size.width * 0.25).clamp(240.0, 300.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Account Management", 'assets/images/information_1.png', Icons.person),
        const SizedBox(height: 30),
        _buildTextField("New Phone", "Enter phone number", _phoneController, TextInputType.phone),
        const SizedBox(height: 20),
        _buildTextField("New Email", "Enter email", _emailController, TextInputType.emailAddress),
        const SizedBox(height: 40),
        _isBusy
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: SizedBox(
            width: buttonWidth,
            child: PillButton(label: 'Update Info', onTap: _performAccountUpdate),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    // Dynamic width: 20% of screen, clamped between 200 and 280 pixels
    final buttonWidth = (MediaQuery.of(context).size.width * 0.25).clamp(220.0, 300.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Notification Settings", 'assets/images/notify_1.png', Icons.notifications),
        const SizedBox(height: 30),
        _buildDropdown("System Alerts", _selectedGeneral, (val) => setState(() => _selectedGeneral = val)),
        const SizedBox(height: 20),
        _buildDropdown("User Support Requests", _selectedQA, (val) => setState(() => _selectedQA = val)),
        const SizedBox(height: 20),
        _buildDropdown("Staff Announcements", _selectedAnnouncements, (val) => setState(() => _selectedAnnouncements = val)),
        const SizedBox(height: 40),
        _isBusy
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: SizedBox(
            width: buttonWidth,
            child: PillButton(label: 'Save Preferences', onTap: _saveNotificationSettings),
          ),
        ),
      ],
    );
  }

  // --- UPDATED UI FOR GOOGLE SHEETS ---
  Widget _buildExportLogs() {
    // Dynamic width: 20% of screen, clamped between 200 and 280 pixels
    final buttonWidth = (MediaQuery.of(context).size.width * 0.25).clamp(220.0, 300.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("System Logs", 'assets/icons/Export.png', Icons.notifications),
        const SizedBox(height: 40),
        const Text('Access the real-time Google Sheet containing all staff actions and system logs. You can download the sheet by clicking the open google sheet button then pressing the 3 dots button and after that press download.'),
        const SizedBox(height: 60),
        Center(
          child: SizedBox(
            width: buttonWidth,
            child: PillButton(label: 'Open Google Sheet', onTap: _openGoogleSheetLogs),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    // Dynamic width: 20% of screen, clamped between 200 and 280 pixels
    final buttonWidth = (MediaQuery.of(context).size.width * 0.25).clamp(220.0, 300.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Feedback", 'assets/images/review_1.png', Icons.rate_review),
        const SizedBox(height: 30),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => setState(() => _rating = index + 1),
              child: Icon(
                Icons.star_rounded,
                size: 40,
                color: index < _rating ? AppColors.primary : Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _feedbackController,
          maxLines: 4,
          maxLength: 250,
          decoration: InputDecoration(
            hintText: "Enter feedback as Staff...",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 30),
        _isBusy
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: SizedBox(
            width: buttonWidth,
            child: PillButton(label: 'Submit Feedback', onTap: _submitFeedback),
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("App Information", 'assets/images/merge_1.png', Icons.account_tree),
        const SizedBox(height: 24),
        const Text(
          "This feature is used to acknowledge the system developers and supervisors also to check the UniNexus version.",
          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 80),
        const Center(
          child: Text(
            "App Version: UN2.0",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 80),
        const Text(
          "Presented to you by the family of the UniNexus team and supervised by:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        const Text(
          "DR. Iman El-Sayed\nEng. Hossam Medhat",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.4),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: "Logout Staff Session?",
      message: "Are you sure you want to exit the staff portal?",
      confirmText: "Logout",
      cancelText: "Stay",
      confirmColor: Colors.red,
      icon: Icons.logout,
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomePage()), (route) => false);
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? currentValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: currentValue,
              hint: const Text("Set alert mode"),
              items: _alertModes.map((mode) {
                return DropdownMenuItem(value: mode, child: Text(mode));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
Widget _buildSectionHeader(String title, String iconPath, IconData fallbackIcon) {
  return Row(
    children: [
      Image.asset(
        iconPath,
        width: 36,
        height: 36,
        color: AppColors.primary,
        errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: AppColors.primary, size: 36),
      ),
      const SizedBox(width: 16),
      Container(width: 2, height: 36, color: Colors.grey.withOpacity(0.5)),
      const SizedBox(width: 16),
      Text(title, style: AppTextStyles.heading),
    ],
  );
}