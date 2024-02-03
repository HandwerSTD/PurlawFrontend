import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';

const tag = "Account Login ViewModel";

class AccountLoginViewModel extends BaseViewModel {
  TextEditingController nameCtrl = TextEditingController(), passwdCtrl = TextEditingController();
  FocusNode nameFocus = FocusNode(), passwdFocus = FocusNode();
  bool loggingIn = false;

  AccountLoginViewModel({required super.context});

  bool verifyLogin() {
    return nameCtrl.text.isNotEmpty && passwdCtrl.text.isNotEmpty;
  }
  void login() async {
    nameFocus.unfocus(); passwdFocus.unfocus();
    loggingIn = true;
    notifyListeners();
    var result = await loginUser();
    Log.i(tag: tag,result);
    if (result != "success") {
      makeToast(result);
    } else {
      return;
    }
    loggingIn = false;
    notifyListeners();
  }
  Future<String> loginUser() async {
    if (!verifyLogin()) {
      return "用户名或密码不完整";
    }
    try {
      var passwd = sha1.convert(utf8.encode(passwdCtrl.text)).toString();
      (String, String?) httpResult = await HttpGet.postGetCookie(API.userLogin.api, HttpGet.jsonHeaders, {
        "user": nameCtrl.text,
        "password": passwd
      });
      var response =
          jsonDecode(httpResult.$1);
      Log.i(tag: tag,response);

      if (!response["status"].startsWith("success")) {
        Log.i(tag: tag,"login failed");
        return response["message"];
      }

      // 获取 cookie，存入数据库
      int index = (httpResult.$2)!.indexOf(';');
      var setCookie = (index == -1 ? (httpResult.$2)! : (httpResult.$2)!.substring(0, index));
      DatabaseUtil.storeCookie(setCookie);
      DatabaseUtil.storeUserNamePasswd(nameCtrl.text, passwd);

      // 获取用户信息
      var userModel = await NetworkRequest.getUserInfoWhenLogin(nameCtrl.text, setCookie);
      Provider.of<MainViewModel>(super.context!, listen: false)
        ..myUserInfoModel = userModel
        ..cookies = setCookie
        ..notifyListeners(); // 应该不会出事吧。。。

    } catch(e) {
      Log.e(tag: tag, e);
      return "登录失败，请检查网络";
    }
    eventBus.fire(AccountLoginEventBus(needNavigate: true));
    return "success";
  }
}

class AccountLoginEventBus {
  bool needNavigate;
  AccountLoginEventBus({required this.needNavigate});
}