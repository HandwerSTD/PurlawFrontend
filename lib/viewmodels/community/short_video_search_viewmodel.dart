import 'dart:convert';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/constants/constants.dart';

class ShortVideoSearchViewModel extends BaseViewModel {
  VideoList videoList = VideoList();
  String text = "";
  int pageNum = 1;
  int totalCount = 0;

  ShortVideoSearchViewModel({super.context}) {
    super.state = NetworkLoadingState.READY_WAITING;
  }

  Future<void> searchVideo(String cookie, String val) async {
    text = val;
    pageNum = 1;

    if (text.isEmpty) return;
    try {
      changeState(NetworkLoadingState.LOADING);
      var response = jsonDecode(await HttpGet.post(API.videoSearch.api, HttpGet.jsonHeadersCookie(cookie), {
        "title": text,
        "page": 1,
        "page_size": Constants.videosPerPage * 2 // 20 is better
      }));
      if (response["status"] != "success") throw Exception(response["message"]??"未知错误");
      videoList = VideoList.fromJson(response);
      totalCount = response["count_items"];
      Log.i("[DEBUG] totalCount = $totalCount");
      changeState(NetworkLoadingState.CONTENT);
    } catch(e) {
      Log.e(e);
      makeToast("网络错误");
      changeState(NetworkLoadingState.ERROR);
    }
  }
  Future<void> loadMoreVideo(String cookie) async {
    if (videoList.result!.length >= totalCount) return;
    try {
      var response = jsonDecode(await HttpGet.post(API.videoSearch.api, HttpGet.jsonHeadersCookie(cookie), {
        "title": text,
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
      Log.e(e);
      makeToast("网络错误");
    }
  }
}