import 'package:flutter/material.dart';

import '../../../../admin_tab.dart';
import '../theme/app_theme.dart';

class AdminProfileScreen extends StatelessWidget {
  final void Function(AdminTab) onNavigate;
  const AdminProfileScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile', style: AppTextStyles.largeHeading),
            const SizedBox(height: 20),

            // Profile header card
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: ProfileHeader(
                iconAsset: 'assets/icons/user_purple.png',
                title: 'Ahmed Mohamed Ebrahim Mohamed',
                subtitle: 'IT203021',
              ),
            ),

            const SizedBox(height: 16),

            // Profile details card (UPDATED DESIGN)
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Left aligns everything
                      children: [
                        _buildInfoRow('Department', 'Staff'),
                        _buildDivider(),
                        _buildInfoRow('Position', 'Financial'),
                        _buildDivider(),
                        _buildInfoRow('E-mail', 'sarah@gmail.com'),
                        _buildDivider(),
                        _buildInfoRow('Phone no.', '01920202343'),
                        _buildDivider(),
                        _buildInfoRow('National ID', '2838329204792-32'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED: Combined text, left-aligned, matching the bold design
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0), // Generous spacing for an airy feel
      child: Text(
        '$label : $value',
        style: const TextStyle(
          fontFamily: AppFonts.spaceGrotesk,
          fontSize: 18,
          fontWeight: FontWeight.w800, // Extra bold to match the screenshot
          color: AppColors.textDark,
        ),
      ),
    );
  }

  // ADDED: The horizontal line to separate the rows
  Widget _buildDivider() {
    return Divider(
      color: Colors.black.withOpacity(0.3), // A subtle dark grey line
      thickness: 1,
      height: 1,
    );
  }
}