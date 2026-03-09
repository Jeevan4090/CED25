import 'package:flutter/material.dart';
import 'material_list_screen.dart';

class SubjectScreen extends StatefulWidget {
  final int semester;

  const SubjectScreen({super.key, required this.semester});

  static const Map<int, List<Map<String, dynamic>>> semesterSubjects = {
    // KEEP YOUR FULL MAP HERE EXACTLY AS IT WAS
    // (same content you already provided)
    1: [
      {
        "name": "Linear Algebra & Calculus",
        "icon": Icons.calculate,
        "color": Colors.blue,
      },
      {
        "name": "Engineering Chemistry",
        "icon": Icons.science,
        "color": Colors.green,
      },
      {
        "name": "Technical Communication",
        "icon": Icons.record_voice_over,
        "color": Colors.orange,
      },
      {
        "name": "Programming & Data Structures",
        "icon": Icons.code,
        "color": Colors.purple,
      },
      {
        "name": "Design Thinking",
        "icon": Icons.lightbulb,
        "color": Colors.teal,
      },
      {"name": "PDS Lab", "icon": Icons.computer, "color": Colors.indigo},
      {
        "name": "EAA (Sports/Yoga)",
        "icon": Icons.sports_soccer,
        "color": Colors.red,
      },
    ],
    2: [
      {
        "name": "Laplace & Vector Calculus",
        "icon": Icons.calculate,
        "color": Colors.blue,
      },
      {
        "name": "Engineering Physics",
        "icon": Icons.science,
        "color": Colors.orange,
      },
      {
        "name": "Engineering Mechanics",
        "icon": Icons.engineering,
        "color": Colors.green,
      },
      {
        "name": "Building Planning & Drawing",
        "icon": Icons.architecture,
        "color": Colors.purple,
      },
      {
        "name": "Biology for Engineers",
        "icon": Icons.biotech,
        "color": Colors.teal,
      },
      {"name": "Workshop Practice", "icon": Icons.build, "color": Colors.red},
      {
        "name": "Civil Engineering Materials",
        "icon": Icons.apartment,
        "color": Colors.indigo,
      },
      {"name": "EAA II", "icon": Icons.sports, "color": Colors.pink},
    ],
    3: [
      {
        "name": "Business Essentials",
        "icon": Icons.business,
        "color": Colors.blue,
      },
      {"name": "Surveying", "icon": Icons.map, "color": Colors.orange},
      {"name": "Fluid Mechanics", "icon": Icons.water, "color": Colors.green},
      {
        "name": "Strength of Materials",
        "icon": Icons.fitness_center,
        "color": Colors.purple,
      },
      {
        "name": "Geotechnical Engineering",
        "icon": Icons.landscape,
        "color": Colors.teal,
      },
      {"name": "Surveying Lab", "icon": Icons.science, "color": Colors.red},
      {
        "name": "Geotechnical Lab",
        "icon": Icons.science,
        "color": Colors.indigo,
      },
    ],
    4: [
      {"name": "Fourier & PDE", "icon": Icons.calculate, "color": Colors.blue},
      {
        "name": "Structural Mechanics",
        "icon": Icons.account_tree,
        "color": Colors.orange,
      },
      {
        "name": "Hydrology & Irrigation",
        "icon": Icons.water_drop,
        "color": Colors.green,
      },
      {
        "name": "Steel Structure Design",
        "icon": Icons.apartment,
        "color": Colors.purple,
      },
      {
        "name": "Foundation Engineering",
        "icon": Icons.foundation,
        "color": Colors.teal,
      },
      {
        "name": "Fluid Mechanics Lab",
        "icon": Icons.science,
        "color": Colors.red,
      },
      {"name": "SOM Lab", "icon": Icons.science, "color": Colors.indigo},
    ],
    5: [
      {
        "name": "Environmental Engineering",
        "icon": Icons.eco,
        "color": Colors.green,
      },
      {
        "name": "Theory of Structures",
        "icon": Icons.account_tree,
        "color": Colors.blue,
      },
      {
        "name": "Concrete Design",
        "icon": Icons.apartment,
        "color": Colors.orange,
      },
      {
        "name": "Highway Engineering",
        "icon": Icons.alt_route,
        "color": Colors.purple,
      },
      {
        "name": "Professional Elective I",
        "icon": Icons.menu_book,
        "color": Colors.teal,
      },
      {
        "name": "Fractal Course I",
        "icon": Icons.functions,
        "color": Colors.indigo,
      },
      {"name": "Environmental Lab", "icon": Icons.science, "color": Colors.red},
      {"name": "Concrete Lab", "icon": Icons.science, "color": Colors.pink},
    ],
    6: [
      {
        "name": "Construction Technology",
        "icon": Icons.engineering,
        "color": Colors.blue,
      },
      {
        "name": "Airport & Railway Engg",
        "icon": Icons.flight,
        "color": Colors.orange,
      },
      {
        "name": "Professional Elective II",
        "icon": Icons.menu_book,
        "color": Colors.green,
      },
      {
        "name": "Professional Elective III",
        "icon": Icons.menu_book,
        "color": Colors.purple,
      },
      {
        "name": "Product Development",
        "icon": Icons.build_circle,
        "color": Colors.teal,
      },
      {
        "name": "Fractal Course II",
        "icon": Icons.functions,
        "color": Colors.indigo,
      },
      {
        "name": "Civil Software Lab",
        "icon": Icons.computer,
        "color": Colors.red,
      },
      {
        "name": "Transportation Lab",
        "icon": Icons.alt_route,
        "color": Colors.pink,
      },
    ],
    7: [
      {
        "name": "Hydraulic Structures",
        "icon": Icons.water,
        "color": Colors.blue,
      },
      {
        "name": "Professional Elective IV",
        "icon": Icons.menu_book,
        "color": Colors.orange,
      },
      {
        "name": "Professional Elective V",
        "icon": Icons.menu_book,
        "color": Colors.green,
      },
      {"name": "Open Elective I", "icon": Icons.school, "color": Colors.purple},
      {
        "name": "Quantity Survey Lab",
        "icon": Icons.calculate,
        "color": Colors.teal,
      },
      {"name": "RS & GIS Lab", "icon": Icons.map, "color": Colors.indigo},
      {
        "name": "Seminar & Technical Writing",
        "icon": Icons.edit,
        "color": Colors.red,
      },
      {"name": "Industrial Training", "icon": Icons.work, "color": Colors.pink},
      {
        "name": "Minor Project",
        "icon": Icons.assignment,
        "color": Colors.brown,
      },
    ],
    8: [
      {
        "name": "Professional Elective VI",
        "icon": Icons.menu_book,
        "color": Colors.blue,
      },
      {
        "name": "Professional Elective VII",
        "icon": Icons.menu_book,
        "color": Colors.orange,
      },
      {
        "name": "Professional Elective VIII",
        "icon": Icons.menu_book,
        "color": Colors.green,
      },
      {"name": "Major Project", "icon": Icons.engineering, "color": Colors.red},
    ],
  };

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = SubjectScreen.semesterSubjects[widget.semester] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Semester ${widget.semester}")),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,

        itemBuilder: (context, index) {
          final subject = subjects[index];
          final color = subject["color"] as Color;

          final animation = Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: controller,
                  curve: Interval(index * 0.08, 1, curve: Curves.easeOut),
                ),
              );

          return SlideTransition(
            position: animation,

            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),

              child: InkWell(
                borderRadius: BorderRadius.circular(18),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaterialListScreen(
                        semester: widget.semester,
                        subject: subject["name"],
                      ),
                    ),
                  );
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(
                      color: color.withOpacity(0.4),
                      width: 1.5,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color,
                        child: Icon(subject["icon"], color: Colors.white),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Text(
                          subject["name"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Icon(Icons.arrow_forward, color: color),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
