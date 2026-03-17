import 'dart:ui';
import 'package:flutter/material.dart';


//  COLORS

class AppColors {
  // Base colors
  static const Color primary        = Color(0xFF696BD5);
  static const Color background     = Color(0xFFF8F9FF);
  static const Color white          = Colors.white;

  // Sidebar gradient
  static const Color sidebarStart   = Color(0xFF7C7EE6);
  static const Color sidebarMid     = Color(0xFF8192F0);
  static const Color sidebarEnd     = Color(0xFFAD92FF);

  // Text colors
  static const Color textDark       = Color(0xFF222222);
  static const Color textMid        = Color(0xFF555555);
  static const Color textLight      = Color(0xFF888888);
  static const Color textHint       = Color(0xFFB0B8C1);

  // Borders
  static const Color cardBorder     = Color(0x1A696BD5);
  static const Color divider        = Color(0x1F696BD5);

  // Accent colors
  static const Color alertOrange    = Color(0xFFFF6B35);
  static const Color blueAccent     = Color(0xFF4DB8FF);

  // Glass effect
  static const Color glassWhite     = Color(0xCCFFFFFF);
  static const Color glassLavender  = Color(0xAAE8EAFF);

  // Input fields
  static const Color lightGreyStart = Color(0xFFF3F4F6);
  static const Color lightGreyEnd   = Color(0xFFE5E7EB);

  // Profile info divider stroke
  static const Color infoDivider    = Color(0xFF32006C);

  // Gradients
  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.62, 1.0],
    colors: [sidebarStart, sidebarMid, sidebarEnd],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF818CF8), Color(0xFF38BDF8)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassWhite, glassLavender],
  );

  static const LinearGradient lightGreyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreyStart, lightGreyEnd],
  );
}


//  FONTS

class AppFonts {
  static const String batangas     = 'Batangas';
  static const String spaceGrotesk = 'SpaceGrotesk';
}


//  TEXT STYLES

