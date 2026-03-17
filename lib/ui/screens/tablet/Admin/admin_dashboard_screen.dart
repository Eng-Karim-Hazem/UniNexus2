import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../admin_tab.dart'; // Ensure this contains your search tab
import '../theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  final void Function(AdminTab) onNavigate;
  const AdminDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingCard("Hi Ms. Sarah!"),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN: Requests Overview
                  Expanded(
                    flex: 5,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequestSummaryRow('assets/icons/clipboard.png', "6 Registration requests", Icons.assignment),
                          const SizedBox(height: 15),
                          _buildRequestSummaryRow('assets/icons/lock_reset.png', "3 Password reset requests", Icons.lock_reset),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(),
                          ),
                          const Text("Recent Requests", style: AppTextStyles.senderStyle),
                          const SizedBox(height: 12),
                          _buildRecentRequestItem("Ammar Tarek submitted a request", Icons.assignment),
                          _buildRecentRequestItem("Youssef Salama submitted a request", Icons.lock_reset),
                          _buildRecentRequestItem("Karim Hazem submitted a request", Icons.assignment),
                          const Spacer(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => onNavigate(AdminTab.requests),
                              child: const Text('View Requests >', style: AppTextStyles.viewLinkStyle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // RIGHT COLUMN: Quick Actions & Notices
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // FIXED: User Search now navigates to the search screen
                            Expanded(
                              child: _buildQuickActionCard(
                                "User Search",
                                Icons.person_search_rounded,
                                onTap: () => onNavigate(AdminTab.usersearch), // Ensure 'search' is in AdminTab
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionCard(
                                "Send Notice",
                                Icons.send_rounded,
                                onTap: () => onNavigate(AdminTab.sentnotices),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // NOTICES SECTION
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildNoticeItem("Management", "We need to update our policy rules"),
                                const SizedBox(height: 12),
                                _buildNoticeItem("Management", "The next board meeting will be on 27/5"),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () =>  onNavigate(AdminTab.notices),
                                    child: const Text('View Sent Notices >', style: AppTextStyles.viewLinkStyle),
                                  ),
                                ),
                              ],
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
    );
  }

  // --- UI HELPER METHODS ---

  // Updated to include onTap functionality
  Widget _buildQuickActionCard(String title, IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(icon, size: 35, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // ... rest of your helper methods (buildGreetingCard, etc.) remain the same
  Widget _buildGreetingCard(String name) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          decoration: AppDecorations.greetingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.greetingTitleStyle),
              const SizedBox(height: 4),
              const Text('Good morning', style: AppTextStyles.greetingMorningStyle),
              const SizedBox(height: 2),
              const Text('October 11, 2026', style: AppTextStyles.greetingDateStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestSummaryRow(String iconPath, String title, IconData fallback) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Icon(fallback, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildRecentRequestItem(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.logRowBodyStyle)),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String sender, String msg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [
          const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender, style: AppTextStyles.senderStyle),
                Text(msg, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}