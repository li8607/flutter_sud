import 'package:flutter/services.dart';

import 'flutter_sud_platform_interface.dart';
export 'sud_game_widget.dart';

class FlutterSud {
  static final FlutterSud _instance = FlutterSud._();

  factory FlutterSud() => _instance;

  FlutterSud._();

  String? token;

  Future<void> init(
    String baseUrl,
    String appId,
    String appKey,
    String token,
    String userId, {
    String languageCode = "zh-CN",
    bool gameIsTestEnv = false,
  }) async {
    this.token = token;
    await FlutterSudPlatform.instance.init(
      baseUrl,
      appId,
      appKey,
      token,
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

  void setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    FlutterSudPlatform.instance.setMethodCallHandler(handler);
  }

  Stream<String> get gameStateStream =>
      FlutterSudPlatform.instance.gameStateStream;
}
