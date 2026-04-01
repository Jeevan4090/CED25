import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final supabase = Supabase.instance.client;

  int totalStudents = 0;
  int totalMaterials = 0;
  int totalUploads = 0;
  int uploadsThisWeek = 0;

  List<int> semesterCounts = List.filled(8, 0);
  List<int> weeklyUploads = List.filled(7, 0);
  List<Map<String, dynamic>> recentUploads = [];
  List<Map<String, dynamic>> topUploaders = [];
  bool _loading = true;
  int? _touchedBarIndex;

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    setState(() => _loading = true);

    final students = await supabase.from('students').select();
    final materials = await supabase.from('materials').select();

    int uploadsWeek = 0;
    List<int> semCounts = List.filled(8, 0);
    List<int> weekCounts = List.filled(7, 0);
    Map<String, int> uploaderMap = {};
    DateTime now = DateTime.now();

    for (var item in materials) {
      DateTime created =
          DateTime.tryParse(item['created_at']?.toString() ?? '') ??
          DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final createdDate = DateTime(created.year, created.month, created.day);
      final diff = today.difference(createdDate).inDays;
      if (diff >= 0 && diff < 7) {
        uploadsWeek++;
        weekCounts[6 - diff] += 1;
      }
      int sem = int.tryParse(item['semester']?.toString() ?? '') ?? 0;
      if (sem >= 1 && sem <= 8) semCounts[sem - 1]++;

      String uploader = item['uploaded_by']?.toString() ?? 'Unknown';
      uploaderMap[uploader] = (uploaderMap[uploader] ?? 0) + 1;
    }

    var sorted = uploaderMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<Map<String, dynamic>> uploaders = sorted
        .take(3)
        .map((e) => {'name': e.key, 'uploads': e.value})
        .toList();

    final recent = await supabase
        .from('materials')
        .select('title,created_at')
        .order('created_at', ascending: false)
        .limit(5);

    setState(() {
      totalStudents = students.length;
      totalMaterials = materials.length;
      totalUploads = materials.length;
      uploadsThisWeek = uploadsWeek;
      semesterCounts = semCounts;
      weeklyUploads = weekCounts;
      recentUploads = List<Map<String, dynamic>>.from(recent);
      topUploaders = uploaders;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, topPad)),
                SliverToBoxAdapter(child: _buildStatGrid()),
                SliverToBoxAdapter(
                  child: _buildSectionCard(
                    title: 'Materials by Semester',
                    subtitle: 'Distribution across all 8 semesters',
                    icon: Icons.bar_chart_rounded,
                    iconColor: const Color(0xFF6366F1),
                    child: _semesterBarChart(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionCard(
                    title: 'Upload Trends',
                    subtitle: 'Last 7 days activity',
                    icon: Icons.show_chart_rounded,
                    iconColor: const Color(0xFF0EA5E9),
                    child: _uploadTrendChart(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionCard(
                    title: 'Top Uploaders',
                    subtitle: 'Most active contributors',
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    child: _buildTopUploaders(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionCard(
                    title: 'Recent Uploads',
                    subtitle: 'Latest materials added',
                    icon: Icons.history_rounded,
                    iconColor: const Color(0xFF10B981),
                    child: _buildRecentUploads(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, double topPad) {
    return Container(
      padding: EdgeInsets.only(
        top: topPad + 16,
        left: 24,
        right: 20,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white70,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Overview of your platform',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          _HeaderIconBtn(icon: Icons.refresh_rounded, onTap: loadAnalytics),
        ],
      ),
    );
  }

  // ── STAT GRID ─────────────────────────────────────────────────────────────

  Widget _buildStatGrid() {
    final stats = [
      _StatData('Students', totalStudents, Icons.people_alt_rounded, [
        const Color(0xFF6366F1),
        const Color(0xFF818CF8),
      ]),
      _StatData('Materials', totalMaterials, Icons.menu_book_rounded, [
        const Color(0xFF0EA5E9),
        const Color(0xFF38BDF8),
      ]),
      _StatData('Total Uploads', totalUploads, Icons.cloud_upload_rounded, [
        const Color(0xFF10B981),
        const Color(0xFF34D399),
      ]),
      _StatData('This Week', uploadsThisWeek, Icons.trending_up_rounded, [
        const Color(0xFFF59E0B),
        const Color(0xFFFBBF24),
      ]),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (_, i) => _StatCard(data: stats[i]),
      ),
    );
  }

  // ── SECTION CARD WRAPPER ──────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  // ── SEMESTER BAR CHART ────────────────────────────────────────────────────

  Widget _semesterBarChart() {
    final maxY = (semesterCounts.reduce((a, b) => a > b ? a : b).toDouble() + 2)
        .clamp(4.0, double.infinity);

    const gradients = [
      [Color(0xFF6366F1), Color(0xFF818CF8)],
      [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
      [Color(0xFF10B981), Color(0xFF34D399)],
      [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      [Color(0xFFEF4444), Color(0xFFF87171)],
      [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      [Color(0xFF06B6D4), Color(0xFF67E8F9)],
      [Color(0xFFEC4899), Color(0xFFF9A8D4)],
    ];

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchCallback: (event, response) {
              setState(() {
                _touchedBarIndex = response?.spot?.touchedBarGroupIndex;
              });
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    '${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.shade100, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'S${value.toInt()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          barGroups: List.generate(8, (i) {
            final isTouched = _touchedBarIndex == i;
            return BarChartGroupData(
              x: i + 1,
              barRods: [
                BarChartRodData(
                  toY: semesterCounts[i].toDouble(),
                  width: isTouched ? 22 : 18,
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: gradients[i],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── UPLOAD TREND CHART ────────────────────────────────────────────────────

  Widget _uploadTrendChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.shade100, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= 7) return const SizedBox();
                  // index 6 = today, index 0 = 6 days ago
                  final day = DateTime.now().subtract(Duration(days: 6 - i));
                  final label = DateFormat(
                    'E',
                  ).format(day)[0]; // 'M','T','W' etc.
                  final isToday = i == 6;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday
                            ? const Color(0xFF0EA5E9) // highlight today
                            : Colors.grey.shade500,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                7,
                (i) => FlSpot(i.toDouble(), weeklyUploads[i].toDouble()),
              ),
              isCurved: true,
              barWidth: 3,
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: const Color(0xFF0EA5E9),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0EA5E9).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP UPLOADERS ─────────────────────────────────────────────────────────

  Widget _buildTopUploaders() {
    if (topUploaders.isEmpty) {
      return _emptyState('No upload data yet');
    }

    final medals = ['🥇', '🥈', '🥉'];
    final colors = [
      const Color(0xFFFEF3C7),
      const Color(0xFFF1F5F9),
      const Color(0xFFFFF7ED),
    ];
    final textColors = [
      const Color(0xFFD97706),
      const Color(0xFF64748B),
      const Color(0xFFEA580C),
    ];

    return Column(
      children: topUploaders.asMap().entries.map((entry) {
        final i = entry.key;
        final user = entry.value;
        final pct = topUploaders[0]['uploads'] > 0
            ? (user['uploads'] as int) / (topUploaders[0]['uploads'] as int)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors[i],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(medals[i], style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor: Colors.black.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            textColors[i],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: textColors[i].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${user["uploads"]}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: textColors[i],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── RECENT UPLOADS ────────────────────────────────────────────────────────

  Widget _buildRecentUploads() {
    if (recentUploads.isEmpty) {
      return _emptyState('No recent uploads');
    }

    return Column(
      children: recentUploads.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final date =
            DateTime.tryParse(item['created_at']?.toString() ?? '') ??
            DateTime.now();
        final isLast = i == recentUploads.length - 1;

        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.insert_drive_file_rounded,
                    color: Color(0xFF6366F1),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Untitled',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM yyyy').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.fromLTRB(52, 8, 0, 8),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
      ),
    );
  }
}

// ── HELPERS ──────────────────────────────────────────────────────────────────

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _StatData {
  final String label;
  final int value;
  final IconData icon;
  final List<Color> gradient;
  const _StatData(this.label, this.value, this.icon, this.gradient);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.gradient.first.withOpacity(0.3),
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
            child: Icon(data.icon, color: Colors.white, size: 16),
          ),
          const Spacer(),
          TweenAnimationBuilder(
            tween: IntTween(begin: 0, end: data.value),
            duration: const Duration(milliseconds: 900),
            builder: (_, val, __) => Text(
              '$val',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
