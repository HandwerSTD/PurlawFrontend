import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/views/community/short_video/short_video_play_page.dart';
import 'package:video_player/video_player.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/constants/constants.dart';
import '../../common/network/network_request.dart';
import 'package:flutter/material.dart';

import '../../components/third_party/prompt.dart';

const tag = "ShortVideo Play ViewModel";

class ShortVideoPlayViewModel extends BaseViewModel {
  late VideoList videoList;
  PageController controller = PageController(initialPage: 1);

  ShortVideoPlayViewModel();

  static ShortVideoPlayViewModel fromSingleVideo(VideoInfoModel paramVideo, BuildContext context) {
    ShortVideoPlayViewModel viewModel = ShortVideoPlayViewModel();
    viewModel.videoList = VideoList(result: [paramVideo]);
    // viewModel.pageList = [ShortVideoRefreshPage(), VideoPlayBlock(nowPlaying: paramVideo)];

    return viewModel;
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
      Log.i(tag: tag,"[New Page Load completed");
    } catch(e) {
      Log.e(tag: tag,e);
      showToast("网络错误", toastType: ToastType.warning);
    }
  }
}


class ShortVideoPlayByListViewModel extends BaseViewModel {
  final VideoList videoList;
  final int pageIndex;
  late PageController controller;
  late List<Widget> pageList;
  final Function loadMoreVideo;

  ShortVideoPlayByListViewModel({required this.videoList, required this.pageIndex, required this.loadMoreVideo}) {
    pageList = List<Widget>.generate(videoList.result!.length, (index) {
      return VideoPlayBlock(nowPlaying: videoList.result![index]);
    });
    controller = PageController(initialPage: pageIndex);
  }
}

class ShortVideoPlayBlockViewModel extends BaseViewModel {
  late VideoPlayerController videoPlayerController;
  late ChewieController videoController;
  final VideoInfoModel nowPlaying;
  String cookie = "";
  bool loaded = false;
  bool loadError = false;
  bool autoPlay = true;

  ShortVideoPlayBlockViewModel({required this.nowPlaying});

  Future<void> getVideoIsLiked() async {
    try {
      var response = jsonDecode(await HttpGet.post(API.videoIsLiked.api, HttpGet.jsonHeadersCookie(cookie), {
        "vid": nowPlaying.uid
      }));
      if (response["status"] != "success") throw Exception(response["message"]);
      assert(response["message"] == 0 || response["message"] == 1);
      nowPlaying.meLiked = response["message"];
    } on Exception catch (e) {
      Log.e(tag: tag,e);
      showToast("网络错误", toastType: ToastType.warning);
    }
  }

  load() {
    nowPlaying.meLiked = -1;
    if (cookie != "") {
      getVideoIsLiked();
    }
    // Log.i(tag: tag,tag: tagHttpGet.getApi(API.videoFile.api) + nowPlaying.sha1!);
    try {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(HttpGet.getApi(API.videoFile.api) + nowPlaying.sha1!));
      videoPlayerController.initialize().then((_) {
          videoController = ChewieController(
              videoPlayerController: videoPlayerController,
              showControls: false,
              showOptions: false,
              autoPlay: autoPlay,
              looping: true,
              aspectRatio: videoPlayerController.value.aspectRatio);
          loaded = true;
          notifyListeners();
          if (autoPlay) resumeVideo();
        });
    } on Exception catch (e) {
      Log.e(e, tag: "Short Video Play ViewModel");
      showToast("播放异常", toastType: ToastType.error);
      loadError = true; notifyListeners();
    }
  }

  void pauseVideo() {
    videoPlayerController.pause();
    notifyListeners();
    // 有性能问题要处理这里
  }
  void resumeVideo() {
    videoPlayerController.play();
    notifyListeners();
  }

  Future<void> switchVideoLike() async {
    if (!loaded) {
      return;
    }
    if (nowPlaying.meLiked == -1) {
      pauseVideo();
      eventBus.fire(ShortVideoPlayBlockEventBus(needNavigate: true));
      return;
    }
    var origin = nowPlaying.meLiked.toInt();
    nowPlaying.meLiked = (nowPlaying.meLiked == 0 ? 1 : 0);
    notifyListeners();
    try {
      var response = jsonDecode(await HttpGet.post(API.videoLikeIt.api, HttpGet.jsonHeadersCookie(cookie), {
        "vid": nowPlaying.uid
      }));
      if (response["status"] != "success") throw Exception(response["message"]);
    } catch(e) {
      Log.e(tag: tag,e);
      showToast("${(origin == 0 ? "" : "取消")}点赞失败", toastType: ToastType.error);
      nowPlaying.meLiked = origin;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    if (loaded) videoController.dispose();
  }
}

class ShortVideoPlayBlockEventBus {
  bool needNavigate;
  ShortVideoPlayBlockEventBus({required this.needNavigate});
}