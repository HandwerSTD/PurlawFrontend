/// AI 对话界面的 ViewModel

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purlaw/common/network/chat_api.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/constants/constants.dart';
import '../../common/network/network_request.dart';
import '../../components/third_party/modified_just_audio.dart';
import '../../models/ai_chat/chat_message_model.dart';

const tag = "Chat ViewModel";

/// 对话消息列表的 ViewModel
class AIChatMsgListViewModel extends BaseViewModel {
  ScrollController scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  ListAIChatMessageModelsWithAudio messageModels =
      ListAIChatMessageModelsWithAudio(messages: [
    AIChatMessageModelWithAudio.fromFull(Constants.firstOutput, false,
        first: true)
  ]);

  List<UserInfoModel> recommendLawyers = [];

  bool replying = false;
  bool autoPlay = false;

  final String? firstMessage;
  AIChatMsgListViewModel({this.firstMessage}) {
    if (firstMessage != null) {
      messageModels = ListAIChatMessageModelsWithAudio(messages: [AIChatMessageModelWithAudio.fromFull(firstMessage!, false, first: true)]);
    }
  }

  void getRecommendLawyer(String cookie, String text) async {
    try {
      Log.d(text);
      var response = jsonDecode((await HttpGet.post(API.userRecommendLawyer.api, HttpGet.jsonHeadersCookie(cookie), {
        'content': "火烧山东大学怎么判"
      })));
      if (response["status"] != "success") throw HttpException(response["message"]);
      List result = response["result"];
      Log.d(result);
      recommendLawyers.clear();
      for (var v in result) {
        recommendLawyers.add(UserInfoModel.fromJson(v));
        recommendLawyers.last.verified = true;
      }
      notifyListeners();
    } catch(e) {
      Log.e(e, tag: tag);
      showToast("网络异常");
    }
  }

  void switchToSessionMessages() async {
    final sid = DatabaseUtil.getLastAIChatSession();
    final data = await SessionListDatabaseUtil.getHistoryBySid(sid);
    if (data == "") {
      messageModels =
          ListAIChatMessageModelsWithAudio(messages: [
            AIChatMessageModelWithAudio.fromFull(Constants.firstOutput, false,
                first: true)
          ]);
      notifyListeners();
      return;
    }
    messageModels = ListAIChatMessageModelsWithAudio.fromDb(
      ListOfChatMessageModels.fromJson(jsonDecode(data))
    );
    notifyListeners();
  }
  void saveMessage() {
    HistoryDatabaseUtil.storeHistory(
        jsonEncode(messageModels.export().toJson()));
    messageModels = ListAIChatMessageModelsWithAudio(messages: [
      AIChatMessageModelWithAudio.fromFull(Constants.firstOutput, false,
          first: true)
    ]);
    notifyListeners();
    showToast("保存成功", toastType: ToastType.success);
  }
  void clearMessage() {
    messageModels = ListAIChatMessageModelsWithAudio(messages: [
      AIChatMessageModelWithAudio.fromFull(Constants.firstOutput, false,
          first: true)
    ]);
    notifyListeners();
  }

  void scrollToBottom() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }
  void setDisableWhenSubmit() {
    focusNode.unfocus();
    controller.clear();
    scrollToBottom();
    replying = true;
    notifyListeners();
  }
  void reEnableAfterReceive(String cookie, String sid) {
    if (messageModels.messages.last.sentenceCompleted.isNotEmpty && !messageModels.messages.last.sentenceCompleted.last) {
      messageModels.messages.last.playlist.add(LockCachingAudioSource(
          Uri.parse(HttpGet.getApi(API.chatRequestVoice.api) +
              messageModels.messages.last.sentences.last),
          headers: HttpGet.jsonHeadersCookie(cookie)));
    }
    Log.i("Message completed, re-enabling", tag:"Chat Page ViewModel");

    Log.d(messageModels.messages.last.sentences, tag:"Chat Page ViewModel");
    Log.d(messageModels.messages.last.sentenceCompleted, tag:"Chat Page ViewModel");
    messageModels.messages.last.generateCompleted.value = true;
    replying = false;
    SessionListDatabaseUtil.storeHistoryBySid(sid, jsonEncode(messageModels.export().toJson()));
    notifyListeners();
  }
  void manuallyBreak() {
    Log.i(tag: tag, "[DEBUG] Manually Break");
    try {
      ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
      messageModels.messages.last.player.stop();
    } on Exception catch (e) {
      Log.e(tag: tag, e);
    } finally {
      messageModels.messages.last.generateCompleted.value = true;
    replying = false;
    notifyListeners();
    }
  }
  Future<void> appendMessage(String msg, String cookie) async {
    scrollToBottom();
    var sentences = msg.split('。'); // 按逗号分隔
    bool endsWithDot = msg.endsWith('。'); // 最后一个是否是完整句子
    refresh(){
      notifyListeners();
    }
    Future<void> submitAudio(String sentence, int id) async {
      if (sentence.isEmpty) return;
      // Log.d(HttpGet.getApi(API.chatRequestVoice.api) +
      //     sentence, tag: "Chat Audio API SubmitAudio");
      await messageModels.messages.last.playlist.add(LockCachingAudioSource(
          Uri.parse(HttpGet.getApi(API.chatRequestVoice.api) +
              sentence),
          headers: HttpGet.jsonHeadersCookie(cookie)));
      if (autoPlay) messageModels.messages.last.player.play();
    }
    messageModels.messages.last.animatedAdd(msg, refresh); // TODO: NEED TEST
    // Log.d(sentences, tag:"Chat Page ViewModel appendMessage");
    for (int index = 0; index < sentences.length - 1; ++index) {
      await messageModels.messages.last.append(sentences[index], true, (){}, submitAudio);
    }
    if (sentences.last.isEmpty) return;
    await messageModels.messages.last.append(sentences.last, endsWithDot, (){}, submitAudio);
  }
  void submitNewMessage(String cookie) async {
    final text = controller.text, session = DatabaseUtil.getLastAIChatSession();
    if (text.isEmpty) return;
    if (session.isEmpty) {
      showToast("请先在左上角选择会话", toastType: ToastType.warning);
      return;
    }

    getRecommendLawyer(cookie, text);

    setDisableWhenSubmit();
    notifyListeners();

    messageModels.messages
        .add(AIChatMessageModelWithAudio.fromFull(text, true));
    notifyListeners();

    messageModels.messages.add(AIChatMessageModelWithAudio());
    try {
      autoPlay = DatabaseUtil.getAutoAudioPlay;
      Log.d("autoPlay = $autoPlay", tag: "Chat Page ViewModel");
      messageModels.messages.last.player.setAudioSource(messageModels.messages.last.playlist);
      // await appendMessage("response for 测试第一个句子。 $text", cookie);
      await ChatNetworkRequest.submitNewMessage(session, text, cookie, appendMessage, (){
        reEnableAfterReceive(cookie, session);
        notifyListeners();
      });
    } catch (e) {
      Log.e(tag: tag, e);
      if (e.toString().contains('session')) {
        showToast("生成失败，请尝试刷新会话列表", toastType: ToastType.error);
      }
      showToast("生成失败", toastType: ToastType.error);
      manuallyBreak();
    }
  }
}
