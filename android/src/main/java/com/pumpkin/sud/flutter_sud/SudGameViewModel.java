package com.pumpkin.sud.flutter_sud;

import android.app.Activity;
import android.os.Build;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import com.google.gson.Gson;
import java.util.HashMap;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import tech.sud.mgp.SudMGPWrapper.decorator.SudFSMMGListener;
import tech.sud.mgp.SudMGPWrapper.decorator.SudFSTAPPDecorator;
import tech.sud.mgp.SudMGPWrapper.model.GameConfigModel;
import tech.sud.mgp.SudMGPWrapper.model.GameViewInfoModel;
import tech.sud.mgp.SudMGPWrapper.state.SudMGPMGState;
import tech.sud.mgp.core.ISudFSMMG;
import tech.sud.mgp.core.ISudFSMStateHandle;

/**
 * 游戏业务逻辑
 * 1.自定义ViewModel继承此类，实现对应方法。(注意：onAddGameView()与onRemoveGameView()与页面有交互)
 * 2.外部调用switchGame(activity,gameRoomId,gameId)方法启动游戏，参数定义可查看方法注释。
 * 3.页面销毁时调用onDestroy()
 * <p>
 * Game business logic
 * 1. Define a custom ViewModel that extends this class and implement the corresponding methods. (Note: onAddGameView() and onRemoveGameView() interact with the page)
 * 2. Externally call the switchGame(activity, gameRoomId, gameId) method to start the game. Refer to method comments for parameter definitions.
 * 3. Call onDestroy() when the page is destroyed.
 */
public class SudGameViewModel extends BaseGameViewModel {

    public static String SudMGP_APP_ID = GlobalData.appId;

    public static String SudMGP_APP_KEY = GlobalData.appKey;

    public static final boolean GAME_IS_TEST_ENV = GlobalData.gameIsTestEnv;

    public static String userId = GlobalData.userId;

    // 游戏自定义安全操作区域
    // Customized security operation zone for the game.
    public GameViewInfoModel.GameViewRectModel gameViewRectModel;

    public String languageCode = GlobalData.languageCode;

    // 游戏View回调
    // Game View callback.
    public final MutableLiveData<View> gameViewLiveData = new MutableLiveData<>();

