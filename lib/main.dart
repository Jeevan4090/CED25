import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/semester_screen.dart';

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

  Future<bool> checkLogin() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool("isLoggedIn") ?? false;

  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: "CED25",

      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),

      home: FutureBuilder(

        future: checkLogin(),

        builder: (context, snapshot) {

          if(!snapshot.hasData){
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if(snapshot.data == true){
            return const SemesterScreen();
          }

          return const LoginScreen();

        },

      ),

    );

  }
}