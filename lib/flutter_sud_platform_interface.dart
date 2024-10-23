import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_sud_method_channel.dart';

abstract class FlutterSudPlatform extends PlatformInterface {
  /// Constructs a FlutterSudPlatform.
  FlutterSudPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSudPlatform _instance = MethodChannelFlutterSud();

  /// The default instance of [FlutterSudPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSud].
  static FlutterSudPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSudPlatform] when
  /// they register themselves.
  static set instance(FlutterSudPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
