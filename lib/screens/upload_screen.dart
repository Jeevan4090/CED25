import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/upload_service.dart';
import '../services/material_service.dart';

class UploadScreen extends StatefulWidget {

  final int semester;
  final String subject;

  const UploadScreen({
    super.key,
    required this.semester,
    required this.subject
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  final titleController = TextEditingController();

  String semester = "1";
  String subject = "Mathematics";
  String type = "Notes";

  File? selectedFile;
  String? fileName;

  final semesters = ["1","2","3","4","5","6","7","8"];

  final subjects = [
    "Mathematics",
    "Data Structures",
    "DBMS",
    "Operating Systems",
    "Computer Networks"
  ];

  final types = [
    "Notes",
    "PYQ",
    "Assignment",
    "Lab",
    "Important"
  ];

  Future<void> pickFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf','ppt','pptx','doc','docx']
    );

    if(result != null){

      setState(() {

        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;

      });

    }

  }

  void upload() async {

  if(selectedFile == null){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Select a file")),
    );
    return;
  }

  if(titleController.text.trim().isEmpty){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter title")),
    );
    return;
  }

  final uploadService = UploadService();
  final materialService = MaterialService();

  try {

    final fileUrl = await uploadService.uploadFile(
      selectedFile!,
      fileName!,
    );

    if(fileUrl == null){
      throw Exception("Upload failed");
    }

    await materialService.insertMaterial(
      semester: widget.semester,
      subject: widget.subject,
      title: titleController.text.trim(),
      type: type,
      fileUrl: fileUrl,
    );

    if(!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload successful")),
    );

    Navigator.pop(context);

  } catch (e) {

    if(!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Upload error: $e")),
    );

  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Upload Material"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: ListView(

          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Material Title",
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height:20),

            DropdownButtonFormField(
              value: semester,
              items: semesters.map((e){
                return DropdownMenuItem(
                  value: e,
                  child: Text("Semester $e"),
                );
              }).toList(),
              onChanged: (value){
                setState(() {
                  semester = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Semester",
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height:20),

            DropdownButtonFormField(
              value: subject,
              items: subjects.map((e){
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value){
                setState(() {
                  subject = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height:20),

            DropdownButtonFormField(
              value: type,
              items: types.map((e){
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value){
                setState(() {
                  type = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Material Type",
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height:20),

            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Select File"),
            ),

            if(fileName != null)
              Padding(
                padding: const EdgeInsets.only(top:10),
                child: Text(
                  fileName!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height:30),

            ElevatedButton(
              onPressed: upload,
              child: const Text("Upload"),
            ),

          ],
        ),
      ),
    );
  }
}