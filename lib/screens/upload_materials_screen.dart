import 'package:flutter/material.dart';
import 'package:login_sample/auth/login_screen.dart'; // Import LoginScreen
import 'package:login_sample/screens/SubjectsScreen.dart'; // Import UpdateSubjectsScreen
import 'package:login_sample/screens/enter_subject_screen.dart';


class UploadMaterialsScreen extends StatelessWidget {
  const UploadMaterialsScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Plain dark background
      body: Stack(
        children: [
          // Centered Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Upload Materials",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                _buildButton("UPDATE SUBJECT", const Color(0xFFA9DCE3), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpdateSubjectsScreen()),
                  );
                }),
                const SizedBox(height: 20),

                _buildButton("CREATE SUBJECT", const Color(0xFF7689DE), () {
                  // TODO: Add navigation to Upload Material Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EnterSubjectScreen()),
                  );
                }),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Logout Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                _logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
