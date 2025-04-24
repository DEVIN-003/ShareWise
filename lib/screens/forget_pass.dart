import 'package:flutter/material.dart';
import '../auth/service.dart';
import '../widgets/button.dart';
import '../widgets/textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9BE3A8), Color(0xFF5F7FCB)], // More Green, Less Blue
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
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  CustomTextField(
                    hint: "Enter Email",
                    label: "Email",
                    controller: _email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                      if (!RegExp(emailPattern).hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    label: "Send Mail",
                    onPressed: () async{
                      await _auth.sendPasswordResetLink(_email.text);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An email for password reset has been sent to your mail")));
                      Navigator.pop(context);
                    },
                    color: Color(0xFF6CC9CE),
                  ),
                  const Spacer()
                ],
              ),
            ),
          ),
        ));
  }
}
