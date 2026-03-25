import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firebase
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITAnnouncementsScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const ITAnnouncementsScreen({super.key, required this.onNavigate});

  // Helper to format the date if you want to display it later
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading announcements.', style: TextStyle(color: Colors.red)));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No announcements available.', style: TextStyle(color: Colors.grey, fontSize: 18)),
                      );
                    }

                    // 1. Filter for IT targeted notifications locally
                    var docs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['targetValue'] == 'IT' || data['targetValue'] == 'All';
                    }).toList();

                    // 2. Sort by date newest first
                    docs.sort((a, b) {
                      final timeA = (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
                      final timeB = (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
                      if (timeA != null && timeB != null) return timeB.compareTo(timeA);
                      return 0;
                    });

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('No announcements targeted for IT.', style: TextStyle(color: Colors.grey, fontSize: 18)),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        // Extracting data exactly as your Firebase structure shows
                        final sender = data['sentBy'] ?? 'Management';
                        final message = data['description'] ?? 'No details provided.';
                        final timestamp = data['date'] as Timestamp?;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12), // Slightly increased spacing
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: AppDecorations.smallCard(), // Removed the artificial fade effect
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/notify_1.png',
                                width: 22, height: 22,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.notifications_outlined,
                                    size: 22, color: AppColors.primary),
                              ),
                              const SizedBox(width: 10),
                              const SectionDivider(),
                              const SizedBox(width: 10),

                              Expanded( // Wrapped in Expanded to prevent text overflow
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sender, style: AppTextStyles.announcementSenderStyle),
                                    const SizedBox(height: 4),
                                    Text(message, style: AppTextStyles.announcementMessageStyle),
                                  ],
                                ),
                              ),

                              // Added a subtle date to the right side of the card!
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