import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const String name = "Student";
    const String year = "1";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            /// Avatar
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.deepPurple,
              child: Text(
                name[0],
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Name
            const Text(
              name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// Year
            const Text(
              "Year 1",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            /// Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),

              child: const Column(
                children: [

                  Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 12),
                      Text("Name"),
                      Spacer(),
                      Text(name),
                    ],
                  ),

                  Divider(),

                  Row(
                    children: [
                      Icon(Icons.school),
                      SizedBox(width: 12),
                      Text("Year"),
                      Spacer(),
                      Text(year),
                    ],
                  ),

                ],
              ),
            ),

            const Spacer(),

            /// Logout
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}