import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'subject_screen.dart';

class SemesterScreen extends StatelessWidget {
  const SemesterScreen({super.key});

  final List<int> semesters = const [1,2,3,4,5,6,7,8];

  Color getColor(int index) {

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink
    ];

    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Select Semester"),
        backgroundColor: AppColors.primary,
      ),

      body: GridView.builder(

        padding: const EdgeInsets.all(16),

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),

        itemCount: semesters.length,

        itemBuilder: (context,index){

          final semester = semesters[index];
          final color = getColor(index);

          return GestureDetector(

            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubjectScreen(
                    semester: semester,
                  ),
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

                    const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 36,
                    ),

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