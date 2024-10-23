import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sud/flutter_sud.dart';
import 'package:flutter_sud/flutter_sud_platform_interface.dart';
import 'package:flutter_sud/flutter_sud_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSudPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSudPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSudPlatform initialPlatform = FlutterSudPlatform.instance;

  test('$MethodChannelFlutterSud is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSud>());
  });

  test('getPlatformVersion', () async {
    FlutterSud flutterSudPlugin = FlutterSud();
    MockFlutterSudPlatform fakePlatform = MockFlutterSudPlatform();
    FlutterSudPlatform.instance = fakePlatform;

    expect(await flutterSudPlugin.getPlatformVersion(), '42');
  });
}
