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

  Future<void> deleteAdmin(String id) async {

    await supabase
        .from('admins')
        .delete()
        .eq('id', id);

    setState(() {
      adminsFuture = getAdmins();
    });

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

            itemCount: admins.length,

            itemBuilder: (context, index) {

              final admin = admins[index];

              return ListTile(

                title: Text(admin["name"] ?? "No Name"),

                subtitle: Text(admin["access_code"] ?? ""),

                trailing: IconButton(

                  icon: const Icon(Icons.delete, color: Colors.red),

                  onPressed: () async {
                    await deleteAdmin(admin["id"]);
                  },

                ),

              );

            },
          );
        },
      ),
    );
  }
}