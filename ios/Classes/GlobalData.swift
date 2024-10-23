//
//  GlobalData.swift
//  flutter_sud
//
//  Created by limf on 2024/10/15.
//

import Flutter
import Foundation

class GlobalData {
    static var gameIsTestEnv: Bool = false
    static var appId: String?
    static var appKey: String?
    static var userId: String?
    static var languageCode: String = "en-US"
    static var eventSink: FlutterEventSink?
    static var sudGameEventHandler: SudGameEventHandler?
    static var methodChannel: FlutterMethodChannel?
}
