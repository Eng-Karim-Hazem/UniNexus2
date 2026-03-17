import 'package:flutter/material.dart';

class DeviceType {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
}