import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';
import 'package:http/http.dart' as http;
import 'package:purlaw/common/utils/log_utils.dart';


class MyAccountAvatar extends StatelessWidget {
  static const tag = "Account UploadNewAvatar";
  const MyAccountAvatar({super.key});

  Future uploadNewAvatar(
      {required List<int> avatar, required String cookie}) async {
    Log.i(tag: tag, "Uploading new avatar");
    var req = http.MultipartRequest(
        'post', Uri.parse(HttpGet.getApi(API.userUploadAvatar.api)));
    req.headers
        .addAll({"content-type": "multipart/form-data", "cookie": cookie});
    req.files.add(
        http.MultipartFile.fromBytes('avatar', avatar, filename: "avatar"));
    return req.send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: '我的头像', showBack: true).build(context),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatarLoader(
              verified: false,
              margin: const EdgeInsets.all(47),
                avatar:
                    Provider.of<MainViewModel>(context).myUserInfoModel.avatar,
                size: 144,
                radius: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      child: const Text("上传新头像"),
                      onPressed: () async {
                        bool refreshed = getMainViewModel(context, listen: false).myUserInfoModel.cookie.isNotEmpty;
                        if (!refreshed) {
                          showToast("请先刷新用户信息", toastType: ToastType.warning);
                          return;
                        }
                        var avatar = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1000,
                            requestFullMetadata: false);
                        if (avatar == null) return;
                        var avatarData = await ImageCropper().cropImage(
                            sourcePath: avatar.path,
                            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
                        if (avatarData == null) return;
                        showToast("上传中", toastType: ToastType.info);
                        try {
                          var response = await uploadNewAvatar(
                              avatar: await avatarData.readAsBytes(),
                              cookie: getCookie(context, listen: false));
                          var resp = await response.stream
                              .transform(utf8.decoder)
                              .join();
                          Log.i(tag: tag, "res: $resp");
                          if (context.mounted) {
                            showToast(
                                "${jsonDecode(
                                resp)["message"]}", toastType: ToastType.info);
                            Provider.of<MainViewModel>(context, listen: false).refreshCookies();
                          }
                        } on Exception catch (e) {
                          Log.e(e, tag:"AccountAvatar");
                          if (context.mounted) showToast("设置失败", toastType: ToastType.warning);
                        }
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
