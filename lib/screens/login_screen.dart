import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'semester_screen.dart';
import 'dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  Future<void> login() async {
    final code = codeController.text.trim();
    final name = nameController.text.trim();

    final supabase = Supabase.instance.client;

    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter your name")));
      return;
    }
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter access code")));
      return;
    }

    // check admin
    final admin = await supabase
        .from('admins')
        .select()
        .eq('access_code', code)
        .maybeSingle();

    if (admin != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_code", code);
      await prefs.setString("name", name);
      await prefs.setBool("isLoggedIn", true);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );

      return;
    }

    // check student
    final student = await supabase
        .from('students')
        .select()
        .eq('access_code', code)
        .maybeSingle();

    if (student != null) {
      // save student name in database
      await supabase
          .from('students')
          .update({"name": name})
          .eq('access_code', code);

      // save login locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_code", code);
      await prefs.setString("name", name);
      await prefs.setBool("isLoggedIn", true);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SemesterScreen()),
      );

      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Invalid access code")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 99, 232),
              Color.fromARGB(255, 251, 195, 236),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "CED25",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Engineering Study Materials",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: nameController,

                    decoration: InputDecoration(
                      labelText: "Your Name",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,

                    decoration: InputDecoration(
                      labelText: "Access Code",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () async {
                        await login();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Enter",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
