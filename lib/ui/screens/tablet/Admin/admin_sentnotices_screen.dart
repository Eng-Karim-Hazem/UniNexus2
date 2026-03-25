import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../admin_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminSentNoticesScreen extends StatelessWidget {
  final void Function(AdminTab) onNavigate;

  const AdminSentNoticesScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('Notifications')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(child: Text('Error loading notices.'));
                          }

                          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                              snapshot.data?.docs ?? const [];

                          if (docs.isEmpty) {
                            return const Center(
                              child: Text('No sent notices yet.', style: AppTextStyles.body),
                            );
                          }

                          return ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> data = docs[index].data();
                              final String sender =
                              (data['sentBy'] ?? data['sender'] ?? 'Admin').toString();
                              final String message =
                              (data['description'] ?? data['message'] ?? '').toString();

                              return _buildSentNoticeItem(sender, message);
                            },
                          );
                        },
                      ),
                    ),
                  ),
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
          const Icon(Icons.notifications_none_rounded,
              color: AppColors.primary, size: 28),
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