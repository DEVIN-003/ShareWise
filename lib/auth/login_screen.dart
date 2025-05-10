import 'dart:developer';
import 'service.dart';
import 'signup_screen.dart';
import 'package:login_sample/screens/welcome_screen.dart';
import '/widgets/button.dart';
import '/widgets/textfield.dart';
import '/screens/forget_pass.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                  "Login",
                  style: TextStyle(
                    fontSize: 30,
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

                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Enter Password",
                  label: "Password",
                  isPassword: true,
                  controller: _password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword(),));
                    }, child: Text("Forgot Password?",
                        style: TextStyle(
                            height: 4,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)))),
                const SizedBox(height: 30),
                CustomButton(
                  label: "Login",
                  onPressed: () => _validateAndLogin(context),
                  color: Color(0xFF6CC9CE),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    icon: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/icons/google_image.png',
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                    label: const Text(
                      "Sign in with Google",
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () => _signInWithGoogle(context),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? ",
                        style: TextStyle(color: Colors.white)),
                    InkWell(
                      onTap: () => goToSignup(context),
                      child: const Text("Signup",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignupScreen()),
  );

  goToHome(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
  );

  _validateAndLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _login(context);
    }
  }

  _login(BuildContext context) async {
    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        log("User Logged In");
        goToHome(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  _signInWithGoogle(BuildContext context) async {
    final user = await _auth.signInWithGoogle();
    if (!mounted) return;

    if (user != null) {
      log("Google Sign-In successful");
      goToHome(context);
    } else {
      log("Google Sign-In failed");
    }
  }
}