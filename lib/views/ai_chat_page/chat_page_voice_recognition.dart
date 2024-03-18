

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:purlaw/common/network/chat_api.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_voice_recognition_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../components/purlaw/chat_message_block.dart';
import '../account_mgr/my_account_page.dart';

class ChatPageVoiceRecognition extends StatelessWidget {
  const ChatPageVoiceRecognition({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (val){
        // ChatNetworkRequest.isolate?.kill(priority: Isolate.immediate);
        ChatNetworkRequest.breakIsolate(getCookie(context, listen: false), DatabaseUtil.getLastAIChatSession());
      },
      child: Scaffold(
        appBar: PurlawAppTitleBar(title: "语音对话", showBack: true).build(context),
        body: const ChatVoiceRecognitionBody(),
      ),
    );
  }
}

class ChatVoiceRecognitionBody extends StatefulWidget {
  const ChatVoiceRecognitionBody({super.key});

  @override
  State<ChatVoiceRecognitionBody> createState() =>
      _ChatVoiceRecognitionBodyState();
}

class _ChatVoiceRecognitionBodyState extends State<ChatVoiceRecognitionBody> {

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ChatVoiceRecognitionViewModel>(
        model: ChatVoiceRecognitionViewModel(),
        onReady: (model) {
          model.load(getCookie(context, listen: false));
        },
        onDispose: (model) {
          model.onDispose();
        },
        builder: (context, model, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Builder(
                builder: (context) {
                  if (model.listeningVoice) {
                    return Container(
                      padding: const EdgeInsets.only(bottom: 96),
                      alignment: Alignment.center,
                      child: SpinKitWave(size: 108, color: getThemeModel(context).colorModel.generalFillColor,),
                    );
                  }
                  if (model.startGen) {
                    return Animate(
                      autoPlay: true,
                      effects: [FadeEffect(duration: 300.milliseconds)],

                      child: Container(
                        alignment: Alignment.center,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 108, top: 64),
                          children: [
                            SpinKitDoubleBounce(size: 144,color: getThemeModel(context).colorModel.generalFillColor),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 108,),
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 36),
                                      child: Text("回复  "),
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
                                  alwaysMarkdown: true
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    );
                  }
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 96),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpinKitPianoWave(color: getThemeModel(context).colorModel.generalFillColor,),
                        const Text("\n点击开始说话")
                      ],
                    ),
                  );
                }
              ),
              Builder(builder: (context) {
                if (model.listeningVoice) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 108),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RippleAnimation(
                          color: getThemeModel(context).colorModel.generalFillColorLight,
                          repeat: true,
                          child: FloatingActionButton.large(
                            shape: const CircleBorder(),
                            backgroundColor:
                            getThemeModel(context).colorModel.generalFillColor,
                            onPressed: () async {
                              if (!model.listeningVoice) {
                                model.startRecord();
                              } else {
                                model.stopRecord();
                              }
                            },
                            child: Icon(
                              (model.listeningVoice
                                  ? Icons.mic_rounded
                                  : Icons.mic_none_rounded),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text("\n点击停止", style: TextStyle(color: getThemeModel(context).colorModel.generalFillColor.withOpacity(0.8)),)
                      ],
                    ),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: model.showMineText,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 36, bottom: 8),
                              child: Text("识别结果"),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 24, right: 24, bottom: 24),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: getThemeModel(context)
                                              .colorModel
                                              .loginTextFieldColor,
                                          borderRadius: BorderRadius.circular(24)),
                                      child: Text(model.text,),
                                    ))
                              ],
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.milliseconds),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton.extended(
                              backgroundColor:
                              getThemeModel(context).colorModel.generalFillColor,
                              onPressed: () async {
                                if (!checkAndLoginIfNot(context)) return;
                                if (!model.listeningVoice) {
                                  model.startRecord();
                                } else {
                                  model.stopRecord();
                                }
                              },
                              icon: Icon(
                                (model.listeningVoice
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded),
                                color: Colors.white,
                              ),
                              label: Text(
                                (model.listeningVoice ? "停止并识别" : "开始说话"),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: model.message.generateCompleted,
                              builder: (context, value, child) {
                                if (value || model.startGen == false) return Container();
                                return Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: FloatingActionButton.extended(onPressed: (){
                                                  model.manuallyBreak(getCookie(context, listen: false), DatabaseUtil.getLastAIChatSession());
                                                  }, label: const Icon(Icons.stop_circle_rounded,
                                                  color: Colors.white,),
                                                  backgroundColor:
                                                  getThemeModel(context).colorModel.generalFillColor,),
                                );

                              })
                          ],
                        ),
                      ),
                    ],
                  );
                }
              })
            ],
          );
        });
  }
}
