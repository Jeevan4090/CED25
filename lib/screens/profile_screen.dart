import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final nameController = TextEditingController();
  final yearController = TextEditingController();

  String name = 'Student';
  String year = '1';
  String accessCode = '';       // identifier instead of auth id
  bool isEditing = false;
  bool isLoading = true;
  bool isSaving = false;
  Map<DateTime, int> activityData = {};

  late AnimationController _animController;

  // Real stats
  int materialsCount = 0;
  int uploadsCount = 0;
  int viewsCount = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    // Load access_code + name from SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    accessCode = prefs.getString('access_code') ?? '';
    final savedName = prefs.getString('name') ?? 'Student';

    setState(() {
      name = savedName;
      nameController.text = savedName;
    });

    await Future.wait([fetchProfile(), fetchStats(), fetchHeatmap()]);
    _animController.forward();
  }

  // Fetch profile from studentprofile table using access_code
  Future<void> fetchProfile() async {
    try {
      if (accessCode.isEmpty) return;

      final data = await supabase
          .from('studentprofile')
          .select()
          .eq('access_code', accessCode)
          .maybeSingle();

      if (data != null) {
        setState(() {
          name = (data['name'] ?? name).toString();
          year = (data['year'] ?? 1).toString();
          nameController.text = name;
          yearController.text = year;
        });
      } else {
        // No profile row yet — create one
        await supabase.from('studentprofile').insert({
          'access_code': accessCode,
          'name': name,
          'year': 1,
        });
        setState(() {
          yearController.text = '1';
        });
      }
    } catch (e) {
      debugPrint('Profile error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Fetch real stats from materials table
  Future<void> fetchStats() async {
    try {
      // Total materials in the app
      final all = await supabase.from('materials').select('id');
      // Materials uploaded by this user
      final mine = await supabase
          .from('materials')
          .select('id')
          .eq('uploaded_by', name);

      setState(() {
        materialsCount = (all as List).length;
        uploadsCount = (mine as List).length;
      });
    } catch (e) {
      debugPrint('Stats error: $e');
    }
  }

  Future<void> fetchHeatmap() async {
    try {
      if (accessCode.isEmpty) return;
      final data = await supabase
          .from('activity_logs')
          .select()
          .eq('access_code', accessCode);
      final map = <DateTime, int>{};
      for (var item in data) {
        map[DateTime.parse(item['date'])] = item['count'];
      }
      setState(() => activityData = map);
    } catch (e) {
      debugPrint('Heatmap error: $e');
    }
  }

  // Save profile using access_code as identifier
  Future<void> updateProfile() async {
    setState(() => isSaving = true);
    try {
      final newName = nameController.text.trim();
      final newYear = int.tryParse(yearController.text) ?? 1;

      await supabase.from('studentprofile').upsert({
        'access_code': accessCode,
        'name': newName,
        'year': newYear,
      }, onConflict: 'access_code');

      // Also update name in students table + SharedPreferences
      await supabase
          .from('students')
          .update({'name': newName})
          .eq('access_code', accessCode);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', newName);

      setState(() {
        name = newName;
        year = newYear.toString();
        isEditing = false;
      });

      await fetchStats(); // refresh uploads count

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  Color _avatarColor(String n) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF0EA5E9),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
    ];
    return n.isEmpty ? colors[0] : colors[n.codeUnitAt(0) % colors.length];
  }

  String get _yearLabel {
    switch (year) {
      case '1': return '1st Year';
      case '2': return '2nd Year';
      case '3': return '3rd Year';
      case '4': return '4th Year';
      default: return 'Year $year';
    }
  }

  int get _totalActivity =>
      activityData.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildShimmer();

    final initial = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'S';
    final color = _avatarColor(name);
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ── HEADER ──────────────────────────────────────────────────
            _buildHeader(context, initial, color, topPad),

            const SizedBox(height: 20),

            /// ── EDIT FORM ───────────────────────────────────────────────
            if (isEditing) _buildEditForm(),

            /// ── STATS ───────────────────────────────────────────────────
            _buildStats(),

            const SizedBox(height: 8),

            /// ── HEATMAP ─────────────────────────────────────────────────
            _buildHeatmap(),

            const SizedBox(height: 16),

            /// ── LOGOUT ──────────────────────────────────────────────────
            _buildLogout(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String initial, Color color,
      double topPad) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
          top: topPad + 16, left: 20, right: 20, bottom: 28),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // Edit toggle
              GestureDetector(
                onTap: () => setState(() => isEditing = !isEditing),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEditing
                            ? Icons.close_rounded
                            : Icons.edit_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isEditing ? 'Cancel' : 'Edit',
                        style: const TextStyle(
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

          const SizedBox(height: 24),

          // Avatar
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_rounded,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      _yearLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── EDIT FORM ──────────────────────────────────────────────────────────────

  Widget _buildEditForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: Color(0xFF6366F1), size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Edit Profile',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 16),
          _formField(
            controller: nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          _formField(
            controller: yearController,
            label: 'Year (1–4)',
            icon: Icons.school_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSaving ? null : updateProfile,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
      ),
    );
  }

  // ── STATS ──────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    final stats = [
      _S('Materials', '$materialsCount', Icons.menu_book_rounded,
          [const Color(0xFF6366F1), const Color(0xFF818CF8)]),
      _S('Uploads', '$uploadsCount', Icons.cloud_upload_rounded,
          [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)]),
      _S('Views', '$viewsCount', Icons.visibility_rounded,
          [const Color(0xFF10B981), const Color(0xFF34D399)]),
      _S('Year', _yearLabel, Icons.school_rounded,
          [const Color(0xFFF59E0B), const Color(0xFFFBBF24)]),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (_, i) {
          final s = stats[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: s.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: s.gradient.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s.icon, color: Colors.white, size: 16),
                ),
                const Spacer(),
                Text(s.value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1)),
                const SizedBox(height: 3),
                Text(s.label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── HEATMAP ────────────────────────────────────────────────────────────────

  Widget _buildHeatmap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Color(0xFF059669), size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activity',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827))),
                  Text('$_totalActivity actions in last 4 months',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          HeatMap(
            datasets: activityData,
            startDate:
                DateTime.now().subtract(const Duration(days: 120)),
            colorMode: ColorMode.opacity,
            defaultColor: Colors.grey.shade100,
            colorsets: const {
              1: Color(0xFFA7F3D0),
              3: Color(0xFF6EE7B7),
              5: Color(0xFF34D399),
              7: Color(0xFF059669),
            },
            showText: false,
            scrollable: true,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400)),
              const SizedBox(width: 4),
              ...List.generate(5, (i) {
                final opacity = (i + 1) / 5;
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669)
                        .withOpacity(0.2 + opacity * 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
              const SizedBox(width: 4),
              Text('More',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Color(0xFFEF4444), size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text('Log out?',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    const SizedBox(height: 8),
                    Text('You will be returned to the login screen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              side: BorderSide(
                                  color: Colors.grey.shade300),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFEF4444),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            child: const Text('Log out',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          if (confirm == true) await supabase.auth.signOut();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFFFCA5A5), width: 1),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  color: Color(0xFFEF4444), size: 18),
              SizedBox(width: 8),
              Text('Log Out',
                  style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  // ── SHIMMER ────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Column(
          children: [
            Container(
              height: 260,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: List.generate(
                  4,
                  (_) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Simple data class for stat cards ─────────────────────────────────────────

class _S {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  const _S(this.label, this.value, this.icon, this.gradient);
}