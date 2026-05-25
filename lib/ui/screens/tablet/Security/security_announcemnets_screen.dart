import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class SecurityAnnouncementsScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const SecurityAnnouncementsScreen({super.key, required this.onNavigate});

  // Format date for display (e.g., Mar 27, 2026)
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp.toDate();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground( // Reusing the same glass-morphism background
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Security Notices'),
            const SizedBox(height: 47),

            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<SharedPreferences>(
                    future: SharedPreferences.getInstance(),
                    builder: (context, prefsSnapshot) {
                      if (!prefsSnapshot.hasData) return const LoadingState();

                      final String currentUserId = prefsSnapshot.data?.getString('userId') ?? '';

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Notifications')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const LoadingState();
                          }

                          if (snapshot.hasError) {
                            return const ErrorState(message: 'Error loading notices.');
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const EmptyState(
                              message: 'No security notices found.',
                              icon: Icons.notifications_none,
                            );
                          }

                          // Filter logic for Security:
                          // Show if targeted to 'Security', 'All', 'Staff', or the specific User ID
                          var docs = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final target = data['targetValue']?.toString() ?? '';
                            final List<dynamic> recipientIds = data['recipientIds'] ?? [];

                            return target == 'Security' ||
                                target == 'All' ||
                                target == 'Staff' ||
                                target == currentUserId ||
                                recipientIds.contains(currentUserId);
                          }).toList();

                          // Sort by date newest first
                          docs.sort((a, b) {
                            final timeA = (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
                            final timeB = (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
                            if (timeA != null && timeB != null) return timeB.compareTo(timeA);
                            return 0;
                          });

                          if (docs.isEmpty) {
                            return const EmptyState(
                              message: 'No relevant notices for your account.',
                              icon: Icons.notifications_none,
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              final sender = data['sentBy'] ?? 'Management';
                              final message = data['description'] ?? 'No details provided.';
                              final timestamp = data['date'] as Timestamp?;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: AppDecorations.smallCard(),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/Alarm.png',
                                      width: 22, height: 22,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.notifications_outlined,
                                          size: 22, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 10),
                                    const SectionDivider(), // Custom divider from your theme
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(sender, style: AppTextStyles.announcementSenderStyle),
                                          const SizedBox(height: 4),
                                          Text(message, style: AppTextStyles.announcementMessageStyle),
                                        ],
                                      ),
                                    ),

                                    if (timestamp != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                            _formatDate(timestamp),
                                            style: AppTextStyles.caption
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}