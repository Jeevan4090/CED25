import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // NEW
import '../theme/app_colors.dart';
import 'semester_screen.dart';
import 'upload_screen.dart';
import 'package:ced25/screens/admins_screen.dart' as admin;
import 'package:ced25/screens/students_screen.dart' as student;
import 'generate_code_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// LOGOUT FUNCTION
  Future<void> logout(BuildContext context) async {

    final supabase = Supabase.instance.client;

    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        title: const Text("Admin Dashboard"),

        actions: [

          /// LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () async {

              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Do you want to logout?"),
                  actions: [

                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),

                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),

                  ],
                ),
              );

              if (confirm == true) {
                logout(context);
              }

            },
          ),

        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Welcome Admin 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Manage study materials and students",
              style: TextStyle(color: AppColors.secondaryText),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,

                children: [

                  dashboardTile(
                    context,
                    "Browse Materials",
                    Icons.menu_book,
                    AppColors.primary,
                    () {
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
                    AppColors.accent,
                    () {
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
                    AppColors.warning,
                    () {
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
                    AppColors.success,
                    () {
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
                    AppColors.secondary,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const admin.AdminsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),

          padding: const EdgeInsets.all(22),

          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: color.withOpacity(0.25),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                height: 50,
                width: 50,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}