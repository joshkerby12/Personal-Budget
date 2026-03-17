import 'receipt_file_io_stub.dart'
    if (dart.library.html) 'receipt_file_io_web.dart'
    as impl;

Future<void> triggerBrowserDownload(String filename, String url) {
  return impl.triggerBrowserDownload(filename, url);
}
