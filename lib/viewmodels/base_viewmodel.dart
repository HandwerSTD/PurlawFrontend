import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../common/network/network_loading_state.dart';

/// 状态管理层级的基础封装
class BaseViewModel extends ChangeNotifier {
  NetworkLoadingState state = NetworkLoadingState.LOADING;
  BuildContext? context;

  BaseViewModel({this.context});

  // 发个 Toast 通知容易吗我。。直接把 ViewModel 破坏了，不得已而为之了
  void makeToast(String text) {
    if (context == null) {
      throw Exception("[BaseViewModel] context not implemented while showing toast");
    }
    if (!context!.mounted) {
      Log.i("[BaseViewModel] context is not mounted while showing toast");
      return;
    }
    TDToast.showText(text, context: context!);
  }

  void changeState(NetworkLoadingState loadingState) {
    state = loadingState;
    if (hasListeners) {
      notifyListeners();
    }
  }
}