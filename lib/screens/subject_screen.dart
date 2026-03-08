import 'package:flutter/material.dart';
import 'material_list_screen.dart';

class SubjectScreen extends StatelessWidget {

  final int semester;

  const SubjectScreen({super.key, required this.semester});

  final List<Map<String, dynamic>> subjects = const [

    {
      "name": "Mathematics",
      "icon": Icons.calculate,
      "color": Colors.blue
    },

    {
      "name": "Data Structures",
      "icon": Icons.memory,
      "color": Colors.orange
    },

    {
      "name": "DBMS",
      "icon": Icons.storage,
      "color": Colors.green
    },

    {
      "name": "Operating Systems",
      "icon": Icons.settings,
      "color": Colors.purple
    },

    {
      "name": "Computer Networks",
      "icon": Icons.public,
      "color": Colors.red
    }

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Semester $semester"),
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: subjects.length,

        itemBuilder: (context,index){

          final subject = subjects[index];

          return GestureDetector(

            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MaterialListScreen(
                    semester: semester,
                    subject: subject["name"],
                  ),
                ),
              );
            },

            child: Container(

              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: subject["color"].withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: subject["color"],width: 2),
              ),

              child: Row(
                children: [

                  CircleAvatar(
                    backgroundColor: subject["color"],
                    child: Icon(
                      subject["icon"],
                      color: Colors.white,
                    ),
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

                  const Icon(Icons.arrow_forward)

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}