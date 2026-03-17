import 'package:flutter/material.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITProfileScreen extends StatelessWidget {
  final void Function(UninexusTab) onNavigate;
  const ITProfileScreen({super.key, required this.onNavigate});

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
                  _buildInfoRow('Department',  'IT'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Position',    'Senior Technician'),
                  const SizedBox(height: 16),
                  _buildInfoRow('E-mail',      'ahmed3044@gmail.com'),
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