import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:grock/grock.dart';
import 'package:image_editor/image_editor.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/viewmodels/ai_chat_page/ai_document_recognition_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../common/utils/log_utils.dart';
import '../../../components/third_party/prompt.dart';

class AIDocumentRecognition extends StatelessWidget {
  const AIDocumentRecognition({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<AIDocumentRecViewModel>(
      model: AIDocumentRecViewModel(),
      onReady: (model) {},
      builder: (context, model, child) => Scaffold(
          appBar: AppBar(
            title: const Text('文档识别'),
            actions: [
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 48),
                                child: const Text(
                                    "扫描的图像已自动保存于：\n内部储存/Android/data/com.tianzhu.purlaw/files/Pictures/")),
                          );
                        });
                  },
                  icon: const Icon(Icons.photo_album_rounded))
            ],
          ),
          floatingActionButtonLocation: (model.result.isNotEmpty ? ExpandableFab.location : FloatingActionButtonLocation.endContained),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(right: 12, bottom: 48),
            child: (model.result.isNotEmpty
                ? ExpandableFab(
                  type: ExpandableFabType.up,
                  distance: 75,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: null,
                      icon: const Icon(Icons.add_a_photo_rounded),
                      label: const Text('添加图像'),
                      onPressed: () {
                        model.load();
                      },
                    ),FloatingActionButton.extended(
                      heroTag: null,
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text('AI 分析'),
                      onPressed: () {
                        int page = model.controller.page!.round();
                        if (!model.models[page].ocrCompleted) {
                          showToast("请先进行识别", toastType: ToastType.info);
                          return;
                        }
                        Log.i("Start analyze document $page", tag: "AI Document Recognition");
                        showDialog(context: context, builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            alignment: Alignment.topCenter,
                            insetPadding: EdgeInsets.zero,
                            child: AIDocumentAnalyzeDialog(documentText: model.models[page].ocrResult,),
                          );
                        });
                      },
                    ),
                  ])
                : FloatingActionButton.extended(
                    onPressed: () async {
                      model.load();
                    },
                    label: const Text("添加图像"),
                    icon: const Icon(Icons.add_a_photo_rounded),
                  )),
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: model.controller,
                  itemBuilder: (context, index) {
                    return AIDocumentRecognitionBody(
                      index: index,
                    );
                  },
                  itemCount: model.result.length,
                ),
              ),
            ],
          )),
    );
  }
}

class AIDocumentRecognitionBody extends StatelessWidget {
  final int index;
  const AIDocumentRecognitionBody({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIDocumentRecViewModel>(builder: (context, mm, child) {
      final model = mm.models[index];
      return LayoutBuilder(builder: (context, constraints) {
        bool rBreak =
            (Responsive.checkWidth(constraints.maxWidth) == Responsive.lg);
        return Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 12, left: 12, right: 12),
                      height: constraints.maxHeight / 2,
                      width: Responsive.assignWidthStM(constraints.maxWidth),
                      child: GestureDetector(
                        onTap: () {
                          showImageViewer(
                              context, Image.memory(model.imageBytes).image,
                              swipeDismissible: true, doubleTapZoomable: true);
                        },
                        child: (Image.memory(model.imageBytes)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PurlawRRectButton(
                          width: 72,
                          onClick: () async {
                            final editorOption = ImageEditorOption();
                            editorOption.addOption(const FlipOption(horizontal: true, vertical: false));
                            final result = await ImageEditor.editFileImage(
                                file: model.image, imageEditorOption: editorOption);
                            model.image.writeAsBytesSync(result!);
                            model.imageBytes = result;
                            mm.notify();
                          },
                          backgroundColor: (getThemeModel(context).dark
                                  ? Colors.black
                                  : Colors.grey[300]!)
                              .withOpacity(0.8),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flip_rounded),
                              Text(" 翻转")
                            ],
                          ),
                        ),
                        PurlawRRectButton(
                          width: 72,
                          onClick: () async {
                            final editorOption = ImageEditorOption();
                            editorOption.addOption(const RotateOption(90));
                            final result = await ImageEditor.editFileImage(
                                file: model.image, imageEditorOption: editorOption);
                            model.image.writeAsBytesSync(result!);
                            model.imageBytes = result;
                            mm.notify();
                          },
                          backgroundColor: (getThemeModel(context).dark
                              ? Colors.black
                              : Colors.grey[300]!)
                              .withOpacity(0.8),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rotate_right_rounded),
                              Text(" 旋转")
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                (!model.ocrCompleted
                    ? ElevatedButton(
                        onPressed: () async {
                          await model.loadOCR();
                          mm.notify();
                        },
                        child: const Text("识别"),
                      )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 24, top: 36, bottom: 8),
                          child: Text("识别结果", style: TextStyle(fontSize: 18),),
                        ),
                        Row(
                            children: [
                              Expanded(
                                  child: Container(
                                margin: const EdgeInsets.only(
                                    left: 12, right: 12, bottom: 48),
                                child: TextField(
                                  decoration: PurlawChatTextField.chatInputDeco(
                                      '',
                                      getThemeModel(context)
                                          .colorModel
                                          .loginTextFieldColor,
                                      24),
                                  controller: model.controller,
                                  maxLines: null,
                                ),
                              ))
                            ],
                          ),
                      ],
                    ))
              ],
            ),
          ),
        );
      });
    });
  }
}

class AIDocumentAnalyzeDialog extends StatelessWidget {
  final String documentText;

  const AIDocumentAnalyzeDialog({super.key, required this.documentText});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<AIDocumentAnalyzeViewModel>(
        model: AIDocumentAnalyzeViewModel(),
        onReady: (model){
          model.load(documentText, getCookie(context, listen: false));
        },
        builder: (context, model, child) {
          return Container(
            width: Responsive.assignWidthMedium(Grock.width),
            margin: const EdgeInsets.only(left: 12, right: 12, top: 64, bottom: 64),
            decoration: BoxDecoration(
              color: getThemeModel(context).dark ? const Color(0xff333333) : getThemeModel(context).themeData.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24)
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 36),
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Text("分析  "),
                        ),
                        ValueListenableBuilder(
                            valueListenable:
                            model.message.generateCompleted,
                            builder: (context, val, child) {
                              if (val) return Container();
                              return const TDLoading(
                                size: TDLoadingSize.small,
                                icon: TDLoadingIcon.circle,
                              );
                            })
                      ],
                    ),
                    PurlawChatMessageBlockWithAudio(
                      msg: model.message,
                      overrideRadius: true,
                    )
                  ],
                )
              ],
            ),
          );
        },
    );
  }
}

