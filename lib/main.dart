import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_sample/screens/splash_screen.dart'; // Import SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Education App',
      home: SplashScreen(), // Start the app with SplashScreen
    );
  }
}
