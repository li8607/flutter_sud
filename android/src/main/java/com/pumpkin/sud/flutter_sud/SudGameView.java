package com.pumpkin.sud.flutter_sud;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;
import androidx.lifecycle.Observer;

import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.platform.PlatformView;

class SudGameView implements PlatformView, LifecycleOwner {

    private FrameLayout gameContainer;
    private SudGameViewModel gameViewModel = new SudGameViewModel();
    private LifecycleRegistry lifecycleRegistry;

    SudGameView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        try {
            init();
            String roomId = (String) creationParams.get("roomId");
            long gameId = Long.parseLong((String) creationParams.get("gameId"));
            gameContainer = new FrameLayout(context);
            GlobalData.sudGameViewModel = gameViewModel;
            gameViewModel.gameViewLiveData.observe(this, new Observer<View>() {
                @Override
                public void onChanged(View view) {
                    if (view == null) { // 在关闭游戏时，把游戏View给移除
                        gameContainer.removeAllViews();
                    } else { // 把游戏View添加到容器内
                        gameContainer.addView(view, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
                    }
                }
            });
            Activity activity = getActivity(context);
            gameViewModel.switchGame(activity, roomId, gameId);
        }catch (Exception e) {
            Log.e("SudGame", e.toString());
        }
    }

    @NonNull
    @Override
    public View getView() {
        return gameContainer;
    }

    private Activity getActivity(Context context) {
        if (context == null) {
            return null;
        } else if (context instanceof Activity) {
            return (Activity) context;
        } else if (context instanceof ContextWrapper) {
            return getActivity(((ContextWrapper) context).getBaseContext());
        }
        return null;
    }

    private void init() {
        lifecycleRegistry = new LifecycleRegistry(this);
        lifecycleRegistry.setCurrentState(Lifecycle.State.CREATED);
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return lifecycleRegistry;
    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        PlatformView.super.onFlutterViewAttached(flutterView);
        lifecycleRegistry.setCurrentState(Lifecycle.State.STARTED);
        gameViewModel.onResume();
    }

    @Override
    public void onFlutterViewDetached() {
        PlatformView.super.onFlutterViewDetached();
        lifecycleRegistry.setCurrentState(Lifecycle.State.DESTROYED);
        gameViewModel.onPause();
    }

    @Override
    public void dispose() {
        gameViewModel.destroyMG();
    }
}