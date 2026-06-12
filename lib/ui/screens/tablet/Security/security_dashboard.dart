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

  // --- 1. LOCAL HIDDEN LIST ---
  List<String> _hiddenNotices = [];

  List<Map<String, dynamic>> _recentNotices = [];
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

  // --- 2. HELPER TO SAVE SWIPED NOTICES ---
  Future<void> _hideNotification(String docId) async {
    setState(() {
      _hiddenNotices.add(docId);
      // Remove from UI immediately
      _recentNotices.removeWhere((notice) => notice['id'] == docId);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('hiddenNotices_sec', _hiddenNotices);
  }

  void _initNoticesStream() async {
    final prefs = await SharedPreferences.getInstance();
    final String currentUserId = prefs.getString('userId') ?? '';

    FirebaseFirestore.instance
        .collection('Notifications')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        var filteredDocs = snapshot.docs.where((doc) {
          // A. Hide if swiped away
          if (_hiddenNotices.contains(doc.id)) return false;

          final data = doc.data();

          // B. Hide if frontend expiration date has passed
          if (data.containsKey('expiryDate') && data['expiryDate'] != null) {
            final DateTime expirationDate = (data['expiryDate'] as Timestamp).toDate();
            if (DateTime.now().isAfter(expirationDate)) return false;
          }

          final target = data['targetValue']?.toString() ?? '';
          final List<dynamic> recipientIds = data['recipientIds'] ?? [];

          return target == 'Security' ||
              target == 'All' ||
              target == 'Staff' ||
              target == currentUserId ||
              recipientIds.contains(currentUserId);
        }).toList();

        filteredDocs.sort((a, b) {
          final timeA = a.data()['date'];
          final timeB = b.data()['date'];
          if (timeA is Timestamp && timeB is Timestamp) {
            return timeB.compareTo(timeA);
          }
          return 0;
        });

        setState(() {
          _recentNotices = filteredDocs.take(3).map((doc) {
            final data = doc.data();
            return {
              'id': doc.id, // Keep ID for dismissal
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

        // Load hidden notices
        _hiddenNotices = prefs.getStringList('hiddenNotices_sec') ?? [];
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
                          const Row(
                            children: [
                              SizedBox(width: 20),
                              StatusBadge(status: 'approved', isDot: true),
                              SizedBox(width: 8),
                              Text("Approved", style: AppTextStyles.legendLabelStyle),
                              SizedBox(width: 110),
                              StatusBadge(status: 'unknown', isDot: true),
                              SizedBox(width: 8),
                              Text("Unknown", style: AppTextStyles.legendLabelStyle),
                              SizedBox(width: 110),
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

                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('gate_scans')
                                  .where('date', isEqualTo: todayDateStr)
                                  .limit(10)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
                                if (snapshot.hasError) return const Center(child: Text("Error loading entries"));

                                List<QueryDocumentSnapshot> recentDocs = snapshot.hasData ? snapshot.data!.docs : [];

                                if (recentDocs.isEmpty) {
                                  return const EmptyState(message: "No gate entries today", icon: Icons.door_front_door);
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Announcements", style: AppTextStyles.recentEntriesLabelStyle),
                                const SizedBox(height: 14),
                                Expanded(
                                  child: _recentNotices.isEmpty
                                      ? const EmptyState(
                                    message: "No notices for Security.",
                                    icon: Icons.notifications_none,
                                  )
                                      : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _recentNotices.length,
                                    itemBuilder: (context, index) {
                                      final notice = _recentNotices[index];
                                      return Dismissible(
                                        key: Key(notice['id']),
                                        direction: DismissDirection.horizontal,
                                        onDismissed: (direction) {
                                          _hideNotification(notice['id']);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: _SecurityAnnouncement(
                                            title: notice['sender']!,
                                            message: notice['message']!,
                                          ),
                                        ),
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
      stream: FirebaseFirestore.instance.collection('gate_scans').where('date', isEqualTo: dateStr).snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: AppDecorations.smallCard(),
          child: Row(
            children: [
              Image.asset('assets/icons/Individual.png', width: 46, height: 46,
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
                imagePath: "assets/icons/ID_Card.png",
                onTap: () => widget.onNavigate(UninexusTab.logs)),
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
        Image.asset(
          'assets/icons/Alarm.png',
          width: 22, height: 22,
          errorBuilder: (_, __, ___) => const Icon(
              Icons.notifications_outlined,
              size: 22, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Container(width: 2, height: 34, color: AppColors.primary.withOpacity(0.35)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.announcementTitleStyle),
            const SizedBox(height: 4),
            Text(message, style: AppTextStyles.announcementBodyStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
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
          Positioned(
              top: 0,
              right: 0,
              child: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 42))),
          Align(alignment: Alignment.bottomLeft, child: Text(label, style: AppTextStyles.actionCardLabelStyle)),
        ]),
      ),
    );
  }
}