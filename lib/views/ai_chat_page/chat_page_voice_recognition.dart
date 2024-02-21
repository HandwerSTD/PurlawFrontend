import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_voice_recognition_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:record/record.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../components/purlaw/button.dart';
import '../../components/purlaw/chat_message_block.dart';
import '../../viewmodels/ai_chat_page/chat_page_viewmodel.dart';

class ChatPageVoiceRecognition extends StatelessWidget {
  const ChatPageVoiceRecognition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: "语音对话", showBack: true).build(context),
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
        onReady: (model) {
          model.load(getCookie(context));
        },
        builder: (context, model, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ListView(
                padding: EdgeInsets.only(bottom: 108),
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(
                            top: 24, left: 24, right: 24, bottom: 24),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: getThemeModel(context)
                                .colorModel
                                .loginTextFieldColor,
                            borderRadius: BorderRadius.circular(24)),
                        child: Text(model.text),
                      ))
                    ],
                  ),
                  Visibility(
                      visible: model.sttFinished,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 36),
                                child: Text("回复  "),
                              ),
                              ValueListenableBuilder(valueListenable: model.message.generateCompleted,
                              builder: (context, val, child)  {
                                if (val) return Container();
                                        return TDLoading(
                                          size: TDLoadingSize.small,
                                          icon: TDLoadingIcon.circle,
                                        );
                                      })
                            ],
                          ),
                          PurlawChatMessageBlockWithAudio(msg: model.message, overrideRadius: true,)
                        ],
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    if (!model.listeningVoice) {
                      model.startRecord();
                    } else {
                      model.stopRecord();
                    }
                  },
                  icon: Icon((model.listeningVoice
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded)),
                  label: Text(
                    (model.listeningVoice ? "停止并识别" : "开始说话"),
                  ),
                ),
              )
            ],
          );
        });
  }
}
