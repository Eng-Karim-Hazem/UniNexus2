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
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // Load search history from preferences
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

  // Save search to history
  Future<void> _saveToHistory(Student student) async {
    final prefs = await SharedPreferences.getInstance();

    _recentSearches.removeWhere((element) => element.id == student.id);
    _recentSearches.insert(0, student);

    if (_recentSearches.length > 10) _recentSearches.removeLast();

    final String encoded = jsonEncode(_recentSearches.map((e) => e.toJson()).toList());
    await prefs.setString('search_history', encoded);
    setState(() {});
  }

  // Perform search
  void _onSearchSubmit() async {
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
      showErrorSnackBar(context, "No user found with this ID");
    }
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
                  // Left panel - Search bar and history
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
                                ? const SingleChildScrollView(child: Center(child: LoadingState()))
                                : _recentSearches.isEmpty
                                ? const SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: EmptyState(
                                    message: 'No recent searches',
                                    icon: Icons.history,
                                  ),
                                ),
                              ),
                            )
                                : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _recentSearches.length,
                              itemBuilder: (context, index) {
                                final student = _recentSearches[index];
                                return AppEntryRow(
                                  label: "${student.fName} ${student.lName}",
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
                  const SizedBox(width: 24),

                  // Right panel - User details
                  Expanded(
                    flex: 4,
                    child: GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: _selectedStudent == null
                          ? SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: _searchError != null
                                ? EmptyState(
                              message: _searchError!,
                              icon: Icons.person_off,
                            )
                                : const EmptyState(
                              message: 'Search for a user to view details',
                              icon: Icons.person_search,
                            ),
                          ),
                        ),
                      )
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


  // Search bar widget
  Widget _buildSearchBar() {
    return Container(
      width: 350,
      decoration: AppDecorations.smallCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
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
        ],
      ),
    );
  }
}

// User data panel widget
class _UserDataPanel extends StatelessWidget {
  final Student student;
  const _UserDataPanel({required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
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
          buildInfoRow(
            label: "Name",
            value: "${student.fName} ${student.lName}",
            fontSize: 18,
            verticalPadding: 12,
            labelWeight: FontWeight.w800,
            valueWeight: FontWeight.w600,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: buildInfoRow(
                  label: "User Type",
                  value: "Student",
                  fontSize: 18,
                  verticalPadding: 12,
                  labelWeight: FontWeight.w800,
                  valueWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: buildInfoRow(
                  label: "Year",
                  value: student.year,
                  fontSize: 18,
                  verticalPadding: 12,
                  labelWeight: FontWeight.w800,
                  valueWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          buildInfoRow(
            label: "ID",
            value: student.id,
            fontSize: 18,
            verticalPadding: 12,
            labelWeight: FontWeight.w800,
            valueWeight: FontWeight.w600,
          ),
          const SizedBox(height: 24),
          buildInfoRow(
            label: "Faculty",
            value: student.faculty,
            fontSize: 18,
            verticalPadding: 12,
            labelWeight: FontWeight.w800,
            valueWeight: FontWeight.w600,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Status : ',
                  style: TextStyle(
                    fontFamily: AppFonts.spaceGrotesk,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                StatusBadge(status: student.entry ? 'approved' : 'denied', isDot: false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          buildInfoRow(
            label: "Note",
            value: student.note,
            fontSize: 18,
            verticalPadding: 12,
            labelWeight: FontWeight.w800,
            valueWeight: FontWeight.w600,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}