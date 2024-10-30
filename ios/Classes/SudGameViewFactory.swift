import Flutter
import UIKit

class SudGameViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return SudGameView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class SudGameView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _args: Any?
    private var _sudGameManager: SudGameManager?
    

    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        _args = args
        super.init()
        createNativeView(view: _view)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func gameId() -> Int64 {
        if let argsDict = _args as? [String: Any],
           let gameIdString = argsDict["gameId"] as? String,
           let gameIdInt64 = Int64(gameIdString) {
            return gameIdInt64
        }
        return 0;
    }
    
    func roomId() -> String {
        if let argsDict = _args as? [String: Any],
           let roomId = argsDict["roomId"] as? String{
            return roomId
        }
        return "";
    }
    
    func createNativeView(view _view: UIView){
        // 1. step
        // Create a game management instance
        _sudGameManager = SudGameManager()
        
        // Create an instance of the game event handler object
        let  gameEventHandler = SudGameEventHandler()
        
        GlobalData.sudGameEventHandler = gameEventHandler
        // Register the game event processing object instance into the game management object instance
        _sudGameManager?.registerGameEventHandler(gameEventHandler)
        
        // 2. step
        // Load the game
        let gameId = gameId()
        loadGame(gameId: gameId)
    }
    
    func loadGame(gameId: Int64) {
        // Set the required parameters for loading SudMGP
        let sudGameConfigModel = SudGameLoadConfigModel()
        
        // Application ID
        sudGameConfigModel.appId = GlobalData.appId ?? ""
        
        // Application key
        sudGameConfigModel.appKey = GlobalData.appKey ?? ""
        
        // Set to true during the test and false when publishing online
        sudGameConfigModel.isTestEnv = GlobalData.gameIsTestEnv
        
        // ID of the game to be loaded
        sudGameConfigModel.gameId = gameId
        
        // Assign a game room, and people with the same room number are in the same game hall
        sudGameConfigModel.roomId = roomId()
        
        // Configure the in-game display language
        sudGameConfigModel.language = GlobalData.languageCode
        
        // Game display view
        sudGameConfigModel.gameView = _view
        
        // Current user id
        sudGameConfigModel.userId = GlobalData.userId ?? ""
        
        _sudGameManager?.loadGame(sudGameConfigModel)
    }
    
    func destroyGame() {
        // Destroy the game
        _sudGameManager?.destroyGame()
        _sudGameManager = nil
        
//        // Remove the observer
//        NotificationCenter.default.removeObserver(self)
    }
}

