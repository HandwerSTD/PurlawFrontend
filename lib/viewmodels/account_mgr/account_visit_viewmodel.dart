import 'dart:convert';

import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/network/network_request.dart';

const tag = "Account Visit ViewModel";

class AccountVisitViewModel extends BaseViewModel {
  late UserInfoModel userInfoModel;
  String userId;
  AccountVisitViewModel({required this.userId, required super.context});

  load() async {
    try {
      var response = jsonDecode(await HttpGet.post(API.userInfo.api, HttpGet.jsonHeaders, {
        "uid": userId
      }));
      if (response["status"] != "success") throw Exception(response["message"] ?? "未知错误");
      userInfoModel = UserInfoModel.fromJson(response["result"]);
      changeState(NetworkLoadingState.CONTENT);
    } catch(e) {
      Log.e(tag: tag, e);
      makeToast("加载失败");
      changeState(NetworkLoadingState.ERROR);
    }
  }
}