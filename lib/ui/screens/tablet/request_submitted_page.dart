import 'package:flutter/material.dart';
import 'package:uninexus/theme/app_theme.dart';

class RequestSubmittedPage extends StatefulWidget {
  const RequestSubmittedPage({super.key});

  @override
  State<RequestSubmittedPage> createState() => _RequestSubmittedPageState();
}

class _RequestSubmittedPageState extends State<RequestSubmittedPage>
    with SingleTickerProviderStateMixin, PageEntryAnimation {

  @override
  void initState() {
    super.initState();
    // Initialize entry animation
    initPageAnimation(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // REMOVED replayPageAnimation() for consistency with other animated pages
  }

  @override
  void dispose() {
    disposePageAnimation(); // Clean up animation controller from the mixin
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [

          //  Background image – top-left (Animated)
          Positioned(
            left: -sw * 0.08, top: -sh * 0.12,
            child: FadeTransition(
              opacity: pageAnimController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(-0.3, -0.3), end: Offset.zero)
                    .animate(CurvedAnimation(parent: pageAnimController, curve: Curves.easeOutCubic)),
                child: Image.asset('assets/images_tab/rectangle_left.png',
                    width: sw * 0.50, height: sw * 0.60, fit: BoxFit.contain),
              ),
            ),
          ),

          // Background image – bottom-right (Animated)
          Positioned(
            right: -sw * 0.16, bottom: -sh * 0.16,
            child: FadeTransition(
              opacity: pageAnimController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.3, 0.3), end: Offset.zero)
                    .animate(CurvedAnimation(parent: pageAnimController, curve: Curves.easeOutCubic)),
                child: Image.asset('assets/images_tab/rectangle_right.png',
                    width: sw * 0.55, height: sw * 0.65, fit: BoxFit.contain),
              ),
            ),
          ),

          // Animated page content (slide-up + fade-in)
          animatedPageContent(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // Logo
                    animatedField(
                      anim: field1Anim,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset('assets/images_tab/logo2.png',
                            width: sw * 0.20, height: sw * 0.20, fit: BoxFit.contain),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Success headline
                    animatedField(
                      anim: field2Anim,
                      child: Text(
                        'Your Request Has Been Submitted',
                        style: AppTextStyles.requestSubmittedTitleStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // SUBTITLE
                    animatedField(
                      anim: field3Anim,
                      child: Text(
                        'For further questions or in case of any delay in\n'
                            'the fulfilling of your request please contact\n'
                            'the university department',
                        style: AppTextStyles.requestSubmittedBodyStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Back button
                    animatedField(
                      anim: checkAnim,
                      child: AppGradientButton(
                        text: 'Back',
                        // Pops back to the previous page
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}