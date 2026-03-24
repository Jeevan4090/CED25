import 'package:flutter/material.dart';
import 'subject_screen.dart';
import 'profile_screen.dart';

class SemesterScreen extends StatefulWidget {
  const SemesterScreen({super.key});

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen>
    with SingleTickerProviderStateMixin {
  final List<int> semesters = const [1, 2, 3, 4, 5, 6, 7, 8];

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

  // Each semester gets a distinct gradient — no purple
  List<Color> _gradientForIndex(int index) {
    final gradients = [
      [const Color(0xFF1D4ED8), const Color(0xFF38BDF8)], // blue
      [const Color(0xFF0F766E), const Color(0xFF2DD4BF)], // teal
      [const Color(0xFFB45309), const Color(0xFFFBBF24)], // amber
      [const Color(0xFF15803D), const Color(0xFF4ADE80)], // green
      [const Color(0xFFB91C1C), const Color(0xFFF87171)], // red
      [const Color(0xFF0369A1), const Color(0xFF7DD3FC)], // sky
      [const Color(0xFFB45309), const Color(0xFFFCD34D)], // yellow
      [const Color(0xFF0F766E), const Color(0xFF5EEAD4)], // cyan
    ];
    return gradients[index % gradients.length];
  }

  final List<String> _semesterLabels = [
    'Foundation',
    'Core Basics',
    'Structures I',
    'Structures II',
    'Advanced',
    'Specialization',
    'Electives',
    'Final Year',
  ];

  final List<IconData> _semesterIcons = [
    Icons.calculate_rounded,
    Icons.biotech_rounded,
    Icons.water_rounded,
    Icons.foundation_rounded,
    Icons.traffic_rounded,
    Icons.construction_rounded,
    Icons.map_rounded,
    Icons.engineering_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // ── HEADER ────────────────────────────────────────────────
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse Materials',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Select your semester',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF38BDF8)],
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFEEF2FF),
                      child: Icon(Icons.person_rounded,
                          color: Color(0xFF6366F1), size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── SEMESTER LIST ──────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: controller,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                itemCount: semesters.length,
                itemBuilder: (context, index) {
                  final semester = semesters[index];
                  final gradient = _gradientForIndex(index);
                  final label = _semesterLabels[index];
                  final icon = _semesterIcons[index];

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectScreen(semester: semester),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(20),
                              ),
                            ),
                            child: Icon(icon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Semester $semester',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: gradient[0].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: gradient[0],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}