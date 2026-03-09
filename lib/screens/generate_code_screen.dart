
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GenerateCodeScreen extends StatefulWidget {
  const GenerateCodeScreen({super.key});

  @override
  State<GenerateCodeScreen> createState() => _GenerateCodeScreenState();
}

class _GenerateCodeScreenState extends State<GenerateCodeScreen> {
  final supabase = Supabase.instance.client;
  final codeController = TextEditingController();

  List<Map<String, dynamic>> codes = [];
  List<Map<String, dynamic>> filteredCodes = [];

  String searchQuery = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchCodes();
  }

  Future<void> fetchCodes() async {
    final data = await supabase
        .from("students")
        .select("id, access_code, used, used_by")
        .order("used", ascending: true)
        .order("created_at", ascending: false);

    final list = List<Map<String, dynamic>>.from(data);

    setState(() {
      codes = list;
      filteredCodes = list;
    });
  }

  void searchCodes(String query) {
    setState(() {
      searchQuery = query;

      filteredCodes = codes.where((code) {
        final accessCode =
            (code["access_code"] ?? "").toString().toLowerCase();

        final usedBy =
            (code["used_by"] ?? "").toString().toLowerCase();

        return accessCode.contains(query.toLowerCase()) ||
            usedBy.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> saveCode() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter a code")));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await supabase.from("students").insert({
        "access_code": code,
        "used": false,
      });

      codeController.clear();
      await fetchCodes();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> deleteCode(String id) async {
    await supabase.from("students").delete().eq("id", id);
    fetchCodes();
  }

  void copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Code copied")));
  }

  @override
  Widget build(BuildContext context) {
    final unusedCount = codes.where((c) => c["used"] == false).length;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Access Codes")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// INPUT FIELD
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "Enter Access Code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// SAVE BUTTON
            ElevatedButton(
              onPressed: loading ? null : saveCode,
              child: const Text("Save Code"),
            ),

            const SizedBox(height: 20),

            /// SEARCH BAR
            TextField(
              onChanged: searchCodes,
              decoration: InputDecoration(
                hintText: "Search code or student...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchCodes("");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// UNUSED COUNTER
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Unused Codes: $unusedCount",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Existing Codes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// CODE LIST
            Expanded(
              child: ListView.builder(
                itemCount: filteredCodes.length,
                itemBuilder: (context, index) {
                  final code = filteredCodes[index];
                  final bool used = code["used"] == true;

                  return Dismissible(
                    key: ValueKey(code["id"]),
                    direction: DismissDirection.endToStart,

                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),

                    confirmDismiss: (_) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Code"),
                          content: const Text(
                            "Are you sure you want to delete this code?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },

                    onDismissed: (_) {
                      deleteCode(code["id"].toString());
                    },

                    child: Card(
                      child: ListTile(

                        leading: CircleAvatar(
                          radius: 8,
                          backgroundColor:
                              used ? Colors.red : Colors.green,
                        ),

                        title: Text(
                          code["access_code"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          used
                              ? "Used by: ${code["used_by"] ?? "Unknown"}"
                              : "Unused",
                          style: TextStyle(
                            color: used ? Colors.red : Colors.green,
                          ),
                        ),

                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () =>
                              copyCode(code["access_code"]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

