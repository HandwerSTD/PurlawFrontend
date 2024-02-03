import 'dart:convert';

import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/constants/constants.dart';
import '../../common/network/network_loading_state.dart';
import '../../common/network/network_request.dart';

const tag = "Account VideoList ViewModel";

class AccountVideoListViewModel extends BaseViewModel {
  final String userId;
  VideoList videoList = VideoList(result: []);

  AccountVideoListViewModel({required this.userId, required super.context});

  int pageNum = 1;
  int totalCount = 0;

  Future<void> load() async {
    pageNum = 1;

    try {
      var response = jsonDecode(await HttpGet.post(API.userListVideo.api, HttpGet.jsonHeaders, {
        "uid": userId,
        "page": 1,
        "page_size": Constants.videosPerPage * 2 // 20 is better
      }));
      if (response["status"] != "success") throw Exception(response["message"]??"未知错误");
      totalCount = response["count_items"];
      Log.i(tag: tag,"totalCount = $totalCount");
      videoList = VideoList.fromJson(response);
      changeState(NetworkLoadingState.CONTENT);
    } catch(e) {
      Log.e(tag: tag, e);
      makeToast("网络错误");
      changeState(NetworkLoadingState.ERROR);
    }
  }
  Future<void> loadMoreVideo(String cookie) async {
    if (videoList.result!.length >= totalCount) return;
    try {
      var response = jsonDecode(await HttpGet.post(API.userListVideo.api, HttpGet.jsonHeadersCookie(cookie), {
        "uid": userId,
        "page": pageNum,
        "page_size": Constants.videosPerPage
      }));
      if (response["status"] != "success") throw Exception(response["message"]??"未知错误");
      var list = VideoList.fromJson(response);
      videoList.result?.addAll(list.result!.map((e) => e));
      if (hasListeners) {
        notifyListeners();
      }
      ++pageNum;
    } catch(e) {
      Log.e(tag: tag, e);
      makeToast("网络错误");
    }
  }
}