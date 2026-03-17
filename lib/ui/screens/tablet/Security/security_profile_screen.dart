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

            const SizedBox(height: 20),

            /// HEADER CARD
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: ProfileHeader(
                iconAsset: 'assets/icons/user_purple.png',
                title: 'Hassan Ammar Seidel Ibrahim',
                subtitle: 'SC204553',
              ),
            ),

            const SizedBox(height: 16),

            /// DETAILS CARD
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  _buildInfoRow('Department', 'Security'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Position', 'Security Officer'),
                  const SizedBox(height: 16),
                  _buildInfoRow('E-mail', '-'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Phone no.', '01564343902'),
                  const SizedBox(height: 16),
                  _buildInfoRow('National ID', '2855832904792-52'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          width: 120,
          child: Text(label,
              style: AppTextStyles.profileInfoLabelStyle,
              textAlign: TextAlign.right),
        ),

        const SizedBox(
          width: 20,
          child: Text(':',
              style: AppTextStyles.profileInfoLabelStyle,
              textAlign: TextAlign.center),
        ),

        Expanded(
          child: Text(value,
              style: AppTextStyles.profileInfoValueStyle),
        ),
      ],
    );
  }
}