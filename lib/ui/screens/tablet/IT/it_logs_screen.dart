import 'package:flutter/material.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITLogsScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const ITLogsScreen({super.key, required this.onNavigate});

  static const List<Map<String, String>> _logs = [
    {'text': 'Hall B201 marked as fixed',     'time': '10:34 AM'},
    {'text': 'Password reset approved',        'time': '11:02 AM'},
    {'text': 'Hall A108 marked as fixed',      'time': '12:45 PM'},
    {'text': 'Hall C203 marked as in repair',  'time': '01:32 PM'},
    {'text': 'Hall B401 marked as fixed',      'time': '02:15 PM'},
    {'text': 'Hall B201 marked as fixed',      'time': '10:34 AM'},
    {'text': 'Password reset approved',        'time': '11:02 AM'},
    {'text': 'Hall A108 marked as fixed',      'time': '12:45 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LOGs', style: AppTextStyles.largeHeading),
            const SizedBox(height: 20),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final isFaded = index == _logs.length - 1;
                    return Opacity(
                      opacity: isFaded ? 0.5 : 1.0,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: AppDecorations.smallCard(isFaded: isFaded),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/restore.png',
                              width: 24, height: 24,
                              color: AppColors.primary.withOpacity(0.7),
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.history, size: 24, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            const SectionDivider(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(log['text']!,
                                  style: AppTextStyles.logTextStyle),
                            ),
                            Text(log['time']!, style: AppTextStyles.logTimeStyle),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}