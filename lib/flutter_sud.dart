
import 'flutter_sud_platform_interface.dart';

class FlutterSud {
  Future<String?> getPlatformVersion() {
    return FlutterSudPlatform.instance.getPlatformVersion();
  }
}
