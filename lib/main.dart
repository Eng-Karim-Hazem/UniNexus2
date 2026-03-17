import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uninexus/ui/screens/tablet/welcome_screen.dart';
import 'firebase_options.dart';
import 'ui/screens/mobile/welcome_screen.dart';
import 'ui/screens/mobile/Faculty/faculty_home_screen.dart';
import 'ui/screens/mobile/Student/stu_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool rememberMe = prefs.getBool('rememberMe') ?? false;
  final String? userCode = prefs.getString('ID');

  // 1. Determine Device Type
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final double width = view.physicalSize.width / view.devicePixelRatio;
  final double height = view.physicalSize.height / view.devicePixelRatio;
  bool isTablet = (width < height ? width : height) >= 600;

  Widget initialScreen;

  if (!isTablet) {
    // --- MOBILE LOGIC ---
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (rememberMe && userCode != null) {
      if (userCode.startsWith('FA')) {
        initialScreen = const FacultyHomeScreen();
      } else if (userCode.startsWith('ST')) {
        initialScreen = const StuHomeScreen();
      } else {
        initialScreen = const WelcomeScreen();
      }
    } else {
      initialScreen = const WelcomeScreen();
    }
  } else {
    // --- TABLET LOGIC ---
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (rememberMe && userCode != null) {
      if (userCode.startsWith('FA')) {
        initialScreen = const FacultyHomeScreen();
      } else if (userCode.startsWith('ST')) {
        initialScreen = const StuHomeScreen();
      } else {
        initialScreen = const WelcomePage();
      }
    } else {
      initialScreen = const WelcomePage();
    }
  }

  // 2. Launch the App
  runApp(UniNexusApp(startScreen: initialScreen));
}



class UniNexusApp extends StatelessWidget {
  final Widget startScreen;
  const UniNexusApp({Key? key, required this.startScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniNexus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: startScreen,
    );
  }
}