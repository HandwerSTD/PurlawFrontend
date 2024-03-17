import 'package:flutter/cupertino.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

import '../../common/constants/constants.dart';
import '../../common/network/chat_api.dart';
import '../../common/network/network_request.dart';
import '../../common/utils/database/database_util.dart';
import '../../common/utils/log_utils.dart';
import '../../components/third_party/modified_just_audio.dart';
import '../../components/third_party/prompt.dart';
import '../../models/ai_chat/chat_message_model.dart';

class SimilarCasesViewModel extends BaseViewModel {
  String selectedRegion = "全国";
  String selectedLevel = "全部案例";
  String selectedSort = "综合排序";
  String description = "";

  List<String> cases = ["案例1", "案例2"];

  bool genComplete = false;
  bool genStart = false;
  AIChatMessageModelWithAudio message = AIChatMessageModelWithAudio();

  Future<void> appendMessage(String msg, String cookie) async {
    var sentences = msg.split('。'); // 按逗号分隔
    bool endsWithDot = msg.endsWith('。'); // 最后一个是否是完整句子

    refresh() {
      notifyListeners();
    }

    Future<void> submitAudio(String sentence, int id) async {
      if (sentence.isEmpty) return;
      await message.playlist.add(LockCachingAudioSource(
          Uri.parse(HttpGet.getApi(API.chatRequestVoice.api) + sentence),
          headers: HttpGet.jsonHeadersCookie(cookie)));
    }

    message.animatedAdd(msg, refresh);
    // Log.d(sentences, tag:"Chat Page ViewModel appendMessage");
    for (int index = 0; index < sentences.length - 1; ++index) {
      await message.append(sentences[index], true, () {}, submitAudio);
    }
    if (sentences.last.isEmpty) return;
    await message.append(sentences.last, endsWithDot, () {}, submitAudio);
  }
  Future<void> submit(String cookie) async {
    // text = "";
    genStart = true;
    genComplete = false;
    notifyListeners();
    final session = DatabaseUtil.getLastAIChatSession();
    if (session.isEmpty) {
      showToast("请先指定一个会话",
          toastType: ToastType.warning, alignment: Alignment.center);
      return;
    }
    try {
      showToast("生成中", toastType: ToastType.info, alignment: Alignment.center);
      message = AIChatMessageModelWithAudio();
      ChatNetworkRequest.breakIsolate(cookie, session);
      await ChatNetworkRequest.submitNewMessage(
          session,
          "请列出3个与如下案例相似的案例，要求案例地区为$selectedRegion，法院级别为$selectedLevel，按${selectedSort == "综合排序" ? "相关度排序" : selectedSort}方式进行排序，包括案号、案例名称、关键词、详细信息。不要输出其他内容。案例描述为：$description",
          cookie,
          appendMessage, () {
        genStart = false;
        genComplete = true;
        var text = "";
        for (var txt in message.sentences) {
          text += txt;
        }
        notifyListeners();
      });
    } on Exception catch (e) {
      Log.e(tag: "ContractGeneration ViewModel", e);
      showToast("生成失败", toastType: ToastType.warning);
      // ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
      ChatNetworkRequest.breakIsolate(cookie, session);
    }
  }
}