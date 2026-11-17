import 'launcher_stub.dart' if (dart.library.js_interop) 'launcher_web.dart' as platform;

/// Opens [url] in a new tab. An empty URL is ignored rather than treated as an
/// error: the data file is hand-edited and a placeholder link should not crash
/// the page.
Future<void> openUrl(String url) async {
  if (url.trim().isEmpty) return;
  await platform.openExternal(url);
}

/// Downloads a bundled PDF asset. An empty asset path is ignored.
Future<void> downloadAsset(String asset) async {
  if (asset.trim().isEmpty) return;
  await platform.downloadFile(resolveAssetUrl(Uri.base, asset));
}

/// Flutter serves declared assets under `assets/<declared path>`. Resolving
/// against the page's own base keeps the file reachable under any base href.
String resolveAssetUrl(Uri base, String asset) =>
    base.resolve('assets/$asset').toString();
