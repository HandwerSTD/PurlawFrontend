
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';
/// 程序运行的全局配置存储区
class MainViewModel extends BaseViewModel {
  /// 登录者的用户信息模型，应当在重新刷新 Cookies 后再使用
  MyUserInfoModel myUserInfoModel = MyUserInfoModel(avatar: '', uid: '', user: ' ', cookie: '');

  bool autoAudioPlay = false;

  void logout() async {
    DatabaseUtil.storeUserNamePasswd('', '');
    DatabaseUtil.storeCookie('');
    myUserInfoModel = MyUserInfoModel(avatar: '', uid: '', user: ' ', cookie: '');
    cookies = '';
    await HistoryDatabaseUtil.clearHistory();
    SystemNavigator.pop();
  }

  void refreshCookies({bool toast = false}) async {
    (String, String) login = DatabaseUtil.getUserNamePasswd();
    try {
      cookies = await NetworkRequest.refreshCookies(login.$1, login.$2);
      Log.i("[MainViewModel] cookies refreshed");
      myUserInfoModel =
          await NetworkRequest.getUserInfoWhenLogin(login.$1, cookies);
      if (toast) {
        eventBus.fire(MainViewModelEventBus(toast: "刷新成功"));
      }
    } catch(e) {
      Log.e(e);
      eventBus.fire(MainViewModelEventBus(toast: "网络错误"));
    }
    notifyListeners();
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