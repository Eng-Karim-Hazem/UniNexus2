import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../admin_tab.dart';
import '../../../../uninexus_tab.dart';
import '../theme/app_theme.dart';

class AdminSettingsScreen extends StatelessWidget {
  final void Function(AdminTab) onNavigate;
  const AdminSettingsScreen({super.key, required this.onNavigate});

  static const List<Map<String, String>> _items = [
    {'icon': 'assets/icons/information.png', 'label': 'Account management'},
    {'icon': 'assets/icons/notify.png',      'label': 'Notification settings'},
    {'icon': 'assets/icons/merge.png',       'label': 'App Information'},
    {'icon': 'assets/icons/review.png',      'label': 'Feedback'},
    {'icon': 'assets/icons/logout.png',      'label': 'Logout'},
  ];

  @override
  Widget build(BuildContext context) {

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings', style: AppTextStyles.largeHeading),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 32,
                  mainAxisSpacing: 32,
                  childAspectRatio: 1.2,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
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
                                width: 95, height: 95, fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.settings, size: 95,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(height: 24),
                              Text(item['label']!,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.settingsCardTitleStyle),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}