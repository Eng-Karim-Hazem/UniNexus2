import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'ui/screens/mobile/welcome_screen.dart';
import 'ui/screens/mobile/Faculty/faculty_home_screen.dart';
import 'ui/screens/mobile/Student/stu_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- AUTO LOGIN LOGIC ---
  final prefs = await SharedPreferences.getInstance();
  final bool rememberMe = prefs.getBool('rememberMe') ?? false;
  final String? userCode = prefs.getString('ID');

  Widget initialScreen;
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
  // Set orientations and THEN run the app
  // This ensures SystemChrome commands are sent correctly
  _setOrientation().then((_) {
    runApp(UniNexusApp(startScreen: initialScreen));
  });
}

Future<void> _setOrientation() async {
  // Use View.of(context) equivalent for raw window metrics
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final double devicePixelRatio = view.devicePixelRatio;
  final double width = view.physicalSize.width / devicePixelRatio;
  final double height = view.physicalSize.height / devicePixelRatio;

  // A device is a tablet if the shortest side is >= 600dp
  bool isTablet = (width < height ? width : height) >= 600;
  if (!isTablet) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  else{
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
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