import 'dart:convert';

import 'package:flutter/services.dart';

import 'flutter_sud_platform_interface.dart';

typedef AsyncValueSetter<T> = Future<void> Function(T value);

class MethodChannelFlutterSud extends FlutterSudPlatform {
  static const String _messagesChannel = 'com.pumpkin.sud/messages';
  static const String _eventsChannel = 'com.pumpkin.sud/events';

  static const _method = MethodChannel(_messagesChannel);
  static const _event = EventChannel(_eventsChannel);

  @override
  Future<void> init(
    String appId,
    String appKey,
    String userId, {
    String languageCode = "zh-CN",
    bool gameIsTestEnv = false,
  }) async {
    await _method.invokeMethod('init', <String, dynamic>{
      'appId': appId,
      'appKey': appKey,
      'userId': userId,
      'languageCode': languageCode,
      'gameIsTestEnv': gameIsTestEnv,
    });
  }

  @override
  Future<void> notifyStateChange(
    String state, {
    Map<String, dynamic>? data,
  }) async {
    await _method.invokeMethod('notifyStateChange', <String, dynamic>{
      'state': state,
      'dataJson': jsonEncode(data),
    });
  }

  @override
  Future<void> resume() async {
    await _method.invokeMethod('resume');
  }

  @override
  Future<void> pause() async {
    await _method.invokeMethod('pause');
  }

  @override
  Future<void> destroy() async {
    await _method.invokeMethod('destroy');
  }

  @override
  void setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    _method.setMethodCallHandler(handler);
  }

  @override
  Stream<String> get gameStateStream => _event
      .receiveBroadcastStream()
      .where((state) => state != null && state is String && state.isNotEmpty)
      .map<String>((dynamic state) => state as String);
}
