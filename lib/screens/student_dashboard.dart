import 'package:flutter/material.dart';

import 'semester_screen.dart';
import 'upload_screen.dart';
import 'analytics_screen.dart';
import 'students_screen.dart';
import 'profile_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5F9),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                /// TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "CED25",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        child: Icon(Icons.person),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// GREEN GREETING CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff2E9B66),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [

                          Text(
                            "Hello Student 👋",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Ready to study today?",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 32,
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// ACTION GRID
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,

                  children: [

                    dashboardCard(
                      context,
                      "Browse Materials",
                      Icons.folder,
                      const Color(0xffDEE7FF),
                      const Color(0xff3D5AFE),
                      const SemesterScreen(),
                    ),

                    dashboardCard(
                      context,
                      "Upload Material",
                      Icons.upload_file,
                      const Color(0xffFFE9CC),
                      const Color(0xffFF9800),
                      const UploadScreen(),
                    ),

                    dashboardCard(
                      context,
                      "Analytics",
                      Icons.bar_chart,
                      const Color(0xffFFDADA),
                      const Color(0xffE53935),
                      const AnalyticsScreen(),
                    ),

                    dashboardCard(
                      context,
                      "Students",
                      Icons.group,
                      const Color(0xffDDF5E8),
                      const Color(0xff2E9B66),
                      const StudentsScreen(isAdmin: false),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// DECORATIVE STUDY CARD
                Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Row(
                    children: const [

                      Icon(
                        Icons.menu_book,
                        size: 32,
                        color: Color(0xff2E9B66),
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "Share notes and help your classmates learn better.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Icon(
              icon,
              size: 30,
              color: iconColor,
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}