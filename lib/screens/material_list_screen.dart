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

  List<Map<String, dynamic>> allMaterials = [];
  List<Map<String, dynamic>> filteredMaterials = [];
  TextEditingController searchController = TextEditingController();
  String selectedType = 'All';

  final List<String> types = ['All', 'Notes', 'PYQ', 'Assignment', 'Lab', 'Important'];

  final Map<String, Color> typeColors = {
    'All':        const Color(0xFF1D4ED8),
    'Notes':      const Color(0xFF0EA5E9),
    'PYQ':        const Color(0xFFF59E0B),
    'Assignment': const Color(0xFF10B981),
    'Lab':        const Color(0xFF06B6D4),
    'Important':  const Color(0xFFEF4444),
  };

  final Map<String, IconData> typeIcons = {
    'All':        Icons.grid_view_rounded,
    'Notes':      Icons.description_rounded,
    'PYQ':        Icons.quiz_rounded,
    'Assignment': Icons.assignment_rounded,
    'Lab':        Icons.science_rounded,
    'Important':  Icons.star_rounded,
  };

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadMaterials();
  }

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    materialsFuture = materialService.fetchMaterials(
      widget.semester,
      widget.subject,
    );
    final data = await materialsFuture;
    setState(() {
      allMaterials = data;
      filteredMaterials = data;
    });
    controller.forward();
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredMaterials = allMaterials.where((m) {
        final matchesSearch = m["title"].toString().toLowerCase().contains(query) ||
            m["type"].toString().toLowerCase().contains(query);
        final matchesType = selectedType == 'All' ||
            m["type"].toString() == selectedType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  Future<void> refreshMaterials() async {
    controller.reset();
    final data = await materialService.fetchMaterials(
      widget.semester,
      widget.subject,
    );
    setState(() {
      allMaterials = data;
      filteredMaterials = data;
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // ── HEADER ────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: topPad + 16,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Semester ${widget.semester}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Upload button
                    GestureDetector(
                      onTap: () async {
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => _applyFilters(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search materials...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.white.withOpacity(0.6), size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── TYPE FILTER CHIPS ──────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final t = types[index];
                final isSelected = selectedType == t;
                final color = typeColors[t]!;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedType = t);
                    _applyFilters();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcons[t],
                            size: 13,
                            color: isSelected ? Colors.white : color),
                        const SizedBox(width: 5),
                        Text(
                          t,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── MATERIALS LIST ─────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: materialsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1D4ED8)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 52, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        const Text('Error loading materials',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                if (filteredMaterials.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.folder_open_rounded,
                              size: 48, color: Color(0xFF1D4ED8)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No materials found',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try a different filter or upload one!',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: refreshMaterials,
                  color: const Color(0xFF1D4ED8),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: filteredMaterials.length,
                    itemBuilder: (context, index) {
                      final material = filteredMaterials[index];

                      final animation = Tween(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: controller,
                        curve: Interval(
                          (index * 0.08).clamp(0.0, 1.0),
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ));

                      return FadeTransition(
                        opacity: controller,
                        child: SlideTransition(
                          position: animation,
                          child: MaterialTile(
                            title: material["title"],
                            type: material["type"],
                            fileUrl: material["file_url"],
                            uploadedBy: material["uploaded_by"],
                            createdAt: material["created_at"],
                            onDelete: () async {
                              await MaterialService().deleteMaterial(
                                material["id"],
                                material["file_url"],
                              );
                              refreshMaterials();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}