// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// dart:ui_web contains platformViewRegistry in Flutter 3.x+
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';

/// Web-only implementation — renders files in an iframe.
/// PDFs open directly (Safari renders them natively).
/// PPT/DOC go through Google Docs Viewer.

void registerWebViewer(String viewType, String url, bool isPdf) {
  final src = isPdf
      ? url
      : 'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(url)}';

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    return html.IFrameElement()
      ..src = src
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'fullscreen'
      ..setAttribute('allowfullscreen', 'true');
  });
}

Widget buildWebViewer(String viewType) {
  return HtmlElementView(viewType: viewType);
}