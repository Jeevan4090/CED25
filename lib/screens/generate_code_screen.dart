import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GenerateCodeScreen extends StatefulWidget {
  const GenerateCodeScreen({super.key});

  @override
  State<GenerateCodeScreen> createState() => _GenerateCodeScreenState();
}

class _GenerateCodeScreenState extends State<GenerateCodeScreen> {

  final supabase = Supabase.instance.client;

  String? generatedCode;

  String createCode() {

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return "CED${timestamp.toString().substring(7)}";

  }

  Future<void> generate() async {

    final code = createCode();

    await supabase.from("students").insert({
      "access_code": code
    });

    setState(() {
      generatedCode = code;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Generate Student Code"),
      ),

      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: generate,
              child: const Text("Generate Code"),
            ),

            const SizedBox(height:20),

            if(generatedCode != null)
              Column(
                children: [

                  const Text(
                    "New Access Code",
                    style: TextStyle(fontSize:18),
                  ),

                  const SizedBox(height:10),

                  Text(
                    generatedCode!,
                    style: const TextStyle(
                      fontSize:28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              )

          ],
        ),
      ),
    );
  }
}