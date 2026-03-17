// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

Future<void> downloadJsonFile(String filename, String content) async {
  final html.Blob blob = html.Blob(<dynamic>[content], 'application/json');
  final String url = html.Url.createObjectUrlFromBlob(blob);

  final html.AnchorElement anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  html.Url.revokeObjectUrl(url);
}

Future<String?> pickJsonFileContent() async {
  final Completer<String?> completer = Completer<String?>();
  final html.FileUploadInputElement picker = html.FileUploadInputElement()
    ..accept = 'application/json,.json';

  picker.onChange.first.then((_) {
    final html.File? file = picker.files?.isNotEmpty == true
        ? picker.files!.first
        : null;
    if (file == null) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return;
    }

    final html.FileReader reader = html.FileReader();
    reader.onLoadEnd.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(reader.result as String?);
      }
    });
    reader.onError.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
    reader.readAsText(file);
  });

  picker.click();
  return completer.future;
}
