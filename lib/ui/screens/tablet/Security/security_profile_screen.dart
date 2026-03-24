import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class SecurityProfileScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const SecurityProfileScreen({super.key, required this.onNavigate});

  @override
  State<SecurityProfileScreen> createState() => _SecurityProfileScreenState();
}

class _SecurityProfileScreenState extends State<SecurityProfileScreen> {
  String _fullName = 'Loading...';
  String _id = 'Loading...';
  String _email = 'Loading...';
  String _phone = 'Loading...';
  String _department = 'Loading...';
  String _position = 'Loading...';
  String _nationalId = 'Loading...';
  String? _base64Photo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Returns a valid string or '-' if empty/null
  String _getValidString(SharedPreferences prefs, String key) {
    final value = prefs.getString(key);
    if (value == null || value.trim().isEmpty) return '-';
    return value;
  }

  /// Loads profile data from shared preferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      final fName = prefs.getString('fName') ?? 'Unknown';
      final lName = prefs.getString('lName') ?? 'User';
      _fullName = '$fName $lName';

      _id = _getValidString(prefs, 'ID');
      _email = _getValidString(prefs, 'email');
      _phone = _getValidString(prefs, 'pNum');
      _department = _getValidString(prefs, 'department');
      _position = _getValidString(prefs, 'position');
      _nationalId = _getValidString(prefs, 'nationalId');
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
            const PageHeading('Profile'),
            const SizedBox(height: 45),

            /// Profile header card with photo and name
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                          width: 2),
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

            /// Profile details card
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildSecurityInfoRow('Department', _department),
                    AppDecorations.profileInfoDivider,
                    buildSecurityInfoRow('Position', _position),
                    AppDecorations.profileInfoDivider,
                    buildSecurityInfoRow('E-mail', _email),
                    AppDecorations.profileInfoDivider,
                    buildSecurityInfoRow('Phone no.', _phone),
                    AppDecorations.profileInfoDivider,
                    buildSecurityInfoRow('National ID', _nationalId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback icon when photo is not available
  Widget _buildFallbackIcon() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.asset(
        'assets/icons/user_purple.png',
        fit: BoxFit.contain,
      ),
    );
  }
}