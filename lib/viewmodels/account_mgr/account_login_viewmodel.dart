import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';

import '../../models/account_mgr/user_info_model.dart';

const tag = "Account Login ViewModel";

class AccountLoginViewModel extends BaseViewModel {
  TextEditingController nameCtrl = TextEditingController(), passwdCtrl = TextEditingController();
  FocusNode nameFocus = FocusNode(), passwdFocus = FocusNode();
  bool loggingIn = false;


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
      showToast(result, toastType: ToastType.warning);
    } else {
      showToast("登陆成功", toastType: ToastType.success);
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
      await fetchUserSessionList(setCookie);
      eventBus.fire(AccountLoginEventBus(needNavigate: false, model: userModel, setCookie: setCookie));

    } catch(e) {
      Log.e(tag: tag, e);
      return "登录失败，请检查网络";
    }
    eventBus.fire(AccountLoginEventBus(needNavigate: true));
    return "success";
  }

  Future<void> fetchUserSessionList(String cookie) async {
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
    } catch(e) {
      Log.e(e, tag: "Chat Session ViewModel");
      showToast("获取失败", toastType: ToastType.error);
    }
  }
}

class AccountLoginEventBus {
  bool needNavigate;
  MyUserInfoModel? model;
  String? setCookie;
  AccountLoginEventBus({required this.needNavigate, this.model, this.setCookie});
}