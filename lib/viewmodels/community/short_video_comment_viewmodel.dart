import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/constants/constants.dart';
import '../../common/network/network_loading_state.dart';
import '../../common/network/network_request.dart';
import '../../components/third_party/prompt.dart';
import '../../models/community/short_video_comment_model.dart';

const tag = "ShortVideo Comment ViewModel";

class ShortVideoCommentViewModel extends BaseViewModel {
  final String cid;
  int pageNum = 1;
  late VideoCommentList videoCommentList;
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();


  ShortVideoCommentViewModel({required this.cid});

  load() async {
    loadComments();
  }
  reload() {
    videoCommentList.result!.clear();
    notifyListeners();
    loadComments();
  }

  Future<void> loadComments() async {
    pageNum = 1;
    try {
      var response = jsonDecode(await HttpGet.post(API.commentList.api, HttpGet.jsonHeaders, {
        "cid": cid,
        "page": 1,
        "page_size": Constants.commentsPerPage
      }));
      if (response["status"] != "success") throw Exception(response["message"]??"未知错误");
      videoCommentList = VideoCommentList.fromJson(response);
      // Log.d(response);
      if (videoCommentList.total! == 0) {
        changeState(NetworkLoadingState.EMPTY);
      } else {
        changeState(NetworkLoadingState.CONTENT);
      }
    } catch(e) {
      Log.e(tag: tag, e);
      showToast("网络错误", toastType: ToastType.warning);
      changeState(NetworkLoadingState.ERROR);
    }
  }
  Future<void> loadMoreComments() async {
    if (videoCommentList.result!.length >= videoCommentList.total!) return;
    try {
      var response = jsonDecode(await HttpGet.post(API.videoSearch.api, HttpGet.jsonHeaders, {
        "cid": cid,
        "page": pageNum,
        "page_size": Constants.videosPerPage
      }));
      if (response["status"] != "success") throw Exception(response["message"]??"未知错误");
      var list = VideoCommentList.fromJson(response);
      videoCommentList.result?.addAll(list.result!.map((e) => e));
      if (hasListeners) {
        notifyListeners();
      }
      ++pageNum;
    } catch(e) {
      Log.e(tag: tag, e);
      showToast("网络错误", toastType: ToastType.warning);
    }
  }
  Future<void> submitComment(String cookie) async {
    var text = controller.text;
    if (text.isEmpty) return;
    try {
      showToast("评论中", toastType: ToastType.info);
      controller.clear();
      focusNode.unfocus();
      var response = jsonDecode(await HttpGet.post(API.commentSubmit.api, HttpGet.jsonHeadersCookie(cookie), {
        "cid": cid,
        "comment": text
      }));
      if (response["status"] != "success") throw Exception(response["message"]);
      showToast("评论成功", toastType: ToastType.success);
      reload();
    } catch (e) {
      Log.e(tag: tag, e);
      showToast("评论失败", toastType: ToastType.error);
    }
  }
}