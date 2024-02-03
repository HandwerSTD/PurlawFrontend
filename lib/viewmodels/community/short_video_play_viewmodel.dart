import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/views/community/short_video/short_video_play_page.dart';
import 'package:video_player/video_player.dart';

import '../../common/constants/constants.dart';
import '../../common/network/network_request.dart';
import 'package:flutter/material.dart';

class ShortVideoPlayViewModel extends BaseViewModel {
  late VideoList videoList;
  PageController controller = PageController(initialPage: 1);

  ShortVideoPlayViewModel({required super.context});

  static ShortVideoPlayViewModel fromSingleVideo(VideoInfoModel paramVideo, BuildContext context) {
    ShortVideoPlayViewModel viewModel = ShortVideoPlayViewModel(context: context);
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
      // pageList.addAll(list.result!.map((e) => VideoPlayBlock(nowPlaying: e)));
      notifyListeners();
      print("[DEBUG] New Page Load completed");
    } catch(e) {
      print(e);
      makeToast("网络错误");
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

  // Future<void> loadMoreVideo(String cookie) async {
  //   try {
  //     var response = jsonDecode(await HttpGet.post(API.videoRecommended.api, HttpGet.jsonHeadersCookie(cookie), {
  //       "page_size": Constants.videosPerPage
  //     }));
  //     if (response["status"] != "success") throw Exception(response["message"]??"未知错误");
  //     var list = VideoList.fromJson(response);
  //     videoList.result?.addAll(list.result!.map((e) => e));
  //     pageList.addAll(list.result!.map((e) => VideoPlayBlock(nowPlaying: e)));
  //     notifyListeners();
  //     print("[DEBUG] New Page Load completed");
  //   } catch(e) {
  //     print(e);
  //     makeToast("网络错误");
  //   }
  // }
}

class ShortVideoPlayBlockViewModel extends BaseViewModel {
  late VideoPlayerController videoPlayerController;
  late ChewieController videoController;
  final VideoInfoModel nowPlaying;
  String cookie = "";
  bool loaded = false;
  bool autoPlay = true;

  ShortVideoPlayBlockViewModel({required this.nowPlaying, required super.context});

  Future<void> getVideoIsLiked() async {
    try {
      var response = jsonDecode(await HttpGet.post(API.videoIsLiked.api, HttpGet.jsonHeadersCookie(cookie), {
        "vid": nowPlaying.uid
      }));
      if (response["status"] != "success") throw Exception(response["message"]);
      assert(response["message"] == 0 || response["message"] == 1);
      nowPlaying.meLiked = response["message"];
    } on Exception catch (e) {
      print(e);
      makeToast("网络错误");
    }
  }

  load() {
    nowPlaying.meLiked = -1;
    if (cookie != "") {
      getVideoIsLiked();
    }
    // print(HttpGet.getApi(API.videoFile.api) + nowPlaying.sha1!);
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
      print(e);
      makeToast("${(origin == 0 ? "" : "取消")}点赞失败");
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