import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Triggers a CSV file download in the browser.
void downloadCsv(String csv, String filename) {
  final blob = web.Blob(
    [csv.toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  (web.document.createElement('a') as web.HTMLAnchorElement)
    ..href = url
    ..download = filename
    ..click();
  web.URL.revokeObjectURL(url);
}
