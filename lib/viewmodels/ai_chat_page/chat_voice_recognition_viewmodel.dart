import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/method_channels/speech_to_text.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:record/record.dart';

class ChatVoiceRecognitionViewModel extends BaseViewModel {
  bool listeningVoice = false;
  String text = "";
  final audioRecorder = AudioRecorder();
  late StreamSubscription recordStateSub, sttSub;

  RecordState recordState = RecordState.stop;

  ChatVoiceRecognitionViewModel({required super.context});

  load() {
    recordStateSub = audioRecorder.onStateChanged().listen((event) {
      recordState = event;
      notifyListeners();
    });
    sttSub = SpeechToTextUtil.getStream().listen((event) {
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        text = event.toString();
        notifyListeners();
      });
    }, onDone: () {
      Log.i("STT Stream done");
    }, onError: (e) {
      Log.e("STT Stream error", error: e);
    }, cancelOnError: true);

    recordStateSub.resume();
    sttSub.resume();
  }

  onDispose() {
    recordStateSub.cancel();
    sttSub.cancel();
    audioRecorder.dispose();
  }

  void startRecord() async {
    // audioSub = (await audioRecorder.startStream(const RecordConfig(
    //   encoder: AudioEncoder.pcm16bits,
    //   sampleRate: 16000
    // ))).listen((event) {
    //   // print("Audio Data: ${sha1.convert(event)}");
    // }, onDone: (){
    //   Log.i("Record done", tag:"Chat Voice ViewModel");
    // });
    Log.i("Start record");
    try {
      if (!await Permission.microphone.isGranted) {
        if (!(await Permission.microphone.request().isGranted)) {
          Log.i("Permission not granted", tag: "ChatVoice ViewModel");
          makeToast("请授予权限");
          return;
        }
      }
      await audioRecorder.start(
          const RecordConfig(
              encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
          path: "${(await getApplicationDocumentsDirectory()).path}/temp.wav");
      listeningVoice = true;
      notifyListeners();
    } on Exception catch (e) {
      Log.e(e);
    }
  }

  void stopRecord() async {
    final path = await audioRecorder.stop();
    Log.i("Record ended. $path");
    listeningVoice = false;
    notifyListeners();
    SpeechToTextUtil.getResult(filename: path!);
    // Log.i("STT Result got", tag: "ChatVoice ViewModel");
    // notifyListeners();
    // test();
  }

  void test() async {
    SpeechToTextUtil.getResult(
        filename:
            '/storage/emulated/0/Android/data/com.tianzhu.purlaw/files/0.wav');
    // Log.i("STT Result got", tag: "ChatVoice ViewModel");
    // notifyListeners();
  }
}
