import 'package:flutter/services.dart';

import 'flutter_sud_platform_interface.dart';
export 'sud_game_widget.dart';

class FlutterSud {
  static final FlutterSud _instance = FlutterSud._();

  factory FlutterSud() => _instance;

  FlutterSud._();

  Future<void> init(
    String appId,
    String appKey,
    String userId, {
    String languageCode = "zh-CN",
    bool gameIsTestEnv = false,
  }) async {
    await FlutterSudPlatform.instance.init(
      appId,
      appKey,
      userId,
      languageCode: languageCode,
      gameIsTestEnv: gameIsTestEnv,
    );
  }

  Future<void> notifyStateChange(
    String state, {
    Map<String, dynamic> data = const <String, dynamic>{},
  }) async {
    await FlutterSudPlatform.instance.notifyStateChange(
      state,
      data: data,
    );
  }

  Future<void> resume() async {
    await FlutterSudPlatform.instance.resume();
  }

  Future<void> pause() async {
    await FlutterSudPlatform.instance.pause();
  }
  
  Future<void> destroy() async {
    await FlutterSudPlatform.instance.destroy();
  }

  void setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    FlutterSudPlatform.instance.setMethodCallHandler(handler);
  }

  Stream<String> get gameStateStream =>
      FlutterSudPlatform.instance.gameStateStream;
}
