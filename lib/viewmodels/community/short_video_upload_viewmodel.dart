import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multipart_request_null_safety/multipart_request_null_safety.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import '../../common/utils/cache_utils.dart';
import '../../components/third_party/prompt.dart';

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
  
  late File tempCoverPath;

  ShortVideoUploadViewModel(
      {required this.selectedFile});

  load() {
    VideoThumbnail.thumbnailData(
            video: selectedFile.path,
            imageFormat: ImageFormat.PNG,
            quality: 100)
        .then((value) async {
          tempCoverPath = await CacheUtil.getTempFilePath('cover');
      coverData = value!;
      tempCoverPath.writeAsBytesSync(coverData);
      loaded = true;
      notifyListeners();
    });
  }

  void setCover(Uint8List val) {
    if (val.isNotEmpty) {
      tempCoverPath.writeAsBytesSync(val);
      coverData = val;
    }
    notifyListeners();
  }

  Response uploadNewVideo(
      {required String title,
      required String desc,
      required String tags,
      required String videoPath,
      required String coverPath,
      required String cookie})  {
    Log.i(tag: tag, "[ShortVideo] Uploading Video");
    var req = MultipartRequest();
    req.addHeaders({"content-type": "multipart/form-data", "cookie": cookie});
    req.addFields({"title": title, "description": desc, "tags": tags});
    req.addFile('video', videoPath);
    req.addFile('cover', coverPath);
    return req.send();
  }

  Future<void> uploadVideo(String cookie) async {
    String title = titleController.value.text,
        desc = descController.value.text,
        tags = tagsController.value.text;
    if (title == "" || desc == "" || tags == "") {
      showToast("视频信息不能为空", toastType: ToastType.warning);
      return;
    }
    showToast("视频上传中", toastType: ToastType.info);
    isVideoUploading = true;
    notifyListeners();
    try {
      var uploaded = 0;
      var response = uploadNewVideo(
        title: title,
        desc: desc,
        tags: tags,
        videoPath: selectedFile.path,
        coverPath: tempCoverPath.path,
        cookie: cookie,
      );
      response.progress.listen((int progress) { // TODO: Test
        percentage.value = progress;
        Log.i(
            tag: tag,
            "[DEBUG] uploaded = $uploaded, percent = ${percentage.value}");
      });
      response.onError = () async {
        showToast("上传失败", toastType: ToastType.error);
        isVideoUploading = false;
        notifyListeners();
        await CacheUtil.clear(); // 清除缓存 不知道有没有用
      };
      response.onComplete = (response) async {
        showToast("上传成功", toastType: ToastType.success);
        Future.delayed(const Duration(seconds: 1)).then((value) {
          eventBus.fire(ShortVideoUploadEventBus(needNavigate: true));
        });
        await CacheUtil.clear(); // 清除缓存 不知道有没有用
      };
    } on Exception catch (e) {
      Log.e(tag: tag, e);
      showToast("上传失败", toastType: ToastType.error);
    }
  }
}

class ShortVideoUploadEventBus {
  final bool needNavigate;
  ShortVideoUploadEventBus({required this.needNavigate});
}
