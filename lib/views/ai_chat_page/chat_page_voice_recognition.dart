import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_voice_recognition_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:record/record.dart';

import '../../components/purlaw/button.dart';

class ChatPageVoiceRecognition extends StatelessWidget {
  const ChatPageVoiceRecognition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(
        title: "语音识别",
        showBack: true
      ).build(context),
      body: ChatVoiceRecognitionBody(),
    );
  }
}

class ChatVoiceRecognitionBody extends StatelessWidget {
  const ChatVoiceRecognitionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ChatVoiceRecognitionViewModel>(
      model: ChatVoiceRecognitionViewModel(context: context),
      onReady: (model){
        model.load();
      },
      builder: (context, model, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(model.text),
              PurlawRRectButton(
                onClick: () async {
                  if (!model.listeningVoice) {
                    model.startRecord();
                  } else {
                    model.stopRecord();
                  }
                },
                backgroundColor: getThemeModel(context).colorModel.generalFillColor,
                width: 192,
                height: 54,
                radius: 12,
                child:  Text(
                  (model.listeningVoice ? "识别中" : "开始识别"),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}



