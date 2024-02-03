/// AI 对话界面的 ViewModel

import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:purlaw/common/network/chat_api.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

import '../../common/constants/constants.dart';
import '../../models/ai_chat/chat_message_model.dart';

/// 对话消息列表的 ViewModel
class AIChatMsgListViewModel extends BaseViewModel {
  ScrollController scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  ListAIChatMessageModels messageModels = ListAIChatMessageModels(messages: [AIChatMessageModel(message: Constants.firstOutput, isMine: false, isFirst: true)]);
  bool replying = false;

  AIChatMsgListViewModel({required super.context});

  void saveMessage() {
    HistoryDatabaseUtil.storeHistory(jsonEncode(messageModels.toJson()));
    messageModels = ListAIChatMessageModels(messages: [AIChatMessageModel(message: Constants.firstOutput, isMine: false, isFirst: true)]);
    notifyListeners();
    makeToast("保存成功");
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
  void reEnableAfterReceive() {
    messageModels.messages!.last.generateCompleted.value = true;
    replying = false;
    notifyListeners();
  }
  void manuallyBreak() {
    print("[DEBUG] Manually Break");
    try {
      ChatNetworkRequest.isolate.kill(priority: Isolate.immediate);
    } on Exception catch (e) {
      print(e);
    } finally {
      reEnableAfterReceive();
    }
  }

  Future<void> appendMessage(String msg) async {
    scrollToBottom();
    await messageModels.messages![messageModels.messages!.length - 1].append(msg, () {scrollToBottom(); notifyListeners();});
    notifyListeners();
  }

  void submitNewMessage(String cookie) async {
    final text = controller.text;
    if (text.isEmpty) return;

    setDisableWhenSubmit();
    notifyListeners();

    messageModels.messages?.add(AIChatMessageModel(message: text, isMine: true));
    notifyListeners();

    messageModels.messages?.add(AIChatMessageModel(message: "", isMine: false));
    await appendMessage("response for $text");
    try {
      // await ChatNetworkRequest.submitNewMessage(text, cookie, appendMessage);
      reEnableAfterReceive();
      notifyListeners();
    } on Exception catch (e) {
      print(e);
      makeToast("生成失败");
      manuallyBreak();
    }
  }
}

class _Bool {
  bool val;
  _Bool({required this.val});
}
