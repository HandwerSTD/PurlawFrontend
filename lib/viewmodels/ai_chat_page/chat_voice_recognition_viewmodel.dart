import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:record/record.dart';

class ChatVoiceRecognitionViewModel extends BaseViewModel {
  bool listeningVoice = false;
  String text = "";
  final audioRecorder = AudioRecorder();
  late StreamSubscription audioSub, recordStateSub;

  RecordState recordState = RecordState.stop;

  final player = AudioPlayer();
  final playSource = ConcatenatingAudioSource(children: []);

  load() {
    recordStateSub = audioRecorder.onStateChanged().listen((event) {
      recordState = event;
      notifyListeners();
    });
  }
  onDispose() {
    recordStateSub.cancel();
    audioSub.cancel();
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
    audioRecorder.start(const RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1
    ), path: "${(await getApplicationDocumentsDirectory()).path}/111.wav");
    listeningVoice = true;
    notifyListeners();
  }
  void stopRecord() async {
    final path = await audioRecorder.stop();
    Log.i("Record ended. $path");
    listeningVoice = false;
    notifyListeners();
  }
}