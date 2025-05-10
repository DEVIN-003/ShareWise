import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<void> sendPasswordResetLink(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
    }
    catch(e){
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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google sign-in failed: $e");
      return null;
    }
  }

  // Sign up with Email & Password
  Future<User?> signupUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
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
  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
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
    final pattern = r'^(https:\/\/|git@)([\w\.@]+)(\/|:)([\w,\-,_,\/]+)(\.git)?$';
    final regex = RegExp(pattern);
    return regex.hasMatch(url);
  }

  Future<bool> doesGitRepoExist(String url) async {
    try {
      // Normalize URL if needed
      if (!url.endsWith('.git')) {
        url = url.replaceAll(RegExp(r'\.git$'), '');
      }
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyGitLink(String url) async {
    if (!isValidGitUrl(url)) {
      return false;
    }
    return await doesGitRepoExist(url);
  }

  Future<bool> pickAndVerifyCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.first.bytes == null) {
      return false;
    }

    final Uint8List pdfBytes = result.files.first.bytes!;

    try {
      // Load and extract text using pdf_text
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      String fullText = PdfTextExtractor(document).extractText();

      // Step 1: Check for embedded signature metadata
      final hasLocalSignature = _containsSignatureMetadata(pdfBytes);

      if (hasLocalSignature) {
        return true;
      } else if (fullText != null) {
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

        final lowerText = fullText.toLowerCase();
        final keywordFound = keywords.any((word) => lowerText.contains(word));

        if (keywordFound) {
          return true;
        }
      }else{
        final fileUrl = await uploadPDFFile(pdfBytes);

        if (fileUrl != null) {
          final hasCloudSignature = await checkPDFSignature(fileUrl);
          if (hasCloudSignature) {
            return true;
          }
        }
      }

      // If none of the above checks returned true
      return false;

    } catch (e) {
      print('Error verifying certificate: $e');
      return false;
    }
  }

  bool _containsSignatureMetadata(Uint8List pdfBytes) {
    final content = String.fromCharCodes(pdfBytes);
    return content.contains('/Sig') || content.contains('/DigitalSignature') || content.contains('/AcroForm');
  }

  Future<bool> checkPDFSignature(String fileUrl) async {
    const apiKey = 'varshetha0204@gmail.com_eIRrYbW8nmZDDD1svO4WYMFgwe3GJnt1jMw1QwPZsDUkb0LlfCVghPfdHvnek2LR';
    final url = Uri.parse('https://api.pdf.co/v1/pdf/info');

    final headers = {
      'x-api-key': apiKey,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'url': fileUrl});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final signatures = data['signatures'] as List<dynamic>?;
        return signatures != null && signatures.isNotEmpty;
      } else {
        print('Signature check failed: ${response.body}');
      }
    } catch (e) {
      print('Error checking signature: $e');
    }
    return false;
  }



  Future<String?> uploadPDFFile(Uint8List pdfBytes) async {
    const apiKey = 'varshetha0204@gmail.com_eIRrYbW8nmZDDD1svO4WYMFgwe3GJnt1jMw1QwPZsDUkb0LlfCVghPfdHvnek2LR';
    final requestUrl = Uri.parse('https://api.pdf.co/v1/file/upload/get-presigned-url?contenttype=application/pdf&name=certificate.pdf');

    try {
      // Step 1: Get presigned URL
      final response = await http.get(requestUrl, headers: {'x-api-key': apiKey});
      final jsonData = json.decode(response.body);

      final uploadUrl = jsonData['presignedUrl'];
      final fileUrl = jsonData['url'];

      // Step 2: Upload file
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'application/pdf'},
        body: pdfBytes,
      );

      if (uploadResponse.statusCode == 200) {
        return fileUrl;
      } else {
        print('Upload failed: ${uploadResponse.body}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
    return null;
  }
}