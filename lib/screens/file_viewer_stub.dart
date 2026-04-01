import 'package:flutter/widgets.dart';

/// Stub for non-web platforms (Android, iOS native).
/// These functions do nothing on mobile.

void registerWebViewer(String viewType, String url, bool isPdf) {
  // No-op on mobile
}

Widget buildWebViewer(String viewType) {
  // Never called on mobile
  return const SizedBox.shrink();
}