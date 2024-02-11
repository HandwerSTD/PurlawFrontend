/// AI 对话界面的 ViewModel

import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:purlaw/common/network/chat_api.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/constants/constants.dart';
import '../../common/network/network_request.dart';
import '../../components/purlaw/chat_message_block.dart';
import '../../components/third_party/modified_just_audio.dart';
import '../../models/ai_chat/chat_message_model.dart';
import '../main_viewmodel.dart';
import 'package:path/path.dart' as p;

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

  bool replying = false;
  bool autoPlay = false;

  AIChatMsgListViewModel({required super.context});

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
      ListAIChatMessageModels.fromJson(jsonDecode(data))
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
    makeToast("保存成功");
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
      ChatNetworkRequest.isolate.kill(priority: Isolate.immediate);
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
      Log.d(HttpGet.getApi(API.chatRequestVoice.api) +
          sentence, tag: "Chat Audio API SubmitAudio");
      await messageModels.messages.last.playlist.add(LockCachingAudioSource(
          Uri.parse(HttpGet.getApi(API.chatRequestVoice.api) +
              sentence),
          headers: HttpGet.jsonHeadersCookie(cookie)));
      if (autoPlay) messageModels.messages.last.player.play();
    }
    Log.d(sentences, tag:"Chat Page ViewModel appendMessage");
    for (int index = 0; index < sentences.length - 1; ++index) {
      await messageModels.messages.last.append(sentences[index], true, refresh, submitAudio);
    }
    if (sentences.last.isEmpty) return;
    await messageModels.messages.last.append(sentences.last, endsWithDot, refresh, submitAudio);
  }

  void submitNewMessage(String cookie) async {
    final text = controller.text, session = DatabaseUtil.getLastAIChatSession();
    if (text.isEmpty) return;
    if (session.isEmpty) {
      makeToast("请先选择会话");
      return;
    }

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
    } on Exception catch (e) {
      Log.e(tag: tag, e);
      makeToast("生成失败");
      manuallyBreak();
    }
  }
}
