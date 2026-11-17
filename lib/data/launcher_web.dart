import 'package:web/web.dart' as web;

Future<void> openExternal(String url) async {
  web.window.open(url, '_blank');
}

Future<void> downloadFile(String url) async {
  final fileName = url.split('/').last.split('?').first;
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..target = '_blank'
    ..rel = 'noopener';
  anchor.click();
}
