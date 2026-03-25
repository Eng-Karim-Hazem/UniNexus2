import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../admin_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminProfileScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;
  const AdminProfileScreen({super.key, required this.onNavigate});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
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

  String _getValidString(SharedPreferences prefs, String key) {
    final value = prefs.getString(key);
    if (value == null || value.trim().isEmpty) return '-';
    return value;
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

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
            const Text('Profile', style: AppTextStyles.largeHeading),
            const SizedBox(height: 20),

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
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
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
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Department', _department),
                        _buildDivider(),
                        _buildInfoRow('Position', _position),
                        _buildDivider(),
                        _buildInfoRow('E-mail', _email),
                        _buildDivider(),
                        _buildInfoRow('Phone no.', _phone),
                        _buildDivider(),
                        _buildInfoRow('National ID', _nationalId),
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

  Widget _buildFallbackIcon() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.asset('assets/icons/user_purple.png', fit: BoxFit.contain),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Text(
        '$label : $value',
        style: const TextStyle(
          fontFamily: AppFonts.spaceGrotesk,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.black.withValues(alpha: 0.3),
      thickness: 1,
      height: 1,
    );
  }
}