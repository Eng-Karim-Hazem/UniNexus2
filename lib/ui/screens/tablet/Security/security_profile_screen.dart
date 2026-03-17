import 'package:flutter/material.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class SecurityProfileScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;

  const SecurityProfileScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text('Profile', style: AppTextStyles.largeHeading),

            const SizedBox(height: 45),

            /// HEADER CARD
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: const ProfileHeader(
                iconAsset: 'assets/icons/user_purple.png',
                title: 'Hassan Ammar Seidel Ibrahim',
                subtitle: 'SC204553',
              ),
            ),

            const SizedBox(height: 16),

            /// DETAILS CARD
            Expanded(child:
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30), // Increased vertical padding
              child: Column(
                children: [
                  _buildInfoRow('Department', 'Security'),
                  _buildDivider(),

                  _buildInfoRow('Position', 'Security Officer'),
                  _buildDivider(),

                  _buildInfoRow('E-mail', '-'),
                  _buildDivider(),

                  _buildInfoRow('Phone no.', '01564343902'),
                  _buildDivider(),

                  _buildInfoRow('National ID', '2855832904792-52'),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  // EDITED: Now perfectly left-aligned without the awkward SizedBox staggering
  Widget _buildInfoRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Matches text spacing to the edges
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.profileInfoLabelStyle, // Makes the Label bold
          children: [
            TextSpan(
              text: '$label : ',
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.profileInfoValueStyle, // Makes the Value slightly lighter
            ),
          ],
        ),
      ),
    );
  }

  // EDITED: Increased vertical space to match the new design
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20), // Adds generous vertical spacing
      child: Divider(
        color: AppColors.primary.withOpacity(0.6),
        thickness: 2,
        height: 2,
      ),
    );
  }
}