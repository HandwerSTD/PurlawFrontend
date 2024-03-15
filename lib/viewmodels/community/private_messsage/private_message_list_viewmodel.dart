import 'dart:convert';

import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

import '../../../common/constants/constants.dart';
import '../../../common/network/network_request.dart';
import '../../../common/utils/log_utils.dart';
import '../../../components/third_party/prompt.dart';

class PrivateMessageListViewModel extends BaseViewModel {
  List<(UserInfoModel, int)> userList = [];
  List<(UserInfoModel, int)> unreadUserList = [];

  load(String cookie) async {
    try {
      var response = jsonDecode(
          await HttpGet.post(API.pmGetAllUsers.api, HttpGet.jsonHeadersCookie(cookie), {}));
      if (response["status"] != "success") {
        throw Exception(response["message"] ?? "未知错误");
      }
      List<dynamic> result = response["result"];
      userList = List.generate(result.length, (index) {
        return (UserInfoModel(
            avatar: result[index]["avatar"],
            uid: result[index]["uid"],
            user: result[index]["user"], desc: '', verified: (result[index]["user_info"]) == 1), 0);
      });

      response = jsonDecode(
          await HttpGet.post(API.pmGetUnreadCount.api, HttpGet.jsonHeadersCookie(cookie), {}));
      if (response["status"] != "success") {
        throw Exception(response["message"] ?? "未知错误");
      }
      result = response["result"];
      for (var res in result) {
        String sender = res["sender"]; int count = res["count"];
        for (int i = 0; i < userList.length; ++i) {
          if (userList[i].$1.user == sender) {
            unreadUserList.add((userList[i].$1, count));
            userList[i] = (userList[i].$1, -1);
            break;
          }
        }
      }
      userList.removeWhere((element) {
        return element.$2 == -1;
      });
      userList = unreadUserList + userList;
      unreadUserList.clear();

      if (userList.isEmpty) {
        changeState(NetworkLoadingState.EMPTY);
      } else {
        changeState(NetworkLoadingState.CONTENT);
      }
    } catch (e) {
      Log.e(tag: "PrivateMessageList ViewModel", e);
      if (e.toString().contains("cookie")) {
        showToast("请尝试刷新用户信息", toastType: ToastType.error);
      } else {
        showToast("网络错误", toastType: ToastType.error);
      }
      changeState(NetworkLoadingState.ERROR);
    }
  }

  void clearUnread(int index) {
    userList[index] = (userList[index].$1, 0);
    notifyListeners();
  }
}
