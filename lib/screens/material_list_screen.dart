import 'package:flutter/material.dart';
import '../services/material_service.dart';
import '../widgets/material_tile.dart';
import 'upload_screen.dart';

class MaterialListScreen extends StatefulWidget {

  final int semester;
  final String subject;

  const MaterialListScreen({
    super.key,
    required this.semester,
    required this.subject,
  });

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {

  final materialService = MaterialService();

  late Future<List<Map<String, dynamic>>> materialsFuture;

  @override
  void initState() {
    super.initState();

    materialsFuture = materialService.fetchMaterials(
      widget.semester,
      widget.subject,
    );
  }
  Future<void> refreshMaterials() async {

  setState(() {
    materialsFuture = materialService.fetchMaterials(
      widget.semester,
      widget.subject,
    );
  });

}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
  title: Text(widget.subject),

  actions: [

    IconButton(
      icon: const Icon(Icons.upload),
      onPressed: () async {

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UploadScreen(
        semester: widget.semester,
        subject: widget.subject,
      ),
    ),
  );

  setState(() {
    materialsFuture = materialService.fetchMaterials(
      widget.semester,
      widget.subject,
    );
  });

},
    ),

  ],
),
      body: FutureBuilder<List<Map<String, dynamic>>>(

        future: materialsFuture,

        builder: (context, snapshot) {

          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }

          if(snapshot.hasError){
            return const Center(child: Text("Error loading materials"));
          }

          final materials = snapshot.data ?? [];

          if(materials.isEmpty){
            return const Center(
              child: Text("No materials uploaded yet"),
            );
          }

          return RefreshIndicator(

  onRefresh: refreshMaterials,

  child: ListView.builder(

    padding: const EdgeInsets.all(16),

    itemCount: materials.length,

    itemBuilder: (context,index){

      final material = materials[index];

      return MaterialTile(
        title: material["title"],
        type: material["type"],
        fileUrl: material["file_url"],
      );

    },
  ),

);
        },
      ),
    );
  }
}