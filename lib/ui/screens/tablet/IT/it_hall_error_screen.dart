import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kAccent   = Color(0xFF4A6FD5);
const _kDark     = Color(0xFF0D1B4B);
const _kRoomText = Color(0xFF237ABA);
const _kBlack    = Color(0xFF030007); // all black text — bold

class _ErrorItem {
  final String room;
  final String desc;
  final String details;
  final String? imagePath;
  const _ErrorItem({
    required this.room,
    required this.desc,
    required this.details,
    this.imagePath,
  });
}

final _errors = [
  const _ErrorItem(
    room: 'A108',
    desc: "Projector isn't working",
    details:
    "Projector boots up then shows this blue screen only without any "
        "change even after restarting the projector",
    imagePath: 'assets/images/blue_screen_error.png',
  ),
  const _ErrorItem(
    room: 'A202',
    desc: "PC doesn't work",
    details:
    "The PC in room A202 powers on but fails to boot into Windows. "
        "Black screen after POST.",
  ),
  const _ErrorItem(
    room: 'B304',
    desc: "HDMI cable is missing",
    details:
    "The HDMI cable connecting the PC to the projector in B304 is "
        "missing. Needs replacement.",
  ),
];

class ITHallErrorScreen extends StatefulWidget {
  const ITHallErrorScreen({super.key});
  @override
  State<ITHallErrorScreen> createState() => _ITHallErrorScreenState();
}

class _ITHallErrorScreenState extends State<ITHallErrorScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;
    final sel = _errors[_selected];

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
                          child: Text('Hall Error',
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
                            children: _errors.asMap().entries.map((e) {
                              final idx   = e.key;
                              final item  = e.value;
                              final isSel = idx == _selected;
                              return GestureDetector(
                                onTap: () => setState(() => _selected = idx),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(bottom: h * 0.015),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: h * 0.016,
                                      vertical: h * 0.014),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? _kRoomText.withOpacity(0.08)
                                        : Colors.white.withOpacity(0.88),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? _kRoomText
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
                                            Icons.warning_amber_rounded,
                                            color: _kRoomText,
                                            size: h * 0.028),
                                      ),
                                      SizedBox(width: h * 0.012),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(item.room,
                                                style: GoogleFonts.inter(
                                                  fontSize: h * 0.022,
                                                  fontWeight: FontWeight.w700,
                                                  color: _kRoomText,
                                                )),
                                            // desc — black bold
                                            Text(item.desc,
                                                style: GoogleFonts.inter(
                                                  fontSize: h * 0.018,
                                                  fontWeight: FontWeight.w700,
                                                  color: _kBlack,
                                                )),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.attach_file_rounded,
                                          color: const Color(0xFF8892B0),
                                          size: h * 0.024),
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
                                      child: Icon(
                                          Icons.warning_amber_rounded,
                                          color: _kRoomText,
                                          size: h * 0.032),
                                    ),
                                    SizedBox(width: h * 0.014),
                                    // Room — #237ABA bold
                                    Text(sel.room,
                                        style: GoogleFonts.inter(
                                          fontSize: h * 0.030,
                                          fontWeight: FontWeight.w700,
                                          color: _kRoomText,
                                        )),
                                  ],
                                ),
                                SizedBox(height: h * 0.016),

                                // Description title — black bold
                                Text(sel.desc,
                                    style: GoogleFonts.inter(
                                      fontSize: h * 0.024,
                                      fontWeight: FontWeight.w700,
                                      color: _kBlack,
                                    )),
                                SizedBox(height: h * 0.016),

                                // Error image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: sel.imagePath != null
                                      ? Image.asset(
                                    sel.imagePath!,
                                    width: double.infinity,
                                    height: h * 0.26,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    width: double.infinity,
                                    height: h * 0.26,
                                    color: const Color(0xFFEEF2FF),
                                    child: Icon(
                                      Icons.monitor_rounded,
                                      color: _kRoomText.withOpacity(0.3),
                                      size: h * 0.08,
                                    ),
                                  ),
                                ),
                                SizedBox(height: h * 0.016),

                                // Details — black bold
                                Text(sel.details,
                                    style: GoogleFonts.inter(
                                      fontSize: h * 0.019,
                                      fontWeight: FontWeight.w700,
                                      color: _kBlack,
                                      height: 1.55,
                                    )),

                                const Spacer(),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      width: w * 0.14,
                                      height: h * 0.065,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5B9BD5),
                                            Color(0xFF6B6FD5),
                                          ],
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(
                                            color: _kAccent.withOpacity(0.35),
                                            blurRadius: 14,
                                            offset: const Offset(0, 6))],
                                      ),
                                      child: Center(
                                        child: Text('Fixed',
                                            style: GoogleFonts.inter(
                                              fontSize: h * 0.026,
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
}