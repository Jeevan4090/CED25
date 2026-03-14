import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/student_dashboard.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/semester_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const Ced25App());
}

class Ced25App extends StatelessWidget {
  const Ced25App({super.key});

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CED25",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),

      home: FutureBuilder<String?>(
        future: getUserRole(),
        builder: (context, snapshot) {

          /// Loading screen while checking login
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final role = snapshot.data;

          /// Student auto login
          if (role == "student") {
  return const StudentDashboard();
}

          /// Admin auto login
          if (role == "admin") {
            return const DashboardScreen();
          }

          /// Default → Login screen
          return const LoginScreen();
        },
      ),
    );
  }
}