Future<void> openExternal(String url) async {
  throw UnsupportedError('Opening links is only supported on the web build.');
}

Future<void> downloadFile(String url) async {
  throw UnsupportedError('Downloading files is only supported on the web build.');
}
