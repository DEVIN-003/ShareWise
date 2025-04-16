class Subject {
  final String title;
  final String description;
  final List<String> websiteLinks;
  final List<String> youtubeLinks;

  Subject({
    required this.title,
    required this.description,
    required this.websiteLinks,
    required this.youtubeLinks,
  });

  factory Subject.fromMap(Map<String, dynamic> data) {
    return Subject(
      title: data['name'] ?? "No Title",
      description: data['desc'] ?? "No Description",
      websiteLinks: List<String>.from(data['wT'] ?? []),
      youtubeLinks: List<String>.from(data['yT'] ?? []),
    );
  }
}
