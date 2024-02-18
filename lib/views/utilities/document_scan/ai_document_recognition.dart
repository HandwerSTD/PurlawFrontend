import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/viewmodels/ai_chat_page/ai_document_recognition_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';


class AIDocumentRecognition extends StatelessWidget {
  const AIDocumentRecognition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(
        title: '文档识别',
        showBack: true
      ).build(context),
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
                      GestureDetector(
                        onLongPress: () async {
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 12, left: 12, right: 12),
                          child: (
                              Image.file(model.image)
                          ),
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

