import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/method_channels/document_recognition.dart';
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
      body: AIDocumentRecognitionBody(),
    );
  }
}

class AIDocumentRecognitionBody extends StatefulWidget {
  const AIDocumentRecognitionBody({super.key});

  @override
  State<AIDocumentRecognitionBody> createState() => _AIDocumentRecognitionBodyState();
}

class _AIDocumentRecognitionBodyState extends State<AIDocumentRecognitionBody> {

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<AIDocumentRecViewModel>(
      model: AIDocumentRecViewModel(),
      onReady: (model){},
      builder: (context, model, child) => Column(
        children: [
          ElevatedButton(onPressed: () async {
            model.loadNew();
            model.load(model.results.length - 1);
          }, child: Text("添加图像")),
          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: model.controller,
              itemBuilder: (context, index) {
                TextEditingController controller = TextEditingController(
                  text: model.results[index]
                );
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
                                model.images[index] == null ? Container()
                                : Image.file(File(model.images[index]!.path))
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(child: Container(
                                    margin: EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 48),
                                    child: TextField(
                                      decoration: PurlawChatTextField.chatInputDeco('', getThemeModel(context).colorModel.loginTextFieldColor, 24),
                                      controller: controller,
                                      maxLines: null,
                                    ),
                                  ))
                                ],
                              )
                            ],
                          ),
                        ),
                    );
                  }
                );
              },
              itemCount: model.results.length,
            ),
          )
        ],
      ),
    );
  }
}

