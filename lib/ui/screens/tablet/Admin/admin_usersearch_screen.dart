import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../admin_tab.dart'; // Ensure this path is correct
import 'package:uninexus/model/student_model.dart';
import 'package:uninexus/services/firebase/idlookup_service.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminUserSearchScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate; // Uses AdminTab enum

  const AdminUserSearchScreen({super.key, required this.onNavigate});

  @override
  State<AdminUserSearchScreen> createState() => _AdminUserSearchScreenState();
}

class _AdminUserSearchScreenState extends State<AdminUserSearchScreen> {
  final IDLookupService _idLookupService = IDLookupService();
  final TextEditingController _searchController = TextEditingController();
  Student? _selectedStudent;
  List<Student> _recentSearches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyData = prefs.getString('admin_search_history');
    if (historyData == null) return;
    final List<dynamic> decoded = jsonDecode(historyData);
    setState(() {
      _recentSearches = decoded.map((item) => Student.fromJson(item)).toList();
      if (_recentSearches.isNotEmpty) _selectedStudent = _recentSearches.first;
    });
  }

  Future<void> _saveToHistory(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.removeWhere((element) => element.id == student.id);
    _recentSearches.insert(0, student);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }

    await prefs.setString(
      'admin_search_history',
      jsonEncode(_recentSearches.map((e) => e.toJson()).toList()),
    );
    setState(() {});
  }

  Future<void> _onSearchSubmit() async {
    final id = _searchController.text.trim();
    if (id.isEmpty) return;

    setState(() => _isLoading = true);
    final student = await _idLookupService.searchStudentById(id);
    if (student == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user found with this ID")),
      );
      setState(() => _isLoading = false);
      return;
    }

    await _saveToHistory(student);
    if (!mounted) return;
    setState(() {
      _selectedStudent = student;
      _isLoading = false;
    });
  }

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
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ListView.builder(
                              itemCount: _recentSearches.length,
                              itemBuilder: (context, index) {
                                final student = _recentSearches[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildUserResultTile(
                                    student,
                                    onTap: () => setState(() => _selectedStudent = student),
                                  ),
                                );
                              },
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
                          ..._buildDataEntries(),
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
          suffixIcon: GestureDetector(
            onTap: _onSearchSubmit,
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
        onSubmitted: (_) => _onSearchSubmit(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildUserResultTile(Student student, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_rounded, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${student.fName} ${student.lName}'.trim(),
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
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

  List<Widget> _buildDataEntries() {
    if (_selectedStudent == null) {
      return const [
        Text('Search or select a recent user', style: AppTextStyles.body),
      ];
    }

    final student = _selectedStudent!;
    final data = <MapEntry<String, String>>[
      MapEntry('Name', '${student.fName} ${student.lName}'.trim()),
      const MapEntry('User Type', 'Student'),
      MapEntry('ID', student.id),
      MapEntry('Email', student.email),
      MapEntry('Year', student.year),
      MapEntry('Faculty', student.faculty),
      MapEntry('Status', student.entry ? 'Approved' : 'Denied'),
    ];

    return data.map((entry) => _buildDataRow(entry.key, entry.value)).toList();
  }
}