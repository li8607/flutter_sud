package com.pumpkin.sud.flutter_sud_example;

import androidx.annotation.NonNull;

import com.pumpkin.sud.flutter_sud.SudGameViewFactory;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        flutterEngine
                .getPlatformViewsController()
                .getRegistry()
                .registerViewFactory("SudGame", new SudGameViewFactory());
    }
}
