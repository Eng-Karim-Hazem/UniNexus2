import 'package:flutter/material.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_community.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_qa_screen.dart';
import 'package:uninexus/ui/screens/mobile/Student/stu_schedule.dart';
import 'package:uninexus/ui/screens/mobile/profile_screen.dart';


class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 4; // Default rating

  // No specific index highlighted
  final int _selectedIndex = -1;

  final Color _mainPurple = const Color(0xFF7B61FF);
  final Color _primaryBlue = const Color(0xFF237ABA);

  final Gradient _fabGradient = const LinearGradient(
    colors: [Color(0xFF237ABA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  void _onNavBarTapped(int index) async {
    if (index == 0) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuCommunity()));
    } else if (index == 1) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuSchedule()));
    } else if (index == 2) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const StuQAScreen()));
    } else if (index == 3) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 150),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildFormCard(),
                const SizedBox(height: 40),
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
        // Back Button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: _mainPurple),
        ),

        const Text(
          "Feedback",
          style: TextStyle(
            fontFamily: 'Batangas',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C5C80),
          ),
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/LOGO.png', width: 36, height: 36),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This feature is used to express your experience with our system till this moment and maybe drop some notes to make the journey more smooth.",
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),

          // Rating Section
          _buildLabel("Rate our app"),
          const SizedBox(height: 8),
          _buildStarRating(),

          const SizedBox(height: 20),

          // Question/Feedback Input
          _buildLabel("Question"),
          const SizedBox(height: 8),
          Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: 6,
              maxLength: 250,
              style: const TextStyle(fontFamily: 'SpaceGrotesk'),
              decoration: InputDecoration(
                hintText: "Submit your Question maximum 250 letters...",
                hintStyle: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    color: Colors.grey.shade400,
                    fontSize: 13
                ),
                border: InputBorder.none,
                counterStyle: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Batangas',
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.star_rounded,
              size: 40,
              color: index < _rating ? const Color(0xFF7B61FF) : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 200,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Feedback Submitted! Thank you.")),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _mainPurple, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        child: Text(
          "Submit",
          style: TextStyle(
            fontFamily: 'Batangas',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _mainPurple,
          ),
        ),
      ),
    );
  }

  // --- GLOWING HOME FAB ---
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
            gradient: _fabGradient,
          ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem('assets/images/solidarity_1.png', "Community", 0),
                  _navItem('assets/images/calendar.png', "Schedule", 1),
                ],
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem('assets/images/qa.png', "Q&A", 2),
                  _navItem('assets/images/user.png', "Profile", 3),
                ],
              ),
            ),
          ],
        ),
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