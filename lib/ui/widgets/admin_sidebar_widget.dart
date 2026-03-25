import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import '../../admin_tab.dart';
class AdminSidebar extends StatelessWidget {
  final AdminTab current;
  final void Function(AdminTab) onNavigate;

  const AdminSidebar({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  // NAVIGATION ITEMS
  static const _items = [
    ('assets/icons/home.png',       'Dashboard',   AdminTab.dashboard),
    ('assets/icons/qr_code.png',    'ID',          AdminTab.id),
    ('assets/icons/alert1.png',      'Notices',    AdminTab.notices),
    ('assets/icons/request.png',    'Requests',    AdminTab.requests),
    ('assets/icons/user_white.png', 'Profile',     AdminTab.profile),
    ('assets/icons/settings.png',   'Settings',    AdminTab.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 166,
      child: Stack(
        children: [
          // SIDEBAR BACKGROUND
          // Gradient background with rounded corners and shadow
          Positioned(
            top: 141,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.sidebarGradient,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x44696BD5),
                    blurRadius: 16,
                    offset: Offset(4, 0),
                  ),
                ],
              ),
              // THE FIX: Makes the column scrollable only if it runs out of vertical space
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(), // Gives it a nice tablet bounce
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight, // Forces it to take up at least the full sidebar height
                      ),
                      child: IntrinsicHeight( // Allows MainAxisAlignment.spaceEvenly to work inside a scroll view
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _items
                                .map((e) => _navItem(e.$1, e.$2, e.$3))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // LOGO

          Positioned(
            top: 29,
            left: 34,
            child: Image.asset(
              'assets/images_tab/logo.png',
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }

  // NAVIGATION ITEM WIDGET

  Widget _navItem(String iconPath, String label, AdminTab tab) {
    final isActive = current == tab;
    return GestureDetector(
      onTap: () => onNavigate(tab),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Image.asset(iconPath, width: 45, height: 45),
            const SizedBox(height: 5),
            // Label
            Text(
              label,
              style: AppTextStyles.sidebarLabel,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}