import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final TextEditingController _feedbackController =
  TextEditingController();

  int _rating = 4;

  static const List<Map<String, String>> _items = [
    {'icon': 'assets/images/information_1.png', 'label': 'Account management'},
    {'icon': 'assets/images/notify_1.png', 'label': 'Notification settings'},
    {'icon': 'assets/images/review_1.png', 'label': 'Feedback'},
    {'icon': 'assets/images/merge_1.png', 'label': 'App Information'},
    {'icon': 'assets/images/logout_1.png', 'label': 'Logout'},
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

            const Text(
              "Settings",
              style: AppTextStyles.largeHeading,
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Row(
                children: [

                  /// SETTINGS GRID
                  Expanded(
                    flex: selectedSettingTab == null ? 1 : 0,
                    child: Center(
                      child: SizedBox(
                        width: selectedSettingTab == null ? 900 : 420,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
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

                                if (index == 4) {
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
                          borderRadius:
                          BorderRadius.circular(28),
                          border: Border.all(
                              color: AppColors.primary,
                              width: 2),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
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

  /// SETTINGS CARD (ICONS MADE BIGGER)
  Widget _buildSettingCard(Map<String, String> item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: GlassDecoration.light,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item['icon']!,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.settings,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
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

  /// TAB CONTENT SWITCH
  Widget _getContentForTab(int index) {

    switch (index) {

      case 0:
        return _buildAccountManagement();

      case 1:
        return _buildNotificationSettings();

      case 2:
        return _buildFeedback();

      case 3:
        return _buildAppInfo();

      default:
        return const SizedBox();
    }
  }

  /// ACCOUNT MANAGEMENT
  Widget _buildAccountManagement() {

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        const Text(
          "Account Management",
          style: AppTextStyles.heading,
        ),

        const SizedBox(height: 30),

        _buildTextField(
            "New Phone", "Enter phone number"),

        const SizedBox(height: 20),

        _buildTextField(
            "New Email", "Enter email"),

        const SizedBox(height: 40),

        _buildPrimaryButton("Update"),
      ],
    );
  }

  /// NOTIFICATIONS
  Widget _buildNotificationSettings() {

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        const Text(
          "Notification Settings",
          style: AppTextStyles.heading,
        ),

        const SizedBox(height: 30),

        _buildDropdown("Gate Alerts"),

        const SizedBox(height: 20),

        _buildDropdown("Announcements"),

        const SizedBox(height: 20),

        _buildDropdown("Warnings"),
      ],
    );
  }

  /// FEEDBACK
  Widget _buildFeedback() {

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
              borderRadius:
              BorderRadius.circular(15),
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
      crossAxisAlignment:
      CrossAxisAlignment.start,
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

  /// LOGOUT
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

  /// INPUT FIELD
  Widget _buildTextField(String label, String hint) {

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Text(label),

        const SizedBox(height: 8),

        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(12),
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
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Text(label),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius:
            BorderRadius.circular(12),
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
        side:
        const BorderSide(color: AppColors.primary),
        padding:
        const EdgeInsets.symmetric(
            horizontal: 50, vertical: 16),
      ),
      child: Text(text),
    );
  }
}