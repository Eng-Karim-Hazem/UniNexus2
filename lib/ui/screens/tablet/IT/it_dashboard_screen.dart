import 'dart:async'; // --- ADDED FOR STREAM SUBSCRIPTIONS ---
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

  // --- NEW: STREAM SUBSCRIPTIONS ---
  StreamSubscription<QuerySnapshot>? _hallErrorsSub;
  StreamSubscription<QuerySnapshot>? _passRequestsSub;

  // Variables to hold the live counts from each stream
  int _hallTotal = 0;
  int _hallResolved = 0;
  int _hallActive = 0;

  int _passTotal = 0;
  int _passResolved = 0;
  int _passActive = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _setupRealtimeStats(); // Changed from Future to Stream!
  }

  @override
  void dispose() {
    // ALWAYS cancel streams when leaving the screen to prevent memory leaks!
    _hallErrorsSub?.cancel();
    _passRequestsSub?.cancel();
    super.dispose();
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

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
      if(mounted) {
        setState(() {
          _userName = 'Eng. $firstName';
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _userName = 'Eng. Error';
        });
      }
    }
  }

  // --- NEW: REAL-TIME LISTENERS ---
  void _setupRealtimeStats() {
    final db = FirebaseFirestore.instance;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final timestampLimit = Timestamp.fromDate(sevenDaysAgo);

    // 1. Listen to Hall Errors Live
    _hallErrorsSub = db.collection('HallErrors')
        .where('timestamp', isGreaterThanOrEqualTo: timestampLimit)
        .snapshots()
        .listen((snapshot) {
      int total = 0;
      int resolved = 0;
      int active = 0;

      for (var doc in snapshot.docs) {
        total++;
        final status = doc.data()['status']?.toString().toLowerCase() ?? 'pending';
        if (status == 'fixed') {
          resolved++;
        } else {
          active++;
        }
      }

      _hallTotal = total;
      _hallResolved = resolved;
      _hallActive = active;
      _updateCombinedStats();
    });

    // 2. Listen to Password Requests Live
    _passRequestsSub = db.collection('ForgotPass_request')
        .where('requestDate', isGreaterThanOrEqualTo: timestampLimit)
        .snapshots()
        .listen((snapshot) {
      int total = 0;
      int resolved = 0;
      int active = 0;

      for (var doc in snapshot.docs) {
        total++;
        final isProcessed = doc.data()['isProcessed'] == true;
        if (isProcessed) {
          resolved++;
        } else {
          active++;
        }
      }

      _passTotal = total;
      _passResolved = resolved;
      _passActive = active;
      _updateCombinedStats();
    });
  }

  // Merges the data from both streams and updates the UI instantly
  void _updateCombinedStats() {
    if (!mounted) return;

    int combinedTotal = _hallTotal + _passTotal;
    int combinedResolved = _hallResolved + _passResolved;
    int combinedActive = _hallActive + _passActive;

    double rate = 0.0;
    if (combinedTotal > 0) {
      rate = combinedResolved / combinedTotal;
    }

    setState(() {
      _activeIssuesCount = combinedActive;
      _resolutionRate = rate;
      _isLoadingStats = false;
    });
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
                                  .limit(5)
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
                                Expanded(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Notifications')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError) {
                                        return const Center(child: Text('Error loading notifications.', style: TextStyle(color: Colors.red)));
                                      }

                                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return const Center(child: Text('No new announcements.', style: TextStyle(color: Colors.grey)));
                                      }

                                      var docs = snapshot.data!.docs.where((doc) {
                                        final data = doc.data() as Map<String, dynamic>;
                                        return data['targetValue'] == 'IT' || data['targetValue'] == 'All';
                                      }).toList();

                                      docs.sort((a, b) {
                                        final timeA = (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
                                        final timeB = (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
                                        if (timeA != null && timeB != null) return timeB.compareTo(timeA);
                                        return 0;
                                      });

                                      final previewDocs = docs.take(2).toList();

                                      if (previewDocs.isEmpty) {
                                        return const Center(child: Text('No new announcements for IT.', style: TextStyle(color: Colors.grey)));
                                      }

                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: previewDocs.length,
                                        itemBuilder: (context, index) {
                                          final data = previewDocs[index].data() as Map<String, dynamic>;
                                          final sender = data['sentBy'] ?? 'Management';
                                          final message = data['description'] ?? 'No details provided.';

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: _AnnouncementCard(
                                              sender: sender,
                                              message: message,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 8),

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
                                    // Make the circle dynamically fill up based on open issues (max 20 for visual scale)
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
          Image.asset('assets/icons/History.png', width: 26, height: 26,
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
          Image.asset('assets/icons/Alarm.png', width: 26, height: 26,
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
                Text(message, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}