import 'package:flutter/material.dart';
import '../../../../admin_tab.dart'; // Ensure this path is correct
import 'package:uninexus/theme/app_theme.dart';

class AdminUserSearchScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate; // Uses AdminTab enum

  const AdminUserSearchScreen({super.key, required this.onNavigate});

  @override
  State<AdminUserSearchScreen> createState() => _AdminUserSearchScreenState();
}

class _AdminUserSearchScreenState extends State<AdminUserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data matching the UI
  final Map<String, String> _userData = {
    'Name': 'Moaz Osama Gamil',
    'User Type': 'Student',
    'ID': 'ST20222',
    'Email': 'MoazOsama@gmail.com',
    'Year': '4',
    'Faculty': 'ICT',
    'Status': 'Approved',
  };

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Search', style: AppTextStyles.largeHeading),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                children: [
                  // Left Side: Search and Results
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: ListView(
                              children: [
                                _buildUserResultTile(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Right Side: User Data Card
                  Expanded(
                    flex: 2,
                    child: GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 32),
                          ..._userData.entries.map((e) => _buildDataRow(e.key, e.value)),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Search User By ID',
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildUserResultTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(_userData['Name']!, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
        const SizedBox(width: 16),
        const Text('|', style: TextStyle(fontSize: 30, color: Colors.grey)),
        const SizedBox(width: 16),
        Text('User Data', style: AppTextStyles.settingsCardTitleStyle),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Text('$label : ', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}