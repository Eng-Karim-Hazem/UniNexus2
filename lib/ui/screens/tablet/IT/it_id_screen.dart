import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kAccent = Color(0xFF4A6FD5);
const _kDark = Color(0xFF0D1B4B);
const _kEmployeeClr = Color(0xFF0A4C7D);

const _punchInColors = [Color(0xFF6723BA), Color(0xFF0A4C7D)];
const _punchOutColors = [
  Color(0xFF6723BA),
  Color(0xFF6723BA),
  Color(0xFF0A4C7D)
];
const _punchOutStops = [0.01, 0.51, 0.97];

class ITIDScreen extends StatefulWidget {
  const ITIDScreen({super.key});

  @override
  State<ITIDScreen> createState() => _ITIDScreenState();
}

class _ITIDScreenState extends State<ITIDScreen> {
  bool _punchedIn = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/rectangle_bg.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                // TOPBAR
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.025, vertical: h * 0.018),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: _kDark,
                          size: h * 0.038,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'ID',
                            style: GoogleFonts.inter(
                              fontSize: h * 0.028,
                              fontWeight: FontWeight.w600,
                              color: _kAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Main Content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar
                        Container(
                          width: h * 0.095,
                          height: h * 0.095,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _kEmployeeClr.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: _kEmployeeClr,
                            size: h * 0.058,
                          ),
                        ),

                        // Glass Card
                        Transform.translate(
                          offset: Offset(0, -(h * 0.025)),
                          child: Container(
                            width: w * 0.42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.55),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _kAccent.withOpacity(0.10),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(
                              w * 0.025,
                              h * 0.045,
                              w * 0.025,
                              h * 0.028,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Employee Name
                                Text(
                                  'Employee Name',
                                  style: GoogleFonts.inter(
                                    fontSize: h * 0.026,
                                    fontWeight: FontWeight.w700,
                                    color: _kEmployeeClr,
                                  ),
                                ),
                                SizedBox(height: h * 0.005),

                                // ID Number
                                Text(
                                  'ID Number',
                                  style: GoogleFonts.inter(
                                    fontSize: h * 0.021,
                                    fontWeight: FontWeight.w500,
                                    color:
                                    _kEmployeeClr.withOpacity(0.80),
                                  ),
                                ),
                                SizedBox(height: h * 0.022),

                                // QR Code
                                Container(
                                  width: h * 0.26,
                                  height: h * 0.26,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _kAccent
                                            .withOpacity(0.10),
                                        blurRadius: 12,
                                        offset:
                                        const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding:
                                  const EdgeInsets.all(6),
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/qr_code.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.022),

                        // Punch Button
                        AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 300),
                          width: w * 0.18,
                          height: h * 0.055,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _punchedIn
                                  ? _punchOutColors
                                  : _punchInColors,
                              stops: _punchedIn
                                  ? _punchOutStops
                                  : null,
                            ),
                            borderRadius:
                            BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6723BA)
                                    .withOpacity(0.38),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius:
                            BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius:
                              BorderRadius.circular(30),
                              onTap: () {
                                setState(() {
                                  _punchedIn = !_punchedIn;
                                });
                              },
                              child: Center(
                                child: Text(
                                  _punchedIn
                                      ? 'Punch Out'
                                      : 'Punch IN',
                                  style: GoogleFonts.inter(
                                    fontSize: h * 0.022,
                                    fontWeight:
                                    FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
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