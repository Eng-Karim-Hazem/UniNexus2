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

  // Initialize notices stream listener
  void _initNoticesStream() async {
    final prefs = await SharedPreferences.getInstance();
    final String currentUserId = prefs.getString('userId') ?? '';

    FirebaseFirestore.instance
        .collection('Notifications')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        // Filter notices for security
        var filteredDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          final target = data['targetValue']?.toString() ?? '';
          final List<dynamic> recipientIds = data['recipientIds'] ?? [];

          return target == 'Security' ||
              target == 'All' ||
              target == 'Staff' ||
              target == currentUserId ||
              recipientIds.contains(currentUserId);
        }).toList();

        // Sort by date newest first
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

  // Load user data from preferences
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

  // Update date and greeting
  void _updateDateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentDate = DateFormat('MMMM dd, yyyy').format(now);
        _greeting = _getGreeting(now.hour);
      });
    }
  }

  // Get greeting based on time of day
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
                  // Left column - Gate entries
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
                          const Row(
                            children: [
                              StatusBadge(status: 'approved', isDot: true),
                              SizedBox(width: 8),
                              Text("Approved", style: AppTextStyles.legendLabelStyle),
                              SizedBox(width: 26),
                              StatusBadge(status: 'unknown', isDot: true),
                              SizedBox(width: 8),
                              Text("Unknown", style: AppTextStyles.legendLabelStyle),
                              SizedBox(width: 26),
                              StatusBadge(status: 'denied', isDot: true),
                              SizedBox(width: 8),
                              Text("Denied", style: AppTextStyles.legendLabelStyle),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Divider(color: AppColors.primary.withOpacity(0.35), thickness: 1.5),
                          const SizedBox(height: 20),
                          const Text("Recent Entries", style: AppTextStyles.recentEntriesLabelStyle),
                          const SizedBox(height: 14),

                          // Recent entries list
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('gate_sc_ans')
                                  .where('date', isEqualTo: todayDateStr)
                                  .limit(10)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const LoadingState();
                                }

                                if (snapshot.hasError) {
                                  return ErrorState(
                                    message: "Error loading entries: ${snapshot.error}",
                                    onRetry: () => setState(() {}),
                                  );
                                }

                                List<QueryDocumentSnapshot> recentDocs = snapshot.hasData ? snapshot.data!.docs : [];

                                if (recentDocs.isEmpty) {
                                  return const EmptyState(
                                    message: "No gate entries today",
                                    icon: Icons.door_front_door,
                                  );
                                }

                                return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: recentDocs.length,
                                  itemBuilder: (context, index) {
                                    var data = recentDocs[index].data() as Map<String, dynamic>;
                                    return AppEntryRow(
                                      label: data['name'] ?? "Unknown User",
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

                  // Right column - Notices and quick actions
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: _loadingNotices
                                ? const LoadingState()
                                : Column(
                              children: [
                                if (_recentNotices.isEmpty)
                                  const Expanded(
                                    child: EmptyState(
                                      message: "No notices for Security.",
                                      icon: Icons.notifications_none,
                                    ),
                                  ),
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

  // Gate counter widget
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

  // Quick action buttons
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

// Security announcement card
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

// Action card widget
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