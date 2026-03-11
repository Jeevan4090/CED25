import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsScreen extends StatefulWidget {

  final bool isAdmin;

  const StudentsScreen({
    super.key,
    this.isAdmin = false,
  });

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen>
    with SingleTickerProviderStateMixin {

  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> studentsFuture;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    studentsFuture = getStudents();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    controller.forward();
  }

  Future<List<Map<String, dynamic>>> getStudents() async {

    final response = await supabase
        .from('students')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteStudent(String id) async {

    await supabase
        .from('students')
        .delete()
        .eq('id', id);

    setState(() {
      studentsFuture = getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Students"),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(

        future: studentsFuture,

        builder: (context, snapshot) {

          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }

          if(snapshot.hasError){
            return const Center(child: Text("Error loading students"));
          }

          final students = snapshot.data ?? [];

          if(students.isEmpty){

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [

                  Icon(
                    Icons.people_outline,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 10),

                  Text(
                    "No students yet",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            );
          }

          return ListView.builder(

            padding: const EdgeInsets.all(16),

            itemCount: students.length,

            itemBuilder: (context, index){

              final student = students[index];

              final animation = Tween(
                begin: const Offset(0,0.2),
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

              return FadeTransition(

                opacity: controller,

                child: SlideTransition(

                  position: animation,

                  child: Container(

                    margin: const EdgeInsets.only(bottom:14),

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0,4),
                        )
                      ],
                    ),

                    child: Row(
                      children: [

                        /// avatar
                        const CircleAvatar(
                          radius: 22,
                          child: Icon(Icons.person),
                        ),

                        const SizedBox(width:14),

                        /// name + code
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(
                                student["name"] ?? "No Name",

                                style: const TextStyle(
                                  fontSize:16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height:2),

                              Text(
                                "Code: ${student["access_code"]}",

                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// delete button (ADMIN ONLY)
                        if (widget.isAdmin)
                          IconButton(

                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),

                            onPressed: () async {
                              await deleteStudent(student["id"]);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}