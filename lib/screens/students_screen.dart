import 'package:flutter/material.dart';

class StudentsScreen extends StatelessWidget {

  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final students = [
      "A12345",
      "B12345",
      "C54321"
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Students"),
      ),

      body: ListView.builder(

        itemCount: students.length,

        itemBuilder: (context,index){

          return ListTile(

            leading: const Icon(Icons.person),

            title: Text(students[index]),

            trailing: IconButton(
              icon: const Icon(Icons.delete,color: Colors.red),
              onPressed: (){},
            ),

          );
        },
      ),
    );
  }
}