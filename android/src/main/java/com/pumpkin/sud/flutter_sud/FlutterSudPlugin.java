package com.pumpkin.sud.flutter_sud;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterSudPlugin
 */
public class FlutterSudPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    private MethodChannel methodChannel;
    private EventChannel eventChannel;

    private static final String MESSAGES_CHANNEL = "com.pumpkin.sud/messages";
    private static final String EVENTS_CHANNEL = "com.pumpkin.sud/events";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), MESSAGES_CHANNEL);
        methodChannel.setMethodCallHandler(this);
        GlobalData.methodChannel = methodChannel;

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENTS_CHANNEL);
        eventChannel.setStreamHandler(this);
        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory("SudGame", new SudGameViewFactory());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            if (call.method.equals("init")) {
                String appId = call.argument("appId");
                String appKey = call.argument("appKey");
                boolean gameIsTestEnv = call.argument("gameIsTestEnv");
                String userId = call.argument("userId");
                String languageCode = call.argument("languageCode");
                GlobalData.appId = appId;
                GlobalData.appKey = appKey;
                GlobalData.gameIsTestEnv = gameIsTestEnv;
                GlobalData.userId = userId;
                GlobalData.languageCode = languageCode;
                result.success(true);
            } else if (call.method.equals("notifyStateChange")) {
                String state = call.argument("state");
                String dataJson = call.argument("dataJson");
                if (GlobalData.sudGameViewModel != null) {
                    GlobalData.sudGameViewModel.sudFSTAPPDecorator.notifyStateChange(state, dataJson);
                }
                result.success(true);
            } else if (call.method.equals("resume")) {
                if (GlobalData.sudGameViewModel != null) {
                    GlobalData.sudGameViewModel.onResume();
                }
                result.success(true);
            } else if (call.method.equals("pause")) {
                if (GlobalData.sudGameViewModel != null) {
                    GlobalData.sudGameViewModel.onPause();
                }
                result.success(true);
            } else {
                result.notImplemented();
            }
        } catch (Exception e) {
            result.error("500", e.getMessage(), e.toString());
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink eventSink) {
        GlobalData.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object arguments) {
        GlobalData.eventSink = null;
    }
}
