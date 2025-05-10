import 'package:flutter/material.dart';
import '/widgets/button.dart';
import '/widgets/textfield.dart';
import 'package:login_sample/auth/login_screen.dart';

class EnterSubjectScreen extends StatefulWidget {
  const EnterSubjectScreen({super.key});

  @override
  State<EnterSubjectScreen> createState() => _EnterSubjectScreenState();
}

class _EnterSubjectScreenState extends State<EnterSubjectScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitSubject() {
    if (_formKey.currentState!.validate()) {
      String subjectName = _subjectController.text.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subject "$subjectName" submitted successfully!')),
      );
      Navigator.pop(context); // Go back after submission
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Enter Subject', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9BE3A8), Color(0xFF5F7FCB)], // Same as LoginScreen
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Spacer(),
                const Text(
                  "Add Subject",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  hint: "Enter Subject Name",
                  label: "Subject",
                  controller: _subjectController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Subject name is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "You should either have certification in the entered course or any project should be done in order to get access.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  label: "Submit",
                  onPressed: _submitSubject,
                  color: const Color(0xFF6CC9CE),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
