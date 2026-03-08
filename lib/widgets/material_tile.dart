import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../screens/pdf_viewer_screen.dart';

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

  Color getColor(){

    switch(type){

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

  IconData getIcon(){

    switch(type){

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

    if(!await launchUrl(uri, mode: LaunchMode.externalApplication)){
      throw Exception("Could not open file");
    }

  }

  @override
  Widget build(BuildContext context) {

    final color = getColor();

    return GestureDetector(

      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PdfViewerScreen(
        url: fileUrl,
        title: title,
      ),
    ),
  );
},

      child: Container(

        margin: const EdgeInsets.only(bottom:16),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(

          color: color.withOpacity(0.15),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: color,
            width: 2
          ),
        ),

        child: Row(
          children: [

            CircleAvatar(
              backgroundColor: color,
              child: Icon(
                getIcon(),
                color: Colors.white,
              ),
            ),

            const SizedBox(width:16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize:16,
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height:4),

                  Text(
                    type,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600
                    ),
                  )

                ],
              ),
            ),

            const Icon(Icons.visibility)

          ],
        ),
      ),
    );
  }
}