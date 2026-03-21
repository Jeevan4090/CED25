import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool loading = true;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 0;
  int totalPages = 0;

  // Download state
  bool isDownloading = false;
  bool isDownloaded = false;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    setState(() { loading = true; hasError = false; });

    try {
      final response = await http.get(Uri.parse(widget.url));

      if (response.statusCode != 200) {
        setState(() {
          loading = false;
          hasError = true;
          errorMessage = 'Server returned ${response.statusCode}.\nCheck if the file URL is public.';
        });
        return;
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('pdf') && !contentType.contains('octet-stream')) {
        setState(() {
          loading = false;
          hasError = true;
          errorMessage = 'Invalid file received (got $contentType).\nThe bucket may not be public.';
        });
        return;
      }

      if (response.bodyBytes.isEmpty) {
        setState(() {
          loading = false;
          hasError = true;
          errorMessage = 'Downloaded file is empty.';
        });
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      setState(() {
        localPath = file.path;
        loading = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        hasError = true;
        errorMessage = 'Failed to load: $e';
      });
    }
  }

  /// Saves PDF directly to the device Downloads folder
  Future<void> downloadPdf() async {
    if (localPath == null || isDownloading) return;

    setState(() => isDownloading = true);

    try {
      final safeName = widget.title
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .trim();
      final fileName = '$safeName.pdf';

      // Save directly to /storage/emulated/0/Download/
      // This is the actual Downloads folder visible in Files app
      const downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);

      String savePath;
      if (await downloadsDir.exists()) {
        savePath = '$downloadsPath/$fileName';
      } else {
        // Fallback to external storage if Downloads doesn't exist
        final dir = await getExternalStorageDirectory();
        if (dir == null) throw Exception('Storage unavailable');
        savePath = '${dir.path}/$fileName';
      }

      await File(localPath!).copy(savePath);

      if (!mounted) return;
      setState(() {
        isDownloading = false;
        isDownloaded = true;
      });

      _showSuccessSheet(fileName);
    } catch (e) {
      if (!mounted) return;
      setState(() => isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSuccessSheet(String fileName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B4B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.download_done_rounded,
                  color: Color(0xFF059669), size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Downloaded!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text(
              fileName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            const Text(
              'Saved to Downloads folder',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Done',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            if (totalPages > 0)
              Text(
                'Page ${currentPage + 1} of $totalPages',
                style: const TextStyle(
                    fontSize: 11, color: Colors.white54),
              ),
          ],
        ),
        actions: [
          // Refresh button
          if (hasError || !loading)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: loadPdf,
              tooltip: 'Reload',
            ),

          // Download button — only show when PDF is loaded
          if (!loading && !hasError && localPath != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: isDownloaded ? null : downloadPdf,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDownloaded
                        ? const Color(0xFF059669).withOpacity(0.2)
                        : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDownloaded
                          ? const Color(0xFF059669).withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: isDownloading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDownloaded
                                  ? Icons.download_done_rounded
                                  : Icons.download_rounded,
                              size: 15,
                              color: isDownloaded
                                  ? const Color(0xFF34D399)
                                  : Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isDownloaded ? 'Saved' : 'Download',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDownloaded
                                    ? const Color(0xFF34D399)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) return _buildLoader();
    if (hasError) return _buildError();

    return PDFView(
      filePath: localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      onRender: (pages) {
        if (mounted) setState(() => totalPages = pages ?? 0);
      },
      onPageChanged: (page, total) {
        if (mounted) setState(() {
          currentPage = page ?? 0;
          totalPages = total ?? 0;
        });
      },
      onError: (e) {
        if (mounted) setState(() {
          hasError = true;
          errorMessage = 'Could not render PDF: $e';
        });
      },
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF6366F1)),
          SizedBox(height: 16),
          Text('Loading PDF…',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          SizedBox(height: 6),
          Text('Please wait',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Color(0xFFEF4444), size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Could not open PDF',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 Fix: Go to Supabase → Storage → your bucket → Make it Public',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.amber, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: loadPdf,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}