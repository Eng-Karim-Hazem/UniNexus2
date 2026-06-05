import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uninexus/model/hall_error_model.dart';
import 'package:uninexus/services/firebase/hall_error_service.dart';
import '../Student/stu_community.dart';
import 'qa_screen.dart';
import '../profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_home.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/faculty_home_screen.dart';

class HallErrorScreen extends StatefulWidget {
  const HallErrorScreen({super.key});

  @override
  State<HallErrorScreen> createState() => _HallErrorScreenState();
}

class _HallErrorScreenState extends State<HallErrorScreen> {
  final TextEditingController _hallNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final HallErrorService _service = HallErrorService();
  final ImagePicker _picker = ImagePicker();

  String? _selectedBuilding;
  String? _selectedDepartment;
  String? _selectedErrorType;
  String _base64Image = "";
  String _attachmentText = "Attach a photo (Required)";
  bool _isUploading = false;
  int _selectedIndex = 1;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _textIndigo = const Color(0xFF5C5C80);
  final Color _primaryBlue = const Color(0xFF237ABA);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final List<String> _buildings = ['A', 'B', 'C'];
  final List<String> _departments = ['IT', 'Storage', 'Maintenance'];
  final List<String> _errorTypes = ['Projector Issue', 'Air Conditioner', 'Lighting', 'Furniture/Desk', 'Other'];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,  // <-- ADD THIS
      maxHeight: 800, // <-- ADD THIS
    );
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      if (mounted) {
        setState(() {
          _base64Image = base64Encode(bytes);
          _attachmentText = "Image Selected ✓";
        });
      }
    }
  }

  // Helper function to show floating SnackBars that don't break the FAB layout
  void _showFloatingSnackBar(String message, Color color) {
    final sh = MediaQuery.of(context).size.height; // Get dynamic screen height

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: MobileAppFonts.body, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        // Pushes it exactly 78% up the screen, adapting perfectly to any phone size
        margin: EdgeInsets.only(
          bottom: sh * 0.01,
          left: 20,
          right: 20,
        ),
        // Rounds the corners for a cleaner notification look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    // --- ADD THIS LINE TO DROP THE KEYBOARD ---
    FocusScope.of(context).unfocus();

    // 1. Check all basic dropdowns and hall name
    if (_hallNameController.text.isEmpty || _selectedErrorType == null || _selectedDepartment == null || _selectedBuilding == null) {
      _showFloatingSnackBar("Please fill in Building, Hall Name, Department, and Error Type", Colors.redAccent);
      return;
    }

    // 2. Check if a description was provided
    if (_descriptionController.text.trim().isEmpty) {
      _showFloatingSnackBar("Please provide a description of the error to help with debugging.", Colors.redAccent);
      return;
    }

    // 3. Check if an attachment was uploaded
    if (_base64Image.isEmpty) {
      _showFloatingSnackBar("Please attach a photo of the issue.", Colors.redAccent);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final String building = _selectedBuilding!;
      final String hallCode = _hallNameController.text.trim();
      final String fullHallLocation = "Building $building - $hallCode";

      // --- 1. VERIFY THE HALL ACTUALLY EXISTS ON CAMPUS ---
      bool hallExists = await _service.doesHallExist(building, hallCode);

      if (!hallExists) {
        if (mounted) {
          _showFloatingSnackBar("This hall does not exist on campus. Please check the building and number.", Colors.redAccent);
          setState(() => _isUploading = false);
        }
        return;
      }

      // --- 2. CHECK IF ERROR ALREADY EXISTS ---
      bool isDuplicate = await _service.isErrorAlreadyReported(fullHallLocation, _selectedErrorType!);

      if (isDuplicate) {
        if (mounted) {
          _showFloatingSnackBar("This issue has already been reported for this hall!", Colors.orange);
          setState(() => _isUploading = false);
        }
        return;
      }

      // --- 3. SUBMIT THE ERROR ---
      final report = HallErrorModel(
        hallName: fullHallLocation,
        department: _selectedDepartment!,
        errorType: _selectedErrorType!,
        description: _descriptionController.text,
        attachment: _base64Image,
        timestamp: DateTime.now(),
      );

      await _service.submitError(
          report,
          _selectedBuilding!,
          _hallNameController.text.trim()
      );

      if (mounted) {
        _showFloatingSnackBar("Error Report Submitted!", Colors.green);
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) _showFloatingSnackBar("Error: $e", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _onNavBarTapped(int index) async {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    final Map<int, Widget> routes = {
      0: const StuCommunity(),
      2: const QAScreen(),
      3: const ProfileScreen(),
    };
    if (index == 1) {
      Navigator.pop(context);
    } else if (routes.containsKey(index)) {
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => routes[index]!));
    }
    if (mounted) setState(() => _selectedIndex = 1);
  }

  Future<void> _goHome() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('ID') ?? '';

    Widget targetHome;
    if (userId.toUpperCase().startsWith('FA')) {
      targetHome = const FacultyHomeScreen();
    } else {
      targetHome = const StuHomeScreen();
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetHome),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    // --- ADDED: Track keyboard height ---
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/Phone_Background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  // --- THE FIX: Dynamic bottom padding ---
                  padding: EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    keyboardHeight > 0
                        ? keyboardHeight + 20
                        : MediaQuery.of(context).padding.bottom + 140.0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildFormContainer(),
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
          ),
        ),
        Text("Hall Error",
            style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: _textIndigo)),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildFormContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _mainPurple.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(color: _primaryBlue.withOpacity(0.12), blurRadius: 25, offset: const Offset(0, 8))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Building"),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedBuilding,
                      hint: "Bld",
                      items: _buildings,
                      onChanged: (val) => setState(() => _selectedBuilding = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Hall Name"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _hallNameController,
                      hint: "123",
                      isNumberOnly: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel("Designated To"),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedDepartment,
            hint: "Choose Department",
            items: _departments,
            onChanged: (val) => setState(() => _selectedDepartment = val),
          ),
          const SizedBox(height: 20),
          _buildLabel("Error Type"),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedErrorType,
            hint: "Choose Error Type",
            items: _errorTypes,
            onChanged: (val) => setState(() => _selectedErrorType = val),
          ),
          const SizedBox(height: 20),
          _buildLabel("Description"),
          const SizedBox(height: 8),
          _buildDescriptionField(),
          const SizedBox(height: 20),
          _buildLabel("Attachment"),
          const SizedBox(height: 8),
          _buildTextField(
            controller: TextEditingController(text: _base64Image.isNotEmpty ? "Image Attached" : ""),
            hint: _attachmentText,
            icon: Icons.add_rounded,
            readOnly: true,
            onIconTap: _pickImage,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String? value, required String hint, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey.shade400, fontSize: 14)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textIndigo, size: 28),
          items: items.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val, style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14),
        decoration: InputDecoration.collapsed(
          hintText: "Submit your problem details (Required)",
          hintStyle: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey.shade400, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 220,
      height: 55,
      child: OutlinedButton(
        onPressed: _isUploading ? null : _submitReport,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        child: _isUploading
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2.5))
            : Text("Submit",
            style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 18, fontWeight: FontWeight.bold, color: _mainPurple)),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onIconTap,
    bool isNumberOnly = false,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumberOnly ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumberOnly ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ] : null,
        style: const TextStyle(fontFamily: MobileAppFonts.body, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: MobileAppFonts.body, color: Colors.grey.shade400),
          border: InputBorder.none,
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: icon != null
              ? GestureDetector(
              onTap: onIconTap,
              child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _mainPurple.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: Colors.white, size: 22)))
              : null,
        ),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _mainPurple.withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: FloatingActionButton(
        onPressed: _goHome,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        notchMargin: 9.0,
        color: Colors.white,
        elevation: 0,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavSection([
              _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
              _buildNavBarItem('assets/images/classroom_1.png', "Halls", 1),
            ]),
            const SizedBox(width: 72),
            _buildNavSection([
              _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
              _buildNavBarItem('assets/images/user.png', "Profile", 3),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavSection(List<Widget> items) =>
      Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade500;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 28, height: 28, color: itemColor),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                fontFamily: MobileAppFonts.body,
                fontSize: 12,
                color: itemColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}