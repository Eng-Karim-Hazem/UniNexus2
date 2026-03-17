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
            const SizedBox(height: 45),

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
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoRow('Department',  'IT'),
                    AppDecorations.profileInfoDivider,
                    _buildInfoRow('Position',    'Senior Technician'),
                    AppDecorations.profileInfoDivider,
                    _buildInfoRow('E-mail',      'ahmed3044@gmail.com'),
                    AppDecorations.profileInfoDivider,
                    _buildInfoRow('Phone no.',   '01920202343'),
                    AppDecorations.profileInfoDivider,
                    _buildInfoRow('National ID', '2838329204792-32'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$label : ', style: AppTextStyles.profileInfoLabelStyle),
          Expanded(
            child: Text(value, style: AppTextStyles.profileInfoValueStyle),
          ),
        ],
      ),
    );
  }
}