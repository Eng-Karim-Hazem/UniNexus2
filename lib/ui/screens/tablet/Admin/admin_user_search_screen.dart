import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyData = prefs.getString('admin_search_history');
    if (historyData == null) return;

    final List<dynamic> decoded = jsonDecode(historyData);
    if (!mounted) return;
    setState(() {
      _recentSearches = decoded.map((item) => Student.fromJson(item)).toList();
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
    if (!mounted) return;
    setState(() {});
  }

  void _handleStudentUpdate(Student updatedStudent) {
    setState(() {
      _selectedStudent = updatedStudent;
      int index = _recentSearches.indexWhere((s) => s.id == updatedStudent.id);
      if (index != -1) {
        _recentSearches[index] = updatedStudent;
      }
    });
    _saveToHistory(updatedStudent);
  }

  Future<void> _onSearchSubmit() async {
    final id = _searchController.text.trim();
    if (id.isEmpty) {
      setState(() => _searchError = 'Please enter an ID to search');
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
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('User Search'),
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
                        const Text("Recent Searches", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: _isLoading
                                ? const Center(child: LoadingState())
                                : _recentSearches.isEmpty
                                ? const Center(child: EmptyState(message: 'No recent searches', icon: Icons.history))
                                : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _recentSearches.length,
                              itemBuilder: (context, index) {
                                final student = _recentSearches[index];
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
                          ? Center(child: EmptyState(message: _searchError ?? 'Search for a user to view details', icon: Icons.person_search))
                          : _UserDataPanel(
                        key: ValueKey(_selectedStudent!.id),
                        student: _selectedStudent!,
                        onUpdate: _handleStudentUpdate,
                      ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _UserDataPanel extends StatefulWidget {
  final Student student;
  final Function(Student) onUpdate;

  const _UserDataPanel({super.key, required this.student, required this.onUpdate});

  @override
  State<_UserDataPanel> createState() => _UserDataPanelState();
}

class _UserDataPanelState extends State<_UserDataPanel> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _noteController;
  late bool _entryStatus;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.student.note);
    _entryStatus = widget.student.entry;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _resetFields() {
    setState(() {
      _noteController.text = widget.student.note;
      _entryStatus = widget.student.entry;
      _isEditing = false;
    });
  }

  Future<void> _updateStudentData() async {
    setState(() => _isSaving = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('ID', isEqualTo: widget.student.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) throw Exception("User document not found");

      final docId = querySnapshot.docs.first.id;
      final updatedNote = _noteController.text.trim();
      final updatedEntry = _entryStatus;

      await FirebaseFirestore.instance
          .collection('students')
          .doc(docId)
          .update({
        'note': updatedNote,
        'entry': updatedEntry,
      });

      // Updated to include all required parameters from your Student model
      final updatedStudent = Student(
        id: widget.student.id,
        fName: widget.student.fName,
        lName: widget.student.lName,
        entry: updatedEntry,
        note: updatedNote,
        photo: widget.student.photo,
        year: widget.student.year,
        faculty: widget.student.faculty,
        app: widget.student.app,
        email: widget.student.email,
        nID: widget.student.nID,
        pass: widget.student.pass,
        pNum: widget.student.pNum,
        section: widget.student.section,
      );

      widget.onUpdate(updatedStudent);

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary, size: 40),
                  const SizedBox(width: 16),
                  const Text("User Data", style: TextStyle(fontFamily: AppFonts.batangas, fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  if (_isSaving)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  else if (!_isEditing)
                    IconButton(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit, color: AppColors.primary, size: 24),
                    )
                  else ...[
                      IconButton(
                        onPressed: _updateStudentData,
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      ),
                      IconButton(
                        onPressed: _resetFields,
                        icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 24),
                      ),
                    ],
                ],
              ),
              const SizedBox(height: 40),
              buildInfoRow(label: "Name", value: "${widget.student.fName} ${widget.student.lName}", fontSize: 18, verticalPadding: 12),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 3, child: buildInfoRow(label: "User Type", value: "Student", fontSize: 18, verticalPadding: 12)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: buildInfoRow(label: "Year", value: widget.student.year, fontSize: 18, verticalPadding: 12)),
                ],
              ),
              const SizedBox(height: 16),
              buildInfoRow(label: "ID", value: widget.student.id, fontSize: 18, verticalPadding: 12),
              const SizedBox(height: 16),
              buildInfoRow(label: "Faculty", value: widget.student.faculty, fontSize: 18, verticalPadding: 12),
              const SizedBox(height: 16),

              const Text('Status : ', style: TextStyle(fontFamily: AppFonts.spaceGrotesk, fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<bool>(
                  value: _entryStatus,
                  // Fixed: Using InputDecoration to resolve type mismatch
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2))),
                  ),
                  iconEnabledColor: AppColors.primary,
                  items: const [
                    DropdownMenuItem(value: true, child: Text("Approved")),
                    DropdownMenuItem(value: false, child: Text("Denied")),
                  ],
                  onChanged: _isEditing ? (val) => setState(() => _entryStatus = val!) : null,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Note : ', style: TextStyle(fontFamily: AppFonts.spaceGrotesk, fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Container(
                decoration: AppDecorations.smallCard(),
                child: TextField(
                  controller: _noteController,
                  enabled: _isEditing,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (widget.student.photo != null && widget.student.photo!.isNotEmpty)
                  ? Image.memory(
                base64Decode(widget.student.photo!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              )
                  : const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}