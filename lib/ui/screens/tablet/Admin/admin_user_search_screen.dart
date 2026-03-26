import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../admin_tab.dart';
import 'package:uninexus/model/student_model.dart';
import 'package:uninexus/services/firebase/id_lookup_service.dart';
import 'package:uninexus/theme/app_theme.dart';

class AdminUserSearchScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;

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
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // Load search history from preferences
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

  // Save search to history
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

  // Perform search
  Future<void> _onSearchSubmit() async {
    final id = _searchController.text.trim();
    if (id.isEmpty) {
      setState(() {
        _searchError = 'Please enter an ID to search';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    final student = await _idLookupService.searchStudentById(id);
    if (student == null) {
      if (!mounted) return;
      setState(() {
        _searchError = 'No user found with ID: $id';
        _selectedStudent = null;
        _isLoading = false;
      });
      showErrorSnackBar(context, "No user found with this ID");
      return;
    }

    await _saveToHistory(student);
    if (!mounted) return;
    setState(() {
      _selectedStudent = student;
      _isLoading = false;
      _searchError = null;
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
            const PageHeading('User Search'),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                children: [
                  // Left panel - Search bar and history
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
                                ? const LoadingState()
                                : _recentSearches.isEmpty
                                ? const EmptyState(
                              message: 'No recent searches',
                              icon: Icons.history,
                            )
                                : ListView.builder(
                              itemCount: _recentSearches.length,
                              itemBuilder: (context, index) {
                                final student = _recentSearches[index];
                                return AppEntryRow(
                                  label: '${student.fName} ${student.lName}'.trim(),
                                  status: student.entry ? 'approved' : 'denied',
                                  onTap: () => setState(() => _selectedStudent = student),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Right panel - User details
                  Expanded(
                    flex: 2,
                    child: GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: _selectedStudent == null
                          ? Center(
                        child: _searchError != null
                            ? EmptyState(
                          message: _searchError!,
                          icon: Icons.person_off,
                        )
                            : const EmptyState(
                          message: 'Search for a user to view details',
                          icon: Icons.person_search,
                        ),
                      )
                          : Column(
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

  // Search bar widget
  Widget _buildSearchBar() {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Search User By ID',
              hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Profile header
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

  // Build user data rows
  List<Widget> _buildDataEntries() {
    final student = _selectedStudent!;
    return [
      buildInfoRow(
        label: 'Name',
        value: '${student.fName} ${student.lName}'.trim(),
        fontSize: 16,
        verticalPadding: 20,
        labelWeight: FontWeight.bold,
        valueWeight: FontWeight.normal,
      ),
      buildInfoRow(
        label: 'User Type',
        value: 'Student',
        fontSize: 16,
        verticalPadding: 20,
        labelWeight: FontWeight.bold,
        valueWeight: FontWeight.normal,
      ),
      buildInfoRow(
        label: 'ID',
        value: student.id,
        fontSize: 16,
        verticalPadding: 20,
        labelWeight: FontWeight.bold,
        valueWeight: FontWeight.normal,
      ),
      buildInfoRow(
        label: 'Email',
        value: student.email,
        fontSize: 16,
        verticalPadding: 20,
        labelWeight: FontWeight.bold,
        valueWeight: FontWeight.normal,
      ),
      buildInfoRow(
        label: 'Year',
        value: student.year,
        fontSize: 16,
        verticalPadding: 20,
        labelWeight: FontWeight.bold,
        valueWeight: FontWeight.normal,
      ),
      buildInfoRow(
        label: 'Faculty',
        value: student.faculty,
        fontSize: 16,
        verticalPadding: 20,
        labelWeight: FontWeight.bold,
        valueWeight: FontWeight.normal,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: [
            Text(
              'Status : ',
              style: const TextStyle(
                fontFamily: AppFonts.spaceGrotesk,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            StatusBadge(status: student.entry ? 'approved' : 'denied', isDot: false),
          ],
        ),
      ),
    ];
  }
}