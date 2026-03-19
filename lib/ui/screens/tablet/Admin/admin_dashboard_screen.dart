import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../admin_tab.dart'; // Ensure this contains your search tab
import 'package:uninexus/theme/app_theme.dart';

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
            const AppGreetingCard(
              name: 'Ms. Sarah',
              subtitle: 'Good morning',
              date: 'October 11, 2026',
            ),
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
                                "assets/images/id-card 5.png",
                                onTap: () => onNavigate(AdminTab.usersearch), // Ensure 'search' is in AdminTab
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionCard(
                                "Send Notice",
                                "assets/images/send_butt.png",
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

  // Updated to match the new crisp white design with the top-right icon box!
  // Updated to use image assets instead of standard icons
  Widget _buildQuickActionCard(String title, String imagePath, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // TOP RIGHT: Filled Asset Box
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  imagePath, // Uses your custom asset path
                  width: 30,
                  height: 30,
                  //color: Colors.white, // Tints your asset white to match the design!
                  fit: BoxFit.contain,
                  // Fallback icon just in case the asset path is mistyped
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // BOTTOM LEFT: Bold Title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                fontFamily: AppFonts.spaceGrotesk,
                color: AppColors.textDark,
              ),
            ),

          ],
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