import 'package:flutter/material.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITSidebar extends StatelessWidget {
  final UninexusTab current;
  final void Function(UninexusTab) onNavigate;

  const ITSidebar({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  // NAVIGATION ITEMS
  static const _items = [
    ('assets/images/home_tab.png',       'Dashboard',   UninexusTab.dashboard),
    ('assets/images/qr_code.png',    'ID',          UninexusTab.id),
    ('assets/images/error_tab.png',      'Hall Errors', UninexusTab.hallErrors),
    ('assets/images/request_tab.png',    'Requests',    UninexusTab.requests),
    ('assets/images/profile_tab.png', 'Profile',     UninexusTab.profile),
    ('assets/images/settings_tab.png',   'Settings',    UninexusTab.settings),
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
                    color: Color(0xFFFFFFFF),
                    blurRadius: 1,
                    offset: Offset(4, 0),
                  ),
                ],
              ),
              // THE FIX: Makes the column scrollable only if it runs out of vertical space
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
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
              'assets/images/LOGO.png',
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }

  // NAVIGATION ITEM WIDGET

  Widget _navItem(String iconPath, String label, UninexusTab tab) {
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