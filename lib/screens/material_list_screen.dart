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

class _MaterialListScreenState extends State<MaterialListScreen>
    with SingleTickerProviderStateMixin {
  final materialService = MaterialService();

  late Future<List<Map<String, dynamic>>> materialsFuture;

  late AnimationController controller;

  /// SEARCH VARIABLES
  List<Map<String, dynamic>> allMaterials = [];
  List<Map<String, dynamic>> filteredMaterials = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    materialsFuture = materialService.fetchMaterials(
      widget.semester,
      widget.subject,
    );

    materialsFuture.then((data) {
      allMaterials = data;
      filteredMaterials = data;
    });

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    controller.forward();
  }

  /// SEARCH FUNCTION
  void filterMaterials(String query) {
    final results = allMaterials.where((material) {
      final title = material["title"].toString().toLowerCase();
      final type = material["type"].toString().toLowerCase();

      return title.contains(query.toLowerCase()) ||
          type.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredMaterials = results;
    });
  }

  Future<void> refreshMaterials() async {
    final data = await materialService.fetchMaterials(
      widget.semester,
      widget.subject,
    );

    setState(() {
      allMaterials = data;
      filteredMaterials = data;
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

              refreshMaterials();
            },
          ),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: materialsFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading materials"));
          }

          final materials = snapshot.data ?? [];

          if (materials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.folder_open, size: 60, color: Colors.grey),

                  SizedBox(height: 10),

                  Text(
                    "No materials uploaded yet",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

                child: TextField(
                  controller: searchController,
                  onChanged: filterMaterials,

                  decoration: InputDecoration(
                    hintText: "Search materials...",

                    prefixIcon: const Icon(Icons.search),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshMaterials,

                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: filteredMaterials.length,

                    itemBuilder: (context, index) {
                      final material = filteredMaterials[index];

                      final animation =
                          Tween(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: controller,
                              curve: Interval(
                                index * 0.08,
                                1,
                                curve: Curves.easeOut,
                              ),
                            ),
                          );

                      return FadeTransition(
                        opacity: controller,

                        child: SlideTransition(
                          position: animation,

                          child: MaterialTile(
                            title: material["title"],
                            type: material["type"],
                            fileUrl: material["file_url"],
                            uploadedBy: material["uploaded_by"],
                            createdAt: material["created_at"], // NEW
                            onDelete: () async {
                              await MaterialService().deleteMaterial(
                                material["id"],
                                material["file_url"],
                              );

                              setState(() {
                                materialsFuture = MaterialService()
                                    .fetchMaterials(
                                      widget.semester,
                                      widget.subject,
                                    );
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
