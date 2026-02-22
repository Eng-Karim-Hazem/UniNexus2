import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart'; // REQUIRED
import 'firebase_options.dart';
import '../../ui/screens/welcome_screen.dart';
import '../../ui/screens/Faculty/faculty_home_screen.dart';
import 'ui/screens/Student/stu_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- AUTO LOGIN LOGIC ---
  final prefs = await SharedPreferences.getInstance();
  final bool rememberMe = prefs.getBool('rememberMe') ?? false;
  final String? userCode = prefs.getString('ID');

  if (rememberMe && userCode != null) {
    if (userCode.startsWith('FA')) {
      runApp(UniNexusApp(startScreen:FacultyHomeScreen()));
    } else if(userCode.startsWith('ST')) {
      runApp(UniNexusApp(startScreen:StuHomeScreen()));
    }
  } else {
    runApp(UniNexusApp(startScreen: WelcomeScreen()));
    // If not remembered, go to Welcome or Login
  }
  runApp(UniNexusApp(startScreen: WelcomeScreen()));
}

class UniNexusApp extends StatelessWidget {
  final Widget startScreen;

  const UniNexusApp({Key? key, required this.startScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniNexus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: startScreen, // Uses the screen determined in main()
    );
  }
}