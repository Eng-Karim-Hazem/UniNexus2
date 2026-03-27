import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csv/csv.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

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
    {'icon': 'assets/icons/information.png', 'label': 'Account management'},
    {'icon': 'assets/icons/notify.png',      'label': 'Notification settings'},
    {'icon': 'assets/icons/export.png',      'label': 'Export Logs'},
    {'icon': 'assets/icons/review.png',      'label': 'Feedback'},
    {'icon': 'assets/icons/merge.png',       'label': 'App Information'},
    {'icon': 'assets/icons/logout.png',      'label': 'Logout'},
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

  // --- LOGIC: Export Logs to CSV ---
  Future<void> _exportLogsToCSV() async {
    showLoadingOverlay(context, message: 'Exporting logs...');
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('IT_Logs')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        hideLoadingOverlay(context);
        showErrorSnackBar(context, "No logs available to export.");
        return;
      }

      List<List<dynamic>> rows = [["Date", "Time", "Action Message"]];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String message = data['message'] ?? 'Unknown Action';
        final Timestamp? timestamp = data['timestamp'] as Timestamp?;

        String dateStr = 'Unknown';
        String timeStr = 'Unknown';

        if (timestamp != null) {
          final DateTime dt = timestamp.toDate();
          dateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
          int hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
          timeStr = '$hour:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
        }
        rows.add([dateStr, timeStr, message]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      Uint8List bytes = Uint8List.fromList(csvData.codeUnits);

      await FileSaver.instance.saveAs(
        name: 'Staff_IT_Logs_${DateTime.now().millisecondsSinceEpoch}',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      hideLoadingOverlay(context);
      showSuccessSnackBar(context, "Logs exported!");
    } catch (e) {
      hideLoadingOverlay(context);
      showErrorSnackBar(context, "Export error: $e");
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
            const PageHeading('Staff Settings'),
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
      case 2: return _buildExportLogs();
      case 3: return _buildFeedback();
      case 4: return _buildAppInfo();
      default: return const SizedBox();
    }
  }

  Widget _buildAccountManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Staff Account Management", style: AppTextStyles.heading),
        const SizedBox(height: 30),
        _buildTextField("New Phone", "Enter phone number", _phoneController, TextInputType.phone),
        const SizedBox(height: 20),
        _buildTextField("New Email", "Enter email", _emailController, TextInputType.emailAddress),
        const SizedBox(height: 40),
        _isBusy
            ? const Center(child: CircularProgressIndicator())
            : PillButton(label: 'Update Info', onTap: _performAccountUpdate),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Staff Notification Settings", style: AppTextStyles.heading),
        const SizedBox(height: 30),
        _buildDropdown("System Alerts", _selectedGeneral, (val) => setState(() => _selectedGeneral = val)),
        const SizedBox(height: 20),
        _buildDropdown("User Support Requests", _selectedQA, (val) => setState(() => _selectedQA = val)),
        const SizedBox(height: 20),
        _buildDropdown("Staff Announcements", _selectedAnnouncements, (val) => setState(() => _selectedAnnouncements = val)),
        const SizedBox(height: 40),
        _isBusy
            ? const Center(child: CircularProgressIndicator())
            : PillButton(label: 'Save Preferences', onTap: _saveNotificationSettings),
      ],
    );
  }

  Widget _buildExportLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('System Logs', style: AppTextStyles.heading),
        const SizedBox(height: 40),
        const Text('Export official CSV reports for staff analysis.'),
        const SizedBox(height: 60),
        Center(child: PillButton(label: 'Download CSV', onTap: _exportLogsToCSV)),
      ],
    );
  }

  Widget _buildFeedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Feedback", style: AppTextStyles.heading),
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
            : PillButton(label: 'Submit Feedback', onTap: _submitFeedback),
      ],
    );
  }

  Widget _buildAppInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Staff Portal Information", style: AppTextStyles.heading),
        SizedBox(height: 20),
        Text("Version: IT-Nexus 2.0 (Staff Edition)"),
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