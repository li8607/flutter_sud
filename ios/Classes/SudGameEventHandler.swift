//
//  QuickStartSudGameEventHandler.swift
//  QuickStart
//
//  Created by kaniel on 2024/1/16.
//  Copyright © 2024 Sud.Tech (https://sud.tech). All rights reserved.
//

import Foundation
import UIKit
import SudMGP
import SudMGPWrapper

class SudGameEventHandler: SudGameBaseEventHandler {
    
    override func onGetGameCfg() -> GameCfgModel {
        let gameCfgModel = GameCfgModel.default()
        /// You can configure the game according to your application needs here, such as configuring the sound
        gameCfgModel.gameSoundVolume = 100
        /// ...
        return gameCfgModel
    }
    
    override func onGetGameViewInfo() -> GameViewInfoModel {
        /// The application configures the game display view information here according to its layout requirements
        
        // Screen Safety zone
        let safeArea = self.safeAreaInsets()
        // Status bar height
        let statusBarHeight = safeArea.top == 0 ? 20 : safeArea.top
        
        let m = GameViewInfoModel()
        let gameViewRect = self.loadConfigModel?.gameView?.bounds
        
        // Game display area
        m.view_size.width = Int(gameViewRect?.size.width ?? 0)
        m.view_size.height = Int(gameViewRect?.size.height ?? 0)
        // Game content layout security area, adjust the top spacing according to their own business
        // top spacing
        m.view_game_rect.top = Int((statusBarHeight + 80))
        // Left
        m.view_game_rect.left = 0
        // Right
        m.view_game_rect.right = 0
        // Bottom safe area
        m.view_game_rect.bottom = Int((safeArea.bottom + 100))
        return m
    }
    
    override func onGetCode(_ userId: String, result: @escaping (String) -> Void) {
        guard let methodChannel = GlobalData.methodChannel else {
            result("")
            return
        }
        
        methodChannel.invokeMethod("getCode", arguments: nil) { code in
            if let codeString = code as? String {
                result(codeString)
            } else {
                result("")
            }
        }
    }
    
    // MARK: - Private
    /// Device safety zone
    private func safeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        } else {
            return .zero
        }
    }
    
    func onGameStateChange(_ handle: any ISudFSMStateHandle, state: String, dataJson: String) -> Bool {
        if let eventSink = GlobalData.eventSink {
            let map: [String: Any] = [
                "state": state,
                "dataJson": dataJson
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: map),
               let event = String(data: jsonData, encoding: .utf8) {
                eventSink(event)
            }
        }
        return false;
    }
}
