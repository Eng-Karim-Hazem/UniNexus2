import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class SecurityGateEntryScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;

  const SecurityGateEntryScreen({super.key, required this.onNavigate});

  /// Sample gate entry data
  static const entries = [
    {'id': 'ST00453', 'status': 'denied'},
    {'id': 'ST78077', 'status': 'denied'},
    {'id': 'ST67864', 'status': 'approved'},
    {'id': 'TA88277', 'status': 'approved'},
    {'id': 'IT65221', 'status': 'approved'},
    {'id': 'ST64321', 'status': 'unknown'},
  ];

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Gate Entry'),
            const SizedBox(height: 47),

            Expanded(
              child: Row(
                children: [
                  /// Left side - entry list
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: entries
                            .map((e) => _EntryRow(
                          id: e['id']!,
                          status: e['status']!,
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  /// Right side - user data panel
                  Expanded(
                    flex: 4,
                    child: GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: const _UserDataPanel(),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final String id;
  final String status;

  const _EntryRow({required this.id, required this.status});

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
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Container(
            width: 4,
            height: 28,
            color: AppColors.primary.withOpacity(.35),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              id,
              style: const TextStyle(
                fontFamily: AppFonts.spaceGrotesk,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
          ),
          StatusBadge(status: status, isDot: true),
        ],
      ),
    );
  }
}

class _UserDataPanel extends StatelessWidget {
  const _UserDataPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          children: [
            Image.asset(
              'assets/images/avatar.png',
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 3,
              height: 40,
              color: AppColors.primary.withOpacity(0.4),
            ),
            const SizedBox(width: 16),
            const Text(
              "User Data",
              style: TextStyle(
                fontFamily: AppFonts.batangas,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        /// User data rows
        buildDataRow("Name", "Ammar Tarek Mohamed"),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(flex: 3, child: buildDataRow("User Type", "Student")),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: buildDataRow("Year", "4")),
          ],
        ),
        const SizedBox(height: 24),

        buildDataRow("ID", "ST00453"),
        const SizedBox(height: 24),

        buildDataRow("Faculty", "ICT"),
        const SizedBox(height: 24),

        buildDataRow("Status", "Denied"),
        const SizedBox(height: 24),

        buildDataRow("Note", "Last year's tuition unpaid"),
      ],
    );
  }
}