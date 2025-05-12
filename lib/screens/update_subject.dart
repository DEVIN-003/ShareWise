import 'package:flutter/material.dart';
import 'package:login_sample/screens/home_screen.dart';
import '../services/firestore_services.dart';

class UpdateSubject extends StatefulWidget {
  final String subjectName;

  const UpdateSubject({super.key, required this.subjectName});

  @override
  _UpdateSubjectState createState() => _UpdateSubjectState();
}

class _UpdateSubjectState extends State<UpdateSubject> {
  final FirestoreService _firestoreService = FirestoreService();

  final List<TextEditingController> _websiteControllers = [TextEditingController()];
  final List<TextEditingController> _youtubeControllers = [TextEditingController()];

  @override
  void dispose() {
    _websiteControllers.forEach((c) => c.dispose());
    _youtubeControllers.forEach((c) => c.dispose());
    super.dispose();
  }

  void _addWebsiteField() {
    setState(() {
      _websiteControllers.add(TextEditingController());
    });
  }

  void _addYouTubeField() {
    setState(() {
      _youtubeControllers.add(TextEditingController());
    });
  }

  void _submitData() async {
    List<String> newWebsites = _websiteControllers.map((c) => c.text.trim()).where((l) => l.isNotEmpty).toList();
    List<String> newYouTubes = _youtubeControllers.map((c) => c.text.trim()).where((l) => l.isNotEmpty).toList();

    if (newWebsites.isEmpty && newYouTubes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter at least one website or YouTube link.")),
      );
      return;
    }

    try {
      await _firestoreService.appendLinksToSubject(widget.subjectName, newWebsites, newYouTubes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Links added successfully!")),
      );
      Navigator.pop(context); // Optionally go back
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving links: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Links - ${widget.subjectName}"),
        backgroundColor: const Color(0xFF9AC1F0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Website Links", style: _sectionTitleStyle),
            ..._websiteControllers.map((controller) => _buildInputField("", controller)).toList(),
            TextButton.icon(
              onPressed: _addWebsiteField,
              icon: const Icon(Icons.add),
              label: const Text("Add Website Link"),
            ),
            const SizedBox(height: 16),

            Text("YouTube Links", style: _sectionTitleStyle),
            ..._youtubeControllers.map((controller) => _buildInputField("", controller)).toList(),
            TextButton.icon(
              onPressed: _addYouTubeField,
              icon: const Icon(Icons.add),
              label: const Text("Add YouTube Link"),
            ),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _submitData,
                    child: const Text("Submit"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7689DE),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "Goto View Materials",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: label.isNotEmpty ? label : "Enter link",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  TextStyle get _sectionTitleStyle => const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}