    /**
     * 向接入方服务器获取code
     * Retrieve the code from the partner's server.
     */
    @Override
    protected void getCode(Activity activity,  GameGetCodeListener listener) {
        if(GlobalData.methodChannel != null) {
            GlobalData.methodChannel.invokeMethod("getCode", "", new MethodChannel.Result() {
                @Override
                public void success(@Nullable Object result) {
                    if(result.toString().isEmpty()) {
                        listener.onFailed();
                        return;
                    }
                    listener.onSuccess(result.toString());
                }

                @Override
                public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                    listener.onFailed();
                }

                @Override
                public void notImplemented() {
                    listener.onFailed();
                }
            });
        }
    }

    /**
     * 设置当前用户id(接入方定义)
     * Set the current user ID (defined by the partner).
     */
    @Override
    protected String getUserId() {
        return userId;
    }

    /**
     * 设置Sud平台申请的appId
     * Set the appId obtained from the Sud platform.
     */
    @Override
    protected String getAppId() {
        return SudMGP_APP_ID;
    }

    /**
     * 设置Sud平台申请的appKey
     * Set the appKey obtained from the Sud platform.
     */
    @Override
    protected String getAppKey() {
        return SudMGP_APP_KEY;
    }

    /**
     * 设置游戏的语言代码
     * Set the language code for the game.
     */
    @Override
    protected String getLanguageCode() {
        return languageCode;
    }

    /**
     * 设置游戏的安全操作区域，{@link ISudFSMMG}.onGetGameViewInfo()的实现。
     * 参考文档：https://docs.sud.tech/zh-CN/app/Client/API/ISudFSMMG/onGetGameViewInfo.html
     * <p>
     * Set the secure operation area for the game, implementation of {@link ISudFSMMG}.onGetGameViewInfo().
     * Reference documentation: https://docs.sud.tech/en-US/app/Client/API/ISudFSMMG/onGetGameViewInfo.html
     *
     * @param gameViewInfoModel 游戏视图模型
     *                          Game view model
     */
    @Override
    protected void getGameRect(GameViewInfoModel gameViewInfoModel) {
        // 相对于view_size（左、上、右、下）边框偏移（单位像素）
        // 开发者可自定义gameViewRectModel来控制安全区域

        // Border offset relative to view_size (left, top, right, bottom) in pixels
        // Developers can customize the gameViewRectModel to control the safe area
        if (gameViewRectModel != null) {
            gameViewInfoModel.view_game_rect = gameViewRectModel;
        }
    }

    /**
     * 获取游戏配置对象，{@link ISudFSMMG}.onGetGameCfg()的实现。
     * 参考文档：https://docs.sud.tech/zh-CN/app/Client/API/ISudFSMMG/onGetGameCfg.html
     * 开发者拿到此对象之后，可修改自己需要的配置
     * 注意：在加载游戏之前配置才有效
     * <p>
     * Get the game configuration object, implementation of {@link ISudFSMMG}.onGetGameCfg().
     * Reference documentation: https://docs.sud.tech/en-US/app/Client/API/ISudFSMMG/onGetGameCfg.html
     * Once developers obtain this object, they can modify the desired configurations.
     * Note: The configurations are only effective before loading the game.
     *
     * @return 游戏配置对象
     * Game configuration object
     */
    public GameConfigModel getGameConfigModel() {
        return gameConfigModel;
    }

    /**
     * true 加载游戏时为测试环境
     * false 加载游戏时为生产环境
     * <p>
     * true for loading the game in the testing environment
     * false for loading the game in the production environment.
     */
    @Override
    protected boolean isTestEnv() {
        return GAME_IS_TEST_ENV;
    }

    /**
     * 将游戏View添加到页面中
     * Add the game View to the page.
     */
    @Override
    protected void onAddGameView(View gameView) {
        gameViewLiveData.setValue(gameView);
    }

    /**
     * 将页面中的游戏View移除
     * Remove the game View from the page.
     */
    @Override
    protected void onRemoveGameView() {
        gameViewLiveData.setValue(null);
    }

    // ************ 上面是基础能力以及必要配置，下面讲解状态交互
    // ************ 主要有：1.App向游戏发送状态；2.游戏向App回调状态

    // ************ Above are the basic capabilities and necessary configurations, below we explain state interactions
    // ************ Mainly include: 1. App sending states to the game; 2. Game callback states to the App

    /**
     * 1.App向游戏发送状态
     * 这里演示的是发送：1. 加入状态；
     * 开发者可自由定义方法，能发送的状态都封装在{@link SudFSTAPPDecorator}
     * 参考文档：https://docs.sud.tech/zh-CN/app/Client/APPFST/
     * 注意：
     * 1，App向游戏发送状态，因为需要走网络，所以向游戏发送状态之后，不能马上销毁游戏或者finish Activity，否则状态无法发送成功。
     * 2，要保证状态能到达，可以发送之后，delay 500ms再销毁游戏或者finish Activity。
     *
     * <p> English
     * App sending states to the game
     * Here, we demonstrate sending the "join" state.
     * Developers can freely define methods to send different states, all encapsulated in {@link SudFSTAPPDecorator}.
     * Reference documentation: https://docs.sud.tech/en-US/app/Client/APPFST/
     * Note:
     * When sending states from the App to the game, as it involves network communication, the game should not be immediately destroyed or the Activity finished after sending the state; otherwise, the state may not be successfully sent.
     * To ensure the state reaches the game, it is recommended to delay the destruction of the game or finishing the Activity by 500ms after sending the state.
     */
    public void notifyAPPCommonSelfInV2(boolean isIn, int seatIndex, boolean isSeatRandom, int teamId) {
        sudFSTAPPDecorator.notifyAPPCommonSelfInV2(isIn, seatIndex, isSeatRandom, teamId);
    }

    /**
     * 2.游戏向App回调状态
     * 这里演示的是接收游戏回调状态：10. 游戏状态 mg_common_game_state
     * 游戏回调的每个状态都对应着一个方法，方法定义在：{@link SudFSMMGListener}
     * 在文档(https://docs.sud.tech/zh-CN/app/Client/MGFSM/)里面定义的都是游戏向APP回调状态的定义
     * 其中又细分为通过两个不同接口进行回调，分别是：onGameStateChange和onPlayerStateChange，但是都已封装好，只需关心SudFSMMGListener对应回调即可
     *
     * <p> English
     * 2. Game callback states to the App
     * Here, we demonstrate receiving the game callback state: 10. Game state mg_common_game_state
     * Each callback state from the game corresponds to a method defined in {@link SudFSMMGListener}.
     * The definitions for game callback states are provided in the documentation (https://docs.sud.tech/en-US/app/Client/MGFSM/).
     * These states are further divided into two different interfaces for callbacks: onGameStateChange and onPlayerStateChange. However, they are already encapsulated, and you only need to focus on the corresponding callbacks in SudFSMMGListener.
     */
    @Override
    public void onGameMGCommonGameState(ISudFSMStateHandle handle, SudMGPMGState.MGCommonGameState model) {
        super.onGameMGCommonGameState(handle, model);
    }

    @Override
    public boolean onGameStateChange(ISudFSMStateHandle handle, String state, String dataJson) {
        if (GlobalData.eventSink != null) {
            Map<String, String> map = new HashMap<String, String>();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                map.putIfAbsent("state", state);
                map.putIfAbsent("dataJson", dataJson);
            }else {
                map.put("state", state);
                map.put("dataJson", dataJson);
            }
            Gson gson = new Gson();
            String event = gson.toJson(map);
            GlobalData.eventSink.success(event);
        }
        return super.onGameStateChange(handle, state, dataJson);
    }
}
