import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/upload_service.dart';

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
    "1": ["Linear Algebra & Calculus","Engineering Chemistry","Technical Communication","Programming & Data Structures","Design Thinking","PDS Lab","EAA (Sports/Yoga)"],
    "2": ["Laplace & Vector Calculus","Engineering Physics","Engineering Mechanics","Building Planning & Drawing","Biology for Engineers","Workshop Practice","Civil Engineering Materials","EAA II"],
    "3": ["Business Essentials","Surveying","Fluid Mechanics","Strength of Materials","Geotechnical Engineering","Surveying Lab","Geotechnical Lab"],
    "4": ["Fourier & PDE","Structural Mechanics","Hydrology & Irrigation","Steel Structure Design","Foundation Engineering","Fluid Mechanics Lab","SOM Lab"],
    "5": ["Environmental Engineering","Theory of Structures","Concrete Design","Highway Engineering","Professional Elective I","Fractal Course I","Environmental Lab","Concrete Lab"],
    "6": ["Construction Technology","Airport & Railway Engg","Professional Elective II","Professional Elective III","Product Development","Fractal Course II","Civil Software Lab","Transportation Lab"],
    "7": ["Hydraulic Structures","Professional Elective IV","Professional Elective V","Open Elective I","Quantity Survey Lab","RS & GIS Lab","Seminar & Technical Writing","Industrial Training","Minor Project"],
    "8": ["Professional Elective VI","Professional Elective VII","Professional Elective VIII","Major Project"],
  };

  final types = ["Notes", "PYQ", "Assignment", "Lab", "Important"];

  // Icon + color per type
  final Map<String, IconData> typeIcons = {
    "Notes": Icons.description_rounded,
    "PYQ": Icons.quiz_rounded,
    "Assignment": Icons.assignment_rounded,
    "Lab": Icons.science_rounded,
    "Important": Icons.star_rounded,
  };
  final Map<String, Color> typeColors = {
    "Notes": Color(0xFF0EA5E9),
    "PYQ": Color(0xFFF59E0B),
    "Assignment": Color(0xFF10B981),
    "Lab": Color(0xFF06B6D4),
    "Important": Color(0xFFEF4444),
  };

  @override
  void initState() {
    super.initState();
    semester = widget.semester?.toString() ?? "1";
    if (!semesters.contains(semester)) semester = "1";
    final subjectsForSemester = semesterSubjects[semester] ?? [];
    final passedSubject = widget.subject;
    if (passedSubject != null && subjectsForSemester.contains(passedSubject)) {
      subject = passedSubject;
    } else {
      subject = subjectsForSemester.isNotEmpty ? subjectsForSemester.first : "";
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  Future<void> upload() async {
    if (selectedFile == null) {
      _showSnack("Please select a file first", isError: true);
      return;
    }
    if (titleController.text.trim().isEmpty) {
      _showSnack("Please enter a title", isError: true);
      return;
    }

    setState(() => isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString("name") ?? "Unknown";

      await UploadService().uploadMaterial(
        file: selectedFile!,
        fileName: fileName!,
        title: titleController.text.trim(),
        subject: subject,
        semester: int.parse(semester),
        type: type,
        uploadedBy: name,
      );

      if (!mounted) return;
      setState(() => isUploading = false);
      _showSnack("Uploaded successfully!");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isUploading = false);
      _showSnack("Upload failed: $e", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── HEADER ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                      top: topPad + 16,
                      left: 20,
                      right: 20,
                      bottom: 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0F172A),
                        Color(0xFF1D4ED8),
                        Color(0xFF38BDF8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70,
                            size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Material',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Add study material for students',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── FORM ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Title field
                      _SectionLabel(label: 'Title', icon: Icons.title_rounded),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: _fieldDecoration(
                            "e.g. Unit 3 Notes", Icons.edit_rounded),
                      ),

                      const SizedBox(height: 20),

                      // Semester
                      _SectionLabel(label: 'Semester', icon: Icons.calendar_today_rounded),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: semester,
                        decoration: _fieldDecoration(
                            "Select semester", Icons.school_rounded),
                        borderRadius: BorderRadius.circular(14),
                        items: semesters.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text("Semester $e"),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            semester = value!;
                            subject = semesterSubjects[semester]?.first ?? "";
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // Subject
                      _SectionLabel(label: 'Subject', icon: Icons.menu_book_rounded),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        key: ValueKey(semester),
                        value: subject,
                        decoration: _fieldDecoration(
                            "Select subject", Icons.subject_rounded),
                        borderRadius: BorderRadius.circular(14),
                        items: (semesterSubjects[semester] ?? [])
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => subject = value!),
                      ),

                      const SizedBox(height: 20),

                      // Material Type — chip selector
                      _SectionLabel(label: 'Type', icon: Icons.label_rounded),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: types.map((t) {
                          final isSelected = type == t;
                          final color = typeColors[t]!;
                          final icon = typeIcons[t]!;
                          return GestureDetector(
                            onTap: () => setState(() => type = t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : Colors.grey.shade300,
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
                                  Icon(icon,
                                      size: 15,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // File picker
                      _SectionLabel(label: 'File', icon: Icons.attach_file_rounded),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: pickFile,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: fileName != null
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: fileName != null
                                  ? const Color(0xFF1D4ED8)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: fileName != null
                                      ? const Color(0xFF1D4ED8)
                                          .withOpacity(0.1)
                                      : Colors.grey.shade200,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  fileName != null
                                      ? Icons.insert_drive_file_rounded
                                      : Icons.upload_file_rounded,
                                  color: fileName != null
                                      ? const Color(0xFF1D4ED8)
                                      : Colors.grey.shade500,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fileName ?? 'Tap to select file',
                                      style: TextStyle(
                                        fontWeight: fileName != null
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 14,
                                        color: fileName != null
                                            ? const Color(0xFF0F172A)
                                            : Colors.grey.shade500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'PDF, PPT, DOC supported',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Upload button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isUploading ? null : upload,
                          icon: const Icon(
                              Icons.cloud_upload_rounded,
                              size: 20),
                          label: const Text(
                            'Upload Material',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8),
                            disabledBackgroundColor:
                                const Color(0xFF1D4ED8).withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── UPLOADING OVERLAY ──────────────────────────────────────────
          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF1D4ED8),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Uploading…',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Please wait',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF1D4ED8)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}