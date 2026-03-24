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
  final searchController = TextEditingController();

  List<Map<String, dynamic>> codes = [];
  List<Map<String, dynamic>> filteredCodes = [];

  String searchQuery = '';
  bool loading = false;
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    fetchCodes();
  }

  @override
  void dispose() {
    codeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCodes() async {
    setState(() => isFetching = true);
    final data = await supabase
        .from('students')
        .select('id, access_code, used, used_by')
        .order('used', ascending: true)
        .order('created_at', ascending: false);

    final list = List<Map<String, dynamic>>.from(data);
    setState(() {
      codes = list;
      filteredCodes = list;
      isFetching = false;
    });
  }

  void searchCodes(String query) {
    setState(() {
      searchQuery = query;
      filteredCodes = codes.where((code) {
        final accessCode = (code['access_code'] ?? '').toString().toLowerCase();
        final usedBy = (code['used_by'] ?? '').toString().toLowerCase();
        return accessCode.contains(query.toLowerCase()) ||
            usedBy.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> saveCode() async {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      _showSnack('Enter a code first', isError: true);
      return;
    }

    setState(() => loading = true);
    try {
      await supabase.from('students').insert({
        'access_code': code,
        'used': false,
      });
      codeController.clear();
      await fetchCodes();
      _showSnack('Code "$code" added!');
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteCode(String id) async {
    await supabase.from('students').delete().eq('id', id);
    fetchCodes();
  }

  void copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _showSnack('Code copied to clipboard');
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

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final unusedCount = codes.where((c) => c['used'] == false).length;
    final usedCount = codes.where((c) => c['used'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // ── HEADER ────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: topPad + 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Access Codes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Manage student access',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Refresh
                    GestureDetector(
                      onTap: fetchCodes,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    _StatPill(
                      label: 'Total',
                      value: '${codes.length}',
                      color: Colors.white.withOpacity(0.2),
                      textColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      label: 'Unused',
                      value: '$unusedCount',
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      textColor: const Color(0xFF6EE7B7),
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      label: 'Used',
                      value: '$usedCount',
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                      textColor: const Color(0xFFFCA5A5),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Add code input
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                        child: TextField(
                          controller: codeController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter new access code...',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13),
                            prefixIcon: Icon(Icons.vpn_key_rounded,
                                color: Colors.white.withOpacity(0.6),
                                size: 18),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: loading ? null : saveCode,
                      child: Container(
                        height: 46,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: loading
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1D4ED8)),
                                )
                              : const Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── SEARCH ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: searchCodes,
                decoration: InputDecoration(
                  hintText: 'Search code or student...',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.grey.shade400, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: Colors.grey.shade400, size: 18),
                          onPressed: () {
                            searchController.clear();
                            searchCodes('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── LIST ──────────────────────────────────────────────────
          Expanded(
            child: isFetching
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1D4ED8)),
                  )
                : filteredCodes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.vpn_key_rounded,
                                  size: 40, color: Color(0xFF1D4ED8)),
                            ),
                            const SizedBox(height: 16),
                            const Text('No codes found',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        itemCount: filteredCodes.length,
                        itemBuilder: (context, index) {
                          final code = filteredCodes[index];
                          final bool used = code['used'] == true;

                          return Dismissible(
                            key: ValueKey(code['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(24)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 28),
                                        ),
                                        const SizedBox(height: 14),
                                        const Text('Delete Code?',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 8),
                                        Text(
                                          'This will remove "${code['access_code']}" permanently.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 13),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        ctx, false),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: FilledButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFEF4444),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            onDismissed: (_) =>
                                deleteCode(code['id'].toString()),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: used
                                      ? const Color(0xFFFECACA)
                                      : const Color(0xFFBBF7D0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Status dot
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: used
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Code + used by
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          code['access_code'],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          used
                                              ? 'Used by: ${code["used_by"] ?? "Unknown"}'
                                              : 'Available',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: used
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Copy button
                                  GestureDetector(
                                    onTap: () =>
                                        copyCode(code['access_code']),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.copy_rounded,
                                          size: 16,
                                          color: Color(0xFF1D4ED8)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Pill Widget ──────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}