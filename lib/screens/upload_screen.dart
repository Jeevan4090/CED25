import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/upload_service.dart';
import '../services/material_service.dart';

class UploadScreen extends StatefulWidget {
  final int? semester;
  final String? subject;

  const UploadScreen({
    super.key,
    this.semester,
    this.subject,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  final titleController = TextEditingController();

  late String semester;
  late String subject;

  String type = "Notes";

  File? selectedFile;
  String? fileName;

  bool isUploading = false;

  final semesters = ["1","2","3","4","5","6","7","8"];

  final Map<String, List<String>> semesterSubjects = {

    "1": [
      "Linear Algebra & Calculus",
      "Engineering Chemistry",
      "Technical Communication",
      "Programming & Data Structures",
      "Design Thinking",
      "PDS Lab",
      "EAA (Sports/Yoga)"
    ],

    "2": [
      "Laplace & Vector Calculus",
      "Engineering Physics",
      "Engineering Mechanics",
      "Building Planning & Drawing",
      "Biology for Engineers",
      "Workshop Practice",
      "Civil Engineering Materials",
      "EAA II"
    ],

    "3": [
      "Business Essentials",
      "Surveying",
      "Fluid Mechanics",
      "Strength of Materials",
      "Geotechnical Engineering",
      "Surveying Lab",
      "Geotechnical Lab"
    ],

    "4": [
      "Fourier & PDE",
      "Structural Mechanics",
      "Hydrology & Irrigation",
      "Steel Structure Design",
      "Foundation Engineering",
      "Fluid Mechanics Lab",
      "SOM Lab"
    ],

    "5": [
      "Environmental Engineering",
      "Theory of Structures",
      "Concrete Design",
      "Highway Engineering",
      "Professional Elective I",
      "Fractal Course I",
      "Environmental Lab",
      "Concrete Lab"
    ],

    "6": [
      "Construction Technology",
      "Airport & Railway Engg",
      "Professional Elective II",
      "Professional Elective III",
      "Product Development",
      "Fractal Course II",
      "Civil Software Lab",
      "Transportation Lab"
    ],

    "7": [
      "Hydraulic Structures",
      "Professional Elective IV",
      "Professional Elective V",
      "Open Elective I",
      "Quantity Survey Lab",
      "RS & GIS Lab",
      "Seminar & Technical Writing",
      "Industrial Training",
      "Minor Project"
    ],

    "8": [
      "Professional Elective VI",
      "Professional Elective VII",
      "Professional Elective VIII",
      "Major Project"
    ],
  };

  final types = [
    "Notes",
    "PYQ",
    "Assignment",
    "Lab",
    "Important"
  ];

  @override
  void initState() {
    super.initState();

    semester = widget.semester?.toString() ?? "1";
    subject = widget.subject ?? semesterSubjects[semester]!.first;
  }

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

  Future<void> upload() async {

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

    setState(() {
      isUploading = true;
    });

    final uploadService = UploadService();
    final materialService = MaterialService();

    try {

      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString("name") ?? "Unknown";

      final fileUrl = await uploadService.uploadFile(
        selectedFile!,
        fileName!,
      );

      if(fileUrl == null){
        throw Exception("Upload failed");
      }

      await materialService.insertMaterial(
        semester: int.parse(semester),
        subject: subject,
        title: titleController.text.trim(),
        type: type,
        fileUrl: fileUrl,
        uploadedBy: name,
      );

      if(!mounted) return;

      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload successful")),
      );

      Navigator.pop(context);

    } catch (e) {

      if(!mounted) return;

      setState(() {
        isUploading = false;
      });

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

      body: Stack(
        children: [

          Padding(
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
                        subject = semesterSubjects[semester]?.first ?? "";
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

                  DropdownButtonFormField(
                    value: subject,

                    items: (semesterSubjects[semester] ?? []).map((e){
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

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: isUploading ? null : upload,

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

          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.35),

              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    CircularProgressIndicator(),

                    SizedBox(height:12),

                    Text(
                      "Uploading file...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }
}