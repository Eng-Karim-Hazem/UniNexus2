import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- NEW IMPORTS FOR CSV EXPORT ---
import 'package:csv/csv.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

import '../welcome_screen.dart';

class ITSettingsScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;

  const ITSettingsScreen({super.key, required this.onNavigate});

  @override
  State<ITSettingsScreen> createState() => _ITSettingsScreenState();
}

class _ITSettingsScreenState extends State<ITSettingsScreen> {
  int? selectedSettingTab;
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 4;
  bool _isExporting = false; // Added to show loading state during export

  /// Settings menu items
  static const List<Map<String, String>> _items = [
    {'icon': 'assets/icons/information.png', 'label': 'Account management'},
    {'icon': 'assets/icons/notify.png',      'label': 'Notification settings'},
    {'icon': 'assets/icons/export.png',      'label': 'Export Logs'},
    {'icon': 'assets/icons/review.png',      'label': 'Feedback'},
    {'icon': 'assets/icons/merge.png',       'label': 'App Information'},
    {'icon': 'assets/icons/logout.png',      'label': 'Logout'},
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // --- CSV EXPORT LOGIC ---
  Future<void> _exportLogsToCSV() async {
    setState(() => _isExporting = true);

    try {
      // 1. Fetch data from Firestore
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('IT_Logs')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No logs available to export.")));
        }
        setState(() => _isExporting = false);
        return;
      }

      // 2. Prepare the CSV Header Row
      List<List<dynamic>> rows = [];
      rows.add(["Date", "Time", "Action Message"]);

      // 3. Loop through data and format it
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String message = data['message'] ?? 'Unknown Action';
        final Timestamp? timestamp = data['timestamp'] as Timestamp?;

        String dateStr = 'Unknown Date';
        String timeStr = 'Unknown Time';

        if (timestamp != null) {
          final DateTime dt = timestamp.toDate();
          dateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

          int hour = dt.hour;
          String period = hour >= 12 ? 'PM' : 'AM';
          if (hour == 0) hour = 12;
          if (hour > 12) hour -= 12;
          String minute = dt.minute.toString().padLeft(2, '0');
          timeStr = '$hour:$minute $period';
        }

        // Add the row
        rows.add([dateStr, timeStr, message]);
      }

      // 4. Convert to CSV string, then to Bytes
      String csvData = const ListToCsvConverter().convert(rows);
      Uint8List bytes = Uint8List.fromList(csvData.codeUnits);

      // 5. Trigger Native Save Dialog via file_saver
      await FileSaver.instance.saveAs(
        name: 'IT_Logs_Report_${DateTime.now().millisecondsSinceEpoch}',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Logs successfully exported!"), backgroundColor: Colors.green));
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error exporting logs: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
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
                  /// Settings grid panel
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
                                  setState(() {
                                    selectedSettingTab = index;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  /// Right panel - detail view
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

  /// Returns the content widget for the selected settings tab
  Widget _getContentForTab(int index) {
    switch (index) {
      case 0:
        return _buildAccountManagement();
      case 1:
        return _buildNotificationSettings();
      case 2:
        return _buildExportLogs();
      case 3:
        return _buildFeedback();
      case 4:
        return _buildAppInfo();
      default:
        return const SizedBox();
    }
  }

  /// Account management form
  Widget _buildAccountManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Account Management",
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 30),
        _buildTextField("New Phone", "Enter phone number"),
        const SizedBox(height: 20),
        _buildTextField("New Email", "Enter email"),
        const SizedBox(height: 40),
        _buildPrimaryButton("Update", onPressed: () {}),
      ],
    );
  }

  /// Notification settings form
  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Notification Settings",
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 30),
        _buildDropdown("Hall Alerts"),
        const SizedBox(height: 20),
        _buildDropdown("User Requests"),
        const SizedBox(height: 20),
        _buildDropdown("Announcements"),
      ],
    );
  }

  /// Export logs feature
  Widget _buildExportLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Export Logs', style: AppTextStyles.heading),
        const SizedBox(height: 40),
        const Text(
            'This feature is used to export the logged information so it can be used for backup or analyzing behaviour.'),
        const SizedBox(height: 60),
        Center(
          child: _isExporting
              ? const CircularProgressIndicator()
              : _buildPrimaryButton('Export', onPressed: _exportLogsToCSV),
        ),
      ],
    );
  }

  /// Feedback form with star rating
  Widget _buildFeedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Feedback",
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 30),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
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
          decoration: InputDecoration(
            hintText: "Write feedback...",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildPrimaryButton("Submit", onPressed: () {}),
      ],
    );
  }

  /// App information display
  Widget _buildAppInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "App Information",
          style: AppTextStyles.heading,
        ),
        SizedBox(height: 20),
        Text("App Version: UN2.0"),
      ],
    );
  }

  /// Logs out the user and clears session
  Future<void> _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (route) => false,
    );
  }

  /// Text input field
  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Dropdown selector
  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Choose alert mode"),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    );
  }

  /// Primary outlined button (Modified to accept an onPressed callback!)
  Widget _buildPrimaryButton(String text, {required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
      ),
      child: Text(text),
    );
  }
}