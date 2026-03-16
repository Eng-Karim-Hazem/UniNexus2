import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../uninexus_tab.dart';
import '../theme/app_theme.dart';

class _HallError {
  final String hall;
  final String issue;
  final bool hasAttachment;
  final bool hasAlert;
  final String description;

  const _HallError({
    required this.hall,
    required this.issue,
    this.hasAttachment = false,
    this.hasAlert = false,
    required this.description,
  });
}

class ITHallErrorScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITHallErrorScreen({super.key, required this.onNavigate});

  @override
  State<ITHallErrorScreen> createState() => _ITHallErrorScreenState();
}

class _ITHallErrorScreenState extends State<ITHallErrorScreen> {
  int _selectedIndex = 0;

  static const List<_HallError> _errors = [
    _HallError(
      hall: 'A 108',
      issue: 'Projector is not working',
      description:
      'Projector boots up then shows this blue screen only without any change even after restarting the projector',
    ),
    _HallError(
      hall: 'A 207',
      issue: "PC's is malfunctioning",
      hasAlert: true,
      description: 'Multiple PCs in the lab are failing to boot properly.',
    ),
    _HallError(
      hall: 'B 402',
      issue: 'Lighting problems',
      hasAttachment: true,
      hasAlert: true,
      description: 'Several ceiling lights flickering and two have stopped working.',
    ),
    _HallError(
      hall: 'C 203',
      issue: 'HDMI Cable is missing',
      description: 'The HDMI cable for the projector has gone missing.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = _errors[_selectedIndex];

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.only(top: 54, left: 28, right: 28, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hall Errors', style: AppTextStyles.largeHeading),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error list
                  Expanded(
                    flex: 45,
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: _errors.length,
                          itemBuilder: (context, index) {
                            final e = _errors[index];
                            final isSelected = _selectedIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIndex = index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: AppDecorations.smallCard(
                                    isSelected: isSelected),
                                child: Row(
                                  children: [
                                    Image.asset('assets/icons/warning.png',
                                        width: 28, height: 28,
                                        errorBuilder: (_, __, ___) => const Icon(
                                            Icons.warning_amber_rounded,
                                            size: 28, color: AppColors.primary)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.hall,
                                              style: AppTextStyles.hallListNumberStyle),
                                          const SizedBox(height: 2),
                                          Text(e.issue,
                                              style: AppTextStyles.hallListErrorStyle,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    if (e.hasAttachment)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Icon(Icons.attach_file,
                                            size: 20, color: AppColors.textLight),
                                      ),
                                    if (e.hasAlert)
                                      Container(
                                        width: 14, height: 14,
                                        margin: const EdgeInsets.only(left: 6),
                                        decoration: const BoxDecoration(
                                          color: AppColors.alertOrange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Error detail
                  Expanded(
                    flex: 55,
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset('assets/icons/warning.png',
                                    width: 40, height: 40,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.warning_amber_rounded,
                                        size: 40, color: AppColors.primary)),
                                const SizedBox(width: 16),
                                Container(width: 2, height: 50, color: AppColors.divider),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(selected.hall,
                                          style: AppTextStyles.hallDetailsNumberStyle),
                                      const SizedBox(height: 4),
                                      Text(selected.issue,
                                          style: AppTextStyles.hallDetailsErrorStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              height: 220,
                              decoration: AppDecorations.blueScreen,
                              child: Center(
                                child: Container(
                                  width: 260, height: 155,
                                  decoration: AppDecorations.innerBlueScreen,
                                  child: Center(
                                    child: Text('Blue Screen',
                                        style: AppTextStyles.blueScreenLabelStyle),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(selected.description,
                                style: AppTextStyles.hallDetailsDescriptionStyle),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                    child: PillButton(label: 'In Repair', onTap: () {})),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: PillButton(label: 'Fixed', onTap: () {})),
                              ],
                            ),
                          ],
                        ),
                      ),
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