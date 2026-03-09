import 'dart:ui';
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

    final student = await supabase
        .from('students')
        .select()
        .eq('access_code', code)
        .maybeSingle();

    if (student != null) {
      await supabase
          .from('students')
          .update({"name": name})
          .eq('access_code', code);

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
      backgroundColor: AppColors.background,

      body: Stack(
        children: [
          /// Soft gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Center Glass Card
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),

                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// App Title
                        const Text(
                          "CED25",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Engineering Study Materials",
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// Name Field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.hoverSurface,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: "Your Name",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Access Code Field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.hoverSurface,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: codeController,
                            decoration: const InputDecoration(
                              hintText: "Access Code",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        /// Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 45,

                          child: ElevatedButton(
                            onPressed: () async {
                              await login();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Enter",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
