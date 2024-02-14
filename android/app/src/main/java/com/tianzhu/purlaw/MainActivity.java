package com.tianzhu.purlaw;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Arrays;

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
                        case "testGetStringFromAndroid" -> result.success(HelloJNI(call.argument("arg1")));
                        case "getCVVersion" -> result.success(getCVBuildInfo());
                        case "documentRecognition" -> {
                            final String filename = call.argument("filename");
                            final String ocrModelPath = call.argument("ocrModelPath");
//                            documentRectify(filename);
                            final String[] recResult = (documentRecognition(filename, ocrModelPath));
                            final ArrayList<String> res = new ArrayList<>(recResult.length);
                            res.addAll(Arrays.asList(recResult));
                            result.success(res);
                        }
                    }
                });
    }

    static {
        System.loadLibrary("purlaw");
    }

    private native String HelloJNI(String arg);
    private native String getCVBuildInfo();

    private native String[] documentRecognition(String filename, String ocrModelPath);

    private native void documentRectify(String filename);
}
