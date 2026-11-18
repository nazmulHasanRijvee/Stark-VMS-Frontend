import 'platform_file_helper_stub.dart'
    if (dart.library.js_interop) 'platform_file_helper_web.dart'
    as impl;

abstract final class PlatformFileHelper {
  static void openUrl(String url) {
    impl.openUrlImpl(url);
  }
}
