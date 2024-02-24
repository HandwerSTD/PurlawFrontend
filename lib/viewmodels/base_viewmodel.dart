import 'package:flutter/material.dart';
import '../common/network/network_loading_state.dart';

// const tag = "Base ViewModel";

/// 状态管理层级的基础封装
class BaseViewModel extends ChangeNotifier {
  NetworkLoadingState state = NetworkLoadingState.LOADING;
  // BuildContext? context;
  //
  // BaseViewModel({this.context});
  //
  // void makeToast(String text) {
  //   if (context == null) {
  //     throw Exception("context not implemented while showing toast");
  //   }
  //   if (!context!.mounted) {
  //     Log.i(tag: "BaseViewModel","context is not mounted while showing toast");
  //     return;
  //   }
  //   TDToast.showText(text, context: context!);
  // }

  void changeState(NetworkLoadingState loadingState) {
    state = loadingState;
    if (hasListeners) {
      notifyListeners();
    }
  }
}