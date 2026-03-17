import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

import '../login_page.dart';
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

  static const List<Map<String, String>> _items = [
    {'icon': 'assets/icons/information.png', 'label': 'Account management'},
    {'icon': 'assets/icons/notify.png', 'label': 'Notification settings'},
    {'icon': 'assets/icons/export.png', 'label': 'Export Logs'},
    {'icon': 'assets/icons/review.png', 'label': 'Feedback'},
    {'icon': 'assets/icons/merge.png', 'label': 'App Information'},
    {'icon': 'assets/icons/logout.png', 'label': 'Logout'},
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: const [
                Text(
                  "Settings",
                  style: AppTextStyles.largeHeading,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Row(
                children: [

                  /// GRID
                  Expanded(
                    flex: selectedSettingTab == null ? 1 : 0,
                    child: Center(
                      child: SizedBox(
                        width: selectedSettingTab == null ? 900 : 420,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                            selectedSettingTab == null ? 3 : 2,
                            mainAxisSpacing: 25,
                            crossAxisSpacing: 25,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {

                            final item = _items[index];

                            return GestureDetector(
                              onTap: () {
                                if (index == 5) {
                                  _logout();
                                } else {
                                  setState(() {
                                    selectedSettingTab = index;
                                  });
                                }
                              },
                              child: _buildSettingCard(item),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  /// RIGHT PANEL
                  if (selectedSettingTab != null) ...[

                    const SizedBox(width: 30),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            /// BACK BUTTON
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                setState(() {
                                  selectedSettingTab = null;
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            Expanded(
                              child: SingleChildScrollView(
                                child: _getContentForTab(
                                    selectedSettingTab!),
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

  /// SETTINGS CARD
  Widget _buildSettingCard(Map<String, String> item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: GlassDecoration.light,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item['icon']!,
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.settings,
                    size: 80, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                item['label']!,
                textAlign: TextAlign.center,
                style: AppTextStyles.settingsCardTitleStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TAB SWITCH
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

  /// ACCOUNT
  Widget _buildAccountManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Account Management",
            style: AppTextStyles.largeHeading),

        const SizedBox(height: 30),

        _buildTextField("New Phone", "Enter phone number"),

        const SizedBox(height: 20),

        _buildTextField("New Email", "Enter email"),

        const SizedBox(height: 40),

        _buildPrimaryButton("Update"),
      ],
    );
  }

  /// NOTIFICATIONS
  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Notification Settings",
            style: AppTextStyles.largeHeading),

        const SizedBox(height: 30),

        _buildDropdown("Hall Alerts"),

        const SizedBox(height: 20),

        _buildDropdown("User Requests"),

        const SizedBox(height: 20),

        _buildDropdown("Announcements"),
      ],
    );
  }

  /// EXPORT
  Widget _buildExportLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Export Logs",
            style: AppTextStyles.largeHeading),

        const SizedBox(height: 40),

        const Text(
            "This feature is used to export the logged information so it can be used for backup or analyzing behaviour."),

        const SizedBox(height: 60),

        Center(
          child: _buildPrimaryButton("Export"),
        ),
      ],
    );
  }

  /// FEEDBACK
  Widget _buildFeedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Feedback",
            style: AppTextStyles.largeHeading),

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
                color: index < _rating
                    ? AppColors.primary
                    : Colors.grey,
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

        _buildPrimaryButton("Submit"),
      ],
    );
  }

  /// APP INFO
  Widget _buildAppInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text("App Information",
            style: AppTextStyles.largeHeading),

        SizedBox(height: 20),

        Text("App Version: UN2.0"),
      ],
    );
  }

  /// LOGOUT FUNCTION
  Future<void> _logout() async {

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content:
        const Text(
            "Are you sure you want to logout?"),
        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text(
              "Logout",
              style:
              TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomePage(),
      ),
          (route) => false,
    );
  }
  /// INPUT
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

  /// DROPDOWN
  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(label),

        const SizedBox(height: 8),

        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text("Choose alert mode"),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    );
  }

  /// BUTTON
  Widget _buildPrimaryButton(String text) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        padding:
        const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
      ),
      child: Text(text),
    );
  }
}