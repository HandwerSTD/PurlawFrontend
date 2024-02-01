import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:http/http.dart' as http;

class AccountDetails extends StatefulWidget {
  AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  Future uploadNewAvatar(
      {required List<int> avatar, required String cookie}) async {
    print("[AccountAPI] Uploading new avatar");
    var req = http.MultipartRequest(
        'post', Uri.parse(HttpGet.getApi(API.userUploadAvatar.api)));
    req.headers.addAll({"content-type": "multipart/form-data", "cookie": cookie});
    req.files
        .add(http.MultipartFile.fromBytes('avatar', avatar, filename: "avatar"));
    return req.send();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑我的信息"),
      ),
      body: ListView(
        children: [
          ElevatedButton(child: Text("上传新头像"), onPressed: () async {
            var avatar = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1000, requestFullMetadata: false);
            if (avatar == null) return;
            var avatarData = await ImageCropper().cropImage(sourcePath: avatar.path, aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
            if (avatarData == null) return;
            TDToast.showText("上传中", context: context);
            var response = await uploadNewAvatar(avatar: await avatarData.readAsBytes(), cookie: getCookie(context));
            var resp =
            await response.stream.transform(utf8.decoder).join();
            print("[UploadNewAvatar] res: $resp");
            TDToast.showText(context: context, "${jsonDecode(resp)["message"]}");
            Provider.of<MainViewModel>(context, listen: false).refreshCookies();
          }),
        ],
      ),
    );
  }
}
