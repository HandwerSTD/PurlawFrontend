import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/models/ai_chat/chat_message_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

import '../../../common/constants/constants.dart';
import '../../../common/network/network_request.dart';
import '../../../common/utils/log_utils.dart';
import '../../../components/third_party/prompt.dart';

class PrivateMessageViewModel extends BaseViewModel {
  final UserInfoModel sendUser;
  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  PrivateMessageViewModel({required this.sendUser});

  ScrollController scrollController = ScrollController();

  List<PrivateChatMessageModel> messages = [];
  int page = 1;

  load(String cookie) async {
    try {
      var response = jsonDecode(await HttpGet.post(API.pmGetChatContext.api, HttpGet.jsonHeadersCookie(cookie), {
        'target_user': sendUser.user,
        'page_size': Constants.messagesPerPage,
        'page': page
      }));
      if (response["status"] != "success") throw HttpException(response["message"]);
      List<dynamic> result = response["result"];
      messages = List.generate(result.length, (ind) {
        int index = result.length - ind - 1;
        return PrivateChatMessageModel(message: result[index]["content"], timestamp: (result[index]["timestamp"] as double).toInt(), isMine: (result[index]["receiver"] == sendUser.user) );
      });
      notifyListeners();
    } catch(e) {
      Log.e(tag: "PrivateMessage ViewModel", e);
      showToast("网络错误", toastType: ToastType.error);
      changeState(NetworkLoadingState.ERROR);
    }
    try {
      HttpGet.post(API.pmSetRead.api, HttpGet.jsonHeadersCookie(cookie), {
        'target_user': sendUser.user
      });
    } catch(e) {
      Log.e(tag: "PrivateMessage ViewModel", e);
      showToast("网络错误", toastType: ToastType.warning);
    }
  }

  void sendMessage(String cookie) async {
    final msg = controller.text;
    if (msg.isEmpty) return;
    messages.add(PrivateChatMessageModel(message: msg, timestamp: TimeUtils.timestamp, isMine: true));
    controller.clear();
    notifyListeners();
    try {
      var response = jsonDecode(await HttpGet.post(API.pmSendMessage.api, HttpGet.jsonHeadersCookie(cookie), {
        'receiver': sendUser.user,
        'content': msg
      }));
      if (response["status"] != "success") throw HttpException(response["message"]);
      Log.d("发送成功", tag: "PrivateMessage ViewModel");
    } catch(e) {
      Log.e(tag: "PrivateMessage ViewModel", e);
      showToast("发送失败", toastType: ToastType.error);
    }
  }
}
