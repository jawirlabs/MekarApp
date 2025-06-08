// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// Tambahkan baris ini! Tanpa ini error `platformViewRegistry`
import 'dart:ui' as ui;

void registerIframe(String viewId, String url) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) => html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%',
  );
}
