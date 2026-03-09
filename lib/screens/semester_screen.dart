import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'subject_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SemesterScreen extends StatelessWidget {
  const SemesterScreen({super.key});

  final List<int> semesters = const [1, 2, 3, 4, 5, 6, 7, 8];

  Color getColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Select Semester"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();

                        if (!context.mounted) return;

                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(16),

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),

        itemCount: semesters.length,

        itemBuilder: (context, index) {
          final semester = semesters[index];
          final color = getColor(index);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubjectScreen(semester: semester),
                ),
              );
            },

            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, color: Colors.white, size: 36),

                    const SizedBox(height: 10),

                    Text(
                      "SEM $semester",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
