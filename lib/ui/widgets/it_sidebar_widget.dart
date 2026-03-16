import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../uninexus_tab.dart';
import '../screens/tablet/theme/app_theme.dart';
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
    ('assets/icons/home.png',       'Dashboard',   UninexusTab.dashboard),
    ('assets/icons/qr_code.png',    'ID',          UninexusTab.id),
    ('assets/icons/error.png',      'Hall Errors', UninexusTab.hallErrors),
    ('assets/icons/request.png',    'Requests',    UninexusTab.requests),
    ('assets/icons/user_white.png', 'Profile',     UninexusTab.profile),
    ('assets/icons/settings.png',   'Settings',    UninexusTab.settings),
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
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x44696BD5),
                    blurRadius: 16,
                    offset: Offset(4, 0),
                  ),
                ],
              ),
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