import 'package:flutter/material.dart';

class MobileAppColors {
  static const Color primary = Color(0xFFA78BFA);
  static const Color secondary = Color(0xFF67E8F9);
  static const Color white = Colors.white;
  static const Color black54 = Colors.black54;
  static const Color fieldBorder = Color(0x4D9E9E9E);
}

class MobileAppFonts {
  static const String heading = 'Batangas';
  static const String body = 'SpaceGrotesk';
}

class MobileAppTextStyles {
  static const TextStyle screenTitle = TextStyle(
    fontFamily: MobileAppFonts.heading,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle screenSubtitle = TextStyle(
    fontFamily: MobileAppFonts.body,
    fontSize: 17,
    fontWeight: FontWeight.w200,
    color: MobileAppColors.black54,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: MobileAppFonts.heading,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle fieldText = TextStyle(
    fontFamily: MobileAppFonts.body,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: MobileAppFonts.body,
  );

  static const TextStyle bodyTextMedium = TextStyle(
    fontFamily: MobileAppFonts.body,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle buttonText = TextStyle(
    color: Colors.white,
    fontFamily: MobileAppFonts.heading,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle textButtonHeading = TextStyle(
    fontFamily: MobileAppFonts.heading,
    fontWeight: FontWeight.bold,
  );
}

class MobileAppDimensions {
  static const double heroImageWidth = 90;
  static const double headingSpacing = 10;
  static const double sectionSpacing = 40;

  static const double inputHeight = 50;
  static const double inputRadius = 18;
  static const double inputBorderWidth = 1.4;
  static const double inputHorizontalPadding = 15;

  static const double primaryButtonWidth = 280;
  static const double primaryButtonHeight = 65;
  static const double primaryButtonRadius = 24;
  static const double primaryButtonBorderWidth = 1.5;

  static const double wideButtonHeight = 64;
  static const double wideButtonRadius = 22;
  static const double wideButtonHorizontalMargin = 65;
  static const double wideButtonBorderWidth = 1.4;
}

class MobileCardStyles {
  static const Color figmaBorderColor = Color(0xFF6D6FD9);

  static Border highlightedBorder({double width = 1}) {
    return Border.all(color: figmaBorderColor, width: width);
  }
}

class MobileAppDecorations {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [MobileAppColors.primary, MobileAppColors.secondary],
  );

  static BoxDecoration inputBox = BoxDecoration(
    color: MobileAppColors.white,
    borderRadius: BorderRadius.circular(MobileAppDimensions.inputRadius),
    border: Border.all(
      color: MobileAppColors.fieldBorder,
      width: MobileAppDimensions.inputBorderWidth,
    ),
  );

  static BoxDecoration primaryButtonBox = BoxDecoration(
    border: Border.all(
      color: MobileAppColors.white.withValues(alpha: 0.3),
      width: MobileAppDimensions.primaryButtonBorderWidth,
    ),
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(MobileAppDimensions.primaryButtonRadius),
  );

  static BoxDecoration wideButtonBox = BoxDecoration(
    border: Border.all(
      color: MobileAppColors.white.withValues(alpha: 0.3),
      width: MobileAppDimensions.wideButtonBorderWidth,
    ),
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(MobileAppDimensions.wideButtonRadius),
  );
}

class MobileAppInputStyles {
  static InputDecoration fieldDecoration({
    required String hint,
    Widget? suffixIcon,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: MobileAppDimensions.inputHorizontalPadding,
      vertical: 10,
    ),
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: MobileAppTextStyles.fieldText,
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      contentPadding: contentPadding,
    );
  }
}

class MobileAppButtonStyles {
  static ButtonStyle transparentElevated = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    elevation: 0,
  );
}