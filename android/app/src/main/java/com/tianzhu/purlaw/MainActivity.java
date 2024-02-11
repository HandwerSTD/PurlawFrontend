package com.tianzhu.purlaw;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_NAME = "com.tianzhu.purlaw/channel";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "testGetStringFromAndroid" -> {
                            result.success(HelloJNI(call.argument("arg1")));
                        }
                        case "getCVVersion" -> {
                            result.success("Not implemented yet");
                        }
                    }
                });
    }

    static {
        System.loadLibrary("purlaw");
    }

    private native String HelloJNI(String arg);
}
