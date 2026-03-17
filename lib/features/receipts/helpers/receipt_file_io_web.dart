// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<void> triggerBrowserDownload(String filename, String url) async {
  final html.AnchorElement anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
