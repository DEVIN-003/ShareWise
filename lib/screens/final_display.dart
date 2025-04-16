import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resources.dart';
import '../services/firestore_services.dart';

class FinalDisplay extends StatefulWidget {
  final String subjectName;

  const FinalDisplay({super.key, required this.subjectName});

  @override
  _FinalDisplayState createState() => _FinalDisplayState();
}

class _FinalDisplayState extends State<FinalDisplay> {
  final FirestoreService _firestoreService = FirestoreService();
  Subject? _subjectData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Subject? data = await _firestoreService.getSubjectData(widget.subjectName);
    if (mounted) {
      setState(() {
        _subjectData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        backgroundColor: const Color(0xFF9AC1F0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Title", _subjectData?.title ?? "Loading..."),
            const SizedBox(height: 16),
            _buildTextField("Description", _subjectData?.description ?? "Loading..."),
            const SizedBox(height: 16),
            _buildTextField("Website Links", _subjectData?.websiteLinks ?? []),
            const SizedBox(height: 16),
            _buildTextField("YouTube Links", _subjectData?.youtubeLinks ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, dynamic value) {
    if (value is List<String>) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Column(children: value.map((link) => _buildClickableLink(link)).toList()),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      );
    }
  }

  Widget _buildClickableLink(String link) {
    return GestureDetector(
      onTap: () async {
        Uri url = Uri.parse(link);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open link")),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          link,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