class AppTextStyles {
  // Headings
  static const TextStyle largeHeading = TextStyle(
    fontSize: 48, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle heading = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle subheading = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.primary,
  );
  static const TextStyle buttonStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.primary,
  );
  static const TextStyle buttonWhiteStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: Colors.white,
  );
  static const TextStyle buttonSmallStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.primary,
  );
  static const TextStyle gradientButtonLabel = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: Colors.white, letterSpacing: 0.4,
  );
  static const TextStyle sidebarLabel = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: Colors.white, height: 1.2,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textMid,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textMid,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textLight,
  );
  static const TextStyle labelStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textDark,
  );

  // Profile screen
  static const TextStyle profileHeaderNameStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle profileHeaderIdStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.textLight,
  );
  static const TextStyle profileInfoLabelStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textDark,
  );
  static const TextStyle profileInfoValueStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w500,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textMid,
  );
  static const TextStyle greetingNameStyle = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle greetingSubStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textLight,
  );
  static const TextStyle dateStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.primary,
  );
  static const TextStyle viewAllStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.primary,
  );

  // Logs screen
  static const TextStyle logTextStyle = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w500,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textDark,
  );
  static const TextStyle logTimeStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textLight,
  );

  // Announcements screen
  static const TextStyle announcementSenderStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.primary,
  );
  static const TextStyle announcementMessageStyle = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textMid,
  );
  static const TextStyle senderStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.primary,
  );
  static const TextStyle senderSmallStyle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.primary,
  );
  static const TextStyle chartLabelStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle chartSublabelStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textLight,
  );
  static const TextStyle statValueStyle = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textDark, height: 1.1,
  );
  static const TextStyle statLabelStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textLight, height: 1.3,
  );
  static const TextStyle statSublabelStyle = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w400,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textLight, height: 1.2,
  );

  // Hall errors screen
  static const TextStyle hallListNumberStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.primary,
  );
  static const TextStyle hallListErrorStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w500,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textMid,
  );
  static const TextStyle hallDetailsNumberStyle = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.primary,
  );
  static const TextStyle hallDetailsErrorStyle = TextStyle(
    fontSize: 25, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle hallDetailsDescriptionStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w500,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textMid, height: 1.5,
  );

  // Requests screen
  static const TextStyle requestListTitleStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.primary,
  );
  static const TextStyle requestListNameStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textMid,
  );
  static const TextStyle requestDetailsHeaderStyle = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.primary,
  );
  static const TextStyle requestDetailsLabelStyle = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle requestDetailsNameStyle = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle requestDetailsInfoStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textDark,
  );
  static const TextStyle requestDetailsValueStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w500,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textMid,
  );

  // Settings screen
  static const TextStyle settingsCardTitleStyle = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    fontFamily: AppFonts.spaceGrotesk, color: AppColors.textDark,
  );

  // Request submitted page
  static const TextStyle requestSubmittedTitleStyle = TextStyle(
    fontFamily: AppFonts.batangas,
    fontSize: 22, fontWeight: FontWeight.w700,
    color: Color(0xFF1E1B4B), height: 1.5,
  );
  static const TextStyle requestSubmittedBodyStyle = TextStyle(
    fontFamily: AppFonts.batangas,
    fontSize: 13, fontWeight: FontWeight.w700,
    color: Color(0xFF64748B), height: 1.5,
  );

  // Dashboard
  static const TextStyle greetingTitleStyle = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800,
    fontFamily: AppFonts.batangas, color: AppColors.textDark,
  );
  static const TextStyle greetingMorningStyle = TextStyle(
    fontSize: 14, fontFamily: AppFonts.spaceGrotesk
    ,color: AppColors.textLight,
  );
  static const TextStyle greetingDateStyle = TextStyle(
    fontSize: 14,fontFamily: AppFonts.spaceGrotesk,
    fontWeight: FontWeight.w600, color: AppColors.primary,
  );

  // "View All" links
  static const TextStyle viewLinkStyle = TextStyle(
    color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14,
  );

  // Log row
  static const TextStyle logRowBodyStyle = TextStyle(
    fontSize: 14, color: AppColors.textDark,
  );

  // Hall error
  static const TextStyle blueScreenLabelStyle = TextStyle(
    color: Color(0x80FFFFFF), fontSize: 14,
  );

  // Empty state
  static const TextStyle emptyStateStyle = TextStyle(
    color: AppColors.textLight, fontSize: 14,
  );

  // Info rows
  static const TextStyle infoRowLabelStyle = TextStyle(
    fontWeight: FontWeight.w700,
  );
  static const TextStyle infoRowValueStyle = TextStyle(
    fontWeight: FontWeight.w500, color: AppColors.textMid,
  );
  static const TextStyle infoRowValueBoldStyle = TextStyle(
    fontWeight: FontWeight.w700, color: AppColors.textMid,
  );
}

//  DECORATIONS

