import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITDashboardScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITDashboardScreen({super.key, required this.onNavigate});

  @override
  State<ITDashboardScreen> createState() => _ITDashboardScreenState();
}

class _ITDashboardScreenState extends State<ITDashboardScreen> {
  // STATE VARIABLES
  String _userName = 'Loading...';

  // GRAPH VARIABLES
  int _activeIssuesCount = 0;
  double _resolutionRate = 0.0;
  bool _isLoadingStats = true;

  // WE REMOVED THE STATIC _logs LIST HERE!

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchWeeklyStats();
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // Helper to format Time (e.g., 10:34 AM) for the logs
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

  Future<void> _fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String firstName = prefs.getString('fName') ?? 'Guest';
      setState(() {
        _userName = 'Eng. $firstName';
      });
    } catch (e) {
      setState(() {
        _userName = 'Eng. Error';
      });
    }
  }

  Future<void> _fetchWeeklyStats() async {
    try {
      final db = FirebaseFirestore.instance;

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final timestampLimit = Timestamp.fromDate(sevenDaysAgo);

      int totalWeeklyIssues = 0;
      int resolvedWeeklyIssues = 0;
      int activeIssuesCurrently = 0;

      final hallQuery = await db.collection('HallErrors')
          .where('timestamp', isGreaterThanOrEqualTo: timestampLimit)
          .get();

      for (var doc in hallQuery.docs) {
        totalWeeklyIssues++;
        final status = doc.data()['status']?.toString().toLowerCase() ?? 'pending';
        if (status == 'fixed') {
          resolvedWeeklyIssues++;
        } else {
          activeIssuesCurrently++;
        }
      }

      final passQuery = await db.collection('ForgotPass_request')
          .where('requestDate', isGreaterThanOrEqualTo: timestampLimit)
          .get();

      for (var doc in passQuery.docs) {
        totalWeeklyIssues++;
        final isProcessed = doc.data()['isProcessed'] == true;
        if (isProcessed) {
          resolvedWeeklyIssues++;
        } else {
          activeIssuesCurrently++;
        }
      }

      double rate = 0.0;
      if (totalWeeklyIssues > 0) {
        rate = resolvedWeeklyIssues / totalWeeklyIssues;
      }

      if (mounted) {
        setState(() {
          _activeIssuesCount = activeIssuesCurrently;
          _resolutionRate = rate;
          _isLoadingStats = false;
        });
      }

    } catch (e) {
      print("Error fetching weekly stats: $e");
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGreetingCard(
              name: _userName,
              subtitle: 'Good morning',
              date: _getFormattedDate(),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- RECENT LOGS SECTION ---
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        children: [
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('IT_Logs')
                                  .orderBy('timestamp', descending: true)
                                  .limit(5) // Only fetch the 5 most recent!
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return const Center(child: Text('Error loading logs.', style: TextStyle(color: Colors.red)));
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Center(child: Text('No recent activity.', style: TextStyle(color: Colors.grey)));
                                }

                                final docs = snapshot.data!.docs;

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final logData = docs[index].data() as Map<String, dynamic>;
                                    final message = logData['message'] ?? 'Unknown Action';
                                    final timeStr = _formatTime(logData['timestamp'] as Timestamp?);

                                    return _LogRow(text: message, time: timeStr);
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => widget.onNavigate(UninexusTab.logs),
                              child: const Text('View Logs >', style: AppTextStyles.viewLinkStyle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // --- RIGHT COLUMN ---
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _AnnouncementCard(
                                  sender: 'Management',
                                  message: 'We need to update our policy rules',
                                ),
                                const SizedBox(height: 10),
                                const _AnnouncementCard(
                                  sender: 'Management',
                                  message: 'The next board meeting will be on 27/5',
                                ),

                                const Spacer(),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => widget.onNavigate(UninexusTab.announcements),
                                    child: const Text('View All >', style: AppTextStyles.viewLinkStyle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- STATS ROW ---
                        SizedBox(
                          height: 250,
                          child: Row(
                            children: [
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                                  child: _isLoadingStats
                                      ? const Center(child: CircularProgressIndicator())
                                      : CircularStat(
                                    value: _resolutionRate,
                                    line1: 'Resolution',
                                    line2: 'Rate',
                                    valueLabel: '${(_resolutionRate * 100).toInt()}%',
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                                  child: _isLoadingStats
                                      ? const Center(child: CircularProgressIndicator())
                                      : CircularStat(
                                    value: (_activeIssuesCount > 0) ? (_activeIssuesCount / 20.0).clamp(0.1, 1.0) : 0.0,
                                    line1: 'Open',
                                    line2: 'Issues',
                                    valueLabel: '$_activeIssuesCount',
                                    sublabel: 'Active\nissues',
                                    color: AppColors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final String text;
  final String time;
  const _LogRow({required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [
          Image.asset('assets/icons/restore.png', width: 26, height: 26,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.history, size: 26, color: AppColors.primary)),
          const SizedBox(width: 12),
          Container(width: 1.5, height: 24, color: AppColors.divider),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTextStyles.logRowBodyStyle),
          ),
          Text(time, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String sender;
  final String message;
  const _AnnouncementCard({required this.sender, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppDecorations.smallCard(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/icons/bell_outline.png', width: 26, height: 26,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.notifications_outlined, size: 26, color: AppColors.primary)),
          const SizedBox(width: 12),
          Container(width: 1.5, height: 36, color: AppColors.divider),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender, style: AppTextStyles.senderStyle),
                const SizedBox(height: 2),
                Text(message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}