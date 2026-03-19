import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';


class SecurityDashboardScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;

  const SecurityDashboardScreen({super.key, required this.onNavigate});

  static const List<Map<String, dynamic>> _entries = [
    {'name': 'User Scanned', 'status': 'unknown'},
    {'name': 'Moaz Osama Entered', 'status': 'denied'},
    {'name': 'Abd el-rahman Mohamed Entered', 'status': 'approved'},
  ];


  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// GREETING CARD
            // Greeting card
            const AppGreetingCard(
              name: 'Hassan',
              subtitle: 'Good morning',
              date: 'October 11, 2026',
            ),

            const SizedBox(height: 28),

            Expanded(
              child: Row(
                children: [

                  /// LEFT PANEL
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// GATE ENTRIES CARD
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: AppDecorations.smallCard(),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/avatar.png',
                                  width: 46,
                                  height: 46,
                                  errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.person,
                                      size: 46,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 70),
                                const Text(
                                  "6 Gate entries today",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontFamily: "Batangas",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Divider(
                            color: AppColors.primary.withOpacity(0.35),
                            thickness: 1.5,
                          ),

                          const SizedBox(height: 20),

                          /// STATUS LEGEND
                          Row(
                            children: const [
                              _LegendDot(color: Colors.green, label: "Approved"),
                              SizedBox(width: 26),
                              _LegendDot(color: Colors.yellow, label: "Unknown"),
                              SizedBox(width: 26),
                              _LegendDot(color: Colors.red, label: "Denied"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Divider(
                            color: AppColors.primary.withOpacity(0.35),
                            thickness: 1.5,
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Recent Entries",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // THE FIX: Wrap the list of entries in an Expanded + SingleChildScrollView
                          // This ensures the list scrolls if it's too long, preventing the overflow!
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: _entries.map(
                                      (e) => _EntryRow(
                                    name: e['name'],
                                    status: e['status'],
                                  ),
                                ).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => onNavigate(UninexusTab.logs),
                              child: const Text(
                                "View Entries >",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 26),

                  /// RIGHT PANEL
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [

                        /// ANNOUNCEMENTS
                        Expanded(
                          child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: const [
                              _SecurityAnnouncement(
                                title: "Management",
                                message:
                                "We need to update our gate policy rules",
                              ),
                              SizedBox(height: 14),
                              _SecurityAnnouncement(
                                title: "Management",
                                message:
                                "All security personnel will be needed at the end of the day",
                              ),
                            ],
                          ),
                        ),
                        ),

                        const SizedBox(height: 26),

                        /// ACTION BUTTONS
                        SizedBox(
                          height: 160,
                          child: Row(
                            children: [

                              Expanded(
                                child: _ActionCard(
                                  label: "Verify User",
                                  imagePath: "assets/images/id_card.png",
                                  onTap: () {}
                                ),
                              ),

                              const SizedBox(width: 18),

                              Expanded(
                                child: _ActionCard(
                                  label: "Entries Log",
                                  imagePath: "assets/images/log.png",
                                  onTap: () =>
                                      onNavigate(UninexusTab.logs),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  final String name;
  final String status;

  const _EntryRow({required this.name, required this.status});

  Color get color {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'denied':
        return Colors.red;
      default:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [

          Image.asset(
            'assets/images/avatar.png',
            width: 26,
            height: 26,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          Container(
            width: 2,
            height: 26,
            color: AppColors.primary.withOpacity(0.35),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
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

  const _SecurityAnnouncement({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [

          const Icon(Icons.notifications,
              color: AppColors.primary, size: 28),

          const SizedBox(width: 10),

          Container(
            width: 2,
            height: 34,
            color: AppColors.primary.withOpacity(0.35),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Stack(
          children: [

            /// ICON TOP RIGHT
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.image, size: 42),
              ),
            ),

            /// TEXT
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.batangas,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}