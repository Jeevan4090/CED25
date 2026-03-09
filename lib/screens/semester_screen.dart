import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'subject_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SemesterScreen extends StatefulWidget {
  const SemesterScreen({super.key});

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen>
    with SingleTickerProviderStateMixin {

  final List<int> semesters = const [1,2,3,4,5,6,7,8];

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

      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Select Semester"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () {
              showDialog(
                context: context,

                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),

                  actions: [

                    TextButton(
                      onPressed: (){
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
          )
        ],
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(18),

        itemCount: semesters.length,

        itemBuilder: (context,index){

          final semester = semesters[index];
          final color = getColor(index);

          final animation = Tween(
            begin: const Offset(1,0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(
                index * 0.08,
                1,
                curve: Curves.easeOut,
              ),
            ),
          );

          return SlideTransition(
            position: animation,

            child: Padding(
              padding: const EdgeInsets.only(bottom:16),

              child: InkWell(

                borderRadius: BorderRadius.circular(30),

                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubjectScreen(semester: semester),
                    ),
                  );
                },

                child: Container(

                  padding: const EdgeInsets.symmetric(
                    horizontal:20,
                    vertical:18,
                  ),

                  decoration: BoxDecoration(

                    color: color.withOpacity(0.12),

                    borderRadius: BorderRadius.circular(30),

                    border: Border.all(
                      color: color.withOpacity(0.4),
                    ),
                  ),

                  child: Row(
                    children: [

                      Container(
                        height:44,
                        width:44,

                        decoration: BoxDecoration(
                          color: color.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Icon(
                          Icons.school,
                          color: color,
                        ),
                      ),

                      const SizedBox(width:16),

                      Expanded(
                        child: Text(
                          "Semester $semester",

                          style: const TextStyle(
                            fontSize:18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_ios,
                        size:18,
                        color: color,
                      ),
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