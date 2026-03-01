import 'package:flutter/material.dart';
import 'package:uninexus/ui/screens/mobile/Faculty/halls_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import '../settings_screen.dart';
import 'qa_screen.dart';
import '../profile_screen.dart';

// Import NEW Model and Service
import '../../../../model/who_sent_model.dart';
import '../../../../services/firebase/who_sent_service.dart';

class WhoSentThisScreen extends StatefulWidget {
  final String senderId; // ID passed from the previous screen

  const WhoSentThisScreen({super.key, required this.senderId});

  @override
  State<WhoSentThisScreen> createState() => _WhoSentThisScreenState();
}

class _WhoSentThisScreenState extends State<WhoSentThisScreen> {
  final WhoSentService _whoSentService = WhoSentService();

  int _selectedIndex = 2;
  final Color _mainPurple = const Color(0xFF7B61FF);

  // Future to hold the fetched sender data
  late Future<WhoSentModel?> _senderFuture;

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    // Initialize the fetch
    _senderFuture = _whoSentService.getSenderById(widget.senderId);
  }

  void _onNavBarTapped(int index) async {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    } else if (index == 1) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const HallsScreen()));
    } else if (index == 2) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const QAScreen()));
    } else if (index == 3) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
    if (mounted) setState(() => _selectedIndex = 2);
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<WhoSentModel?>(
            future: _senderFuture,
            builder: (context, snapshot) {
              // 1. Loading State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: _mainPurple));
              }

              // 2. Error or No Data State
              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return _buildErrorView();
              }

              // 3. Success State
              final sender = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 150),
                child: Column(
                  children: [
                    _buildTopHeader(),
                    const SizedBox(height: 40),
                    _buildIDHeaderCard(sender),
                    const SizedBox(height: 24),
                    _buildDetailsCard(sender),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
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
        const Text(
            "Who sent this?",
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

  Widget _buildIDHeaderCard(WhoSentModel sender) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF9747FF),
            ),
            child: sender.photoUrl.isNotEmpty
                ? ClipOval(child: Image.network(sender.photoUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.person, color: Colors.white, size: 50)))
                : const Icon(Icons.person, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 12),
          // --- CHANGED: Now displays Full Name ---
          Text(
            sender.fullName.isNotEmpty ? sender.fullName : "Student Name",
            style: const TextStyle(
              fontFamily: 'Batangas',
              fontSize: 20, // Made it slightly larger
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(WhoSentModel sender) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mainPurple.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237ABA).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CHANGED: Now displays Student ID here ---
          _buildInfoField("Student ID :", sender.id),

          _buildInfoField("Faculty :", sender.faculty),
          _buildInfoField("Year :", _formatYear(sender.year)),
          _buildInfoField("E-mail :", sender.email),
          _buildInfoField("Phone no. :", sender.phone),
        ],
      ),
    );
  }
  String _formatYear(String year) {
    switch (year) {
      case '1': return "First";
      case '2': return "Second";
      case '3': return "Third";
      case '4': return "Fourth";
      default: return year;
    }
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Batangas',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: _mainPurple.withOpacity(0.3), thickness: 1),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 60, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text("Sender info not found", style: TextStyle(fontFamily: 'SpaceGrotesk', color: Colors.grey.shade600)),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Go Back", style: TextStyle(color: _mainPurple)))
        ],
      ),
    );
  }

  // --- GLOWING HOME FAB ---
  Widget _buildHomeFab() {
    return Container(
      height: 72, width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: _mainPurple.withOpacity(0.6), blurRadius: 25, spreadRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.transparent, elevation: 0, shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: _fabGradient),
          child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 40)),
        ),
      ),
    );
  }

  // --- BOTTOM NAVIGATION BAR ---
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, -6)),
        ],
      ),
      child: BottomAppBar(
        clipBehavior: Clip.antiAlias, shape: const CircularNotchedRectangle(), notchMargin: 9.0, color: Colors.white, elevation: 0, height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavBarItem('assets/images/solidarity_1.png', "Community", 0),
                  _buildNavBarItem('assets/images/classroom_1.png', "Halls", 1),
                ],
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem('assets/images/qa.png', "Q&A", 2),
                  _buildNavBarItem('assets/images/user.png', "Profile", 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? _mainPurple : Colors.grey.shade500;
    return GestureDetector(
      onTap: () => _onNavBarTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 28, height: 28, color: itemColor),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk', fontSize: 12, color: itemColor,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}