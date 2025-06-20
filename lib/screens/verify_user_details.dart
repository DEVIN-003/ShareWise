import 'package:flutter/material.dart';
import 'package:login_sample/screens/update_subject.dart';
import '../auth/service.dart';
import '../widgets/button.dart';
import '../widgets/textfield.dart';
import 'create_subject.dart';

class VerifyUserDetails extends StatefulWidget {
  final String previousScreen;
  final String subjectName;

  const VerifyUserDetails({super.key, required this.previousScreen, required this.subjectName});

  @override
  State<VerifyUserDetails> createState() => _VerifyUserDetailsState();
}

class _VerifyUserDetailsState extends State<VerifyUserDetails> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _link = TextEditingController();

  bool gitVerified = false;
  bool certificateVerified = false;
  bool certificateUploaded = false;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9BE3A8), Color(0xFF5F7FCB)],
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
                  "Details Verification",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // GIT Link Input
                CustomTextField(
                  hint: "Enter GIT Link",
                  label: "Link",
                  controller: _link,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "HTTPS Link is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Verify Git Button
                CustomButton(
                  label: "Verify GIT Link",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool isValid = await _auth.verifyGitLink(_link.text);
                      if (isValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("✅ GIT Repo verified!")));
                        setState(() {
                          gitVerified = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("❌ GIT Repo doesn't exist!")));
                      }
                    }
                  },
                  color: Color(0xFF6CC9CE),
                ),

                const SizedBox(height: 20),

                // OR Text
                const Text(
                  "OR",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Upload and Verify Certificate
                ElevatedButton.icon(
                  onPressed: () async {
                    // Step 1: Pick and Verify the Certificate (No permanent storage)
                    final isVerified = await _auth.pickAndExtractTextFromPdf(subjectName: widget.subjectName,);
                    if (isVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ Certificate verified!')));
                      setState(() {
                        certificateVerified = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('❌ Certificate verification failed!')));
                    }
                  },
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Upload and Verify Certificate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6CC9CE),
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 10), // Add spacing between buttons
                // Next Button
                CustomButton(
                  label: "Next",
                  onPressed: () {
                    if (gitVerified) {
                      if(widget.previousScreen=="Upload"){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateSubject(subjectName: widget.subjectName,),
                          ),
                        );
                      }
                      else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateSubject(subjectName: widget.subjectName,),
                          ),
                        );
                      }
                    }
                    else if(certificateVerified){
                      if(widget.previousScreen=="Upload"){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateSubject(subjectName: widget.subjectName,),
                          ),
                        );
                      }
                      else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateSubject(subjectName: widget.subjectName,),
                          ),
                        );
                      }
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Please provide a GIT Link or verify a Certificate.",
                            style: TextStyle(color: Colors.white),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  color: Color(0xFF6CC9CE),
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
