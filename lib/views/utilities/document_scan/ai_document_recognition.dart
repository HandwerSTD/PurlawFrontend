
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/viewmodels/ai_chat_page/ai_document_recognition_viewmodel.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_page_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';


class AIDocumentRecognition extends StatelessWidget {
  const AIDocumentRecognition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文档识别'),
        actions: [
          IconButton(onPressed: (){
            showDialog(context: context, builder: (context) {
              return Dialog(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 48),
                    child: const Text("扫描的图像已自动保存于：\n内部储存/Android/data/com.tianzhu.purlaw/files/Pictures/")),
              );
            });
          }, icon: const Icon(Icons.photo_album_rounded))
        ],
      ),
      body: ProviderWidget<AIDocumentRecViewModel>(
        model: AIDocumentRecViewModel(),
        onReady: (model){},
        builder: (context, model, child) => Stack(
          alignment: Alignment.bottomRight,
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: model.controller,
                    itemBuilder: (context, index) {
                      return AIDocumentRecognitionBody(index: index,);
                    },
                    itemCount: model.result.length,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 48, right: 24), child: FloatingActionButton.extended(onPressed: () async {
              model.load();
            }, label: const Text("添加图像"), icon: Icon(Icons.add_a_photo_rounded),),)
          ],
        ),
      )
    );
  }
}

class AIDocumentRecognitionBody extends StatelessWidget {
  final int index;
  const AIDocumentRecognitionBody({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIDocumentRecViewModel>(
      builder: (context, mm, child) {
        final model = mm.viewModels[index];
        return LayoutBuilder(
            builder: (context, constraints) {
              bool rBreak = (Responsive.checkWidth(constraints.maxWidth) == Responsive.lg);
              return Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
                            height: constraints.maxHeight / 2,
                            width: Responsive.assignWidthStM(constraints.maxWidth),
                            child: GestureDetector(
                              onTap: (){
                                showImageViewer(context, Image.memory(model.imageBytes).image, swipeDismissible: true, doubleTapZoomable: true);
                              },
                              child: (
                                  Image.memory(model.imageBytes)
                              ),
                            ),
                          ),
                          PurlawRRectButton(
                            width: 72,
                            onClick: () async {
                              final editorOption = ImageEditorOption();
                              editorOption.addOption(const RotateOption(90));
                              final result = await ImageEditor.editFileImage(file: model.image, imageEditorOption: editorOption);
                              model.image.writeAsBytesSync(result!);
                              model.imageBytes = result;
                              mm.notify();
                          }, backgroundColor: (getThemeModel(context).dark ? Colors.black : Colors.white).withOpacity(0.8),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rotate_right_rounded),
                              Text(" 旋转")
                            ],
                          ),)
                        ],
                      ),
                      ( !model.ocrCompleted ? ElevatedButton(
                        onPressed: () async {
                          await model.loadOCR();
                          mm.notify();
                        },
                        child: const Text("识别"),
                      ) : Row(
                        children: [
                          Expanded(child: Container(
                            margin: const EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 48),
                            child: TextField(
                              decoration: PurlawChatTextField.chatInputDeco('', getThemeModel(context).colorModel.loginTextFieldColor, 24),
                              controller: model.controller,
                              maxLines: null,
                            ),
                          ))
                        ],
                      ))
                    ],
                  ),
                ),
              );
            }
        );
      }
    );
  }
}

