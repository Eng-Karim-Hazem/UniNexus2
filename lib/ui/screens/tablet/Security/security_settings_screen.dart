import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/ui/screens/tablet/welcome_screen_tablet.dart';

class SecuritySettingsScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const SecuritySettingsScreen({super.key, required this.onNavigate});

  @override
  State<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  int? selectedSettingTab;

  // Controllers
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Notification States
  String? _selectedGate;
  String? _selectedAnnouncements;
  String? _selectedWarnings;
  final List<String> _alertModes = ['Sound', 'Vibrate', 'Silent', 'Priority'];

  int _rating = 4;
  bool _isBusy = false; // Loading state for buttons

  static const List<Map<String, String>> _items = [
    {'icon': 'assets/images/information_1.png', 'label': 'Account management'},
    {'icon': 'assets/images/notify_1.png', 'label': 'Notification settings'},
    {'icon': 'assets/images/review_1.png', 'label': 'Feedback'},
    {'icon': 'assets/images/merge_1.png', 'label': 'App Information'},
    {'icon': 'assets/images/logout_1.png', 'label': 'Logout'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- LOGIC: Load Local Preferences ---
  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGate = prefs.getString('sec_gate_notif');
      _selectedAnnouncements = prefs.getString('sec_ann_notif');
      _selectedWarnings = prefs.getString('sec_warn_notif');
    });
  }

  // --- LOGIC: Account Management Update (Staff Collection) ---
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

      if (userId.isEmpty) throw Exception("Session not found.");

      // Targeting 'staff' collection for Security personnel
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

      // Sync local cache
      if (newPhone.isNotEmpty) await prefs.setString('pNum', newPhone);
      if (newEmail.isNotEmpty) await prefs.setString('email', newEmail);

      if (mounted) {
        showSuccessSnackBar(context, 'Security account updated successfully!');
        _phoneController.clear();
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Update failed: $e");
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // --- LOGIC: Notification Settings Sync ---
  Future<void> _saveNotificationSettings() async {
    setState(() => _isBusy = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('ID') ?? '';

      final query = await FirebaseFirestore.instance
          .collection('staff')
          .where('ID', isEqualTo: userId.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) throw Exception("Profile not found.");

      Map<String, String> settingsMap = {};
      if (_selectedGate != null) settingsMap['gate_alerts'] = _selectedGate!;
      if (_selectedAnnouncements != null) settingsMap['announcements'] = _selectedAnnouncements!;
      if (_selectedWarnings != null) settingsMap['warnings'] = _selectedWarnings!;

      await query.docs.first.reference.update({
        'security_notification_prefs': settingsMap
      });

      // Save locally
      if (_selectedGate != null) await prefs.setString('sec_gate_notif', _selectedGate!);
      if (_selectedAnnouncements != null) await prefs.setString('sec_ann_notif', _selectedAnnouncements!);
      if (_selectedWarnings != null) await prefs.setString('sec_warn_notif', _selectedWarnings!);

      if (mounted) showSuccessSnackBar(context, 'Security alerts updated!');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Error: $e");
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
      final String userId = prefs.getString('ID') ?? 'Unknown Security';
      final String fName = prefs.getString('fName') ?? '';
      final String lName = prefs.getString('lName') ?? '';

      await FirebaseFirestore.instance.collection('Feedback').add({
        'userId': userId,
        'userName': '$fName $lName'.trim(),
        'role': 'Security',
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

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Settings'),
            const SizedBox(height: 10),
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
                                if (index == 4) {
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
      case 2: return _buildFeedback();
      case 3: return _buildAppInfo();
      default: return const SizedBox();
    }
  }

  // --- HELPER: Reusable Header Layout ---
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

  Widget _buildAccountManagement() {
    // Widened: 20% of screen, clamped between 200 and 280 pixels
    final buttonWidth = (MediaQuery.of(context).size.width * 0.20).clamp(200.0, 280.0);

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
            : Center( // <-- WRAPPED IN CENTER
          child: SizedBox(
              width: buttonWidth,
              child: PillButton(label: 'Update', onTap: _performAccountUpdate)
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    // Widened: 20% of screen, clamped between 200 and 280 pixels
    final buttonWidth = (MediaQuery.of(context).size.width * 0.20).clamp(200.0, 280.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Notification Settings", 'assets/images/notify_1.png', Icons.notifications),
        const SizedBox(height: 30),
        _buildDropdown("Gate Alerts", _selectedGate, (val) => setState(() => _selectedGate = val)),
        const SizedBox(height: 20),
        _buildDropdown("Announcements", _selectedAnnouncements, (val) => setState(() => _selectedAnnouncements = val)),
        const SizedBox(height: 20),
        _buildDropdown("Warnings", _selectedWarnings, (val) => setState(() => _selectedWarnings = val)),
        const SizedBox(height: 40),
        _isBusy
            ? const Center(child: CircularProgressIndicator())
            : Center( // <-- WRAPPED IN CENTER
          child: SizedBox(
              width: buttonWidth,
              child: PillButton(label: 'Save', onTap: _saveNotificationSettings)
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    // Widened: 20% of screen, clamped between 200 and 280 pixels
    final buttonWidth = (MediaQuery.of(context).size.width * 0.20).clamp(200.0, 280.0);

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
            hintText: "Write feedback...",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 30),
        _isBusy
            ? const Center(child: CircularProgressIndicator())
            : Center( // <-- WRAPPED IN CENTER
          child: SizedBox(
              width: buttonWidth,
              child: PillButton(label: 'Submit', onTap: _submitFeedback)
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
      title: "Confirm Logout",
      message: "Are you sure you want to logout?",
      confirmText: "Logout",
      cancelText: "Cancel",
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
              hint: const Text("Choose alert mode"),
              items: _alertModes.map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}