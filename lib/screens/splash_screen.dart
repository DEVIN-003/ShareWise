import
'package:flutter/material.dart';
import 'package:login_sample/auth/login_screen.dart'; // Ensure correct path

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFB2E4D9), // Background color
        child: Center(
          child: Image.asset(
            'assets/images/splash.png', // Replace with your image path
            width: 200, // Adjust width as needed
            height: 200, // Adjust height as needed
            fit: BoxFit.contain, // Adjust scaling as needed
          ),
        ),
      ),
    );
  }
}