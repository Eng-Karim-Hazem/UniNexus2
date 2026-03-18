import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class SecurityIdLookupScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;

  const SecurityIdLookupScreen({super.key, required this.onNavigate});

  static const users = [
    {'name': 'Ammar Tarek Mohamed', 'status': 'denied'},
    {'name': 'Moaz Osama Gamil', 'status': 'denied'},
    {'name': 'Youssef Salama Selem', 'status': 'approved'},
  ];

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            const Text(
              "ID Lookup",
              style: TextStyle(
                fontSize: 50,
                fontFamily: AppFonts.batangas,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 45),

            Expanded(
              child: Row(
                // EDITED: 'stretch' forces both left and right sides to be the exact same height!
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  /// LEFT SIDE (Search Bar + List)
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// SEARCH BAR (Moved inside the left column)
                        Container(
                          width: 350,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: AppDecorations.smallCard(),
                          child: Row(
                            children: [
                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Search User By ID",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send, color: AppColors.primary),
                                onPressed: () {},
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// LEFT LIST
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: ListView(
                              padding: EdgeInsets.zero, // EDITED: Pushes the first card to the top edge
                              children: users
                                  .map((e) => _UserRow(
                                name: e['name']!,
                                status: e['status']!,
                              )).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  /// USER DATA PANEL (Right Side)
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

class _UserRow extends StatelessWidget {
  final String name;
  final String status;

  const _UserRow({required this.name, required this.status});

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
            width: 34,
            height: 34,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),

          const SizedBox(width: 14),

          Container(
            width: 2,
            height: 28,
            color: AppColors.primary.withOpacity(.35),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: AppFonts.spaceGrotesk,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
          ),

          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

        _buildDataRow("ID:", "ST20222"),
        const SizedBox(height: 24),

        _buildDataRow("Faculty:", "ICT"),
        const SizedBox(height: 24),

        _buildDataRow("Status:", "Denied"),
        const SizedBox(height: 24),

        _buildDataRow("Note:", "Last year's tuition unpayed"), // Text matches your design
      ],
    );
  }

  // EDITED: Helper widget to properly bold labels vs values, matching the design!
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