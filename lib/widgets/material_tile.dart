import 'package:flutter/material.dart';
import '../screens/pdf_viewer_screen.dart';
import '../screens/file_viewer_screen.dart';

class MaterialTile extends StatelessWidget {

  final String title;
  final String type;
  final String fileUrl;
  final String? uploadedBy;
  final String? createdAt;
  final VoidCallback? onDelete;

  const MaterialTile({
    super.key,
    required this.title,
    required this.type,
    required this.fileUrl,
    this.uploadedBy,
    this.createdAt,
    this.onDelete,
  });

  Future<void> openFile(BuildContext context) async {

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
  }

  void confirmDelete(BuildContext context) {

    if (onDelete == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Material"),
        content: const Text("Are you sure you want to delete this file?"),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date like 11 Mar
  String formatDate(String? date) {
    if (date == null) return "";

    final dt = DateTime.parse(date);

    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];

    return "${dt.day} ${months[dt.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 2,

        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => openFile(context),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [

                /// File Icon
                Container(
                  height: 42,
                  width: 42,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: const Icon(
                    Icons.insert_drive_file,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(width: 14),

                /// Title + details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "$type • ${uploadedBy ?? "Unknown"} • ${formatDate(createdAt)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Delete button
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => confirmDelete(context),
                  ),

                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}