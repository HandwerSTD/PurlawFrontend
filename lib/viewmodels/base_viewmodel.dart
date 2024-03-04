import 'package:flutter/material.dart';
import '../common/network/network_loading_state.dart';

/// 状态管理层级的基础封装
class BaseViewModel extends ChangeNotifier {
  NetworkLoadingState state = NetworkLoadingState.LOADING;

  void changeState(NetworkLoadingState loadingState) {
    state = loadingState;
    if (hasListeners) {
      notifyListeners();
    }
  }
}