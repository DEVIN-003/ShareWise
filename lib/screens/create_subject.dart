import 'package:flutter/material.dart';
import 'package:login_sample/screens/home_screen.dart';
import '../models/resources.dart';
import '../services/firestore_services.dart';

class CreateSubject extends StatefulWidget {
  final String subjectName;

  const CreateSubject({super.key, required this.subjectName});

  @override
  _CreateSubjectState createState() => _CreateSubjectState();
}

class _CreateSubjectState extends State<CreateSubject> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _websiteControllers = [TextEditingController()];
  final List<TextEditingController> _youtubeControllers = [TextEditingController()];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Description cannot be empty")),
      );
      return;
    }

    Subject newSubject = Subject(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      websiteLinks: _websiteControllers.map((c) => c.text.trim()).where((link) => link.isNotEmpty).toList(),
      youtubeLinks: _youtubeControllers.map((c) => c.text.trim()).where((link) => link.isNotEmpty).toList(),
    );

    try {
      await _firestoreService.saveSubjectData(_titleController.text, newSubject);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Details - ${widget.subjectName}"),
        backgroundColor: const Color(0xFF9AC1F0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Title", _titleController),
            const SizedBox(height: 16),
            _buildInputField("Description", _descriptionController, maxLines: 4),
            const SizedBox(height: 16),

            Text("Website Links", style: _sectionTitleStyle),
            ..._websiteControllers
                .map((controller) => _buildInputField("", controller))
                .toList(),
            TextButton.icon(
              onPressed: _addWebsiteField,
              icon: const Icon(Icons.add),
              label: const Text("Add Website Link"),
            ),
            const SizedBox(height: 16),

            Text("YouTube Links", style: _sectionTitleStyle),
            ..._youtubeControllers
                .map((controller) => _buildInputField("", controller))
                .toList(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(label, style: _sectionTitleStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  TextStyle get _sectionTitleStyle => const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}
