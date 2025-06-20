import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String pdfUrl="";

  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    }
    catch (e) {
      print(e.toString());
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
          credential);
      return userCredential.user;
    } catch (e) {
      print("Google sign-in failed: $e");
      return null;
    }
  }

  // Sign up with Email & Password
  Future<User?> signupUserWithEmailAndPassword(String email,
      String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Signup failed: $e");
      return null;
    }
  }

  // Login with Email & Password
  Future<User?> loginUserWithEmailAndPassword(String email,
      String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password.');
      } else {
        throw Exception('Login failed. ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  bool isValidGitUrl(String url) {
    final pattern = r'^(https:\/\/|git@)([\w\.\-@]+)(\/|:)([\w\-/]+)\.git$';
    return RegExp(pattern).hasMatch(url);
  }

  Future<bool> verifyGitLink(String url) async {
    if (!isValidGitUrl(url)) return false;

    // Try HEAD request first
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) return true;
    } catch (_) {
      // HEAD failed — move on to GitHub fallback
    }

    // Fallback to GitHub API
    final match = RegExp(r'^https:\/\/github\.com\/([\w\-]+)\/([\w\-]+)\.git$')
        .firstMatch(url);

    if (match != null) {
      final owner = match.group(1);
      final repo = match.group(2);
      final apiUrl = 'https://api.github.com/repos/$owner/$repo';

      try {
        final response = await http.get(Uri.parse(apiUrl));
        return response.statusCode == 200;
      } catch (_) {
        return false;
      }
    }

    return false;
  }

  Future<bool> pickAndExtractTextFromPdf({required String subjectName}) async {
    bool isKeywordCheck = true;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.first.bytes == null) {
      print("No file selected or file is empty.");
      return false;
    }

    final Uint8List pdfBytes = result.files.first.bytes!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User not logged in");
      return false;
    }

    String extractedText = '';

    try {
      final document = PdfDocument(inputBytes: pdfBytes);
      for (int i = 0; i < document.pages.count; i++) {
        extractedText += PdfTextExtractor(document).extractText(
          startPageIndex: i,
          endPageIndex: i,
        ) ??
            '';
      }
      document.dispose();
      print("Text extracted using Syncfusion.");
    } catch (e) {
      print("Syncfusion extraction error: $e");
    }

    // If Syncfusion extraction failed or text is empty, fall back to OCR
    if (extractedText.trim().isEmpty) {
      print("Falling back to OCR...");
      extractedText = await extractTextUsingOCR(pdfBytes);
    }

    if (extractedText.trim().isEmpty) {
      print("Text extraction failed.");
      return false;
    }

    final isValid = containsMinimumKeywords(extractedText, subjectName);

    await FirebaseFirestore.instance.collection('certificates').add({
      'email': user.email,
      'subject': subjectName,
      'extractedText': extractedText,
      'isVerified': isValid,
      'uploadedAt': Timestamp.now(),
    });
    print(isValid);
    return isValid;
  }


  bool containsMinimumKeywords(String extractedText, String subjectName) {
    final keywords = [
      // General certificate terms
      'certificate', 'certified', 'certifies', 'award', 'awarded',
      'recognition', 'achievement', 'participation', 'completion',
      'conferred', 'successfully completed', 'entitled', 'granted',

      // Academic terms
      'student', 'course', 'training', 'degree', 'program',
      'project', 'internship', 'research', 'publication',

      // Official indicators
      'seal', 'stamp', 'digital signature', 'issued by',
      'authorized', 'verified', 'board of', 'institute of',

      // Date/context markers
      'date of issue', 'valid until', 'presented on',

      // Names and titles
      'journal', 'editor', 'volume', 'issue',

      // Honours & titles
      'honor', 'excellence', 'outstanding', 'merit'
    ];

    int matchCount = 0;
    final lowerText = extractedText.toLowerCase();
    final lowerSubject = subjectName.toLowerCase();

    for (final keyword in keywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        matchCount++;
      }
    }
    print(matchCount >= 1);
    print(lowerText.contains(lowerSubject));
    return matchCount >= 1 && lowerText.contains(lowerSubject);
  }

  Future<String> extractTextUsingOCR(Uint8List pdfBytes) async {
    //  1. Write the bytes to a temporary PDF file
    final tempDir = await getTemporaryDirectory();
    final pdfPath = '${tempDir.path}/temp.pdf';
    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(pdfBytes);

    //  2. Use the file path (not pdfBytes) in PdfImageRenderer
    final pdfRenderer = PdfImageRenderer(path: pdfFile.path);
    await pdfRenderer.open();

    // 3. OCR logic
    String ocrText = '';
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    for (int i = 0; i < 1; i++) {
      final imageBytes = await pdfRenderer.renderPage(
        x: 0,
        y: 0,
        scale: 1.0,
        width: 1000,
        height: 1000,
        pageIndex: i,
      );

      // Save image to temp file
      final imagePath = '${tempDir.path}/page_$i.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes as List<int>);

      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      ocrText += recognizedText.text + '\n';
    }

    await pdfRenderer.close();
    textRecognizer.close();

    return ocrText;
  }

}
