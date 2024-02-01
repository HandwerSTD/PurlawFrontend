import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

/// 程序运行的全局配置存储区
class MainViewModel extends BaseViewModel {
  /// 登录者的用户信息模型，应当在重新刷新 Cookies 后再使用
  MyUserInfoModel myUserInfoModel = MyUserInfoModel(avatar: '', uid: '', user: '加载失败', cookie: '');

  void logout() {
    DatabaseUtil.storeUserNamePasswd('', '');
    DatabaseUtil.storeCookie('');
    myUserInfoModel = MyUserInfoModel(avatar: '', uid: '', user: '加载失败', cookie: '');
    cookies = '';
    SystemNavigator.pop();
  }

  void refreshCookies() async {
    (String, String) login = DatabaseUtil.getUserNamePasswd();
    try {
      cookies = await NetworkRequest.refreshCookies(login.$1, login.$2);
      print("[MainViewModel] cookies refreshed");
      myUserInfoModel =
          await NetworkRequest.getUserInfoWhenLogin(login.$1, cookies);
    } catch(e) {
      print(e);
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