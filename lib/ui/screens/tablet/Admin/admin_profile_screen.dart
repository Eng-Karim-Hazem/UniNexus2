import 'package:flutter/material.dart';

import '../../../../admin_tab.dart';
import '../../../../uninexus_tab.dart';
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

            // Profile details card
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  _buildInfoRow('Department',  'Staff'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Position',    'Financail'),
                  const SizedBox(height: 16),
                  _buildInfoRow('E-mail',      'sarah@gmail.com'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Phone no.',   '01920202343'),
                  const SizedBox(height: 16),
                  _buildInfoRow('National ID', '2838329204792-32'),
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
          child: Text(value, style: AppTextStyles.profileInfoValueStyle),
        ),
      ],
    );
  }
}