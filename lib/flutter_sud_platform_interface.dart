import 'dart:async';

import 'package:flutter/services.dart';
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

  Future<void> init(
    String appId,
    String appKey,
    String userId, {
    String languageCode = "zh-CN",
    bool gameIsTestEnv = false,
  }) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> notifyStateChange(
    String state, {
    Map<String, dynamic> data = const <String, dynamic>{},
  }) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> resume() {
    throw UnimplementedError(
        'didChangeAppLifecycleState() has not been implemented.');
  }

  Future<void> pause() {
    throw UnimplementedError(
        'didChangeAppLifecycleState() has not been implemented.');
  }

  Future<void> destroy() {
    throw UnimplementedError(
        'didChangeAppLifecycleState() has not been implemented.');
  }

  void setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    throw UnimplementedError(
        'didChangeAppLifecycleState() has not been implemented.');
  }

  Stream<String> get gameStateStream => throw UnimplementedError(
      'gameStateStream not implemented on the current platform.');
}
