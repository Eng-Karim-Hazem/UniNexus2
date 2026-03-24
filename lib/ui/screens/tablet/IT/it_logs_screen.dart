import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITLogsScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const ITLogsScreen({super.key, required this.onNavigate});

  /// Formats time (e.g., 10:34 AM)
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp.toDate();
    int hour = date.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Formats date (e.g., Oct 11, 2026)
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
            const PageHeading('LOGs'),
            const SizedBox(height: 47),

            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('IT_Logs')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingState();
                    }

                    if (snapshot.hasError) {
                      return ErrorState(message: 'Error loading logs: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const EmptyState(message: 'No system activity recorded yet.');
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final logData = docs[index].data() as Map<String, dynamic>;
                        final message = logData['message'] ?? 'Unknown Action';
                        final timestamp = logData['timestamp'] as Timestamp?;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: AppDecorations.smallCard(),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/restore.png',
                                width: 24, height: 24,
                                color: AppColors.primary.withOpacity(0.7),
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.history, size: 24, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Container(width: 1.5, height: 24, color: AppColors.divider),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(message, style: AppTextStyles.logTextStyle),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_formatTime(timestamp), style: AppTextStyles.logTimeStyle),
                                  Text(_formatDate(timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
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