class AppDecorations {
  // Cards
  static BoxDecoration card = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.primary, width: 2),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.08),
        blurRadius: 12, offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration smallCard({bool isSelected = false, bool isFaded = false}) {
    return BoxDecoration(
      color: isFaded
          ? AppColors.primary.withOpacity(0.04)
          : isSelected
          ? AppColors.primary.withOpacity(0.1)
          : Colors.white.withOpacity(0.55),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
        width: 1.5,
      ),
    );
  }

  static BoxDecoration cardSelected = BoxDecoration(
    color: AppColors.primary.withOpacity(0.06),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primary, width: 2),
  );

  static BoxDecoration cardUnselected = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
  );

  static BoxDecoration greetingCard = BoxDecoration(
    color: Colors.white.withOpacity(0.55),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.primary, width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10, offset: const Offset(0, 2),
      ),
    ],
  );

  // Buttons
  static BoxDecoration pillButton({Color? color}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: color ?? AppColors.primary, width: 1.5),
    );
  }

  static BoxDecoration pillButtonOutline({Color? color}) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: color ?? AppColors.primary, width: 2),
    );
  }

  static BoxDecoration gradientButton = BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    gradient: AppColors.buttonGradient,
    boxShadow: const [
      BoxShadow(color: Color(0x558B5CF6), blurRadius: 14, offset: Offset(0, 5)),
    ],
  );

  static BoxDecoration sidebarGradientButton = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: AppColors.sidebarGradient,
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.35),
        blurRadius: 14, offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration backButton = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: AppColors.sidebarGradient,
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.35),
        blurRadius: 10, offset: const Offset(0, 4),
      ),
    ],
  );

  // ID screen
  static BoxDecoration idCardInner = BoxDecoration(
    color: const Color(0xFFEEEEEE),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
  );

  static BoxDecoration iconBackground = BoxDecoration(
    color: AppColors.primary.withOpacity(0.15),
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration qrPlaceholder = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
  );

  static BoxDecoration dot = BoxDecoration(
    color: AppColors.primary.withOpacity(0.4),
    shape: BoxShape.circle,
  );

  // Hall error screen
  static BoxDecoration blueScreen = BoxDecoration(
    color: const Color(0xFF1A1A2E),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
  );

  static BoxDecoration innerBlueScreen = BoxDecoration(
    color: const Color(0xFF0066CC),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
  );

  static BoxDecoration cardWithBorderWidth(double width) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary, width: width),
    );
  }

  static Container verticalDivider({double height = 24}) {
    return Container(width: 1.5, height: height, color: AppColors.divider);
  }

  // Profile info horizontal divider — stroke color 0xFF32006C
  static const Divider profileInfoDivider = Divider(
    color: AppColors.infoDivider,
    thickness: 1,
    height: 1,
  );
}


//  GLASS DECORATIONS

class GlassDecoration {
  static BoxDecoration standard = BoxDecoration(
    gradient: AppColors.glassGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.primary, width: 2),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.10),
        blurRadius: 12, offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration light = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: Colors.white.withOpacity(0.35),
    border: Border.all(color: AppColors.primary.withOpacity(0.7), width: 1.2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 25, offset: const Offset(0, 12),
      ),
    ],
  );
}


//  INPUT STYLES

class AppInputStyles {
  static InputDecoration textField({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.lightGreyStart,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

//  SHARED WIDGETS
// Greeting Card (Solid White with Soft Shadow)
class AppGreetingCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String date;

  const AppGreetingCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(10, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi $name!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: AppFonts.batangas,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: AppFonts.spaceGrotesk,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: AppFonts.spaceGrotesk,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Profile header with avatar and name/ID
class ProfileHeader extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final double avatarSize;
  final double iconPadding;
  final double dividerHeight;
  final double spacing;

  const ProfileHeader({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.avatarSize    = 120,
    this.iconPadding   = 5,
    this.dividerHeight = 52,
    this.spacing       = 47,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar circle
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.15),
          ),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(iconPadding),
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  size: avatarSize * 0.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: spacing),

        // Purple divider
        Container(
          width: 3,
          height: dividerHeight,
          decoration: BoxDecoration(
            gradient: AppColors.sidebarGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        SizedBox(width: spacing),

        // Name and ID
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,   style: AppTextStyles.profileHeaderNameStyle),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.profileHeaderIdStyle),
            ],
          ),
        ),
      ],
    );
  }
}

// Background for IT screens with triangle
class ITScreenBackground extends StatelessWidget {
  final Widget child;

  const ITScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          // Bottom-right triangle
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/background_tab.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Screen content
          child,
        ],
      ),
    );
  }
}

// Text input field
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: AppTextStyles.body.copyWith(color: AppColors.textDark, fontSize: 13),
      decoration: AppInputStyles.textField(hint: hint),
    );
  }
}

// Label + text field
class AppLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const AppLabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelStyle),
        const SizedBox(height: 8),
        AppTextField(controller: controller, hint: hint, obscure: obscure),
      ],
    );
  }
}

// Gradient pill button
class AppGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const AppGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 200,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: AppDecorations.gradientButton,
        child: Center(
          child: Text(text, style: AppTextStyles.gradientButtonLabel),
        ),
      ),
    );
  }
}

// Full-width auth button
class AppAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AppAuthButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: AppDecorations.sidebarGradientButton,
        child: Center(
          child: Text(text, style: AppTextStyles.buttonWhiteStyle),
        ),
      ),
    );
  }
}

