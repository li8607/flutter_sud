import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_sud/flutter_sud.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(builder: (context) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      final flutterSudPlugin = FlutterSud();
                      await flutterSudPlugin.init(
                        "https://test-app.pumpkin.date/",
                        "1845726098887979009",
                        "WPLRPXw4GB6uV3ILNGiID6Q4yxtZG1R0",
                        token,
                        "6555f72a7cb0151745a5f944",
                        gameIsTestEnv: true,
                      );
                      showGameSheet(context);
                    },
                    child: const Text('Play Game'),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void showGameSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (s) {
        return SudGameWidget(
          sudGameDelegate: PumpkinSudGameDelegate(),
          roomId: "10000",
          gameId: "1649319572314173442",
          // gameId: "1765373047507173377",
          //  gameId: "1649319572314173442",
        );
      },
    );
  }

  void showTest(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (s) {
        return const SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("游戏币"),
              Text("游戏币"),
              Text("游戏币"),
              Text("游戏币"),
              Text("游戏币"),
            ],
          ),
        );
      },
    );
  }
}

String token =
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjY0ZGYzMmFjOGYxNTc3NTlhNzMwZmY2ZCIsInVzZXJuYW1lIjoiYWdnaWUiLCJuaWNrbmFtZSI6IkFnZ2llIiwid2FsbGV0IjoiMHgyMjA0NUM0RDVCNDgzNmYxRjE2ZENDQTFBOEMyRWI3YTc5MDY0NDQ3IiwiY29uY2lzZVVzZXJJZCI6IjEwMDAwMTM4IiwiaWF0IjoxNzI5NTY2NjQ1LCJleHAiOjE3MzIxNTg2NDV9.apNxBh_t_24_o1p40NRsFolnF0pesi4_zau1RTu9t0s";

class PumpkinSudGameDelegate extends SudGameDelegate {
  PumpkinSudGameDelegate({super.aspectRatio});

  @override
  Future<String> getSudGameCode() async {
    try {
      final dio = Dio();
      final resp = await dio.post(
        "https://test-app.pumpkin.date/game/sud/get_code",
        data: {
          "app_id": "1845726098887979009",
        },
        options: Options(
          headers: {
            "token": token,
          },
        ),
      );
      final code = resp.data["data"]["code"];
      return code;
    } catch (e, s) {
      print("【Game】$e, $s");
    }
    return "";
  }

  @override
  Future<bool> createOrder(Map<String, dynamic> body) async {
    return true;
  }

  @override
  Future<num> getGameScore() async {
    return 10000;
  }

  @override
  Future<void> onGameStateChange(BuildContext context, String state) async {}
}
