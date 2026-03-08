import 'package:flutter/material.dart';

class AdminsScreen extends StatelessWidget {

  const AdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final admins = [
      "Admin 1",
      "Admin 2"
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admins"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(

        itemCount: admins.length,

        itemBuilder: (context,index){

          return ListTile(

            leading: const Icon(Icons.admin_panel_settings),

            title: Text(admins[index]),

            trailing: IconButton(
              icon: const Icon(Icons.delete,color: Colors.red),
              onPressed: (){},
            ),

          );
        },
      ),
    );
  }
}