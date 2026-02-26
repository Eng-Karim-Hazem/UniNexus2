import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kAccent = Color(0xFF4A6FD5);
const _kDark   = Color(0xFF0D1B4B);
const _kBlack  = Color(0xFF030007); // all black text — bold

class ITProfileScreen extends StatelessWidget {
  const ITProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/rectangle_bg.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.025, vertical: h * 0.018),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.grid_view_rounded,
                            color: _kDark, size: h * 0.038),
                      ),
                      Expanded(
                        child: Center(
                          child: Text('Profile',
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
                  child: Center(
                    child: Container(
                      width: w * 0.46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 28,
                            offset: const Offset(0, 10))],
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: w * 0.028, vertical: h * 0.040),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar + Name — black bold
                          Row(
                            children: [
                              Container(
                                width: h * 0.09, height: h * 0.09,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _kAccent.withOpacity(0.4),
                                      width: 2),
                                ),
                                child: Icon(Icons.person_outline_rounded,
                                    color: _kAccent, size: h * 0.055),
                              ),
                              SizedBox(width: w * 0.015),
                              Text('Hi Ammor!',
                                  style: GoogleFonts.inter(
                                    fontSize: h * 0.030,
                                    fontWeight: FontWeight.w700,
                                    color: _kBlack,
                                  )),
                            ],
                          ),
                          SizedBox(height: h * 0.030),

                          _infoRow('ID Number', 'ST20222', h),
                          _divider(),
                          _infoRow('Email', 'ammor@uni.edu', h),
                          _divider(),
                          _infoRow('Faculty', 'ICT', h),
                          _divider(),
                          _infoRow('Year', '4', h),
                          _divider(),
                          _infoRow('Phone Number', '+20 100 000 0000', h),
                        ],
                      ),
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

  // Label — black bold / Value — black bold
  Widget _infoRow(String label, String value, double h) => Padding(
    padding: EdgeInsets.symmetric(vertical: h * 0.014),
    child: Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: GoogleFonts.inter(
                fontSize: h * 0.022,
                fontWeight: FontWeight.w700,
                color: _kBlack,
              )),
        ),
        Text(value,
            style: GoogleFonts.inter(
              fontSize: h * 0.022,
              fontWeight: FontWeight.w700,
              color: _kBlack,
            )),
      ],
    ),
  );

  Widget _divider() =>
      const Divider(color: Color(0xFFEEF0F8), thickness: 1, height: 1);
}