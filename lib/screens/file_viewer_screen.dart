import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class FileViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String? title;

  const FileViewerScreen({
    super.key,
    required this.fileUrl,
    this.title,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  // States
  bool _downloading = true;   // downloading the file to temp
  bool _error = false;
  String? _localPath;
  double _downloadProgress = 0;

  String get _ext =>
      widget.fileUrl.split('.').last.split('?').first.toLowerCase();

  bool get _isImage =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(_ext);

  @override
  void initState() {
    super.initState();
    if (!_isImage) _downloadToTemp();
  }

  /// Downloads the file to a temp path, then renders it natively
  Future<void> _downloadToTemp() async {
    setState(() { _downloading = true; _error = false; _downloadProgress = 0; });

    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'viewer_${DateTime.now().millisecondsSinceEpoch}.$_ext';
      final savePath = '${dir.path}/$fileName';

      await Dio().download(
        widget.fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _localPath = savePath;
        _downloading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _downloading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Document'),
        actions: [
          if (_error || (!_downloading && _localPath != null))
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _downloadToTemp,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── IMAGE ──────────────────────────────────────────────────────────────
    if (_isImage) {
      return Center(
        child: InteractiveViewer(
          child: Image.network(
            widget.fileUrl,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (_, __, ___) => _buildError(),
          ),
        ),
      );
    }

    // ── ERROR ──────────────────────────────────────────────────────────────
    if (_error) return _buildError();

    // ── DOWNLOADING ────────────────────────────────────────────────────────
    if (_downloading) return _buildDownloading();

    // ── PDF ────────────────────────────────────────────────────────────────
    if (_ext == 'pdf' && _localPath != null) {
      return PDFView(
        filePath: _localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (_) => setState(() => _error = true),
        onPageError: (_, __) {},
      );
    }

    // ── OTHER FILE TYPES (ppt, doc, etc.) ─────────────────────────────────
    // For non-PDF files we can't render natively — show a "file ready" state
    return _buildFileReady();
  }

  Widget _buildDownloading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: _downloadProgress > 0 ? _downloadProgress : null,
              strokeWidth: 3,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Opening file…',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF111827))),
          const SizedBox(height: 6),
          Text(
            _downloadProgress > 0
                ? '${(_downloadProgress * 100).toInt()}%'
                : 'Please wait…',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
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
              child: const Icon(Icons.broken_image_rounded,
                  color: Color(0xFFEF4444), size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Could not open file',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _downloadToTemp,
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

  Widget _buildFileReady() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.insert_drive_file_rounded,
                  color: Color(0xFF6366F1), size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title ?? 'File ready',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            Text(
              '${_ext.toUpperCase()} files can\'t be previewed.\nThe file was downloaded successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}