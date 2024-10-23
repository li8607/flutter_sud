//
//  SudGameBaseEventHandler.swift
//  QuickStart
//
//  Created by kaniel on 2024/1/16.
//  Copyright © 2024 Sud.Tech (https://sud.tech). All rights reserved.
//

import Foundation
import SudMGP
import SudMGPWrapper

/// 加载SudMGP SDK加载必须的业务参数
class SudGameLoadConfigModel {
    /// 应用ID，联系SUD获取
    /// Application ID. Contact SUD to obtain it
    var appId: String = ""
    /// Application Key. Contact SUD to obtain it
    var appKey: String = ""
    /// 加载环境，正式环境传入false,测试环境传入true.
    /// Load environment. Pass false to the formal environment and true to the test environment.
    var isTestEnv: Bool = false
    
    /// 游戏ID
    /// The game ID.
    var gameId: Int64 = 0
    /// 房间ID
    /// The room ID.
    var roomId: String = ""
    /// 当前用户ID
    /// The current user ID.
    var userId: String = ""
    /// 语言 支持简体"zh-CN"    繁体"zh-TW"    英语"en-US"   马来"ms-MY"
    /// The language (e.g., "zh-CN", "zh-TW", "en-US", "ms-MY").
    var language: String = ""
    /// 加载展示视图
    /// The view for displaying the game.
    var gameView: UIView?
    /// 授权秘钥,跨域使用，默认不需要设置
    /// Just use for cross app, default is nil
    var authorizationSecret: String?
}

/// 游戏事件处理基类模块
/// SudGameBaseEventHandler is a base class for handling game events.
class SudGameBaseEventHandler: NSObject, SudFSMMGListener {
    
    /// SudFSMMGDecorator game -> app 辅助接收解析SudMGP SDK抛出的游戏回调事件、获取相关游戏状态模块
    /// Helper module for receiving and parsing game callback events from SudMGP SDK.
    let sudFSMMGDecorator: SudFSMMGDecorator
    
    /// SudFSTAPPDecorator app -> game 辅助APP操作游戏相关指令模块
    /// Helper module for sending game-related commands from the app to the game.
    let sudFSTAPPDecorator: SudFSTAPPDecorator
    
    /// 加载游戏配置
    /// The loaded game configuration model.
    private(set) var loadConfigModel: SudGameLoadConfigModel?
    
    override init() {
        sudFSTAPPDecorator = SudFSTAPPDecorator()
        sudFSMMGDecorator = SudFSMMGDecorator()
        super.init()
        sudFSMMGDecorator.setEventListener(self)
    }
    
    deinit {
        print("SudGameBaseEventHandler deinit")
    }
    
    /// 设置加载游戏配置
    /// Sets the game configuration model.
    /// - Parameter loadConfigModel: 配置model
    func setupLoadConfigModel(_ loadConfigModel: SudGameLoadConfigModel) {
        self.loadConfigModel = loadConfigModel
    }
    
    /// 获取code并返回,子类必须实现像自己应用服务端获取code并返回
    /// 接入方客户端 调用 接入方服务端 getCode: 获取 短期令牌code
    /// 参考文档 https://docs.sud.tech/en-US/app/Server/ImplementAuthenticationByYourself.html
    /// - Parameters:
    ///   - userId: 当前加载游戏用户ID
    ///   - result: 返回code回调
    func onGetCode(_ userId: String, result: @escaping (String) -> Void) {
        assertionFailure("The game code must be loaded from the application service!!")
    }
    
    /// 配置游戏视图，应用根据自身配置游戏
    /// 开发者可以根据自己需求配置游戏相关功能展示
    func onGetGameCfg() -> GameCfgModel {
        return GameCfgModel.default()
    }
    
    /// 获取游戏View信息,默认返回全屏，应用根据自身需要覆写并返回视图信息(注意：此回调返回真实屏幕视图点距离即可，不需要使用计算scale值去算，内部会自行换算)
    func onGetGameViewInfo() -> GameViewInfoModel {
        let m = GameViewInfoModel()
        if let gameViewRect = loadConfigModel?.gameView?.bounds {
            // 默认游戏展示区域
            // Default area of game display
            m.view_size.width = Int(gameViewRect.size.width)
            m.view_size.height = Int(gameViewRect.size.height)
        }
        return m
    }
    
    // MARK: - SudFSMMGListener 游戏SDK回调 Game SDK callback
    
    func onGetGameCfg(_ handle: ISudFSMStateHandle, dataJson: String) {
        // 默认游戏配置
        // Default game configuration
        let m = onGetGameCfg()
        let configJsonStr = m.toJSON()
        print("onGetGameCfg: \(String(describing: configJsonStr))")
        handle.success(configJsonStr!)
    }
    
    func onGetGameViewInfo(_ handle: ISudFSMStateHandle, dataJson: String) {
        assert(loadConfigModel?.gameView != nil, "Must set the gameView")
        // 屏幕缩放比例，游戏内部采用px，需要开发者获取本设备比值 x 屏幕点数来获得真实px值设置相关字段中
        // Screen scaling, px is used inside the game, the developer needs to obtain the device ratio x screen points to get the real px value set in the relevant fields
        let scale = UIScreen.main.nativeScale
        let m = onGetGameViewInfo()
        // 游戏展示区域
        // Game display area
        m.view_size.width = Int(Double(m.view_size.width) * scale)
        m.view_size.height = Int(Double(m.view_size.height) * scale)
        // 游戏内容布局安全区域，根据自身业务调整顶部间距
        // Game content layout security area, adjust the top spacing according to their own business
        // 顶部间距
        // top spacing
        m.view_game_rect.top = Int(Double(m.view_game_rect.top) * scale)
        // 左边
        // To the left
        m.view_game_rect.left = Int(Double(m.view_game_rect.left) * scale)
        // 右边
        // Right
        m.view_game_rect.right = Int(Double(m.view_game_rect.right) * scale)
        // 底部安全区域
        // Bottom safe area
        m.view_game_rect.bottom = Int(Double(m.view_game_rect.bottom) * scale)
        
        m.ret_code = 0
        m.ret_msg = "success"
        let viewInfoJsonStr = m.toJSON()
        print("onGetGameViewInfo: \(String(describing: viewInfoJsonStr))")
        handle.success(viewInfoJsonStr!)
    }
    
    func onExpireCode(_ handle: ISudFSMStateHandle, dataJson: String) {
        // 请求业务服务器刷新令牌 Code更新
        // Request the service server to refresh the token Code update
        if let userId = loadConfigModel?.userId {
            onGetCode(userId) { [weak self] code in
                // 调用游戏接口更新令牌
                // Call game interface update token
                self?.sudFSTAPPDecorator.updateCode(code)
            }
        }
    }
    
    /// 游戏开始
    func onGameStarted() {
        /// 此时表明游戏加载成功
        /// The game is loaded successfully
        print("Game load finished")
    }
    
    /// 游戏销毁
    /// Game destruction
    func onGameDestroyed() {
        print("Game destroyed")
    }
}
