import 'dart:convert';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

import '../../common/constants/constants.dart';

class ShortVideoListViewModel extends BaseViewModel {
  VideoList videoList = VideoList();

  ShortVideoListViewModel({super.context});

  Future<void> fetchVideoList(String cookie) async {
    try {
      var response = jsonDecode(await HttpGet.post(API.videoRecommended.api, HttpGet.jsonHeadersCookie(cookie), {
        "page_size": Constants.videosPerPage
      }));
      if (response["status"] != "success") throw Exception(response["message"]??"未知错误");
      videoList = VideoList.fromJson(response);
      notifyListeners();
      changeState(NetworkLoadingState.CONTENT);
    } catch(e) {
      print(e);
      makeToast("网络错误");
      changeState(NetworkLoadingState.ERROR);
    }
  }
  Future<void> loadMoreVideo(String cookie) async {
    try {
      var response = jsonDecode(await HttpGet.post(API.videoRecommended.api, HttpGet.jsonHeadersCookie(cookie), {
        "page_size": Constants.videosPerPage
      }));
      if (response["status"] != "success") throw Exception(response["message"]??"未知错误");
      var list = VideoList.fromJson(response);
      videoList.result?.addAll(list.result!.map((e) => e));
      notifyListeners();
    } catch(e) {
      print(e);
      makeToast("网络错误");
    }
  }
}