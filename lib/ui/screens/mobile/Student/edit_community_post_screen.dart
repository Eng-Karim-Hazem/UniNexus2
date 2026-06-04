import 'package:flutter/material.dart';
import 'package:uninexus/theme/mobile_app_theme.dart';
import 'package:uninexus/model/community_model.dart';
import 'package:uninexus/services/firebase/community_service.dart';

class EditCommunityPostScreen extends StatefulWidget {
  final CommunityPostModel post; // We pass the post data in!

  const EditCommunityPostScreen({super.key, required this.post});

  @override
  State<EditCommunityPostScreen> createState() => _EditCommunityPostScreenState();
}

class _EditCommunityPostScreenState extends State<EditCommunityPostScreen> {
  final Color _mainPurple = const Color(0xFF7B61FF);
  final _communityService = CommunityService();

  late TextEditingController _titleController;
  late TextEditingController _questionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text fields with the existing post data
    _titleController = TextEditingController(text: widget.post.title);
    _questionController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    if (_titleController.text.trim().isEmpty || _questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fields cannot be empty", style: TextStyle(fontFamily: MobileAppFonts.body))));
      return;
    }

    // Check if they actually changed anything before wasting a Firebase write
    if (_titleController.text.trim() == widget.post.title &&
        _questionController.text.trim() == widget.post.content) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _communityService.updatePost(
          widget.post.id,
          _titleController.text.trim(),
          _questionController.text.trim()
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/Phone_Background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
                      ),
                    ),
                    const Text("Edit Post", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C5C80))),
                    const SizedBox(width: 40), // Spacer to center the title
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(24, 10, 24, keyboardHeight > 0 ? keyboardHeight + 20 : 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildFormContainer(),
                      const SizedBox(height: 40),
                      _buildUpdateButton(),
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

  Widget _buildFormContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Title", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontFamily: MobileAppFonts.body),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Question", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 250,
            decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _questionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontFamily: MobileAppFonts.body),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: 220, height: 55,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _updatePost,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        child: _isLoading
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2.5))
            : Text("Save Changes", style: TextStyle(fontFamily: MobileAppFonts.heading, fontSize: 18, fontWeight: FontWeight.bold, color: _mainPurple)),
      ),
    );
  }
}