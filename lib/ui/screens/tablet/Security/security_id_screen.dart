import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class SecurityIdScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const SecurityIdScreen({super.key, required this.onNavigate});

  @override
  State<SecurityIdScreen> createState() => _SecurityIdScreenState();
}

class _SecurityIdScreenState extends State<SecurityIdScreen> {
  String _userID = "";
  bool _isLoading = true;
  bool _isPunchedIn = false;

  // Colors from Faculty screen for the QR Shader
  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _secondaryPurple = const Color(0xFF9C2CF3);

  @override
  void initState() {
    super.initState();
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    if (mounted) {
      setState(() {
        _userID = prefs.getString('userCode') ?? prefs.getString('ID') ?? "N/A";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ITScreenBackground(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Dynamic QR Data: Appends .in or .out
    final String qrData = _isPunchedIn ? "$_userID.in" : "$_userID.out";

    // Dynamic QR Colors for the ShaderMask
    final List<Color> qrColors = _isPunchedIn
        ? [_secondaryPurple, _primaryBlue]
        : [_primaryBlue, _secondaryPurple];

    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('ID'),
            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: SizedBox(
                    width: 480,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Digital ID Card (UI Preserved)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: AppDecorations.idCardInner,
                          child: Row(
                            children: [
                              /// Left decorations (Ellipse & Rectangle)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/icons/Ellipse 3 (1).png', width: 28, height: 28),
                                  const SizedBox(height: 8),
                                  Image.asset('assets/icons/Rectangle 25 (1).png', width: 20, height: 80, fit: BoxFit.fill),
                                  const SizedBox(height: 8),
                                  Image.asset('assets/icons/Ellipse 3 (1).png', width: 28, height: 28),
                                ],
                              ),
                              const SizedBox(width: 16),

                              /// ID card icon
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: AppDecorations.iconBackground,
                                child: Image.asset('assets/images/id_card.png', width: 40, height: 40),
                              ),
                              const SizedBox(width: 24),

                              /// QR with ShaderMask and Dynamic Suffix (.in/.out)
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: qrColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          version: QrVersions.auto,
                                          size: 240.0,
                                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.asset('assets/images/LOGO.png', fit: BoxFit.contain),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        /// Static Style Button / Toggleable Text
                        GestureDetector(
                          onTap: () {
                            setState(() => _isPunchedIn = !_isPunchedIn);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            // Decoration remains static (Outline style)
                            decoration: AppDecorations.pillButtonOutline(),
                            child: Center(
                              child: Text(
                                _isPunchedIn ? 'Punch OUT' : 'Punch IN', // Toggles text
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}