import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  final supabase = Supabase.instance.client;

  int totalStudents = 0;
  int totalMaterials = 0;
  int totalUploads = 0;
  int uploadsThisWeek = 0;

  List<int> semesterCounts = List.filled(8, 0);

  String mostSubject = "";
  int mostSubjectCount = 0;

  List<Map<String, dynamic>> topContributors = [];
  List<Map<String, dynamic>> recentUploads = [];

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {

  /// TOTAL STUDENTS (from students table)
  final students = await supabase
      .from('students')
      .select();

  /// MATERIALS
  final materials = await supabase
      .from('materials')
      .select();

  DateTime now = DateTime.now();

  Map<String, int> contributorMap = {};
  Map<String, int> subjectMap = {};

  for (var item in materials) {

    /// uploads this week
    DateTime created = DateTime.parse(item['created_at']);
    if (now.difference(created).inDays < 7) {
      uploadsThisWeek++;
    }

    /// semester distribution
    int sem = item['semester'];
    if (sem >= 1 && sem <= 8) {
      semesterCounts[sem - 1]++;
    }

    /// contributor counts
    final uploader = item['uploaded_by'];
    contributorMap[uploader] = (contributorMap[uploader] ?? 0) + 1;

    /// subject counts
    String subject = item['subject'];
    subjectMap[subject] = (subjectMap[subject] ?? 0) + 1;
  }

  /// sort contributors
  List<MapEntry<String, int>> sorted =
      contributorMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  List<Map<String, dynamic>> contributors = [];

  for (int i = 0; i < sorted.length && i < 3; i++) {

    String uploaderId = sorted[i].key;

    /// Try finding in students table
    var student = await supabase
        .from('students')
        .select('name')
        .eq('id', uploaderId)
        .maybeSingle();

    String name;

    if (student != null) {
      name = student['name'];
    } else {

      /// Otherwise check admins table
      var admin = await supabase
          .from('admins')
          .select('name')
          .eq('id', uploaderId)
          .maybeSingle();

      name = admin?['name'] ?? "Unknown";
    }

    contributors.add({
      "name": name,
      "uploads": sorted[i].value
    });
  }

  /// most uploaded subject
  var sortedSubjects = subjectMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  if (sortedSubjects.isNotEmpty) {
    mostSubject = sortedSubjects.first.key;
    mostSubjectCount = sortedSubjects.first.value;
  }

  /// recent uploads
  final recent = await supabase
      .from('materials')
      .select('title, created_at')
      .order('created_at', ascending: false)
      .limit(5);

  setState(() {

    totalStudents = students.length;
    totalMaterials = materials.length;
    totalUploads = materials.length;

    topContributors = contributors;
    recentUploads = List<Map<String, dynamic>>.from(recent);

  });
}

  Widget analyticsCard(String title, int value, IconData icon) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(icon, color: AppColors.primary, size: 28),

          const SizedBox(height: 10),

          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "App Analytics",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),

              children: [

                analyticsCard(
                    "Students", totalStudents, Icons.people),

                analyticsCard(
                    "Materials", totalMaterials, Icons.menu_book),

                analyticsCard(
                    "Uploads", totalUploads, Icons.upload),

                analyticsCard(
                    "This Week", uploadsThisWeek, Icons.calendar_today),

              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Top Contributors",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...topContributors.asMap().entries.map((entry) {

              int index = entry.key;
              var contributor = entry.value;

              String medal = "🥇";
              if (index == 1) medal = "🥈";
              if (index == 2) medal = "🥉";

              return ListTile(
                leading: Text(medal, style: const TextStyle(fontSize: 20)),
                title: Text(contributor['name']),
                trailing: Text("${contributor['uploads']} uploads"),
              );

            }),

            const SizedBox(height: 30),

            const Text(
              "Materials by Semester",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            ...List.generate(8, (i) {

              return ListTile(
                leading: const Icon(Icons.school),
                title: Text("Semester ${i + 1}"),
                trailing: Text("${semesterCounts[i]} materials"),
              );

            }),

            const SizedBox(height: 30),

            const Text(
              "Most Uploaded Subject",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.star),
              title: Text(mostSubject),
              trailing: Text("$mostSubjectCount materials"),
            ),

            const SizedBox(height: 30),

            const Text(
              "Recent Uploads",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            ...recentUploads.map((item) {

              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(item['title']),
                subtitle: Text(item['created_at']),
              );

            }),

          ],
        ),
      ),
    );
  }
}