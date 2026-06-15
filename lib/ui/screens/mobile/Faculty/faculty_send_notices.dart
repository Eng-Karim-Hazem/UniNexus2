import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/firebase/notices_service.dart';
import '../../../../model/notices_model.dart';

class SendNoticeScreen extends StatefulWidget {
  const SendNoticeScreen({super.key});

  @override
  State<SendNoticeScreen> createState() => _SendNoticeScreenState();
}

class _SendNoticeScreenState extends State<SendNoticeScreen> {
  final _userIdController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = false;
  String _selectedReceiverType = 'Individual';
  String _selectedSection = 'All Sections';
  String _selectedSubject = '';

  final List<String> _receiverTypes = ['Individual', 'Subjects/Sections'];
  final List<String> _sections = ['All Sections', 'Section 1', 'Section 2', 'Section 3', 'Section 4'];

  // Dynamic list populated from SharedPreferences memory footprint
  List<String> _subjects = [];

  final Color _mainPurple = const Color(0xFF7B61FF);

  @override
  void initState() {
    super.initState();
    _loadFacultySubjects();
  }

  // Reads the stored subject strings directly out of SharedPreferences storage key
  Future<void> _loadFacultySubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final storedSubjects = prefs.getStringList('facultySubjects') ?? [];

    setState(() {
      if (storedSubjects.isNotEmpty) {
        _subjects = storedSubjects;
        _selectedSubject = _subjects.first;
      } else {
        _subjects = ['No assigned subjects found'];
        _selectedSubject = _subjects.first;
      }
    });
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitNotice() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notice message cannot be empty.')));
      return;
    }
    if (_selectedReceiverType == 'Individual' && _userIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a User ID.')));
      return;
    }
    if (_selectedReceiverType == 'Subjects/Sections' && _selectedSubject == 'No assigned subjects found') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot send notice without a valid subject configuration.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final senderName = 'Dr. ${prefs.getString('fName') ?? ''} ${prefs.getString('lName') ?? ''}'.trim();

      NoticeTargetType type;
      String targetVal;
      List<String> recipients = [];

      if (_selectedReceiverType == 'Individual') {
        type = NoticeTargetType.individual;
        targetVal = _userIdController.text.trim().toLowerCase();
        recipients = [targetVal];
      } else {
        type = NoticeTargetType.group;
        // Strip text clean or grab the code format context directly
        String subjectCode = _selectedSubject.split(' - ').first.trim();

        if (_selectedSection == 'All Sections') {
          targetVal = 'students_$subjectCode';
          final snap = await FirebaseFirestore.instance.collection('students').get();
          recipients = snap.docs.map((doc) => (doc.data()['ID'] ?? '').toString()).where((id) => id.isNotEmpty).toList();
        } else {
          String sectionNumber = _selectedSection.replaceAll(RegExp(r'[^0-9]'), '');
          targetVal = '${subjectCode}_section_$sectionNumber';

          final snap = await FirebaseFirestore.instance.collection('students')
              .where('section', isEqualTo: sectionNumber)
              .get();

          recipients = snap.docs.map((doc) => (doc.data()['ID'] ?? '').toString()).where((id) => id.isNotEmpty).toList();
        }
      }

      if (recipients.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No students found in this target group!'), backgroundColor: Colors.orange),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final newNotice = NoticeModel(
        title: "Faculty Announcement",
        description: message,
        targetType: type,
        targetValue: targetVal,
        recipientIds: recipients,
        createdAt: DateTime.now(),
        sentBy: senderName.isNotEmpty ? senderName : "Faculty Member",
        expiryDate: DateTime.now().add(const Duration(days: 7)),
      );

      await NoticesService().sendNotice(newNotice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice sent successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Phone_Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF5C5C80), size: sw * 0.065),
                    ),
                    Text(
                      "Notices",
                      style: TextStyle(
                          fontFamily: MobileAppFonts.heading,
                          fontSize: (sw * 0.055).clamp(20.0, 24.0),
                          fontWeight: FontWeight.bold,
                          color: _mainPurple
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(sw * 0.02),
                      child: Image.asset('assets/images/LOGO.png', width: sw * 0.08, height: sw * 0.08),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                  child: Column(
                    children: [
                      SizedBox(height: sh * 0.015),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(sw * 0.06),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(sw * 0.06),
                          border: Border.all(color: _mainPurple.withOpacity(0.6), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Send to", sw),
                            _buildDropdown(
                              value: _selectedReceiverType,
                              items: _receiverTypes,
                              sw: sw,
                              sh: sh,
                              onChanged: (val) => setState(() {
                                _selectedReceiverType = val!;
                                _userIdController.clear();
                              }),
                            ),
                            SizedBox(height: sh * 0.025),

                            if (_selectedReceiverType == 'Individual') ...[
                              _buildLabel("User ID", sw),
                              _buildTextField(
                                hint: "Enter User ID",
                                controller: _userIdController,
                                sw: sw,
                                sh: sh,
                              ),
                            ] else ...[
                              _buildLabel("Choose Section", sw),
                              _buildDropdown(
                                value: _selectedSection,
                                items: _sections,
                                sw: sw,
                                sh: sh,
                                onChanged: (val) => setState(() => _selectedSection = val!),
                              ),
                              SizedBox(height: sh * 0.025),

                              // --- REACTIVE STORAGE SUBJECT DROPDOWN ---
                              _buildLabel("Choose Subject", sw),
                              if (_selectedSubject.isNotEmpty)
                                _buildDropdown(
                                  value: _selectedSubject,
                                  items: _subjects,
                                  sw: sw,
                                  sh: sh,
                                  onChanged: (val) => setState(() => _selectedSubject = val!),
                                )
                              else
                                const LinearProgressIndicator(),
                            ],

                            SizedBox(height: sh * 0.025),

                            _buildLabel("Notice Message", sw),
                            _buildTextField(
                              hint: "Submit your notice max 120 chars.",
                              controller: _messageController,
                              maxLines: 4,
                              maxLength: 120,
                              sw: sw,
                              sh: sh,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: sh * 0.04),

                      Center(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _submitNotice,
                          child: Container(
                            width: sw * 0.55,
                            height: (sh * 0.065).clamp(45.0, 60.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(sw * 0.08),
                              border: Border.all(color: _mainPurple, width: 1.5),
                              boxShadow: [
                                BoxShadow(color: _mainPurple.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF7B61FF), strokeWidth: 2.5))
                                  : Text(
                                "Submit",
                                style: TextStyle(
                                    fontFamily: MobileAppFonts.heading,
                                    fontSize: (sw * 0.045).clamp(16.0, 20.0),
                                    fontWeight: FontWeight.bold,
                                    color: _mainPurple
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double sw) {
    return Padding(
      padding: EdgeInsets.only(left: sw * 0.01, bottom: sw * 0.02),
      child: Text(
        text,
        style: TextStyle(
            fontFamily: MobileAppFonts.heading,
            fontSize: (sw * 0.038).clamp(14.0, 16.0),
            fontWeight: FontWeight.w800,
            color: Colors.black87
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required double sw,
    required double sh,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF1A1A1A), size: sw * 0.07),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          style: TextStyle(
              fontFamily: MobileAppFonts.body,
              fontSize: (sw * 0.038).clamp(14.0, 16.0),
              color: Colors.black87,
              fontWeight: FontWeight.w600
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    int? maxLength,
    required double sw,
    required double sh,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: TextStyle(
            fontFamily: MobileAppFonts.body,
            fontSize: (sw * 0.038).clamp(14.0, 16.0),
            color: Colors.black87
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontFamily: MobileAppFonts.body,
              fontSize: (sw * 0.035).clamp(13.0, 15.0),
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500
          ),
          border: InputBorder.none,
          counterText: "",
          contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.02),
        ),
      ),
    );
  }
}