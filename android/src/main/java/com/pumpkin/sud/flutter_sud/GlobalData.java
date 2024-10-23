package com.pumpkin.sud.flutter_sud;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class GlobalData {

    static boolean gameIsTestEnv = false;
    static String appId;
    static String appKey;
    static String userId;
    static String languageCode = "en-US";
    static EventChannel.EventSink eventSink;
    static SudGameViewModel sudGameViewModel;;
    static MethodChannel methodChannel;
}
