import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITAnnouncementsScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const ITAnnouncementsScreen({super.key, required this.onNavigate});

  // Format date for display
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp.toDate();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Announcements'),
            const SizedBox(height: 47),

            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Notifications')
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingState();
                    }

                    if (snapshot.hasError) {
                      return const ErrorState(
                        message: 'Error loading announcements.',
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const EmptyState(
                        message: 'No announcements available.',
                        icon: Icons.notifications_none,
                      );
                    }

                    // Filter for IT or All announcements
                    var docs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['targetValue'] == 'IT' || data['targetValue'] == 'All';
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
                        message: 'No announcements targeted for IT.',
                        icon: Icons.notifications_none,
                      );
                    }

                    return ListView.builder(
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
                              const SectionDivider(),
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
                                Text(_formatDate(timestamp), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        );
                      },
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