import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';


// CHANGED TO STATEFUL WIDGET
class ITDashboardScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITDashboardScreen({super.key, required this.onNavigate});

  @override
  State<ITDashboardScreen> createState() => _ITDashboardScreenState();
}

class _ITDashboardScreenState extends State<ITDashboardScreen> {
  // STATE VARIABLES
  String _userName = 'Loading...';
  bool _isLoading = true;

  static const List<Map<String, String>> _logs = [
    {'text': 'Hall B201 marked as fixed',    'time': '10:34 AM'},
    {'text': 'Password reset approved',       'time': '11:02 AM'},
    {'text': 'Hall A108 marked as fixed',     'time': '12:45 PM'},
    {'text': 'Hall C203 marked as in repair', 'time': '01:32 PM'},
    {'text': 'Hall B401 marked as fixed',     'time': '02:15 PM'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the name as soon as the screen loads
  }


  // INSTANT FETCH FROM LOCAL STORAGE
  Future<void> _fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Grab the fName you already saved during login
      final String firstName = prefs.getString('fName') ?? 'Guest';

      setState(() {
        _userName = 'Eng. $firstName';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userName = 'Eng. Error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GREETING CARD (Now uses dynamic data!)
            AppGreetingCard(
              name: _userName,
              subtitle: 'Good morning',
              date: 'October 11, 2026', // We can make this dynamic next if you want!
            ),

            const SizedBox(height: 20),

            // Main content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Logs
                  // Recent Logs
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        children: [
                          ..._logs.map((l) => _LogRow(text: l['text']!, time: l['time']!)),
                          const Spacer(),

                          // Reverted to just the right-aligned View Logs button
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => widget.onNavigate(UninexusTab.logs),
                              child: const Text('View Logs >', style: AppTextStyles.viewLinkStyle),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right column
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _AnnouncementCard(
                                  sender: 'Management',
                                  message: 'We need to update our policy rules',
                                ),
                                const SizedBox(height: 10),
                                const _AnnouncementCard(
                                  sender: 'Management',
                                  message: 'The next board meeting will be on 27/5',
                                ),

                                const Spacer(),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => widget.onNavigate(UninexusTab.announcements), // Updated
                                    child: const Text('View All >', style: AppTextStyles.viewLinkStyle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stats row
                        SizedBox(
                          height: 250,
                          child: Row(
                            children: [
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24, horizontal: 12),
                                  child: const CircularStat(
                                    value: 0.65,
                                    line1: 'Resolution',
                                    line2: 'Rate',
                                    valueLabel: '65%',
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24, horizontal: 12),
                                  child: const CircularStat(
                                    value: 0.70,
                                    line1: 'Open',
                                    line2: 'Issues',
                                    valueLabel: '7',
                                    sublabel: 'Active\nissues',
                                    color: AppColors.blueAccent,
                                  ),
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

// ... Keep your _LogRow and _AnnouncementCard exactly as they are below this
  
  class _LogRow extends StatelessWidget {
    final String text;
    final String time;
    const _LogRow({required this.text, required this.time});
  
    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: AppDecorations.smallCard(),
        child: Row(
          children: [
            Image.asset('assets/icons/restore.png', width: 26, height: 26,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.history, size: 26, color: AppColors.primary)),
            const SizedBox(width: 12),
            Container(width: 1.5, height: 24, color: AppColors.divider),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: AppTextStyles.logRowBodyStyle),
            ),
            Text(time, style: AppTextStyles.caption),
          ],
        ),
      );
    }
  }
  
  class _AnnouncementCard extends StatelessWidget {
    final String sender;
    final String message;
    const _AnnouncementCard({required this.sender, required this.message});
  
    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: AppDecorations.smallCard(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/icons/bell_outline.png', width: 26, height: 26,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.notifications_outlined, size: 26, color: AppColors.primary)),
            const SizedBox(width: 12),
            Container(width: 1.5, height: 36, color: AppColors.divider),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sender, style: AppTextStyles.senderStyle),
                  const SizedBox(height: 2),
                  Text(message, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }