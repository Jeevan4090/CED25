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
        padding: const EdgeInsets.all(16),

        child: Container(

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0,4),
              )
            ],
          ),

          child: ListView(

            children: [

              /// Title
              TextField(
                controller: titleController,

                decoration: InputDecoration(
                  labelText: "Material Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height:20),

              /// Semester
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

                decoration: InputDecoration(
                  labelText: "Semester",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height:20),

              /// Subject
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

                decoration: InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height:20),

              /// Type
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

                decoration: InputDecoration(
                  labelText: "Material Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height:25),

              /// File selector
              InkWell(
                onTap: pickFile,

                borderRadius: BorderRadius.circular(12),

                child: Container(

                  padding: const EdgeInsets.symmetric(vertical:16),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.attach_file),
                      SizedBox(width:8),
                      Text("Select File"),
                    ],
                  ),
                ),
              ),

              if(fileName != null)
                Padding(
                  padding: const EdgeInsets.only(top:10),
                  child: Text(
                    "Selected: $fileName",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height:30),

              /// Upload button
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: upload,

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical:16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    "Upload Material",
                    style: TextStyle(fontSize:16),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}