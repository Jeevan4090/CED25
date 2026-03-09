import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../screens/pdf_viewer_screen.dart';
import '../screens/file_viewer_screen.dart';

class MaterialTile extends StatelessWidget {

  final String title;
  final String type;
  final String fileUrl;

  const MaterialTile({
    super.key,
    required this.title,
    required this.type,
    required this.fileUrl,
  });

  Color getColor() {
    switch (type) {
      case "Notes":
        return AppColors.notes;
      case "PYQ":
        return AppColors.pyq;
      case "Assignment":
        return AppColors.assignment;
      case "Lab":
        return AppColors.lab;
      case "Important":
        return AppColors.important;
      default:
        return Colors.grey;
    }
  }

  IconData getIcon() {
    switch (type) {
      case "Notes":
        return Icons.menu_book;
      case "PYQ":
        return Icons.history_edu;
      case "Assignment":
        return Icons.assignment;
      case "Lab":
        return Icons.science;
      case "Important":
        return Icons.star;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> openFile() async {
    final uri = Uri.parse(fileUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open file");
    }
  }

  @override
  Widget build(BuildContext context) {

    final color = getColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),

        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: () {

  final ext = fileUrl.split('.').last.toLowerCase();

  if (ext == "pdf") {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
  url: fileUrl,
  title: title,
),
      ),
    );

  } else {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FileViewerScreen(fileUrl: fileUrl),
      ),
    );

  }

},

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: color.withOpacity(0.35),
                width: 1.5,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),

            child: Row(
              children: [

                /// icon container
                Container(
                  height: 42,
                  width: 42,

                  decoration: BoxDecoration(
                    color: color.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(
                    getIcon(),
                    color: color,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        type,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}