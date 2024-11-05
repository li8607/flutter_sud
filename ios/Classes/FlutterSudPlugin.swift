import Flutter
import UIKit
import SudMGP

public class FlutterSudPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "com.pumpkin.sud/messages", binaryMessenger: registrar.messenger())
        GlobalData.methodChannel = methodChannel
        
        let eventChannel = FlutterEventChannel(name: "com.pumpkin.sud/events", binaryMessenger: registrar.messenger())
        
        let instance = FlutterSudPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        eventChannel.setStreamHandler(instance)
        SudMGP.getCfg().setEnableAudioSessionActive(false)
        SudMGP.getCfg().setEnableAudioSessionCategory(false)
        
        let factory = SudGameViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "SudGame")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            guard let args = call.arguments as? [String: Any],
                  let appId = args["appId"] as? String,
                  let appKey = args["appKey"] as? String,
                  let gameIsTestEnv = args["gameIsTestEnv"] as? Bool,
                  let userId = args["userId"] as? String,
                  let languageCode = args["languageCode"] as? String
            else {
                return result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for init method", details: nil))
            }
            
            GlobalData.appId = appId
            GlobalData.appKey = appKey
            GlobalData.gameIsTestEnv = gameIsTestEnv
            GlobalData.userId = userId
            GlobalData.languageCode = languageCode
            result(true)
        case "notifyStateChange":
            guard let args = call.arguments as? [String: Any],
                  let state = args["state"] as? String,
                  let dataJson = args["dataJson"] as? String
            else {
                return result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for notifyStateChange method", details: nil))
            }
            GlobalData.sudGameEventHandler?.sudFSTAPPDecorator.notifyStateChange(state, dataJson: dataJson)
            result(true)
        case "resume":
            GlobalData.sudGameEventHandler?.sudFSTAPPDecorator.playMG()
            result(true)
        case "pause":
            GlobalData.sudGameEventHandler?.sudFSTAPPDecorator.pauseMG()
            result(true)
        case "destroy":
            GlobalData.sudGameEventHandler?.sudFSTAPPDecorator.destroyMG()
            result(true)
        default:
            result(true)
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        GlobalData.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        GlobalData.eventSink = nil
        return nil
    }
}