// Back button
class AppBackButton extends StatelessWidget {
  final double width;

  const AppBackButton({super.key, this.width = 80});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: width,
        height: 44,
        decoration: AppDecorations.backButton,
        child: Center(
          child: Text(
            'Back',
            style: AppTextStyles.buttonWhiteStyle.copyWith(fontSize: 13),
          ),
        ),
      ),
    );
  }
}

// Generic card
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final bool useGlass;
  final double? borderWidth;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.decoration,
    this.useGlass = false,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (decoration != null) {
      return Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: decoration,
        child: child,
      );
    }
    if (useGlass) {
      return GlassCard(padding: padding ?? const EdgeInsets.all(16), child: child);
    }
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: borderWidth != null
          ? AppDecorations.cardWithBorderWidth(borderWidth!)
          : AppDecorations.card,
      child: child,
    );
  }
}

// Glass card
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: GlassDecoration.standard,
          child: child,
        ),
      ),
    );
  }
}

// Outlined pill button
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isWhite;

  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: AppDecorations.pillButton(color: c),
        child: Center(
          child: Text(
            label,
            style: isWhite ? AppTextStyles.buttonWhiteStyle : AppTextStyles.buttonStyle,
          ),
        ),
      ),
    );
  }
}

// Vertical divider
class SectionDivider extends StatelessWidget {
  final double height;

  const SectionDivider({super.key, this.height = 28});

  @override
  Widget build(BuildContext context) {
    return AppDecorations.verticalDivider(height: height);
  }
}

// Small circle
class Dot extends StatelessWidget {
  final double size;

  const Dot({super.key, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: AppDecorations.dot);
  }
}

// Label : Value row
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            fontFamily: AppFonts.spaceGrotesk,
            color: AppColors.textDark,
          ),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: AppColors.textMid,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Circular progress
class CircularStat extends StatelessWidget {
  final double value;
  final String line1;
  final String line2;
  final String valueLabel;
  final String? sublabel;
  final Color color;

  const CircularStat({
    super.key,
    required this.value,
    required this.line1,
    required this.line2,
    required this.valueLabel,
    this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 160, height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160, height: 160,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 14,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(line1, textAlign: TextAlign.center, style: AppTextStyles.chartLabelStyle),
                Text(line2, textAlign: TextAlign.center, style: AppTextStyles.chartLabelStyle),
                Text(valueLabel, style: AppTextStyles.statValueStyle),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.chartSublabelStyle,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//  PAGE ENTRY ANIMATION MIXIN
//  Add to pages for slide-up + fade animations.
mixin PageEntryAnimation {
  late AnimationController pageAnimController;
  late Animation<Offset> contentIntro;
  late Animation<double> field1Anim;
  late Animation<double> field2Anim;
  late Animation<double> field3Anim;
  late Animation<double> checkAnim;
  bool _pageAnimInitialized = false;

  void initPageAnimation({required TickerProvider vsync}) {
    pageAnimController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 650),
    );
    contentIntro = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: pageAnimController,
      curve: Curves.easeOutCubic,
    ));
    field1Anim = CurvedAnimation(
      parent: pageAnimController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    );
    field2Anim = CurvedAnimation(
      parent: pageAnimController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );
    field3Anim = CurvedAnimation(
      parent: pageAnimController,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );
    checkAnim = CurvedAnimation(
      parent: pageAnimController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );
    _pageAnimInitialized = true;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_pageAnimInitialized &&
          pageAnimController.status == AnimationStatus.dismissed) {
        pageAnimController.forward();
      }
    });
  }

  void replayPageAnimation() {
    if (!_pageAnimInitialized) return;
    if (pageAnimController.status == AnimationStatus.completed) {
      pageAnimController.reset();
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_pageAnimInitialized) pageAnimController.forward();
      });
    }
  }

  void disposePageAnimation() {
    _pageAnimInitialized = false;
    pageAnimController.dispose();
  }

  Widget animatedField({
    required Animation<double> anim,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  Widget animatedPageContent({required Widget child}) {
    return SlideTransition(
      position: contentIntro,
      child: FadeTransition(
        opacity: pageAnimController,
        child: child,
      ),
    );
  }
}