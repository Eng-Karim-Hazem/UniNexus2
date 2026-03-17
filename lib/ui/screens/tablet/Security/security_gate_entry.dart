import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class SecurityGateEntryScreen extends StatelessWidget {

  final void Function(UninexusTab) onNavigate;

  const SecurityGateEntryScreen({super.key, required this.onNavigate});

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
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Gate Entry",
              style: TextStyle(
                  fontSize: 40,
                  fontFamily: AppFonts.batangas,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 55),

            Expanded(
              child: Row(
                children: [

                  /// LIST
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: ListView(
                        // EDITED: Removes Flutter's default top padding to bring the first card to the top
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

                  /// USER PANEL
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
          // EDITED: Changed back to your avatar image instead of the Icon
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

          Container(
            width: 14,
            height: 14,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
          )
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

        /// HEADER
        Row(
          children: [
            const Icon(Icons.person, color: AppColors.primary, size: 40),

            const SizedBox(width: 16),

            Container(
              width: 2.5,
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

        /// DATA ROWS
        _buildDataRow("Name :", "Ammar Tarek Mohamed"),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(flex: 3, child: _buildDataRow("User Type:", "Student")),
            Expanded(flex: 2, child: _buildDataRow("Year:", "4")),
          ],
        ),
        const SizedBox(height: 24),

        _buildDataRow("ID:", "ST00453"),
        const SizedBox(height: 24),

        _buildDataRow("Faculty:", "ICT"),
        const SizedBox(height: 24),

        _buildDataRow("Status:", "Denied"),
        const SizedBox(height: 24),

        _buildDataRow("Note:", "Last year's tuition unpaid"),
      ],
    );
  }

  // Helper widget to properly bold labels vs values
  Widget _buildDataRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: AppFonts.spaceGrotesk,
          fontSize: 18,
          color: AppColors.textDark,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMid),
          ),
        ],
      ),
    );
  }
}