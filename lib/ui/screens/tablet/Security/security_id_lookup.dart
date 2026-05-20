import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/model/student_model.dart';
import 'package:uninexus/services/firebase/id_lookup_service.dart';
import 'package:uninexus/theme/app_theme.dart';
import 'package:uninexus/theme/uninexus_tab.dart';

class SecurityIdLookupScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const SecurityIdLookupScreen({super.key, required this.onNavigate});

  @override
  State<SecurityIdLookupScreen> createState() => _SecurityIdLookupScreenState();
}

class _SecurityIdLookupScreenState extends State<SecurityIdLookupScreen> {
  final IDLookupService _idLookupService = IDLookupService();
  final TextEditingController _searchController = TextEditingController();

  Student? _selectedStudent;
  List<Student> _recentSearches = [];
  List<Student> _deniedStudents = []; // Stores list from database

  bool _isLoading = false;
  bool _isShowingDeniedList = false; // Toggle state
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyData = prefs.getString('search_history');
    if (historyData != null) {
      final List<dynamic> decoded = jsonDecode(historyData);
      setState(() {
        _recentSearches = decoded.map((item) => Student.fromJson(item)).toList();
      });
    }
  }

  // Fetch only denied students from Firebase
  void _toggleDeniedList() async {
    if (_isShowingDeniedList) {
      setState(() => _isShowingDeniedList = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    final denied = await _idLookupService.getDeniedStudents();

    setState(() {
      _deniedStudents = denied;
      _isShowingDeniedList = true;
      _isLoading = false;
    });
  }

  Future<void> _saveToHistory(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.removeWhere((element) => element.id == student.id);
    _recentSearches.insert(0, student);
    if (_recentSearches.length > 10) _recentSearches.removeLast();
    final String encoded = jsonEncode(_recentSearches.map((e) => e.toJson()).toList());
    await prefs.setString('search_history', encoded);
    setState(() {});
  }

  void _onSearchSubmit() async {
    final id = _searchController.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchError = null;
      _isShowingDeniedList = false; // Return to history view on search
    });

    final student = await _idLookupService.searchStudentById(id);

    if (student != null) {
      _saveToHistory(student);
      setState(() {
        _selectedStudent = student;
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchError = 'No user found with ID: $id';
        _selectedStudent = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Decide which list to show based on toggle
    final displayList = _isShowingDeniedList ? _deniedStudents : _recentSearches;
    final listLabel = _isShowingDeniedList ? "All Denied Students" : "Recent Searches";

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('ID Lookup'),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(listLabel, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                            // --- DENIED LIST TOGGLE BUTTON ---
                            TextButton.icon(
                              onPressed: _toggleDeniedList,
                              icon: Icon(
                                _isShowingDeniedList ? Icons.history : Icons.block,
                                color: _isShowingDeniedList ? AppColors.primary : Colors.redAccent,
                                size: 20,
                              ),
                              label: Text(
                                _isShowingDeniedList ? "Show Recent" : "Show All Denied",
                                style: TextStyle(color: _isShowingDeniedList ? AppColors.primary : Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: _isLoading
                                ? const Center(child: LoadingState())
                                : displayList.isEmpty
                                ? Center(child: EmptyState(message: _isShowingDeniedList ? 'No denied entries found' : 'No recent searches', icon: Icons.person_off))
                                : ListView.builder(
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                final student = displayList[index];
                                return AppEntryRow(
                                  label: "${student.fName} ${student.lName}",
                                  status: student.entry ? 'approved' : 'denied',
                                  isSelected: _selectedStudent?.id == student.id,
                                  onTap: () => setState(() => _selectedStudent = student),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: _selectedStudent == null
                          ? Center(child: EmptyState(message: _searchError ?? 'Select a user', icon: Icons.person_search))
                          : _UserDataPanel(student: _selectedStudent!),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 350,
      decoration: AppDecorations.smallCard(),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search User By ID",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: _onSearchSubmit,
          ),
        ),
        onSubmitted: (_) => _onSearchSubmit(),
      ),
    );
  }
}

class _UserDataPanel extends StatelessWidget {
  final Student student;
  const _UserDataPanel({required this.student});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person, color: AppColors.primary, size: 40),
                  SizedBox(width: 16),
                  Text("User Data", style: TextStyle(fontFamily: AppFonts.batangas, fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 56),
              buildInfoRow(label: "Name", value: "${student.fName} ${student.lName}", fontSize: 18, verticalPadding: 12),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(flex: 3, child: buildInfoRow(label: "User Type", value: "Student", fontSize: 18, verticalPadding: 12)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: buildInfoRow(label: "Year", value: student.year, fontSize: 18, verticalPadding: 12)),
                ],
              ),
              const SizedBox(height: 24),
              buildInfoRow(label: "ID", value: student.id, fontSize: 18, verticalPadding: 12),
              const SizedBox(height: 24),
              buildInfoRow(label: "Faculty", value: student.faculty, fontSize: 18, verticalPadding: 12),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Status : ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  StatusBadge(status: student.entry ? 'approved' : 'denied', isDot: false),
                ],
              ),
              const SizedBox(height: 24),
              buildInfoRow(label: "Note", value: student.note, fontSize: 18, verticalPadding: 12),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (student.photo != null && student.photo!.isNotEmpty)
                  ? Image.memory(base64Decode(student.photo!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                  : const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}