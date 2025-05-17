import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;

  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Subject? data = await _firestoreService.getSubjectData(widget.subjectName);

    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('resource_links')
        .doc(widget.subjectName)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> reviews = reviewSnapshot.docs.map((doc) {
      return {
        'comment': doc['comment'] ?? '',
        'rating': (doc['rating'] ?? 0).toDouble(),
        'timestamp': doc['timestamp'],
      };
    }).toList();

    if (mounted) {
      setState(() {
        _subjectData = data;
        _reviews = reviews;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0.0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide both rating and comment.")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('resource_links')
        .doc(widget.subjectName)
        .collection('reviews')
        .add({
      'comment': _commentController.text.trim(),
      'rating': _rating,
      'timestamp': Timestamp.now(),
    });

    _commentController.clear();
    _rating = 0.0;
    fetchData(); // Refresh reviews
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
            const SizedBox(height: 24),

            const Text("Leave a Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                _rating = rating;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write your comment here...",
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6CC9CE),),
              child: const Text("Submit Review", style: TextStyle(color: Colors.white)),

            ),
            const SizedBox(height: 24),

            const Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _reviews.isEmpty
                ? const Text("No reviews yet.")
                : Column(
              children: _reviews.map((review) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBarIndicator(
                          rating: review['rating'],
                          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 20.0,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          review['comment'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (review['timestamp'] != null)
                          Text(
                            review['timestamp'].toDate().toString(),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
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
            const SnackBar(content: Text("Could not open link")),
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
