import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uninexus/model/hall_error_model.dart';
import 'package:uninexus/services/firebase/hall_error_service.dart';
import '../Student/stu_community.dart';
import '../settings_screen.dart';
import 'qa_screen.dart';
import '../profile_screen.dart';

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

  String? _selectedErrorType;
  String _base64Image = "";
  String _attachmentText = "Attach a photo if possible";
  bool _isUploading = false;
  int _selectedIndex = 1;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  final List<String> _errorTypes = ['Projector Issue', 'Air Conditioner', 'Lighting', 'Furniture/Desk', 'Other'];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
        _attachmentText = "Image Selected ✓";
      });
    }
  }

  Future<void> _submitReport() async {
    if (_hallNameController.text.isEmpty || _selectedErrorType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please provide Hall Name and Error Type"))
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final report = HallErrorModel(
        hallName: _hallNameController.text,
        errorType: _selectedErrorType!,
        description: _descriptionController.text,
        attachment: _base64Image, // Now matches the Model's parameter name
        timestamp: DateTime.now(),
      );

      // Now matches the Service's method name
      await _service.submitError(report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error Report Submitted!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _onNavBarTapped(int index) async {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index == 0) await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    else if (index == 1) Navigator.pop(context);
    else if (index == 2) await Navigator.push(context, MaterialPageRoute(builder: (context) => const QAScreen()));
    else if (index == 3) await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    if (mounted) setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/background.png'), fit: BoxFit.cover)),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 150),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildFormContainer(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())), child: Image.asset('assets/images/settings_1.png', width: 28, color: _mainPurple)),
        const Text("Hall Error", style: TextStyle(fontFamily: 'Batangas', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/LOGO.png', width: 36, height: 36)),
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
          boxShadow: [BoxShadow(color: const Color(0xFF237ABA).withOpacity(0.12), blurRadius: 25, offset: const Offset(0, 8))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Hall name"), const SizedBox(height: 8),
          _buildTextField(controller: _hallNameController, hint: "Submit the errored hall's name", icon: Icons.send_rounded),
          const SizedBox(height: 20),
          _buildLabel("Error Type"), const SizedBox(height: 8),
          _buildDropdown(),
          const SizedBox(height: 20),
          _buildLabel("Description"), const SizedBox(height: 8),
          _buildDescriptionField(),
          const SizedBox(height: 20),
          _buildLabel("Attachment"), const SizedBox(height: 8),
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedErrorType,
          hint: Text("Choose the error type", style: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400)),
          isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5C5C80), size: 30),
          items: _errorTypes.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontFamily: 'SpaceGrotesk')))).toList(),
          onChanged: (newValue) => setState(() => _selectedErrorType = newValue),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      height: 120, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: _descriptionController, maxLines: 5, style: const TextStyle(fontFamily: 'SpaceGrotesk'),
        decoration: InputDecoration.collapsed(hintText: "Submit your problem details", hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 220, height: 55,
      child: OutlinedButton(
        onPressed: _isUploading ? null : _submitReport,
        style: OutlinedButton.styleFrom(side: BorderSide(color: _mainPurple, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), backgroundColor: Colors.white),
        child: _isUploading
            ? CircularProgressIndicator(color: _mainPurple)
            : const Text("Submit", style: TextStyle(fontFamily: 'Batangas', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, IconData? icon, bool readOnly = false, VoidCallback? onIconTap}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller, readOnly: readOnly, style: const TextStyle(fontFamily: 'SpaceGrotesk'),
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: icon != null ? GestureDetector(onTap: onIconTap, child: Container(margin: const EdgeInsets.all(5), decoration: BoxDecoration(color: _mainPurple.withOpacity(0.8), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 24))) : null,
        ),
      ),
    );
  }

  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _mainPurple.withOpacity(0.6), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))]),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent, elevation: 0, shape: const CircleBorder(),
        child: Container(decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient), child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40))),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, -6))]),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(), notchMargin: 9.0, color: Colors.white, elevation: 0, height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildNavBarItem('assets/images/solidarity_1.png', "Community", 0), _buildNavBarItem('assets/images/classroom_1.png', "Halls", 1)])),
            const SizedBox(width: 72),
            Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildNavBarItem('assets/images/qa.png', "Q&A", 2), _buildNavBarItem('assets/images/user.png', "Profile", 3)])),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 28, height: 28, color: isSelected ? _mainPurple : Colors.grey.shade500),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 12, color: isSelected ? _mainPurple : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600)),
        ],
      ),
    );
  }
}