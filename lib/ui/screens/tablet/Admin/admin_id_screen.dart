import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/theme/app_theme.dart';
import '../../../../admin_tab.dart';
import 'package:uninexus/services/qr_generator_service.dart'; // Import your QR Obfuscation Service class

class AdminIdScreen extends StatefulWidget {
  final void Function(AdminTab) onNavigate;

  const AdminIdScreen({super.key, required this.onNavigate});

  @override
  State<AdminIdScreen> createState() => _AdminIdScreenState();
}

class _AdminIdScreenState extends State<AdminIdScreen> {
  String _userID = '';
  String _qrPayload = ''; // Holds the HMAC signed and XOR obfuscated string
  bool _isLoading = true;
  bool _isPunchedIn = false;
  Timer? _refreshTimer; // Periodically refreshes the dynamic token timestamp

  final Color _primaryBlue = const Color(0xFF237ABA);
  final Color _secondaryPurple = const Color(0xFF9C2CF3);

  @override
  void initState() {
    super.initState();
    _loadDataAndGenerateToken();

    // Automatically refresh the obfuscated token bytes every 15 seconds to keep timestamp valid
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_userID.isNotEmpty && _userID != 'N/A') {
        _generateCryptoToken();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Terminate background loop safely to prevent memory leaks
    super.dispose();
  }

  // Load user ID from preferences and calculate initial token
  Future<void> _loadDataAndGenerateToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    if (!mounted) return;

    setState(() {
      _userID = prefs.getString('userCode') ?? prefs.getString('ID') ?? 'N/A';
      _isLoading = false;
    });
    _generateCryptoToken();
  }

  /// Evaluates context punch state and signs it via your encryption service pipeline
  void _generateCryptoToken() {
    if (_userID.isEmpty || _userID == 'N/A') return;

    // Creates contextual baseline payload matching your state criteria
    final String rawContextData = _isPunchedIn ? "OUT_$_userID" : "IN_$_userID";

    setState(() {
      // Passes the conditional state string directly into the backend cryptosystem loop
      _qrPayload = QrGeneratorService.EmpgenerateQrData(rawContextData);
    });
  }

  // Handle punch in/out
  void _handlePunch() {
    setState(() {
      _isPunchedIn = !_isPunchedIn;
    });

    // Instantly recalculate the dynamic token payload structure upon toggling punch status
    _generateCryptoToken();

    showInfoSnackBar(
      context,
      _isPunchedIn ? 'Punched IN successfully' : 'Punched OUT successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ITScreenBackground(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: AppDecorations.idCardInner,
                          child: Row(
                            children: [
                              // Left decorative elements
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset(
                                    'assets/icons/Circle.png',
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Dot(),
                                  ),
                                  const SizedBox(height: 8),
                                  Image.asset(
                                    'assets/icons/Rectangle_Small.png',
                                    width: 20,
                                    height: 80,
                                    fit: BoxFit.fill,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 4,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Image.asset(
                                    'assets/icons/Circle.png',
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Dot(),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // ID icon
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: AppDecorations.iconBackground,
                                child: Image.asset(
                                  'assets/icons/ID_Card.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.badge_outlined,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              // QR Code with gradient
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
                                          // Swapped from raw string data to secure dynamic crypto pipeline payload
                                          data: _qrPayload.isNotEmpty ? _qrPayload : "Loading Identity...",
                                          version: QrVersions.auto,
                                          size: 240.0,
                                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.asset(
                                          'assets/images/LOGO.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Punch button
                        GestureDetector(
                          onTap: _handlePunch,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: _isPunchedIn
                                ? AppDecorations.pillButtonOutline()
                                : AppDecorations.pillButton(),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) => FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: child,
                                  ),
                                ),
                                child: Text(
                                  _isPunchedIn ? 'Punch OUT' : 'Punch IN',
                                  key: ValueKey(_isPunchedIn),
                                  style: AppTextStyles.buttonStyle,
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