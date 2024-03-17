import 'dart:io';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import '../../common/constants/constants.dart';
import '../../common/network/chat_api.dart';
import '../../common/network/network_request.dart';
import '../../common/utils/database/database_util.dart';
import '../../components/third_party/modified_just_audio.dart';
import '../../components/third_party/prompt.dart';
import '../../method_channels/document_recognition.dart';
import '../../models/ai_chat/chat_message_model.dart';

const String tag = "AI DocumentRecognition ViewModel";

class AIDocumentRecViewModel extends BaseViewModel {
  PageController controller = PageController();
  List<String> result = [];
  List<AIDocumentRecBodyModel> models = [];

  void load() async {
    final files = await CunningDocumentScanner.getPictures(true);
    if (files == null) return;
    for (var file in files) {
      result.add(((file)));
      models.add(AIDocumentRecBodyModel(image: File(file)));
    }
    controller.animateToPage(result.length - 1 - (files.length - 1), duration: const Duration(milliseconds: 500), curve: Curves.easeOutExpo);
    notifyListeners();
  }


  void notify() {
    notifyListeners();
  }
}

class AIDocumentRecBodyModel {
  TextEditingController controller = TextEditingController();
  final File image;
  late Uint8List imageBytes;
  AIDocumentRecBodyModel({required this.image}) {
    imageBytes = image.readAsBytesSync();
  }
  bool ocrCompleted = false;
  String ocrResult = "";

  Future<void> loadOCR() async {
    final res = await DocumentRecognition.getResult(XFile(image.absolute.path));
    ocrResult = "";
    for (var str in res) {
      ocrResult += "$str\n";
    }
    print(ocrResult);
    controller = TextEditingController(text: ocrResult);
    ocrCompleted = true;
  }
}

class AIDocumentAnalyzeViewModel extends BaseViewModel {
  String text = "";
  late AIChatMessageModelWithAudio message;

  load(String str, String cookie) {
    text = str;
    submit(cookie);
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

  void manuallyBreak(String cookie, String session) {
    Log.i(tag: "Chat Voice Recognition ViewModel", "[DEBUG] Manually Break");
    try {
      // ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
      ChatNetworkRequest.breakIsolate(cookie, session);
      message.player.stop();
    } on Exception catch (e) {
      Log.e(tag: "Chat Voice Recognition ViewModel", e);
    } finally {
      message.generateCompleted.value = true;
      notifyListeners();
    }
  }
  Future<void> submit(String cookie) async {
    message = AIChatMessageModelWithAudio();
    notifyListeners();
    final session = DatabaseUtil.getLastAIChatSession();
    if (session.isEmpty) {
      showToast("请先指定一个会话", toastType: ToastType.warning, alignment: Alignment.center);
      return;
    }
    try {
      message.player.setAudioSource(message.playlist);
      // ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
      ChatNetworkRequest.breakIsolate(cookie, session);
      await ChatNetworkRequest.submitNewMessage(session, "分析下列文本：\n$text", cookie, appendMessage, (){
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
      showToast("生成失败", toastType: ToastType.error);
      // ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
      ChatNetworkRequest.breakIsolate(cookie, session);
    }
  }
}
