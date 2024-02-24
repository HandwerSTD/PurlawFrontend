import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

import '../../common/network/chat_api.dart';
import '../../components/third_party/prompt.dart';

class ContractGenerationViewModel extends BaseViewModel {
  bool genComplete = false;
  bool genStart = false;
  TextEditingController controller = TextEditingController();

  var title = "";
  var desc = "";
  var aName = "";
  var bName = "";
  var type = "";

  var text = "";

  ContractGenerationViewModel();

  Future<void> appendMessage(String msg, String cookie) async {
    text += msg;
    notifyListeners();
  }

  Future<void> submit(String cookie) async {
    Log.i("title: $title, desc: $desc", tag: "ContractGeneration ViewModel");
    text = "";
    genStart = true; genComplete = false;
    notifyListeners();
    final session = DatabaseUtil.getLastAIChatSession();
    if (session.isEmpty) {
      showToast("请先指定一个会话", toastType: ToastType.warning);
      return;
    }
    try {
      await ChatNetworkRequest.submitNewMessage(session, "按以下信息生成一份合同：合同标题为《$title》，甲方为 $aName，乙方为 $bName，合同类型为 $type。合同描述：$text", cookie, appendMessage, (){
        genStart = false; genComplete = true;
        controller = TextEditingController(text: text);
        notifyListeners();
      });
    } on Exception catch (e) {
      Log.e(tag: "ContractGeneration ViewModel", e);
      showToast("生成失败", toastType: ToastType.warning);
      ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
    }
  }
}