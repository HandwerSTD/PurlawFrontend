package com.tianzhu.purlaw;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Arrays;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_NAME = "com.tianzhu.purlaw/channel";
    private static final String EVENT_CHANNEL_NAME = "com.tianzhu.purlaw/message";

    private static EventChannel.EventSink eventSink;

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
                        case "speechToText" -> {
                            final String filename = call.argument("filename");
                            final String modelPath = call.argument("modelPath");
//                            final String res = speechToText(filename, modelPath);
//                            result.success(res);
                            runSpeechToText(filename, modelPath);
                            result.success("");
                        }
                    }
                });
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL_NAME)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink = events;
                        Log.d("DebugMainActivity", "eventSink got");
                        flushUI("666");
                    }

                    @Override
                    public void onCancel(Object arguments) {

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

    private native String speechToText(String filename, String modelPath);

    public void flushUI(String result) {
        new Handler(Looper.getMainLooper()).post(() -> {
            if (eventSink == null) {
                Log.d("DebugMainActivity", "eventSink is null");
                return;
            }
            eventSink.success(result);

            Log.d("DebugMainActivity", "flush UI with result: " + result);
        });
    }

    public void runSpeechToText(String filename, String modelPath) {
        new Thread(() -> speechToText(filename, modelPath)).start();
    }
}
