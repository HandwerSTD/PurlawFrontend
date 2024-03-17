import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/method_channels/speech_to_text.dart';
import 'package:purlaw/models/ai_chat/chat_message_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:record/record.dart';

import '../../common/constants/constants.dart';
import '../../common/network/chat_api.dart';
import '../../common/network/network_request.dart';
import '../../common/utils/database/database_util.dart';
import '../../components/third_party/modified_just_audio.dart';

class ChatVoiceRecognitionViewModel extends BaseViewModel {
  bool listeningVoice = false;
  String text = "点击按钮来说话...";
  final audioRecorder = AudioRecorder();
  late StreamSubscription recordStateSub, sttSub;
  bool sttFinished = false;
  bool showMineText = false;
  bool startGen = false;
  String cookie = "";
  AIChatMessageModelWithAudio message = AIChatMessageModelWithAudio();

  RecordState recordState = RecordState.stop;

  ChatVoiceRecognitionViewModel();

  load(String c) {
    cookie = c;
    recordStateSub = audioRecorder.onStateChanged().listen((event) {
      recordState = event;
      notifyListeners();
    });
    sttSub = SpeechToTextUtil.getStream().listen((event) {
      final result = event.toString();
      if (result == "<EOF>") {
        // end
        sttFinished = true;
        submit(cookie);
        return;
      }
      text = result;
      notifyListeners();
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

  void manuallyBreak(String cookie, String session) {
    Log.i(tag: "Chat Voice Recognition ViewModel", "[DEBUG] Manually Break");
    try {
      // ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
      ChatNetworkRequest.breakIsolate(cookie, session, manually: true);
      message.player.stop();
    } on Exception catch (e) {
      Log.e(tag: "Chat Voice Recognition ViewModel", e);
    } finally {
      message.generateCompleted.value = true;
      notifyListeners();
      // showToast("打断成功，建议稍等或切换会话使用", toastType: ToastType.info, duration: 5.seconds);
    }
  }

  void startRecord() async {
    text = "聆听中...";  sttFinished = false; showMineText = false; notifyListeners();
    Log.i("Start record");
    try {
      if (!await Permission.microphone.isGranted) {
        if (!(await Permission.microphone.request().isGranted)) {
          Log.i("Permission not granted", tag: "ChatVoice ViewModel");
          showToast("请授予权限", toastType: ToastType.warning);
          return;
        }
      }
      // ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
      ChatNetworkRequest.breakIsolate(cookie, DatabaseUtil.getLastAIChatSession());
      message.player.stop();
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
    text = "";
    showMineText = true;
    notifyListeners();
    await SpeechToTextUtil.getResult(filename: path!);
    await Future.delayed(const Duration(seconds: 3));
    showMineText = false;
    notifyListeners();
  }

  Future<void> appendMessage(String msg, String cookie) async {
    var sentences = msg.split('。'); // 按逗号分隔
    bool endsWithDot = msg.endsWith('。'); // 最后一个是否是完整句子

    refresh(){
      notifyListeners();
    }
    Future<void> submitAudio(String sentence, int id) async {
      if (sentence.isEmpty) return;
      await message.playlist.add(LockCachingAudioSource(
          Uri.parse(HttpGet.getApi(API.chatRequestVoice.api) +
              sentence),
          headers: HttpGet.jsonHeadersCookie(cookie)));
      message.player.play();
    }

    message.animatedAdd(msg, refresh);
    // Log.d(sentences, tag:"Chat Page ViewModel appendMessage");
    for (int index = 0; index < sentences.length - 1; ++index) {
      await message.append(sentences[index], true, (){}, submitAudio);
    }
    if (sentences.last.isEmpty) return;
    await message.append(sentences.last, endsWithDot, (){}, submitAudio);
  }
  Future<void> submit(String cookie) async {
    message = AIChatMessageModelWithAudio();
    startGen = true;
    notifyListeners();
    final session = DatabaseUtil.getLastAIChatSession();
    if (session.isEmpty) {
      showToast("请先指定一个会话", toastType: ToastType.warning);
      return;
    }
    try {
      Log.i(text);
      message.player.setAudioSource(message.playlist);
      await ChatNetworkRequest.submitNewMessage(session, text, cookie, appendMessage, (){
        if (message.sentenceCompleted.isNotEmpty && !message.sentenceCompleted.last) {
          message.playlist.add(LockCachingAudioSource(
              Uri.parse(HttpGet.getApi(API.chatRequestVoice.api) +
                  message.sentences.last),
              headers: HttpGet.jsonHeadersCookie(cookie)));
        }
        message.generateCompleted.value = true;
        notifyListeners();
      });
    } on Exception catch (e) {
      Log.e(tag: "ContractGeneration ViewModel", e);
      if (e.toString().contains('session')) {
        showToast("生成失败，请尝试刷新会话列表", toastType: ToastType.error);
      }
      showToast("生成失败", toastType: ToastType.error);
      // ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
      ChatNetworkRequest.breakIsolate(cookie, session);
    }
  }
}
