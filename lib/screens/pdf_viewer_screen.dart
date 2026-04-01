import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

// ✅ Conditional import — dart:html only on web, stub on Android/iOS
import 'file_viewer_stub.dart'
    if (dart.library.html) 'file_viewer_web.dart';

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
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  WebViewController? _webController;

  // ── PDF viewer state ──
  String? localPdfPath;
  int currentPage = 0;
  int totalPages = 0;

  // ── Download state ──
  bool isDownloading = false;
  bool isDownloaded = false;
  double downloadProgress = 0;

  String get _fileExtension {
    final path = Uri.parse(widget.url).path.toLowerCase();
    if (path.endsWith('.pdf')) return 'pdf';
    if (path.endsWith('.pptx') || path.endsWith('.ppt')) return 'pptx';
    if (path.endsWith('.docx') || path.endsWith('.doc')) return 'docx';
    return 'pdf';
  }

  bool get _isPdf => _fileExtension == 'pdf';

  String get _viewType => 'file-viewer-${widget.url.hashCode}';

  String get _googleDocsUrl =>
      'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(widget.url)}';

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // ── WEB (iPhone PWA / Desktop browser) ──
      registerWebViewer(_viewType, widget.url, _isPdf);
      setState(() => isLoading = false);
    } else if (_isPdf) {
      // ── NATIVE — PDF ──
      _loadPdfLocally();
    } else {
      // ── NATIVE — PPT/DOC ──
      _initWebView();
    }
  }

  Future<void> _loadPdfLocally() async {
    setState(() { isLoading = true; hasError = false; downloadProgress = 0; });
    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await Dio().download(
        widget.url, savePath,
        onReceiveProgress: (r, t) {
          if (t > 0 && mounted) setState(() => downloadProgress = r / t);
        },
      );
      if (!mounted) return;
      setState(() { localPdfPath = savePath; isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { isLoading = false; hasError = true; errorMessage = 'Failed to load PDF: $e'; });
    }
  }

  void _initWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) { if (mounted) setState(() => isLoading = true); },
        onPageFinished: (_) { if (mounted) setState(() => isLoading = false); },
        onWebResourceError: (error) {
          if (mounted) setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = 'Could not load preview.\n${error.description}';
          });
        },
      ))
      ..loadRequest(Uri.parse(_googleDocsUrl));
    setState(() => _webController = controller);
  }

  Future<void> _downloadFile() async {
    if (isDownloading) return;
    setState(() { isDownloading = true; downloadProgress = 0; });
    try {
      final ext = _fileExtension;
      final safeName = widget.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      final fileName = '$safeName.$ext';
      const downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);
      String savePath;
      if (await downloadsDir.exists()) {
        savePath = '$downloadsPath/$fileName';
      } else {
        final dir = await getExternalStorageDirectory();
        if (dir == null) throw Exception('Storage unavailable');
        savePath = '${dir.path}/$fileName';
      }
      await Dio().download(
        widget.url, savePath,
        onReceiveProgress: (r, t) {
          if (t > 0 && mounted) setState(() => downloadProgress = r / t);
        },
      );
      if (!mounted) return;
      setState(() { isDownloading = false; isDownloaded = true; });
      _showSuccessSheet(fileName);
    } catch (e) {
      if (!mounted) return;
      setState(() => isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Download failed: $e'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
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
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.download_done_rounded, color: Color(0xFF059669), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Downloaded!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Text(fileName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          const Text('Saved to Downloads folder', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  IconData get _fileIcon {
    switch (_fileExtension) {
      case 'pptx': return Icons.slideshow_rounded;
      case 'docx': return Icons.description_rounded;
      default: return Icons.picture_as_pdf_rounded;
    }
  }

  Color get _fileColor {
    switch (_fileExtension) {
      case 'pptx': return const Color(0xFFEA580C);
      case 'docx': return const Color(0xFF2563EB);
      default: return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── WEB BUILD ────────────────────────────────────────────────────────────
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
          title: Text(widget.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(widget.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white70),
                label: const Text('Open', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
            : buildWebViewer(_viewType), // ← from conditional import
      );
    }

    // ── NATIVE (Android / iOS) BUILD ─────────────────────────────────────────
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
          if (_isPdf && totalPages > 0)
            Text('Page ${currentPage + 1} of $totalPages',
                style: const TextStyle(fontSize: 11, color: Colors.white54)),
          if (!_isPdf)
            const Text('via Google Docs Viewer',
                style: TextStyle(fontSize: 10, color: Colors.white38)),
        ]),
        actions: [
          if (hasError)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _isPdf ? _loadPdfLocally : _initWebView,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: isDownloaded ? null : _downloadFile,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDownloaded ? const Color(0xFF059669).withOpacity(0.2) : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDownloaded ? const Color(0xFF059669).withOpacity(0.5) : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: isDownloading
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                            value: downloadProgress > 0 ? downloadProgress : null,
                            strokeWidth: 2, color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${(downloadProgress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 11, color: Colors.white54)),
                      ])
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
                          size: 15,
                          color: isDownloaded ? const Color(0xFF34D399) : Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isDownloaded ? 'Saved' : 'Download',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: isDownloaded ? const Color(0xFF34D399) : Colors.white,
                          ),
                        ),
                      ]),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (hasError) return _buildError();
    if (_isPdf) {
      if (isLoading || localPdfPath == null) return _buildLoader('Loading PDF…');
      return _buildPdfView();
    } else {
      if (_webController == null) return _buildLoader('Opening file…');
      return Stack(children: [
        WebViewWidget(controller: _webController!),
        if (isLoading)
          Container(color: const Color(0xFF0F172A), child: _buildLoader('Loading preview…')),
      ]);
    }
  }

  Widget _buildLoader(String message) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 56, height: 56,
          child: CircularProgressIndicator(
            value: (!_isPdf || downloadProgress == 0) ? null : downloadProgress,
            color: const Color(0xFF38BDF8),
            backgroundColor: Colors.white12,
            strokeWidth: 4,
          ),
        ),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 6),
        Text(
          downloadProgress > 0 ? '${(downloadProgress * 100).toInt()}%' : 'Please wait',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ]),
    );
  }

  Widget _buildPdfView() {
    return PDFView(
      filePath: localPdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      onRender: (pages) { if (mounted) setState(() => totalPages = pages ?? 0); },
      onPageChanged: (page, total) {
        if (mounted) setState(() { currentPage = page ?? 0; totalPages = total ?? 0; });
      },
      onError: (e) {
        if (mounted) setState(() { hasError = true; errorMessage = 'Could not render PDF: $e'; });
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _fileColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Icon(_fileIcon, color: _fileColor, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Could not open file', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Text(errorMessage, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isPdf ? _loadPdfLocally : _initWebView,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      ),
    );
  }
}