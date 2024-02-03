import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/utils/cache_utils.dart';

const tag = "ShortVideo Upload ViewModel";

class ShortVideoUploadViewModel extends BaseViewModel {
  final XFile selectedFile;
  TextEditingController titleController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController descController = TextEditingController();
  Uint8List coverData = Uint8List(0);
  bool loaded = false;
  bool isVideoUploading = false;
  ValueNotifier<int> percentage = ValueNotifier(0);

  ShortVideoUploadViewModel({required this.selectedFile, required super.context});

  load() {
    VideoThumbnail.thumbnailData(
        video: selectedFile.path,
        imageFormat: ImageFormat.PNG,
        quality: 100)
        .then((value) {
        coverData = value!;
        loaded = true;
        notifyListeners();
    });
  }

  void setCover(val) {
    coverData = (val.isEmpty ? coverData : val);
    notifyListeners();
  }

  Future<http.StreamedResponse> uploadNewVideo(
      {required String title,
        required String desc,
        required String tags,
        required List<int> videoData,
        required List<int> coverData,
        required String cookie}) async {
    Log.i(tag: tag,"[ShortVideo] Uploading Video");
    var req = http.MultipartRequest(
        'post', Uri.parse(HttpGet.getApi(API.videoUpload.api)));
    req.headers.addAll({"content-type": "multipart/form-data", "cookie": cookie});
    req.fields.addAll({"title": title, "description": desc, "tags": tags});
    req.files
        .add(http.MultipartFile.fromBytes('video', videoData, filename: "video"));
    req.files
        .add(http.MultipartFile.fromBytes('cover', coverData, filename: "cover"));
    return req.send();
  }

  Future<void> uploadVideo(String cookie) async {
    String title = titleController.value.text,
        desc = descController.value.text,
        tags = tagsController.value.text;
    if (title == "" || desc == "" || tags == "") {
      makeToast("视频信息不能为空");
      return;
    }
    var videoData = await selectedFile.readAsBytes();
    makeToast("视频上传中");
    isVideoUploading = true;
    notifyListeners();
    try {
      var response = await uploadNewVideo(
          title: title,
          desc: desc,
          tags: tags,
          videoData: videoData,
          coverData: coverData,
          cookie: cookie);
      var total = response.contentLength!, uploaded = 0;
      Log.i(tag: tag,"[DEBUG] total = $total");
      response.stream.listen((value) {
        uploaded += value.length;
        percentage.value = ((uploaded / total) * 100).toInt();
        Log.i(tag: tag,"[DEBUG] uploaded = $uploaded, percent = ${percentage.value}");
      },
      onDone: () {
        // var result = jsonDecode(resp);
        // Log.i(tag: tag,"[ShortVideoUpload] res: $result");
        // if (result["status"] != "success") throw Exception(result["message"]);
        makeToast("上传成功");
        Future.delayed(const Duration(seconds: 1)).then((value) {
          eventBus.fire(ShortVideoUploadEventBus(needNavigate: true));
        });
      },
      onError: (e) {
        makeToast("上传失败");
        Log.e(tag: tag, e);
        isVideoUploading = false;
        notifyListeners();
      });
      // var resp = await response.stream.transform(utf8.decoder).join();

    } on Exception catch (e) {
      Log.e(tag: tag, e);
      makeToast("上传失败");
    } finally {
      await CacheUtil.clear(); // 清除缓存 不知道有没有用
    }
  }
}

class ShortVideoUploadEventBus {
  final bool needNavigate;
  ShortVideoUploadEventBus({required this.needNavigate});
}