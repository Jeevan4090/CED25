import 'package:flutter/material.dart';
import 'material_list_screen.dart';

class SubjectScreen extends StatefulWidget {
  final int semester;

  const SubjectScreen({super.key, required this.semester});

  static const Map<int, List<Map<String, dynamic>>> semesterSubjects = {
    1: [
      {"name": "Linear Algebra & Calculus", "icon": Icons.calculate, "color": Color(0xFF1D4ED8)},
      {"name": "Engineering Chemistry", "icon": Icons.science, "color": Color(0xFF0F766E)},
      {"name": "Technical Communication", "icon": Icons.record_voice_over, "color": Color(0xFFB45309)},
      {"name": "Programming & Data Structures", "icon": Icons.code, "color": Color(0xFF7C3AED)},
      {"name": "Design Thinking", "icon": Icons.lightbulb, "color": Color(0xFF0369A1)},
      {"name": "PDS Lab", "icon": Icons.computer, "color": Color(0xFF0F766E)},
      {"name": "EAA (Sports/Yoga)", "icon": Icons.sports_soccer, "color": Color(0xFFB91C1C)},
    ],
    2: [
      {"name": "Laplace & Vector Calculus", "icon": Icons.calculate, "color": Color(0xFF1D4ED8)},
      {"name": "Engineering Physics", "icon": Icons.science, "color": Color(0xFFB45309)},
      {"name": "Engineering Mechanics", "icon": Icons.engineering, "color": Color(0xFF15803D)},
      {"name": "Building Planning & Drawing", "icon": Icons.architecture, "color": Color(0xFF7C3AED)},
      {"name": "Biology for Engineers", "icon": Icons.biotech, "color": Color(0xFF0F766E)},
      {"name": "Workshop Practice", "icon": Icons.build, "color": Color(0xFFB91C1C)},
      {"name": "Civil Engineering Materials", "icon": Icons.apartment, "color": Color(0xFF0369A1)},
      {"name": "EAA II", "icon": Icons.sports, "color": Color(0xFFBE185D)},
    ],
    3: [
      {"name": "Business Essentials", "icon": Icons.business, "color": Color(0xFF1D4ED8)},
      {"name": "Surveying", "icon": Icons.map, "color": Color(0xFFB45309)},
      {"name": "Fluid Mechanics", "icon": Icons.water, "color": Color(0xFF15803D)},
      {"name": "Strength of Materials", "icon": Icons.fitness_center, "color": Color(0xFF7C3AED)},
      {"name": "Geotechnical Engineering", "icon": Icons.landscape, "color": Color(0xFF0F766E)},
      {"name": "Surveying Lab", "icon": Icons.science, "color": Color(0xFFB91C1C)},
      {"name": "Geotechnical Lab", "icon": Icons.science, "color": Color(0xFF0369A1)},
    ],
    4: [
      {"name": "Fourier & PDE", "icon": Icons.calculate, "color": Color(0xFF1D4ED8)},
      {"name": "Structural Mechanics", "icon": Icons.account_tree, "color": Color(0xFFB45309)},
      {"name": "Hydrology & Irrigation", "icon": Icons.water_drop, "color": Color(0xFF15803D)},
      {"name": "Steel Structure Design", "icon": Icons.apartment, "color": Color(0xFF7C3AED)},
      {"name": "Foundation Engineering", "icon": Icons.foundation, "color": Color(0xFF0F766E)},
      {"name": "Fluid Mechanics Lab", "icon": Icons.science, "color": Color(0xFFB91C1C)},
      {"name": "SOM Lab", "icon": Icons.science, "color": Color(0xFF0369A1)},
    ],
    5: [
      {"name": "Environmental Engineering", "icon": Icons.eco, "color": Color(0xFF15803D)},
      {"name": "Theory of Structures", "icon": Icons.account_tree, "color": Color(0xFF1D4ED8)},
      {"name": "Concrete Design", "icon": Icons.apartment, "color": Color(0xFFB45309)},
      {"name": "Highway Engineering", "icon": Icons.alt_route, "color": Color(0xFF7C3AED)},
      {"name": "Professional Elective I", "icon": Icons.menu_book, "color": Color(0xFF0F766E)},
      {"name": "Fractal Course I", "icon": Icons.functions, "color": Color(0xFF0369A1)},
      {"name": "Environmental Lab", "icon": Icons.science, "color": Color(0xFFB91C1C)},
      {"name": "Concrete Lab", "icon": Icons.science, "color": Color(0xFFBE185D)},
    ],
    6: [
      {"name": "Construction Technology", "icon": Icons.engineering, "color": Color(0xFF1D4ED8)},
      {"name": "Airport & Railway Engg", "icon": Icons.flight, "color": Color(0xFFB45309)},
      {"name": "Professional Elective II", "icon": Icons.menu_book, "color": Color(0xFF15803D)},
      {"name": "Professional Elective III", "icon": Icons.menu_book, "color": Color(0xFF7C3AED)},
      {"name": "Product Development", "icon": Icons.build_circle, "color": Color(0xFF0F766E)},
      {"name": "Fractal Course II", "icon": Icons.functions, "color": Color(0xFF0369A1)},
      {"name": "Civil Software Lab", "icon": Icons.computer, "color": Color(0xFFB91C1C)},
      {"name": "Transportation Lab", "icon": Icons.alt_route, "color": Color(0xFFBE185D)},
    ],
    7: [
      {"name": "Hydraulic Structures", "icon": Icons.water, "color": Color(0xFF1D4ED8)},
      {"name": "Professional Elective IV", "icon": Icons.menu_book, "color": Color(0xFFB45309)},
      {"name": "Professional Elective V", "icon": Icons.menu_book, "color": Color(0xFF15803D)},
      {"name": "Open Elective I", "icon": Icons.school, "color": Color(0xFF7C3AED)},
      {"name": "Quantity Survey Lab", "icon": Icons.calculate, "color": Color(0xFF0F766E)},
      {"name": "RS & GIS Lab", "icon": Icons.map, "color": Color(0xFF0369A1)},
      {"name": "Seminar & Technical Writing", "icon": Icons.edit, "color": Color(0xFFB91C1C)},
      {"name": "Industrial Training", "icon": Icons.work, "color": Color(0xFFBE185D)},
      {"name": "Minor Project", "icon": Icons.assignment, "color": Color(0xFF92400E)},
    ],
    8: [
      {"name": "Professional Elective VI", "icon": Icons.menu_book, "color": Color(0xFF1D4ED8)},
      {"name": "Professional Elective VII", "icon": Icons.menu_book, "color": Color(0xFFB45309)},
      {"name": "Professional Elective VIII", "icon": Icons.menu_book, "color": Color(0xFF15803D)},
      {"name": "Major Project", "icon": Icons.engineering, "color": Color(0xFFB91C1C)},
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
      duration: const Duration(milliseconds: 400),
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = SubjectScreen.semesterSubjects[widget.semester] ?? [];
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: topPad + 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semester ${widget.semester}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${subjects.length} subjects',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Subject count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${subjects.length} subjects',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── SUBJECT LIST ─────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final color = subject["color"] as Color;

                final animation = Tween(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: controller,
                  curve: Interval(
                    (index * 0.05).clamp(0.0, 0.6),
                    1.0,
                    curve: Curves.easeOut,
                  ),
                ));

                return FadeTransition(
                  opacity: controller,
                  child: SlideTransition(
                    position: animation,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MaterialListScreen(
                            semester: widget.semester,
                            subject: subject["name"],
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Colored icon panel
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(18),
                                ),
                              ),
                              child: Icon(
                                subject["icon"] as IconData,
                                color: color,
                                size: 32,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Subject name + tap hint
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject["name"],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'View materials',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: color.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Arrow
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
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