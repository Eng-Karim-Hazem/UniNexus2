import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class SecurityDashboardScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;

  const SecurityDashboardScreen({super.key, required this.onNavigate});

  @override
  State<SecurityDashboardScreen> createState() => _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  String _userName = "Security Officer";
  String _greeting = "Good morning";
  String _currentDate = "";
  late Timer _timer;

  // Notification State
  List<Map<String, String>> _recentNotices = [];
  bool _loadingNotices = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateDateTime();
    _initNoticesStream();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => _updateDateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Listens to Notifications and filters for 'Security', 'All', or specific User ID
  void _initNoticesStream() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming your ID 'SC20221379' is stored as 'userId'
    final String currentUserId = prefs.getString('userId') ?? '';

    FirebaseFirestore.instance
        .collection('Notifications')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        var filteredDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          final target = data['targetValue']?.toString() ?? '';
          final List<dynamic> recipientIds = data['recipientIds'] ?? [];

          // 1. Filter: Security, All, Staff, OR if User ID is the target/in recipients
          return target == 'Security' ||
              target == 'All' ||
              target == 'Staff' ||
              target == currentUserId ||
              recipientIds.contains(currentUserId);
        }).toList();

        // 2. Sort by date (newest first)
        filteredDocs.sort((a, b) {
          final timeA = a.data()['date'];
          final timeB = b.data()['date'];
          if (timeA is Timestamp && timeB is Timestamp) {
            return timeB.compareTo(timeA);
          }
          return 0;
        });

        setState(() {
          _recentNotices = filteredDocs.take(4).map((doc) {
            final data = doc.data();
            return {
              'sender': (data['sentBy'] ?? 'Management').toString(),
              'message': (data['description'] ?? '').toString(),
            };
          }).toList();
          _loadingNotices = false;
        });
      }
    }, onError: (e) {
      if (mounted) setState(() => _loadingNotices = false);
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (mounted) {
      setState(() {
        String f = prefs.getString('fName') ?? "Security";
        String l = prefs.getString('lName') ?? "";
        _userName = "$f $l".trim();
      });
    }
  }

  void _updateDateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentDate = DateFormat('MMMM dd, yyyy').format(now);
        _greeting = _getGreeting(now.hour);
      });
    }
  }

  String _getGreeting(int hour) {
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final String todayDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGreetingCard(
              name: _userName,
              subtitle: _greeting,
              date: _currentDate,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGateCounter(todayDateStr),
                          const SizedBox(height: 20),
                          Divider(color: AppColors.primary.withOpacity(0.35), thickness: 1.5),
                          const SizedBox(height: 20),
                          const _LegendRow(),
                          const SizedBox(height: 20),
                          Divider(color: AppColors.primary.withOpacity(0.35), thickness: 1.5),
                          const SizedBox(height: 20),
                          const Text("Recent Entries", style: AppTextStyles.recentEntriesLabelStyle),
                          const SizedBox(height: 14),

                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('gate_sc_ans')
                                  .where('date', isEqualTo: todayDateStr)
                                  .limit(10)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                List<QueryDocumentSnapshot> recentDocs = snapshot.hasData ? snapshot.data!.docs : [];

                                if (recentDocs.isEmpty) {
                                  return const Center(child: Text("No entries today", style: TextStyle(color: Colors.grey)));
                                }

                                return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: recentDocs.length,
                                  itemBuilder: (context, index) {
                                    var data = recentDocs[index].data() as Map<String, dynamic>;
                                    return _EntryRow(
                                      name: data['name'] ?? "Unknown User",
                                      status: data['status'] ?? "unknown",
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => widget.onNavigate(UninexusTab.requests),
                              child: const Text("View Entries >", style: AppTextStyles.viewLinkStyle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 26),

                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: _loadingNotices
                                ? const Center(child: CircularProgressIndicator())
                                : Column(
                              children: [
                                if (_recentNotices.isEmpty)
                                  const Expanded(child: Center(child: Text("No notices for Security.", style: TextStyle(color: Colors.grey)))),

                                ..._recentNotices.map((notice) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _SecurityAnnouncement(
                                    title: notice['sender']!,
                                    message: notice['message']!,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        _buildQuickActionSection(),
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

  Widget _buildGateCounter(String dateStr) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('gate_sc_ans').where('date', isEqualTo: dateStr).snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: AppDecorations.smallCard(),
          child: Row(
            children: [
              Image.asset('assets/images/avatar.png', width: 46, height: 46,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 46, color: AppColors.primary)),
              const SizedBox(width: 70),
              Text("$count Gate entries today", style: AppTextStyles.gateEntriesCountStyle),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionSection() {
    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
                label: "Verify User",
                imagePath: "assets/images/id_card.png",
                onTap: () => widget.onNavigate(UninexusTab.logs)
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: _ActionCard(
              label: "Entries Log",
              imagePath: "assets/images/log.png",
              onTap: () => widget.onNavigate(UninexusTab.hallErrors),
            ),
          ),
        ],
      ),
    );
  }
}

// UI Components remain unchanged...
class _SecurityAnnouncement extends StatelessWidget {
  final String title;
  final String message;
  const _SecurityAnnouncement({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppDecorations.smallCard(),
      child: Row(children: [
        const Icon(Icons.notifications, color: AppColors.primary, size: 28),
        const SizedBox(width: 10),
        Container(width: 2, height: 34, color: AppColors.primary.withOpacity(0.35)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.announcementTitleStyle),
          const SizedBox(height: 4),
          Text(message, style: AppTextStyles.announcementBodyStyle),
        ])),
      ]),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final String name;
  final String status;
  const _EntryRow({required this.name, required this.status});
  @override
  Widget build(BuildContext context) {
    Color dotColor;
    switch (status.toLowerCase()) {
      case 'allowed':
      case 'approved':
        dotColor = Colors.green;
        break;
      case 'denied':
        dotColor = Colors.red;
        break;
      default:
        dotColor = Colors.yellow;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: AppDecorations.smallCard(),
      child: Row(children: [
        Image.asset('assets/images/avatar.png', width: 26, height: 26,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary)),
        const SizedBox(width: 12),
        Container(width: 2, height: 26, color: AppColors.primary.withOpacity(0.35)),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: AppTextStyles.entryRowNameStyle)),
        Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
      ]),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();
  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      _LegendDot(color: Colors.green, label: "Approved"),
      SizedBox(width: 26),
      _LegendDot(color: Colors.yellow, label: "Unknown"),
      SizedBox(width: 26),
      _LegendDot(color: Colors.red, label: "Denied"),
    ]);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(label, style: AppTextStyles.legendLabelStyle),
    ]);
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;
  const _ActionCard({required this.label, required this.imagePath, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Stack(children: [
          Positioned(top: 0, right: 0, child: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 42))),
          Align(alignment: Alignment.bottomLeft, child: Text(label, style: AppTextStyles.actionCardLabelStyle)),
        ]),
      ),
    );
  }
}