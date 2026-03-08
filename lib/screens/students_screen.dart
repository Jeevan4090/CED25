import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {

  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> studentsFuture;

  @override
  void initState() {
    super.initState();
    studentsFuture = getStudents();
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
            return const Center(child: Text("No students yet"));
          }

          return ListView.builder(

            itemCount: students.length,

            itemBuilder: (context, index){

              final student = students[index];

              return ListTile(

                title: Text(student["name"] ?? "No Name"),

                subtitle: Text(student["access_code"]),

                trailing: IconButton(

                  icon: const Icon(Icons.delete, color: Colors.red),

                  onPressed: () async {
                    await deleteStudent(student["id"]);
                  },

                ),

              );

            },
          );
        },
      ),
    );
  }
}