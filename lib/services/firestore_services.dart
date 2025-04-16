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
}
