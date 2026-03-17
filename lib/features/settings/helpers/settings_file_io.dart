import 'settings_file_io_stub.dart'
    if (dart.library.html) 'settings_file_io_web.dart'
    as impl;

Future<void> downloadJsonFile(String filename, String content) {
  return impl.downloadJsonFile(filename, content);
}

Future<String?> pickJsonFileContent() {
  return impl.pickJsonFileContent();
}
