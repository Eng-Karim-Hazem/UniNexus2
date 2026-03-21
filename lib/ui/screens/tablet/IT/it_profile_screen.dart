import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITProfileScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITProfileScreen({super.key, required this.onNavigate});

  @override
  State<ITProfileScreen> createState() => _ITProfileScreenState();
}

class _ITProfileScreenState extends State<ITProfileScreen> {
  // Variables to hold the fetched data
  String _fullName = 'Loading...';
  String _id = 'Loading...';
  String _email = 'Loading...';
  String _phone = 'Loading...';
  String? _base64Photo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // INSTANT FETCH FROM LOCAL STORAGE
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Piece together the first and last name saved during login
      final fName = prefs.getString('fName') ?? 'Unknown';
      final lName = prefs.getString('lName') ?? 'User';
      _fullName = '$fName $lName';

      _id = prefs.getString('ID') ?? 'N/A';
      _email = prefs.getString('email') ?? 'N/A';
      _phone = prefs.getString('pNum') ?? 'N/A';

      // Grab the Base64 photo string
      _base64Photo = prefs.getString('photo');

      _isLoading = false;
    });
  }

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

            // --- DYNAMIC PROFILE HEADER CARD ---
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                children: [
                  // PROFILE PICTURE LOGIC
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                    ),
                    child: ClipOval(
                      child: _base64Photo != null && _base64Photo!.isNotEmpty
                          ? Image.memory(
                        base64Decode(_base64Photo!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                      )
                          : _buildFallbackIcon(),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // NAME AND ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.spaceGrotesk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _id,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- DYNAMIC PROFILE DETAILS CARD ---
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoRow('Department',  'IT'), // Static for this dashboard
                    AppDecorations.profileInfoDivider,
                    _buildInfoRow('Position',    'Senior Technician'), // Static for this dashboard
                    AppDecorations.profileInfoDivider,
                    _buildInfoRow('E-mail',      _email),
                    AppDecorations.profileInfoDivider,
                    _buildInfoRow('Phone no.',   _phone),
                    AppDecorations.profileInfoDivider,
                    _buildInfoRow('National ID', '2838329204792-32'), // Keep static if not in DB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fallback icon if the user has no photo yet
  Widget _buildFallbackIcon() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.asset(
        'assets/icons/user_purple.png',
        fit: BoxFit.contain,
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