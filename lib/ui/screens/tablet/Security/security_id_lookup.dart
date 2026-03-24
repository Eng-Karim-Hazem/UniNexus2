import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class SecurityIdLookupScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;

  const SecurityIdLookupScreen({super.key, required this.onNavigate});

  /// Sample user data for demo
  static const users = [
    {'name': 'Ammar Tarek Mohamed', 'status': 'denied'},
    {'name': 'Moaz Osama Gamil', 'status': 'denied'},
    {'name': 'Youssef Salama Selem', 'status': 'approved'},
  ];

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('ID Lookup'),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Left side - search and user list
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Search bar
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

                        /// User list
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: ListView(
                              padding: EdgeInsets.zero,
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

class _UserRow extends StatelessWidget {
  final String name;
  final String status;

  const _UserRow({required this.name, required this.status});

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

        buildDataRow("ID", "ST20222"),
        const SizedBox(height: 24),

        buildDataRow("Faculty", "ICT"),
        const SizedBox(height: 24),

        buildDataRow("Status", "Denied"),
        const SizedBox(height: 24),

        buildDataRow("Note", "Last year's tuition unpayed"),
      ],
    );
  }
}