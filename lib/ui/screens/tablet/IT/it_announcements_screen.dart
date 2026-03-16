import 'package:flutter/material.dart';
import '../../../../uninexus_tab.dart';
import '../theme/app_theme.dart';

class ITAnnouncementsScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const ITAnnouncementsScreen({super.key, required this.onNavigate});

  static const List<Map<String, String>> _announcements = [
    {'sender': 'Management',  'message': 'We need to update our policy rules'},
    {'sender': 'Management',  'message': 'The next board meeting will be on 27/5'},
    {'sender': 'Management',  'message': 'We need to update our policy rules'},
    {'sender': 'Management',  'message': 'The next board meeting will be on 27/5'},
    {'sender': 'Management',  'message': 'We need to update our policy rules'},
    {'sender': 'Management',  'message': 'The next board meeting will be on 27/5'},
    {'sender': 'Management',  'message': 'We need to update our policy rules'},
  ];

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Announcements', style: AppTextStyles.largeHeading),
            const SizedBox(height: 20),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final item = _announcements[index];
                    final isFaded = index == _announcements.length - 1;
                    return Opacity(
                      opacity: isFaded ? 0.5 : 1.0,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: AppDecorations.smallCard(isFaded: isFaded),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/bell_outline.png',
                              width: 22, height: 22,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.notifications_outlined,
                                  size: 22, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            const SectionDivider(),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['sender']!,
                                    style: AppTextStyles.announcementSenderStyle),
                                const SizedBox(height: 4),
                                Text(item['message']!,
                                    style: AppTextStyles.announcementMessageStyle),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}