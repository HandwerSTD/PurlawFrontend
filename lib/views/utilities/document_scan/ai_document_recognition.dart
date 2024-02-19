import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/viewmodels/ai_chat_page/ai_document_recognition_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:path/path.dart' as p;
import 'package:tdesign_flutter/tdesign_flutter.dart';


class AIDocumentRecognition extends StatelessWidget {
  const AIDocumentRecognition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文档识别'),
        actions: [
          IconButton(onPressed: (){
            showDialog(context: context, builder: (context) {
              return Dialog(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 48),
                    child: const Text("扫描的图像位于：\n内部储存/Android/data/com.tianzhu.purlaw/files/Pictures/")),
              );
            });
          }, icon: Icon(Icons.photo_album_rounded))
        ],
      ),
      body: ProviderWidget<AIDocumentRecViewModel>(
        model: AIDocumentRecViewModel(),
        onReady: (model){},
        builder: (context, model, child) => Column(
          children: [
            ElevatedButton(onPressed: () async {
              model.load();
            }, child: Text("添加图像")),
            Expanded(
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: model.controller,
                itemBuilder: (context, index) {
                  return AIDocumentRecognitionBody(index: index,);
                },
                itemCount: model.result.length,
              ),
            )
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
                      Container(
                        margin: EdgeInsets.only(top: 12, left: 12, right: 12),
                        child: (
                            Image.file(model.image)
                        ),
                      ),
                      ( !model.ocrCompleted ? ElevatedButton(
                        onPressed: () async {
                          await model.loadOCR();
                          mm.notify();
                        },
                        child: Text("识别"),
                      ) : Row(
                        children: [
                          Expanded(child: Container(
                            margin: EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 48),
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

