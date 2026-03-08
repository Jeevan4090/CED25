import 'package:flutter/material.dart';
import 'semester_screen.dart';
import 'upload_screen.dart';
import 'package:ced25/screens/admins_screen.dart' as admin;
import 'package:ced25/screens/students_screen.dart' as student;
import 'generate_code_screen.dart';

class DashboardScreen extends StatelessWidget {

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: GridView.count(

          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,

          children: [

  dashboardTile(
    context,
    "Browse Materials",
    Icons.menu_book,
    Colors.blue,
    (){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SemesterScreen(),
        ),
      );
    },
  ),

  dashboardTile(
    context,
    "Upload Material",
    Icons.upload,
    Colors.orange,
    (){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const UploadScreen(
  semester: 1,
  subject: "General",
),
        ),
      );
    },
  ),
  dashboardTile(
  context,
  "Generate Code",
  Icons.vpn_key,
  Colors.red,
  (){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GenerateCodeScreen(),
      ),
    );
  },
),

  dashboardTile(
    context,
    "Students",
    Icons.people,
    Colors.green,
    (){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const student.StudentsScreen(),
        ),
      );
    },
  ),

  dashboardTile(
    context,
    "Admins",
    Icons.admin_panel_settings,
    Colors.purple,
    (){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const admin.AdminsScreen(),
        ),
      );
    },
  ),

]
        ),
      ),
    );
  }

  Widget dashboardTile(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap
      ){

    return GestureDetector(

      onTap: onTap,

      child: Container(

        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color,width: 2),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 40,
              color: color,
            ),

            const SizedBox(height:10),

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )

          ],
        ),
      ),
    );
  }
}