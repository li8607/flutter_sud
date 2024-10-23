//
//  SudGameManager.swift
//  QuickStart
//
//  Created by kaniel on 2024/1/12.
//  Copyright © 2024 Sud.Tech (https://sud.tech). All rights reserved.
//

import Foundation
import SudMGP

class SudGameManager {
    
    // 游戏事件处理对象
    // Game event handling object
    var sudGameEventHandler: SudGameBaseEventHandler?
    
    deinit {
        print("SudGameManager deinit")
    }
    
    // MARK: - Public
    
    func registerGameEventHandler(_ eventHandler: SudGameBaseEventHandler) {
        self.sudGameEventHandler = eventHandler
        self.sudGameEventHandler?.sudFSMMGDecorator.setEventListener(eventHandler)
    }
    
    func loadGame(_ configModel: SudGameLoadConfigModel) {
        assert(sudGameEventHandler != nil, "Must registerGameEventHandler before!")
        if let sudGameEventHandler = sudGameEventHandler {
            sudGameEventHandler.setupLoadConfigModel(configModel)
            sudGameEventHandler.onGetCode(configModel.userId) { [weak self] code in
                print("on getCode success")
                self?.initSudMGPSDK(configModel, code: code)
            }
        }
    }
    
    func destroyGame() {
        assert(sudGameEventHandler != nil, "Must registerGameEventHandler before!")
        sudGameEventHandler?.sudFSMMGDecorator.clearAllStates()
        sudGameEventHandler?.sudFSTAPPDecorator.destroyMG()
    }
    
    // MARK: - Private
    
    /// 初始化游戏SudMDP SDK
    private func initSudMGPSDK(_ configModel: SudGameLoadConfigModel, code: String) {
        if configModel.gameId <= 0 {
            print("Game id is empty can not load the game: \(configModel.gameId), currentRoomID: \(configModel.roomId)")
            return
        }
        
        // SudMGP.getCfg().addEmbeddedMGPkg(1763401430010871809, mgPath: "GreedyStar_1.0.0.1.sp")
        
        // 2. 初始化SudMGP SDK<SudMGP initSDK>
        // 2. Initialize the SudMGP SDK <SudMGP initSDK>
        let paramModel = SudInitSDKParamModel()!
        paramModel.appId = configModel.appId
        paramModel.appKey = configModel.appKey
        paramModel.isTestEnv = configModel.isTestEnv
        
        SudMGP.initSDK(paramModel) { [weak self] retCode, retMsg in
            if retCode != 0 {
                print("ISudFSMMG:initGameSDKWithAppID init sdk failed: \(retMsg)(\(retCode))")
                return
            }
            print("ISudFSMMG:initGameSDKWithAppID: init sdk successfully")
            // 加载游戏
            // Load the game
            self?.loadMG(configModel, code: code)
        }
    }
    
    /// 加载游戏MG
    /// Initialize the SudMDP SDK for the game
    /// - Parameters:
    ///   - configModel: 配置model
    ///   - code: 游戏code
    private func loadMG(_ configModel: SudGameLoadConfigModel, code: String) {
        assert(sudGameEventHandler != nil, "Must registerGameEventHandler before!")
        sudGameEventHandler?.setupLoadConfigModel(configModel)
        // 确保初始化前不存在已加载的游戏 保证SudMGP initSDK前，销毁SudMGP
        // Ensure that there are no loaded games before initialization. Ensure SudMGP is destroyed before initSDK
        destroyGame()
        print("loadMG:userId:\(configModel.userId), gameRoomId:\(configModel.roomId), gameId:\(configModel.gameId)")
        
        if configModel.userId.isEmpty ||
            configModel.roomId.isEmpty ||
            code.isEmpty ||
            configModel.language.isEmpty ||
            configModel.gameId <= 0 {
            print("loadGame: param has some one empty")
            return
        }
        
        // 必须配置当前登录用户
        // The current login user must be configured
        sudGameEventHandler?.sudFSMMGDecorator.setCurrentUserId(configModel.userId)
        
        // 3. 加载SudMGP SDK<SudMGP loadMG>，注：客户端必须持有iSudFSTAPP实例
        // 3. Load SudMGP SDK<SudMGP loadMG>. Note: The client must hold the iSudFSTAPP instance
        let paramModel = SudLoadMGParamModel()!
        paramModel.userId = configModel.userId
        paramModel.roomId = configModel.roomId
        paramModel.code = code
        paramModel.mgId = Int(configModel.gameId)
        paramModel.language = configModel.language
        paramModel.gameViewContainer = configModel.gameView
        paramModel.authorizationSecret = configModel.authorizationSecret
        
        if let sudGameEventHandler = sudGameEventHandler {
            let iSudFSTAPP = SudMGP.loadMG(paramModel, fsmMG: sudGameEventHandler.sudFSMMGDecorator)
            sudGameEventHandler.sudFSTAPPDecorator.iSudFSTAPP = iSudFSTAPP
        }
    }
}
