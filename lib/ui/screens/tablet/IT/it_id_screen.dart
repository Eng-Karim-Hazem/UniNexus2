import 'package:flutter/material.dart';
import 'package:uninexus/theme/uninexus_tab.dart';
import 'package:uninexus/theme/app_theme.dart';

class ITIdScreen extends StatefulWidget {
  final void Function(UninexusTab) onNavigate;
  const ITIdScreen({super.key, required this.onNavigate});

  @override
  State<ITIdScreen> createState() => _ITIdScreenState();
}

class _ITIdScreenState extends State<ITIdScreen> {
  bool _isPunchedIn = false;

  @override
  Widget build(BuildContext context) {
    return ITScreenBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ID', style: AppTextStyles.largeHeading),
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
                        // ID card inner
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: AppDecorations.idCardInner,
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/icons/Ellipse 3 (1).png',
                                      width: 28, height: 28, fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Dot()),
                                  const SizedBox(height: 8),
                                  Image.asset('assets/icons/Rectangle 25 (1).png',
                                      width: 20, height: 80, fit: BoxFit.fill,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 4, height: 80,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.35),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      )),
                                  const SizedBox(height: 8),
                                  Image.asset('assets/icons/Ellipse 3 (1).png',
                                      width: 28, height: 28, fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Dot()),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: AppDecorations.iconBackground,
                                child: Image.asset('assets/images/id_card.png',
                                    width: 40, height: 40, fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.badge_outlined, size: 40,
                                        color: AppColors.primary)),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(
                                      'assets/images/qr_new.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        decoration: AppDecorations.qrPlaceholder,
                                        child: const Center(
                                          child: Icon(Icons.qr_code_2,
                                              size: 100, color: AppColors.primary),
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Punch IN / OUT button
                        GestureDetector(
                          onTap: () => setState(() => _isPunchedIn = !_isPunchedIn),
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