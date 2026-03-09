
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> adminsFuture;

  @override
  void initState() {
    super.initState();
    adminsFuture = getAdmins();
  }

  Future<List<Map<String, dynamic>>> getAdmins() async {
    final response = await supabase
        .from('admins')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admins"),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: adminsFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading admins"));
          }

          final admins = snapshot.data ?? [];

          if (admins.isEmpty) {
            return const Center(child: Text("No admins yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: admins.length,

            itemBuilder: (context, index) {

              final admin = admins[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),

                child: Container(

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0,4),
                      )
                    ],
                  ),

                  child: Row(
                    children: [

                      /// Crown Icon (Royal)
                      Container(
                        height: 46,
                        width: 46,

                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.amber,
                          size: 26,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// Admin info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(
                              admin["name"] ?? "No Name",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Created: ${admin["created_at"].toString().substring(0,10)}",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Admin badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: const Text(
                          "ADMIN",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

