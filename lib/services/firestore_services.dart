import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resources.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, String>>> getAllSubjects() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("resource_links").get();
      List<Map<String, String>> subjects = querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "name": doc["name"]?.toString() ?? doc.id,
        };
      }).toList();
      return subjects;
    } catch (e) {
      print("Error fetching subjects: $e");
      return [];
    }
  }

  Future<Subject?> getSubjectData(String subjectId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("resource_links").doc(subjectId).get();
      if (doc.exists) {
        return Subject.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching subject data: $e");
    }
    return null;
  }

  Future<void> saveSubjectData(String subjectName, Subject subject) async {
    try {
      final data = subject.toMap();
      print("Saving data for '$subjectName': $data"); // Debug print

      await FirebaseFirestore.instance
          .collection('resource_links')
          .doc(subjectName)
          .set(data);

      print("Data saved successfully");
    } catch (e) {
      print("Error saving subject data: $e");
      rethrow;
    }
  }
  Future<void> appendLinksToSubject(String title, List<String> newWebsites, List<String> newYoutubes) async {
    final docRef = FirebaseFirestore.instance.collection('resource_links').doc(title);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception("Subject does not exist!");
    }

    final currentData = snapshot.data()!;
    final existingWebsites = List<String>.from(currentData['wT'] ?? []);
    final existingYoutubes = List<String>.from(currentData['yT'] ?? []);

    await docRef.update({
      'wT': existingWebsites + newWebsites,
      'yT': existingYoutubes + newYoutubes,
    });
  }

}
