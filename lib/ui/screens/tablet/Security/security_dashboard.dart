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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateDateTime();
    // Keeps the greeting and date current
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => _updateDateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Pulls the login name from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (mounted) {
      setState(() {
        String f = prefs.getString('userFirstName') ?? prefs.getString('fName') ?? "Security";
        String l = prefs.getString('userLastName') ?? prefs.getString('lName') ?? "";
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
    // Matches the "date" field format in your Firestore
    final String todayDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<QuerySnapshot>(
          // Real-time listener for today's scans in the gate_scans collection
          stream: FirebaseFirestore.instance
              .collection('gate_scans')
              .where('date', isEqualTo: todayDateStr)
              .snapshots(),
          builder: (context, snapshot) {
            int gateCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
            List<QueryDocumentSnapshot> recentDocs = snapshot.hasData
                ? snapshot.data!.docs.toList()
                : [];

            return Column(
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
                      /// Left Panel: Live Counter & Entry List
                      Expanded(
                        flex: 5,
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: AppDecorations.smallCard(),
                                child: Row(
                                  children: [
                                    Image.asset('assets/images/avatar.png', width: 46, height: 46,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 46, color: AppColors.primary)),
                                    const SizedBox(width: 70),
                                    Text(
                                      "$gateCount Gate entries today",
                                      style: AppTextStyles.gateEntriesCountStyle,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Divider(color: AppColors.primary.withOpacity(0.35), thickness: 1.5),
                              const SizedBox(height: 20),

                              /// Legend with corrected colors
                              const Row(
                                children: [
                                  _LegendDot(color: Colors.green, label: "Approved"),
                                  SizedBox(width: 26),
                                  _LegendDot(color: Colors.yellow, label: "Unknown"),
                                  SizedBox(width: 26),
                                  _LegendDot(color: Colors.red, label: "Denied"),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Divider(color: AppColors.primary.withOpacity(0.35), thickness: 1.5),
                              const SizedBox(height: 20),

                              const Text("Recent Entries", style: AppTextStyles.recentEntriesLabelStyle),
                              const SizedBox(height: 14),

                              Expanded(
                                child: recentDocs.isEmpty
                                    ? const Center(child: Text("No entries today", style: TextStyle(color: Colors.grey)))
                                    : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: recentDocs.length,
                                  itemBuilder: (context, index) {
                                    var data = recentDocs[index].data() as Map<String, dynamic>;
                                    return _EntryRow(
                                      name: data['name'] ?? "Unknown User",
                                      status: data['status'] ?? "unknown",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 14),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  // Updated: goes to gate entry log
                                  onTap: () => widget.onNavigate(UninexusTab.requests),
                                  child: const Text("View Entries >", style: AppTextStyles.viewLinkStyle),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 26),

                      /// Right Panel: Info & Quick Actions
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            const Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _SecurityAnnouncement(title: "Management", message: "We need to update our gate policy rules"),
                                    SizedBox(height: 14),
                                    _SecurityAnnouncement(title: "Management", message: "All security personnel will be needed at the end of the day"),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              height: 160,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _ActionCard(
                                        label: "Verify User",
                                        imagePath: "assets/images/id_card.png",
                                        // Updated: goes to ID look up
                                        onTap: () => widget.onNavigate(UninexusTab.logs)
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: _ActionCard(
                                      label: "Entries Log",
                                      imagePath: "assets/images/log.png",
                                      // Updated: goes to gate entry log
                                      onTap: () => widget.onNavigate(UninexusTab.requests),
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
            );
          },
        ),
      ),
    );
  }
}

// --- Helper Components ---

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

class _EntryRow extends StatelessWidget {
  final String name;
  final String status;
  const _EntryRow({required this.name, required this.status});
  @override
  Widget build(BuildContext context) {
    // Dynamic color mapping: "allowed" or "approved" results in a green dot
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