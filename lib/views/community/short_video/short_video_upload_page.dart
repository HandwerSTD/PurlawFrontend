import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/viewmodels/community/short_video_upload_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ShortVideoUpload extends StatefulWidget {
  final XFile selectedFile;
  const ShortVideoUpload({super.key, required this.selectedFile});

  @override
  State<ShortVideoUpload> createState() => _ShortVideoUploadState();
}

class _ShortVideoUploadState extends State<ShortVideoUpload> {
  late StreamSubscription _;
  @override
  void initState() {
    super.initState();
    _ = eventBus.on<ShortVideoUploadEventBus>().listen((event) {
      if (event.needNavigate) {
        Navigator.pop(context);
      }
    });
    _.resume();
  }

  @override
  void dispose() {
    super.dispose();
    _.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("上传视频"),
      ),
      body: ProviderWidget<ShortVideoUploadViewModel>(
        model: ShortVideoUploadViewModel(
            selectedFile: widget.selectedFile, context: context),
        onReady: (model) {
          model.load();
        },
        builder: (context, model, _) => Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: TextField(
                          decoration: outlineBorderedInputDecoration("视频标题", 36,
                              filled: true),
                          controller: model.titleController,
                          style: TextStyle(fontSize: 15),
                        ),
                      ))
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: TextField(
                      decoration: outlineBorderedInputDecoration(
                          "视频标签，用英文逗号分隔", 36,
                          filled: true),
                      controller: model.tagsController,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: multilineTextField(model.descController),
                  ),
                ],
              ),
              Expanded(
                  child: GestureDetector(
                onTap: () async {
                  print("[ShortVideoUpload] selecting another cover");
                  ImagePicker()
                      .pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 720,
                          maxHeight: 720)
                      .then((value) {
                    value?.readAsBytes().then((val) {
                      model.setCover(val);
                    });
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: (model.loaded
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            (Image.memory(model.coverData)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(14)
                              ),
                              child: const Text(
                                "点击更换封面",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 48,
                          height: 48,
                          child: TDLoading(size: TDLoadingSize.large, icon: TDLoadingIcon.circle,))),
                ),
              )),
              IgnorePointer(
                ignoring: model.isVideoUploading,
                child: ElevatedButton(
                    onPressed: () async {
                      model.uploadVideo(
                          Provider.of<MainViewModel>(context, listen: false)
                              .cookies);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Text(
                          (model.isVideoUploading ? "上传中" : "上传视频"),
                          textAlign: TextAlign.center,
                        ))
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget multilineTextField(TextEditingController cont) {
    return Container(
      // color: Colors.red,
      constraints: BoxConstraints(
        maxHeight: 144.0,
        minHeight: 96.0,
      ),
      child: TextField(
        controller: cont,
        minLines: 3,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: outlineBorderedInputDecoration("视频简介", 18,
            filled: true,
            fillColor: Provider.of<ThemeViewModel>(context)
                .themeModel
                .colorModel
                .loginTextFieldColor),
      ),
    );
  }

  InputDecoration outlineBorderedInputDecoration(String hint, double rad,
          {bool dense = false, bool filled = false, fillColor}) =>
      InputDecoration(
        isDense: dense,
        contentPadding: EdgeInsets.symmetric(vertical: 8.5, horizontal: 12),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(rad))),
        filled: filled,
        fillColor: fillColor ??
            Provider.of<ThemeViewModel>(context)
                .themeModel
                .colorModel
                .loginTextFieldColor,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
      );
}
