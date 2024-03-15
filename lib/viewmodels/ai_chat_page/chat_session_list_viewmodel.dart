import 'dart:convert';

import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

import '../../common/constants/constants.dart';
import '../../common/network/network_request.dart';
import '../../common/utils/log_utils.dart';

class ChatSessionListViewModel extends BaseViewModel {
  List<(String, String)> sessionList = [];
  int chosenRadio = -1;
  bool editing = false;

  bool networkLock = false;

  ChatSessionListViewModel();


  load() async {
    sessionList = await SessionListDatabaseUtil.getList();
    var sid = DatabaseUtil.getLastAIChatSession();
    for (int i = 0; i < sessionList.length; ++i) {
      if (sessionList[i].$1 == sid) {
        chosenRadio = i; break;
      }
    }
    if (sessionList.isEmpty) {
      changeState(NetworkLoadingState.EMPTY);
    } else {
      changeState(NetworkLoadingState.CONTENT);
    }
  }
  Future<void> fetchSessionsFromNetwork(String cookie) async {
    // networkLock = true;
    changeState(NetworkLoadingState.LOADING);
    sessionList.clear();

    try {
      var response = jsonDecode(await HttpGet.get(
          API.chatListSession.api,
          HttpGet.jsonHeadersCookie(cookie),).timeout(const Duration(seconds: 10)));
      if (response["status"] != "success") throw Exception(response["message"]);
      var list = <(String, String)>[];
      for (var sid in (response["sid"])) {
        list.add((sid, "获取的会话信息"));
      }
      SessionListDatabaseUtil.storeSessionList(list);
      sessionList = list;
      notifyListeners();
      if (sessionList.isEmpty) {
        changeState(NetworkLoadingState.EMPTY);
      } else {
        changeState(NetworkLoadingState.CONTENT);
      }
    } catch(e) {
      Log.e(e, tag: "Chat Session ViewModel");
      showToast("获取失败", toastType: ToastType.error);
      changeState(NetworkLoadingState.ERROR);
    } finally {
      networkLock = false;
    }
  }

  void switchDeleting() {
    if (networkLock) return;
    editing = !editing;
    notifyListeners();
  }
  Future<void> deleteEntry(int index, String cookie) async {
    if (sessionList.length == 1) {
      showToast("请保留至少一个会话", toastType: ToastType.warning);
      return;
    }
    if (sessionList[index].$1 == DatabaseUtil.getLastAIChatSession()) {
      showToast("请先切换到其他会话", toastType: ToastType.warning);
      return;
    }
    final sid = sessionList[index].$1;
    try {
      showToast("删除中", toastType: ToastType.info);
      var response = jsonDecode(await HttpGet.post(API.chatDestroySession.api, HttpGet.jsonHeadersCookie(cookie), {
        "sid": sessionList[index].$1
      }));
      if (response["status"] != "success") {
        if (!response["message"].toString().contains("sid")) {
          throw Exception(response["message"]);
        }
      }
      sessionList.removeAt(index);
      notifyListeners();
      SessionListDatabaseUtil.delete(sid);
      showToast("删除成功", toastType: ToastType.success);
    } catch(e) {
      Log.e(e, tag: "Chat Session ViewModel");
      showToast("删除失败", toastType: ToastType.error);
    }
  }

  void createNewSession(String cookie) async {
    if (sessionList.length >= 10) return;
    try {
      showLoading("新建中");
      var response = jsonDecode(await HttpGet.post(
          API.chatCreateSession.api,
          HttpGet.jsonHeadersCookie(cookie),
          ({"type": "chat"})).timeout(const Duration(seconds: 10)));
      Log.i(response);
      if (response["status"] != "success") throw Exception(response["message"]);
      String session = response["sid"];

      var name = TimeUtils.formatDateTime(TimeUtils.timestamp);
      SessionListDatabaseUtil.add(name, session);
      sessionList.add((session, name));
      changeState(NetworkLoadingState.CONTENT);
      hideLoading();
      showToast("新建成功", toastType: ToastType.success);
    } on Exception catch (e) {
      Log.e(e, tag: "Chat Session ViewModel");
      hideLoading();
      showToast("创建新会话失败，可尝试刷新", toastType: ToastType.error);
    }
  }
  void useSession(int index) {
    if (networkLock) return;
    chosenRadio = index;
    DatabaseUtil.storeLastAIChatSession(sessionList[index].$1);
    showToast("设置成功", toastType: ToastType.success);
    eventBus.fire(ChatSessionListEventBus(needNavigate: true));
  }

  void changeSessionName(int index, String newName) {
    sessionList[index] = (sessionList[index].$1, newName);
    SessionListDatabaseUtil.add(newName, sessionList[index].$1);
    notifyListeners();
  }
}

class ChatSessionListEventBus {
  bool needNavigate;

  ChatSessionListEventBus({required this.needNavigate});
}