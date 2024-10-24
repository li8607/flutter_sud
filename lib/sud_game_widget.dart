import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sud/flutter_sud.dart';
import 'dart:convert';

class SudGameWidget extends StatefulWidget {
  const SudGameWidget({
    super.key,
    this.sudGameDelegate = const SudGameDelegate(),
    required this.roomId,
    required this.gameId,
    this.onGameClosed,
  });

  final SudGameDelegate sudGameDelegate;
  final String roomId;
  final String gameId;
  final VoidCallback? onGameClosed;

  @override
  State<SudGameWidget> createState() => _SudGameWidgetState();
}

class _SudGameWidgetState extends State<SudGameWidget>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  StreamSubscription? gameStateStreamSubscription;

  @override
  void initState() {
    super.initState();
    gameStateStreamSubscription =
        FlutterSud().gameStateStream.listen(gameStateListen);
    WidgetsBinding.instance.addObserver(this);
    FlutterSud().setMethodCallHandler((call) async {
      if (call.method == "getCode") {
        return getSudGameCode();
      }
    });
  }

  Future<String> getSudGameCode() async {
    return widget.sudGameDelegate.getSudGameCode();
  }

  Future<void> gameStateListen(String event) async {
    try {
      final eventMap = jsonDecode(event);
      final state = eventMap["state"] as String?;
      if (state == null || state.isEmpty) {
        return;
      }
      await widget.sudGameDelegate.onGameStateChange(context, state);
      if (state == SudMGPAPPState.MG_COMMON_GAME_MONEY_NOT_ENOUGH) {
        // 充币
        FlutterSud()
            .notifyStateChange(SudMGPAPPState.APP_COMMON_UPDATE_GAME_MONEY);
      } else if (state == SudMGPAPPState.MG_COMMON_DESTROY_GAME_SCENE ||
          state == SudMGPAPPState.MG_COMMON_HIDE_GAME_SCENE) {
        // 关闭游戏
        widget.onGameClosed?.call();
      } else if (state == SudMGPAPPState.MG_COMMON_GAME_CREATE_ORDER) {
        // 创建订单
        final dataJson = eventMap["dataJson"] as String?;
        if (dataJson == null || dataJson.isEmpty) {
          return;
        }
        final dataMap = jsonDecode(dataJson);
        final result = await widget.sudGameDelegate.createOrder({
          "roomId": widget.roomId,
          ...dataMap,
        });
        FlutterSud().notifyStateChange(
          SudMGPAPPState.APP_COMMON_GAME_CREATE_ORDER_RESULT,
          data: {
            "result": result ? 1 : 0,
          },
        );
      } else if (state == SudMGPAPPState.MG_COMMON_GAME_GET_SCORE) {
        num score = await widget.sudGameDelegate.getGameScore();
        FlutterSud().notifyStateChange(
          SudMGPAPPState.APP_COMMON_GAME_SCORE,
          data: {
            "score": score.toInt(),
          },
        );
      } else if (state == SudMGPAPPState.MG_COMMON_USERS_INFO) {
        final dataJson = eventMap["dataJson"] as String?;
        if (dataJson == null || dataJson.isEmpty) {
          return;
        }
        final dataMap = jsonDecode(dataJson);
        final userIds =
            (dataMap["uids"] as List).map((e) => e.toString()).toList();
        List<GameUser> users = await widget.sudGameDelegate.getUsers(userIds);
        FlutterSud().notifyStateChange(
          SudMGPAPPState.APP_COMMON_USERS_INFO,
          data: {
            "infos": users
                .map(
                  (e) => {
                    "uid": e.uid,
                    "avatar": e.avatar,
                    "name": e.name,
                  },
                )
                .toList(),
          },
        );
      }
    } catch (e, s) {
      //
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      FlutterSud().resume();
    } else if (state == AppLifecycleState.paused) {
      FlutterSud().pause();
    }
  }

  @override
  void dispose() {
    gameStateStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final roomId = widget.roomId;
    final gameId = widget.gameId;

    const String viewType = 'SudGame';
    final creationParams = {
      "roomId": roomId,
      "gameId": gameId,
    };

    Widget child;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        child = PlatformViewLink(
          key: ValueKey("${roomId}_$gameId"),
          viewType: viewType,
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<EagerGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                )
              },
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        );
      case TargetPlatform.iOS:
        child = UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<EagerGestureRecognizer>(
              () => EagerGestureRecognizer(),
            )
          },
        );
      default:
        child = const SizedBox.shrink();
    }

    child = Stack(
      children: [
        Center(
          child: SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ),
        child,
        // 手势需要
        if (gameId != SudGameDelegate.saiche)
          Positioned(
            top: 0,
            left: 60,
            right: 60,
            height: 48,
            child: Opacity(
              opacity: 0,
              child: Container(
                width: double.infinity,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );

    final aspectRatio = widget.sudGameDelegate.aspectRatio;
    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: child,
      );
    }

    return child;
  }

  @override
  bool get wantKeepAlive => true;
}

class SudMGPAPPState {
  static const MG_COMMON_GAME_MONEY_NOT_ENOUGH =
      "mg_common_game_money_not_enough";
  static const MG_COMMON_GAME_CREATE_ORDER = "mg_common_game_create_order";
  static const MG_COMMON_GAME_GET_SCORE = "mg_common_game_get_score";
  static const MG_COMMON_GAME_SET_SCORE = "mg_common_game_set_score";
  static const MG_COMMON_DESTROY_GAME_SCENE = "mg_common_destroy_game_scene";
  static const MG_COMMON_HIDE_GAME_SCENE = "mg_common_hide_game_scene";
  static const MG_COMMON_SELF_CLICK_GOLD_BTN = "mg_common_self_click_gold_btn";
  static const MG_COMMON_USERS_INFO = "mg_common_users_info";

  static const APP_COMMON_UPDATE_GAME_MONEY = "app_common_update_game_money";
  static const APP_COMMON_GAME_CREATE_ORDER_RESULT =
      "app_common_game_create_order_result";
  static const APP_COMMON_GAME_SCORE = "app_common_game_score";
  static const APP_COMMON_USERS_INFO = "app_common_users_info";
}

class SudGameDelegate {
  const SudGameDelegate({
    this.aspectRatio,
  });

  final double? aspectRatio;

  static const haidaowang = "1765372835854204929";
  static const shuiguopaidui = "1765373047507173377";
  static const buyu = "1765373136321560578";
  static const saiche = "1649319572314173442";
  static const shuiguolaba = "1765373900355977217";

  Future<String> getSudGameCode() async {
    return "";
  }

  Future<bool> createOrder(Map<String, dynamic> body) async {
    return true;
  }

  Future<num> getGameScore() async {
    return 0;
  }

  Future<void> onGameStateChange(BuildContext context, String state) async {}

  Future<List<GameUser>> getUsers(List<String> userIds) async {
    return [];
  }
}

class GameUser {
  final String uid;
  final String avatar;
  final String name;

  const GameUser({
    required this.uid,
    required this.avatar,
    required this.name,
  });
}
