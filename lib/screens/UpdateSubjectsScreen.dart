import 'package:flutter/material.dart';
import 'package:login_sample/screens/update_subject.dart';
import 'package:login_sample/screens/verify_user_details.dart';
import '../services/firestore_services.dart'; // Make sure the path is correct
import '../auth/login_screen.dart'; // To handle logout if needed

class UpdateSubjectsScreen extends StatefulWidget {
  const UpdateSubjectsScreen({super.key});

  @override
  _UpdateSubjectsScreenState createState() => _UpdateSubjectsScreenState();
}

class _UpdateSubjectsScreenState extends State<UpdateSubjectsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, String>> subjects = [];
  List<Map<String, String>> filteredSubjects = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    List<Map<String, String>> data = await _firestoreService.getAllSubjects();
    if (mounted) {
      setState(() {
        subjects = data;
        filteredSubjects = data;
      });
    }
  }

  void filterSubjects(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredSubjects = subjects;
      });
    } else {
      setState(() {
        filteredSubjects = subjects
            .where((subject) => subject["name"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Subjects'),
        backgroundColor: const Color(0xFF9AC1F0),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Subject...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: filterSubjects,
            ),
          ),
          Expanded(
            child: filteredSubjects.isEmpty
                ? const Center(child: Text("No subjects found"))
                : ListView.builder(
              itemCount: filteredSubjects.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? const Color(0xFF7689DE) : const Color(0xFFA9DCE3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        filteredSubjects[index]["name"]!,
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyUserDetails(previousScreen: "Upload",subjectName: filteredSubjects[index]["id"]!,),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
