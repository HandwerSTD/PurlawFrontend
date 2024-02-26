
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';

import '../common/utils/database/kvstore.dart';

const tag = "Main ViewModel";

/// 程序运行的全局配置存储区
class MainViewModel extends BaseViewModel {
  /// 登录者的用户信息模型，应当在重新刷新 Cookies 后再使用
  MyUserInfoModel myUserInfoModel = MyUserInfoModel(avatar: '', uid: '', user: ' ', cookie: '', desc: '', verified: false);

  bool autoAudioPlay = false;
  bool aiChatFloatingButtonEnabled = false;

  void setChatFloatingButtonEnabled(bool value) {
    KVBox.insert(DatabaseConst.aiChatFloatingButtonEnabled, value ? DatabaseConst.dbTrue : DatabaseConst.dbFalse);
    aiChatFloatingButtonEnabled = value;
    notifyListeners();
  }


  void debugSetVerified() {
    myUserInfoModel.verified = !myUserInfoModel.verified;
    notifyListeners();
  }
  void changeDesc(String desc) {
    myUserInfoModel.desc = desc;
    notifyListeners();
  }

  void logout() async {
    DatabaseUtil.storeUserNamePasswd('', '');
    DatabaseUtil.storeCookie('');
    myUserInfoModel = MyUserInfoModel(avatar: '', uid: '', user: ' ', cookie: '', desc: '', verified: false);
    cookies = '';
    await HistoryDatabaseUtil.clearHistory();
    await SessionListDatabaseUtil.clear();
    SystemNavigator.pop();
  }

  Future<bool> refreshCookies({bool toast = false}) async {
    (String, String) login = DatabaseUtil.getUserNamePasswd();
    try {
      cookies = await NetworkRequest.refreshCookies(login.$1, login.$2);
      Log.i(tag: tag,"cookies refreshed");
      myUserInfoModel =
          await NetworkRequest.getUserInfoWhenLogin(login.$1, cookies);
      notifyListeners();
      if (toast) {
        eventBus.fire(MainViewModelEventBus(toast: "刷新成功"));
      }
      return true;
    } catch(e) {
      Log.e(tag: tag, e);
      eventBus.fire(MainViewModelEventBus(toast: "网络错误"));
      return false;
    }
  }

  /// 登陆者的 Cookies，建议始终使用该项，防止 Cookies 刷新未完成时出现错误
  String cookies = "";
}

class MainViewModelEventBus {
  String toast;
  MainViewModelEventBus({required this.toast});
}

String getCookie(context, {bool listen = true}) => Provider.of<MainViewModel>(context, listen: listen).cookies;
MainViewModel getMainViewModel(context, {bool listen = true}) => Provider.of<MainViewModel>(context, listen: listen);