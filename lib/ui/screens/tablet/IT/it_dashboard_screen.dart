import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'it_id_screen.dart';
import 'it_profile_screen.dart';
import 'it_hall_error_screen.dart';
import 'it_requests_screen.dart';

const _kAccent       = Color(0xFF4A6FD5);
const _kDark         = Color(0xFF0D1B4B);
const _kWelcomeColor = Color(0xFF0A4C7D);
const _kRoomColor    = Color(0xFF237ABA);
const _kDescColor    = Color(0xFF030007);

class ITDashboardScreen extends StatelessWidget {
  const ITDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h    = size.height;
    final w    = size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/rectangle_bg.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.025, vertical: h * 0.018),
                  child: Row(
                    children: [
                      Icon(Icons.grid_view_rounded,
                          color: _kDark, size: h * 0.038),
                      SizedBox(width: w * 0.015),
                      Expanded(
                        child: Center(
                          child: Text('Home',
                              style: GoogleFonts.inter(
                                fontSize: h * 0.028,
                                fontWeight: FontWeight.w600,
                                color: _kAccent,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: w * 0.025, vertical: h * 0.01),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT
                        SizedBox(
                          width: w * 0.38,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: h * 0.07, height: h * 0.07,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _kWelcomeColor.withOpacity(0.4),
                                      width: 2),
                                ),
                                child: Icon(Icons.person_outline_rounded,
                                    color: _kWelcomeColor, size: h * 0.042),
                              ),
                              SizedBox(height: h * 0.010),
                              // Welcome User — #0A4C7D bold
                              Text('Welcome User',
                                  style: GoogleFonts.inter(
                                    fontSize: h * 0.030,
                                    fontWeight: FontWeight.w700,
                                    color: _kWelcomeColor,
                                  )),
                              SizedBox(height: h * 0.02),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.88),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 20)],
                                  ),
                                  child: ListView(
                                    padding: EdgeInsets.all(h * 0.015),
                                    children: const [
                                      _NotifCard(room: 'A108', msg: "Projector isn't working"),
                                      _NotifCard(room: 'A202', msg: "PC doesn't work"),
                                      _NotifCard(room: 'B304', msg: "HDMI cable is missing"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: w * 0.025),

                        //RIGHT transparent glass grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: w * 0.022,
                            mainAxisSpacing: h * 0.025,
                            childAspectRatio: 1.10,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _GridCard(
                                icon: Icons.warning_amber_rounded,
                                label: 'Hall Error',
                                onTap: () => Navigator.push(context,
                                    _slide(const ITHallErrorScreen())),
                              ),
                              _GridCard(
                                icon: Icons.qr_code_2_rounded,
                                label: 'ID',
                                onTap: () => Navigator.push(context,
                                    _slide(const ITIDScreen())),
                              ),
                              _GridCard(
                                icon: Icons.lock_outline_rounded,
                                label: 'Requests',
                                onTap: () => Navigator.push(context,
                                    _slide(const ITRequestsScreen())),
                              ),
                              _GridCard(
                                icon: Icons.person_outline_rounded,
                                label: 'Profile',
                                onTap: () => Navigator.push(context,
                                    _slide(const ITProfileScreen())),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// NOTIFICATION CARD
class _NotifCard extends StatelessWidget {
  final String room;
  final String msg;
  const _NotifCard({required this.room, required this.msg});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.012),
      padding: EdgeInsets.symmetric(
          horizontal: h * 0.015, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE2F0), width: 1),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: h * 0.048, height: h * 0.048,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning_amber_rounded,
                color: _kRoomColor, size: h * 0.028),
          ),
          SizedBox(width: h * 0.012),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room number — #237ABA bold
                Text(room,
                    style: GoogleFonts.inter(
                      fontSize: h * 0.022,
                      fontWeight: FontWeight.w700,
                      color: _kRoomColor,
                    )),
                // Description — #030007 bold
                Text(msg,
                    style: GoogleFonts.inter(
                      fontSize: h * 0.018,
                      fontWeight: FontWeight.w700,
                      color: _kDescColor,
                    )),
              ],
            ),
          ),
          Icon(Icons.attach_file_rounded,
              color: const Color(0xFF8892B0), size: h * 0.024),
        ],
      ),
    );
  }
}

// GRID CARD
class _GridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GridCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withOpacity(0.60), width: 1.5),
          boxShadow: [BoxShadow(
              color: _kDark.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bigger icon — no background box
            Icon(icon, color: _kDark, size: h * 0.088),
            SizedBox(height: h * 0.014),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: h * 0.026,
                  fontWeight: FontWeight.w600,
                  color: _kDark,
                )),
          ],
        ),
      ),
    );
  }
}

PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween<Offset>(
        begin: const Offset(1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
    child: child,
  ),
  transitionDuration: const Duration(milliseconds: 350),
);