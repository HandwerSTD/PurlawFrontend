import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/constants/constants.dart';

const tag = "Account Register ViewModel";

class AccountRegisterViewModel extends BaseViewModel {
  TextEditingController nameCtrl = TextEditingController(), passwdCtrl = TextEditingController(), mailCtrl = TextEditingController();
  bool agreeStatement = false;
  bool registering = false;

  AccountRegisterViewModel({required super.context});

  void switchAgree() {
    agreeStatement = !agreeStatement;
    notifyListeners();
  }

  (bool, String) verifyRegister() {
    if (nameCtrl.text.isEmpty || mailCtrl.text.isEmpty || passwdCtrl.text.isEmpty) return (false, "填写信息不完整");
    if (!agreeStatement) return (false, "请同意《用户协议》与《隐私协议》");
    var atPos = mailCtrl.text.indexOf("@");
    if (atPos == 0 || atPos == -1 || atPos == mailCtrl.text.length - 1) return (false, "邮箱格式不正确");
    if (passwdCtrl.text.length < 6) return (false, "密码不得少于 6 位");
    return (true, "注册中");
  }
  Future<String> registerNewAccount() async {
    (bool, String) verify = verifyRegister();
    if (!verify.$1) return verify.$2;
    try {
      var response = jsonDecode(await HttpGet.post(API.userRegister.api, HttpGet.jsonHeaders, {
        "user": nameCtrl.text,
        "password": sha1.convert(utf8.encode(passwdCtrl.text)).toString()
      }));
      Log.i(tag: tag,response);

      if (!response["status"].startsWith("success")) {
        Log.i(tag: tag,"login failed");
        return response["message"];
      }

    } catch(e) {
      Log.e(tag: tag, e);
      return "注册失败";
    }
    return "注册成功";
  }

  void register() async {
    registering = true; notifyListeners();
    var result = await registerNewAccount();
    registering = false; notifyListeners();
    Log.i(tag: tag,result);
    makeToast(result);
  }
}