import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/model/community_model.dart';
import 'package:uninexus/services/firebase/community_service.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';

import '../settings_screen.dart';
import 'stu_schedule.dart';
import '../profile_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';



class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() => _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final int _selectedIndex = 0;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  // --- ADDED SERVICE AND LOADING STATE ---
  final _communityService = CommunityService();
  bool _isLoading = false;

  // Role-based logic variables
  bool _isStudent = true;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final String id = prefs.getString('ID') ?? "";
    if (mounted) {
      setState(() {
        // Assume student unless ID starts with 'FA' (Faculty)
        _isStudent = !id.toUpperCase().startsWith('FA');
      });
    }
  }

  // --- ADDED SUBMIT FUNCTIONALITY ---
  Future<void> _submitPost() async {
    // 1. Validation
    if (_titleController.text.trim().isEmpty || _questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in both Title and Question fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Get User Data
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userCode') ?? prefs.getString('ID') ?? 'unknown_id';

      // Determine Role based on ID prefix
      bool isFaculty = userId.toUpperCase().startsWith('FA');
      String detectedRole = isFaculty ? 'Faculty' : 'Student';
      String faculty = prefs.getString('userFaculty') ?? 'General';

      // 3. Fetch Name (Robust Logic)
      String fName = prefs.getString('fName') ?? prefs.getString('userFirstName') ?? '';
      String lName = prefs.getString('lName') ?? prefs.getString('userLastName') ?? '';

      // If missing locally, fetch from Firestore
      if (fName.isEmpty && userId.isNotEmpty) {
        try {
          if (isFaculty) {
            var doc = await FirebaseFirestore.instance.collection('faculty').doc(userId).get();
            if (doc.exists) {
              fName = doc.data()?['fName'] ?? '';
              lName = doc.data()?['lName'] ?? '';
            }
          } else {
            var doc = await FirebaseFirestore.instance.collection('students').doc(userId).get();
            if (doc.exists) {
              fName = doc.data()?['fName'] ?? '';
              lName = doc.data()?['lName'] ?? '';
            }
          }
        } catch (e) {
          debugPrint("Error fetching user name: $e");
        }
      }

      // 4. Format Display Name
      String displayName = "$fName $lName".trim();

      if (displayName.isEmpty) {
        displayName = isFaculty ? 'Faculty Member' : 'Student';
      } else {
        if (isFaculty) {
          displayName = "Dr. $displayName";
        }
      }

      // 5. Create Model
      CommunityPostModel newPost = CommunityPostModel(
        userId: userId,
        userName: displayName, // Saves "Dr. Abdo..." or "Karim..."
        userRole: detectedRole,
        userFaculty: faculty,
        title: _titleController.text.trim(),
        content: _questionController.text.trim(),
        timestamp: DateTime.now(),
        replyCount: 0,
      );

      // 6. Call Service
      await _communityService.createPost(newPost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post Submitted Successfully!", style: TextStyle(fontFamily: 'SpaceGrotesk')))
        );
        Navigator.pop(context); // Go back to Community Feed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onNavBarTapped(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      // Logic for second icon based on role
      Widget target = _isStudent ? const StuSchedule() : const HallsScreen();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
    } else if (index == 2) {
      // Logic for Q&A based on role
      Widget target = _isStudent ? const StuQAScreen() : const QAScreen();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _isStudent ? _buildStudentBottomBar() : _buildFacultyBottomBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                _buildTopHeader(),

                // --- INCREASED SPACING HERE TO PUSH THE BOX DOWN ---
                const SizedBox(height: 70),

                _buildFormContainer(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // --- ADDED NAVIGATION HERE ---
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

        const Text(
            "Community",
            style: TextStyle(
                fontFamily: 'Batangas',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C5C80)
            )
        ),

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
        border: Border.all(color: _mainPurple.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Title", style: TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontFamily: 'SpaceGrotesk'),
              decoration: InputDecoration(
                hintText: "Submit a title max one sentence..",
                hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Question", style: TextStyle(fontFamily: 'Batangas', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _questionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontFamily: 'SpaceGrotesk'),
              decoration: InputDecoration(
                hintText: "Submit your Question maximum 250 letters...",
                hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 220,
      height: 55,
      child: OutlinedButton(
        // --- UPDATED ON PRESSED ---
        onPressed: _isLoading ? null : _submitPost,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
        ),
        // --- ADDED LOADING INDICATOR ---
        child: _isLoading
            ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: _mainPurple, strokeWidth: 2.5)
        )
            : Text(
          "Submit",
          style: TextStyle(
            fontFamily: 'Batangas',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _mainPurple,
          ),
        ),
      ),
    );
  }

  // --- GLOWING FAB ---
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
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [_primaryBlue, _mainPurple]),
          ),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  // --- BOTTOM NAVIGATION BARS WITH NATIVE CUTOUT SHADOW ---

  Widget _buildStudentBottomBar() {
    return _bottomNavWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem('assets/images/solidarity_1.png', 'Community', 0),
                _navItem('assets/images/calendar.png', 'Schedule', 1),
              ],
            ),
          ),
          const SizedBox(width: 72), // Space for the FAB notch
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', 'Q&A', 2),
                _navItem('assets/images/user.png', 'Profile', 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyBottomBar() {
    return _bottomNavWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem('assets/images/solidarity_1.png', 'Community', 0),
                _navItem('assets/images/classroom_1.png', 'Halls', 1),
              ],
            ),
          ),
          const SizedBox(width: 72), // Space for the FAB notch
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem('assets/images/qa.png', 'Q&A', 2),
                _navItem('assets/images/user.png', 'Profile', 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavWrapper({required Widget child}) {
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        height: 80,
        child: child,
      ),
    );
  }

  Widget _navItem(String path, String label, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            path,
            width: 28,
            height: 28,
            color: sel ? _mainPurple : Colors.grey.shade500,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 12,
              color: sel ? _mainPurple : Colors.grey.shade600,
              fontWeight: sel ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}