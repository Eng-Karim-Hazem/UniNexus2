import 'package:flutter/material.dart';

class SettingsStaffScreen extends StatefulWidget {
  const SettingsStaffScreen({super.key});

  @override
  State<SettingsStaffScreen> createState() => _SettingsStaffScreenState();
}

class _SettingsStaffScreenState extends State<SettingsStaffScreen> {
  int selectedSettingTab = 3;

  /// ===== FEEDBACK LOGIC =====
  final TextEditingController _feedbackController = TextEditingController();
  final int _rating = 4;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  /// SIDEBAR ITEMS
  final List<Map<String, String>> navItems = [
    {'label': 'Dashboard', 'icon': 'assets/images/home_tab.png'},
    {'label': 'Profile', 'icon': 'assets/images/profile_tab.png'},
    {'label': 'Settings', 'icon': 'assets/images/settings_tab.png'},
  ];

  /// GRID OPTIONS (NO EXPORT)
  final List<Map<String, String>> settingOptions = [
    {'label': 'Account\nmanagement', 'icon': 'assets/images/information_1.png'},
    {'label': 'Notification\nsettings', 'icon': 'assets/images/notify_1.png'},
    {'label': 'Feedback', 'icon': 'assets/images/review_1.png'},
    {'label': 'App Information', 'icon': 'assets/images/merge_1.png'},
    {'label': 'Logout', 'icon': 'assets/images/logout_1.png'},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          /// LOGO
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, left: 30),
              child: Image.asset(
                'assets/images/LOGO.png',
                width: 100,
              ),
            ),
          ),

          Row(
            children: [

              /// SIDEBAR
              Container(
                margin: const EdgeInsets.only(top: 140),
                width: size.width * 0.11,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(35),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/nav_tab.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    ...navItems.asMap().entries.map((entry) {
                      int idx = entry.key;
                      bool isSelected = idx == 2;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          children: [
                            Image.asset(
                              entry.value['icon']!,
                              height: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.value['label']!,
                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(isSelected ? 1 : 0.7),
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              /// MAIN CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 75),
                  child: Row(
                    children: [

                      /// GRID
                      SizedBox(
                        width: size.width * 0.30,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 25,
                            crossAxisSpacing: 25,
                            childAspectRatio: 1,
                          ),
                          itemCount: settingOptions.length,
                          itemBuilder: (context, index) =>
                              _buildGridTile(index),
                        ),
                      ),

                      const SizedBox(width: 50),

                      Expanded(child: _buildRightPanel()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// GRID TILE
  Widget _buildGridTile(int index) {
    bool isSelected = selectedSettingTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedSettingTab = index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6F6BFF),
            width: isSelected ? 2.5 : 1.2,
          ),
          color: const Color(0xFFF3F3F3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(settingOptions[index]['icon']!, height: 50),
            const SizedBox(height: 12),
            Text(
              settingOptions[index]['label']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected
                    ? const Color(0xFF6F6BFF)
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// RIGHT PANEL
  Widget _buildRightPanel() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF6F6BFF),
          width: 2,
        ),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: _getContentForTab(selectedSettingTab),
      ),
    );
  }

  Widget _getContentForTab(int index) {
    switch (index) {
      case 0:
        return const Text("Account Management");
      case 1:
        return const Text("Notification Settings");
      case 2:
        return const Text("Feedback");
      case 3:
        return const Text("App Information");
      case 4:
        return const Text("Logout");
      default:
        return const SizedBox();
    }
  }
}