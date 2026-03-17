import 'package:intl/intl.dart';

String formatReceiptDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String formatReceiptSize(int bytes) {
  if (bytes < 1024 * 1024) {
    final double kb = bytes / 1024;
    return '${kb.toStringAsFixed(1)} KB';
  }

  final double mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(1)} MB';
}

String formatStorageUsageMb(int bytes) {
  final double mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(1)} MB used';
}

bool isImageReceipt(String mimeType) {
  final String normalized = mimeType.trim().toLowerCase();
  return normalized.startsWith('image/');
}

bool isPdfReceipt(String mimeType) {
  final String normalized = mimeType.trim().toLowerCase();
  return normalized == 'application/pdf' || normalized.endsWith('/pdf');
}
