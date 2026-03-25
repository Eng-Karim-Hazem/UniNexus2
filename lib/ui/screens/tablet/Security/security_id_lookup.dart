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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // Load history from Shared Preferences
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

  // Save student to history (avoids duplicates)
  Future<void> _saveToHistory(Student student) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove if already exists to move it to the top
    _recentSearches.removeWhere((element) => element.id == student.id);
    _recentSearches.insert(0, student);

    // Keep only last 10 searches
    if (_recentSearches.length > 10) _recentSearches.removeLast();

    final String encoded = jsonEncode(_recentSearches.map((e) => e.toJson()).toList());
    await prefs.setString('search_history', encoded);
    setState(() {});
  }

  void _onSearchSubmit() async {
    final id = _searchController.text.trim();
    if (id.isEmpty) return;

    setState(() => _isLoading = true);
    final student = await _idLookupService.searchStudentById(id);

    if (student != null) {
      _saveToHistory(student);
      setState(() => _selectedStudent = student);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user found with this ID")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                  /// Left side - Search & Local History
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        const Text("Recent Searches",
                            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _recentSearches.length,
                              itemBuilder: (context, index) {
                                final student = _recentSearches[index];
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedStudent = student),
                                  child: _UserRow(
                                    name: "${student.fName} ${student.lName}",
                                    status: student.entry ? 'approved' : 'denied', //
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  /// Right side - Detailed user data panel
                  Expanded(
                    flex: 4,
                    child: GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: _selectedStudent == null
                          ? const Center(child: Text("Search or select a recent user"))
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

/// --- UI HELPER WIDGETS (Original UI Preserved) ---

class _UserRow extends StatelessWidget {
  final String name, status;
  const _UserRow({required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color dotColor = status == 'approved' ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: AppDecorations.smallCard(),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.primary, size: 28),
          const SizedBox(width: 14),
          Container(width: 2, height: 28, color: AppColors.primary.withValues(alpha: .35)),
          const SizedBox(width: 14),
          Expanded(child: Text(name, style: const TextStyle(fontFamily: AppFonts.spaceGrotesk, fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark))),
          Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

class _UserDataPanel extends StatelessWidget {
  final Student student;
  const _UserDataPanel({required this.student});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: AppColors.primary, size: 40),
            const SizedBox(width: 16),
            const Text("User Data", style: TextStyle(fontFamily: AppFonts.batangas, fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 36),
        buildDataRow("Name", "${student.fName} ${student.lName}"),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(flex: 3, child: buildDataRow("User Type", "Student")),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: buildDataRow("Year", student.year)),
          ],
        ),
        const SizedBox(height: 24),
        buildDataRow("ID", student.id),
        const SizedBox(height: 24),
        buildDataRow("Faculty", student.faculty),
        const SizedBox(height: 24),
        buildDataRow("Status", student.entry ? "Approved" : "Denied"), //
        const SizedBox(height: 24),
        buildDataRow("Note", student.note),
      ],
    );
  }
}