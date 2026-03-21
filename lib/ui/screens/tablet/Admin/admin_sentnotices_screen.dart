import 'package:flutter/material.dart';
import '../../../../admin_tab.dart';
import '../theme/app_theme.dart';

class AdminSentNoticesScreen extends StatelessWidget {
  final void Function(AdminTab) onNavigate;

  const AdminSentNoticesScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // Mock data for sent notices
    final List<Map<String, String>> sentNotices = List.generate(
      7,
          (index) => {
        'sender': index % 2 == 0 ? 'Managemet' : 'Management',
        'message': index % 2 == 0
            ? 'We need to update our policy rules'
            : 'The next board meeting will be on 27/5',
      },
    );

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sent Notices', style: AppTextStyles.largeHeading),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                children: [
                  // Main Content Area
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: ListView.separated(
                        itemCount: sentNotices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildSentNoticeItem(
                            sentNotices[index]['sender']!,
                            sentNotices[index]['message']!,
                          );
                        },
                      ),
                    ),
                  ),
                  // Spacer to match dashboard layout width
                  const SizedBox(width: 300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentNoticeItem(String sender, String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 20),
          const Text('|', style: TextStyle(fontSize: 24, color: Colors.grey)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender, style: AppTextStyles.senderStyle),
                const SizedBox(height: 4),
                Text(msg, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}