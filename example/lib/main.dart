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
                        "",
                        "",
                        "",
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
          roomId: "",
          gameId: "",
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

class PumpkinSudGameDelegate extends SudGameDelegate {
  PumpkinSudGameDelegate({super.aspectRatio});

  @override
  Future<String> getSudGameCode() async {
    return "";
  }

  @override
  Future<bool> createOrder(Map<String, dynamic> body) async {
    return true;
  }

  @override
  Future<num> getGameScore() async {
    return 0;
  }

  @override
  Future<void> onGameStateChange(BuildContext context, String state) async {}
}
