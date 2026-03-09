import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FileViewerScreen extends StatelessWidget {

  final String fileUrl;

  const FileViewerScreen({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {

    final ext = fileUrl.split('.').last.toLowerCase();

    if (ext == "jpg" || ext == "jpeg" || ext == "png") {

      return Scaffold(
        appBar: AppBar(title: const Text("Image")),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(fileUrl),
          ),
        ),
      );
    }

    final viewerUrl =
        "https://docs.google.com/gview?embedded=true&url=$fileUrl";

    return Scaffold(
      appBar: AppBar(title: const Text("Document")),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(viewerUrl)),
      ),
    );
  }
}