import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kAccent   = Color(0xFF4A6FD5);
const _kDark     = Color(0xFF0D1B4B);
const _kTypeClr  = Color(0xFF237ABA);  // Forgot-Password title
const _kBlack    = Color(0xFF030007);  // all black text — bold

class _Request {
  final String type;
  final String sender;
  final String id;
  final String email;
  final String year;
  final String faculty;
  bool accepted;

  _Request({
    required this.type,
    required this.sender,
    required this.id,
    required this.email,
    required this.year,
    required this.faculty,
    this.accepted = false,
  });
}

class ITRequestsScreen extends StatefulWidget {
  const ITRequestsScreen({super.key});
  @override
  State<ITRequestsScreen> createState() => _ITRequestsScreenState();
}

class _ITRequestsScreenState extends State<ITRequestsScreen> {
  final List<_Request> _requests = [
    _Request(
      type: 'Forgot-Password',
      sender: 'Moaz Osama',
      id: 'ST20222',
      email: 'MoazOsama@gmail.com',
      year: '4',
      faculty: 'ICT',
    ),
    _Request(
      type: 'Forgot-Password',
      sender: 'Eslam Dahy',
      id: 'ST20219',
      email: 'EslamDahy@gmail.com',
      year: '3',
      faculty: 'ICT',
    ),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;
    final sel = _requests[_selected];

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
                          child: Text('Requests',
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
                      children: [
                        // ── LEFT list ─────────────────────────────────
                        SizedBox(
                          width: w * 0.38,
                          child: Column(
                            children: _requests.asMap().entries.map((e) {
                              final idx   = e.key;
                              final req   = e.value;
                              final isSel = idx == _selected;
                              return GestureDetector(
                                onTap: () => setState(() => _selected = idx),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: h * 0.015),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: h * 0.016,
                                      vertical: h * 0.014),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? _kAccent.withOpacity(0.10)
                                        : Colors.white.withOpacity(0.88),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? _kAccent
                                          : const Color(0xFFDDE2F0),
                                      width: isSel ? 2 : 1,
                                    ),
                                    boxShadow: [BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 8)],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: h * 0.048,
                                        height: h * 0.048,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                            Icons.lock_outline_rounded,
                                            color: _kAccent,
                                            size: h * 0.028),
                                      ),
                                      SizedBox(width: h * 0.012),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            // Type — #237ABA bold
                                            Text(req.type,
                                                style: GoogleFonts.inter(
                                                  fontSize: h * 0.022,
                                                  fontWeight: FontWeight.w700,
                                                  color: _kTypeClr,
                                                )),
                                            // Sender — black bold
                                            Text('${req.sender} sent a request',
                                                style: GoogleFonts.inter(
                                                  fontSize: h * 0.018,
                                                  fontWeight: FontWeight.w700,
                                                  color: _kBlack,
                                                )),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        req.accepted
                                            ? Icons.check_circle_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: req.accepted
                                            ? Colors.green
                                            : const Color(0xFF8892B0),
                                        size: h * 0.028,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        SizedBox(width: w * 0.025),

                        // ── RIGHT detail card ─────────────────────────
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10))],
                            ),
                            padding: EdgeInsets.all(h * 0.030),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: h * 0.055,
                                      height: h * 0.055,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.lock_outline_rounded,
                                          color: _kAccent, size: h * 0.032),
                                    ),
                                    SizedBox(width: h * 0.014),
                                    // Type — #237ABA bold
                                    Text(sel.type,
                                        style: GoogleFonts.inter(
                                          fontSize: h * 0.028,
                                          fontWeight: FontWeight.w700,
                                          color: _kTypeClr,
                                        )),
                                  ],
                                ),
                                SizedBox(height: h * 0.022),

                                // Sender line — black bold
                                Text('${sel.sender} sent a request',
                                    style: GoogleFonts.inter(
                                      fontSize: h * 0.022,
                                      fontWeight: FontWeight.w700,
                                      color: _kBlack,
                                    )),
                                SizedBox(height: h * 0.016),

                                // Detail rows — labels black bold, values black bold
                                _row('ID', sel.id, h),
                                _row('Email', sel.email, h),
                                _row('Year', sel.year, h),
                                _row('Faculty', sel.faculty, h),

                                const Spacer(),

                                // Accept button — #237ABA
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => sel.accepted = true),
                                    child: Container(
                                      width: w * 0.16,
                                      height: h * 0.065,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF237ABA),
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(
                                            color: const Color(0xFF237ABA)
                                                .withOpacity(0.40),
                                            blurRadius: 14,
                                            offset: const Offset(0, 6))],
                                      ),
                                      child: Center(
                                        child: Text(
                                            sel.accepted ? 'Accepted ✓' : 'Accept',
                                            style: GoogleFonts.inter(
                                              fontSize: h * 0.024,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            )),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Detail row — label black bold, value black bold
  Widget _row(String label, String value, double h) => Padding(
    padding: EdgeInsets.only(bottom: h * 0.012),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: GoogleFonts.inter(
              fontSize: h * 0.021,
              fontWeight: FontWeight.w700,
              color: _kBlack,
            )),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(
                fontSize: h * 0.021,
                fontWeight: FontWeight.w700,
                color: _kBlack,
              )),
        ),
      ],
    ),
  );
}