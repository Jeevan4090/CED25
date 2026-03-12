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

  final List<Color> chartColors = const [
    Color(0xff4CAF50),
    Color(0xff2196F3),
    Color(0xffFF9800),
    Color(0xff9C27B0),
    Color(0xffF44336),
    Color(0xff00BCD4),
    Color(0xffFFC107),
    Color(0xff3F51B5),
  ];

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {

    final students = await supabase.from('students').select();
    final materials = await supabase.from('materials').select();

    int uploadsWeek = 0;
    List<int> semCounts = List.filled(8, 0);
    List<int> weekCounts = List.filled(7, 0);

    Map<String,int> uploaderMap = {};

    DateTime now = DateTime.now();

    for (var item in materials) {

      DateTime created =
          DateTime.tryParse(item['created_at']?.toString() ?? '')
          ?? DateTime.now();

      int diff = now.difference(created).inDays;

      if(diff < 7){
        uploadsWeek++;
        weekCounts[6 - diff] += 1;
      }

      int sem =
          int.tryParse(item['semester']?.toString() ?? '') ?? 0;

      if (sem >= 1 && sem <= 8) {
        semCounts[sem - 1]++;
      }

      String uploader =
          item['uploaded_by']?.toString() ?? "Unknown";

      uploaderMap[uploader] =
          (uploaderMap[uploader] ?? 0) + 1;
    }

    List<Map<String,dynamic>> uploaders = [];

    var sorted = uploaderMap.entries.toList()
      ..sort((a,b)=> b.value.compareTo(a.value));

    for(int i=0;i<sorted.length && i<3;i++){
      uploaders.add({
        "name": sorted[i].key,
        "uploads": sorted[i].value
      });
    }

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

      recentUploads =
          List<Map<String,dynamic>>.from(recent);

      topUploaders = uploaders;
    });
  }

  Widget animatedNumber(int value) {
    return TweenAnimationBuilder(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      builder: (context, val, child) {
        return Text(
          "$val",
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget statCard(String title, int value, IconData icon, Color color) {

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.9),
            color.withOpacity(.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(icon,color: Colors.white),

          const Spacer(),

          animatedNumber(value),

          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget semesterBarChart() {

    double maxY = semesterCounts.reduce((a,b)=> a>b?a:b).toDouble() + 1;

    return SizedBox(
      height: 260,

      child: BarChart(

        BarChartData(

          maxY: maxY,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),

          borderData: FlBorderData(show:false),

          titlesData: FlTitlesData(

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text("S${value.toInt()}");
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),

          barGroups: List.generate(8, (i){

            return BarChartGroupData(

              x: i+1,

              barRods: [

                BarChartRodData(

                  toY: semesterCounts[i].toDouble(),

                  width: 18,

                  borderRadius: BorderRadius.circular(8),

                  gradient: LinearGradient(
                    colors: [
                      chartColors[i],
                      chartColors[i].withOpacity(.6)
                    ],
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget uploadTrendChart(){

    return SizedBox(
      height:240,

      child: LineChart(

        LineChartData(

          gridData: FlGridData(show:true),

          borderData: FlBorderData(show:false),

          titlesData: FlTitlesData(

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles:true,
                getTitlesWidget:(value,meta){

                  const days = ["M","T","W","T","F","S","S"];

                  int i = value.toInt();

                  if(i<0 || i>=7) return const SizedBox();

                  return Text(days[i]);
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles:true),
            ),
          ),

          lineBarsData: [

            LineChartBarData(

              spots: List.generate(7,(i){
                return FlSpot(
                    i.toDouble(),
                    weeklyUploads[i].toDouble());
              }),

              isCurved:true,
              barWidth:3,

              gradient: const LinearGradient(
                  colors:[
                    Color(0xff2196F3),
                    Color(0xff00BCD4)
                  ]
              ),

              dotData: FlDotData(show:true),

              belowBarData: BarAreaData(
                show:true,
                gradient: LinearGradient(
                  colors:[
                    Colors.blue.withOpacity(.3),
                    Colors.transparent
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAnalytics,
          )
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              physics: const NeverScrollableScrollPhysics(),

              children: [

                statCard(
                    "Students",
                    totalStudents,
                    Icons.people,
                    chartColors[0]),

                statCard(
                    "Materials",
                    totalMaterials,
                    Icons.menu_book,
                    chartColors[1]),

                statCard(
                    "Uploads",
                    totalUploads,
                    Icons.upload,
                    chartColors[2]),

                statCard(
                    "This Week",
                    uploadsThisWeek,
                    Icons.calendar_today,
                    chartColors[3]),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Materials by Semester",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            semesterBarChart(),

            const SizedBox(height: 30),

            const Text(
              "Upload Trends (Last 7 Days)",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            uploadTrendChart(),

            const SizedBox(height: 30),

            const Text(
              "Top Uploaders",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...topUploaders.asMap().entries.map((entry){

              int index = entry.key;
              var user = entry.value;

              String medal = "🥇";
              if(index==1) medal="🥈";
              if(index==2) medal="🥉";

              return Container(

                margin: const EdgeInsets.symmetric(vertical: 6),

                decoration: BoxDecoration(
                  color: chartColors[index].withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: ListTile(
                  leading: Text(
                    medal,
                    style: const TextStyle(fontSize: 22),
                  ),
                  title: Text(user["name"]),
                  trailing: Text("${user["uploads"]} uploads"),
                ),
              );
            }),

            const SizedBox(height: 30),

            const Text(
              "Recent Uploads",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            ...recentUploads.map((item){

              DateTime date =
                  DateTime.tryParse(item['created_at']?.toString() ?? '')
                  ?? DateTime.now();

              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(item['title']),
                subtitle: Text(
                  DateFormat('dd MMM yyyy').format(date),
                ),
              );
            }),

          ],
        ),
      ),
    );
  }
}