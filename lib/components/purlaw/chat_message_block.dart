
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../common/utils/log_utils.dart';
import '../../models/ai_chat/chat_message_model.dart';
import '../third_party/modified_just_audio.dart';

const tag = "Chat MessageBlock";

class PurlawChatMessageBlockViewOnly extends StatelessWidget {
  final AIChatMessageModel msg;
  const PurlawChatMessageBlockViewOnly({required this.msg, super.key});

  @override
  Widget build(BuildContext context) {
    return chatMessageBlock(context, msg);
  }

  Widget chatMessageBlock(BuildContext context, AIChatMessageModel msgData) {
    bool rBreak = (Responsive.checkWidth(MediaQuery.of(context).size.width) ==
        Responsive.lg);
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    Color foreground = (msgData.isMine
        ? Colors.white
        : (themeModel.dark ? Colors.white : Colors.black87));
    Color background = (msgData.isMine
        ? themeModel.colorModel.generalFillColor
        : (themeModel.dark ? Colors.black : Colors.white));
    double leftMargin = 24 + (msgData.isMine ? (rBreak ? 500 : 24) : 0);
    double rightMargin = 24 + (msgData.isMine ? 0 : (rBreak ? 500 : 0));
    // 总容器
    return Container(
      margin: EdgeInsets.only(
          top: (msgData.isFirst && rBreak)
              ? PurlawAppMainPageTabBar.avoidancePadding
              : 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
        (msgData.isMine ? MainAxisAlignment.end : MainAxisAlignment.start),
        children: [
          Flexible(
            // 文字容器
            child: Container(
              margin: EdgeInsets.only(
                  left: leftMargin, right: rightMargin, top: 12, bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border:
                  Border.all(color: themeModel.colorModel.generalFillColorLight, width: 1),
                  color: background,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                    BoxShadow(
                        color: (themeModel.dark
                            ? Colors.grey[800]!.withOpacity(0.2)
                            : Colors.lightBlue[50]!.withOpacity(0.5)),
                        blurRadius: (themeModel.dark ? 20 : 30),
                        spreadRadius: 5,
                        offset: const Offset(0, 10)
                    )
                  ],
                  borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                      topLeft: (msgData.isMine
                          ? const Radius.circular(20)
                          : const Radius.circular(0)),
                      topRight: (!msgData.isMine
                          ? const Radius.circular(20)
                          : const Radius.circular(0)))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    (msgData.message == "" ? "思考中..." : msgData.message),
                    // softWrap: true,
                    style:
                    TextStyle(color: foreground, height: 1.5, fontSize: 15),
                  ),
                  if (!msgData.isMine)
                    {
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "对话由 AI 大模型生成，仅供参考",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      )
                    }.first
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


class PurlawChatMessageBlockWithAudio extends StatefulWidget {
  final AIChatMessageModelWithAudio msg;
  const PurlawChatMessageBlockWithAudio({required this.msg, super.key});

  @override
  State<PurlawChatMessageBlockWithAudio> createState() => _PurlawChatMessageBlockWithAudioState();
}

class _PurlawChatMessageBlockWithAudioState extends State<PurlawChatMessageBlockWithAudio> {
  ValueNotifier<bool> showAudio = ValueNotifier(false);
  int totalLength = 0;

  @override
  void initState() {
    super.initState();
    widget.msg.audioIsPlaying.value = -1;
    widget.msg.player.durationStream.listen((event) {
      if (event == null) return;
      totalLength = event.inMilliseconds;
    });
    widget.msg.player.positionStream.listen((event) {
      // playedProgress.value = event.inMilliseconds;
      // Log.d("PositionStream listen $event", tag: "Chat MessageBlock Audio");
      if (event != Duration.zero) widget.msg.audioIsPlaying.value = 1;
    });
    widget.msg.player.bufferedPositionStream.listen((event) {
      // bufferedProgress.value = event.inMilliseconds;
      Log.d("Buffering to $event", tag: "Chat MessageBlock Audio");
    });
    widget.msg.player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace st) {
      widget.msg.audioIsPlaying.value = -2;
      Log.e(e, tag: "Chat MessageBlock Audio");
    });
    widget.msg.player.playerStateStream.listen((event) async {
      Log.d("PlayerState listen $event", tag:"Chat MessageBlock Audio");
      switch (event.processingState) {
        case ProcessingState.idle:
          widget.msg.audioIsPlaying.value = -1;
          break;

        case ProcessingState.loading:
          widget.msg.audioIsPlaying.value = 0;
          break;

        case ProcessingState.completed:
          await widget.msg.player.seek(Duration.zero, index: 0);
          await widget.msg.player.stop();
          widget.msg.audioIsPlaying.value = 3;
          break;

        case ProcessingState.buffering:
          widget.msg.audioIsPlaying.value = 4;
          break;

        case ProcessingState.ready:
          widget.msg.audioIsPlaying.value = -1;
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.msg.player.stop();
  }

  @override
  Widget build(BuildContext context) {
    return chatMessageBlock(context, widget.msg);
  }

  Widget chatMessageBlock(BuildContext context, AIChatMessageModelWithAudio msgData) {
    bool rBreak = (Responsive.checkWidth(MediaQuery.of(context).size.width) ==
        Responsive.lg);
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    Color foreground = (msgData.isMine
        ? Colors.white
        : (themeModel.dark ? Colors.white : Colors.black87));
    Color background = (msgData.isMine
        ? themeModel.colorModel.generalFillColor
        : (themeModel.dark ? Colors.black : Colors.white));
    double leftMargin = 24 + (msgData.isMine ? (rBreak ? 500 : 24) : 0);
    double rightMargin = 24 + (msgData.isMine ? 0 : (rBreak ? 500 : 0));
    // 总容器
    return Container(
      margin: EdgeInsets.only(
          bottom: 6,
          top: (msgData.isFirst && rBreak)
              ? PurlawAppMainPageTabBar.avoidancePadding
              : 0.0),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: (msgData.isMine
                ? MainAxisAlignment.end
                : MainAxisAlignment.start),
            children: [
              Flexible(
                // 文字容器
                child: Container(
                  margin: EdgeInsets.only(
                      left: leftMargin,
                      right: rightMargin,
                      top: 12,
                      bottom: 12),
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 16),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: themeModel.colorModel.generalFillColorLight,
                          width: 1),
                      color: background,
                      boxShadow: [
                        const BoxShadow(color: Colors.black12, blurRadius: 5),
                        BoxShadow(
                            color: (themeModel.dark
                                ? Colors.grey[800]!.withOpacity(0.2)
                                : Colors.white.withOpacity(0.5)),
                            blurRadius: (themeModel.dark ? 20 : 30),
                            spreadRadius: 5,
                            offset: const Offset(0, 10))
                      ],
                      borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(20),
                          bottomRight: const Radius.circular(20),
                          topLeft: (msgData.isMine
                              ? const Radius.circular(20)
                              : const Radius.circular(0)),
                          topRight: (!msgData.isMine
                              ? const Radius.circular(20)
                              : const Radius.circular(0)))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        (msgData.sentences.isEmpty ? "思考中..." : msgData.getString()),
                        // softWrap: true,
                        style: TextStyle(
                            color: foreground, height: 1.5, fontSize: 15),
                      ),
                      if (!msgData.isMine)
                        {
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "对话由 AI 大模型生成，仅供参考",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: showAudio,
                                  builder: (context, value, child) {
                                    if (value) return audioPlayWidget();
                                    return Container();
                                  },
                                )
                              ],
                            ),
                          )
                        }.first,
                    ],
                  ),
                ),
              )
            ],
          ),
          ValueListenableBuilder(
              valueListenable: widget.msg.generateCompleted,
              builder: (context, value, child) {
                if (value) {
                  return PurlawRRectButton(
                    margin: const EdgeInsets.only(right: 16, bottom: 8),
                    height: 24,
                    width: 24,
                    radius: 12,
                    onClick: () async {
                      if (showAudio.value) {
                        await widget.msg.player.stop();
                        widget.msg.audioIsPlaying.value = -1;
                      }
                      showAudio.value = !showAudio.value;
                    },
                    backgroundColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    shadow: TDTheme.defaultData().shadowsTop,
                    child: const Icon(
                      Icons.multitrack_audio_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  );
                }
                return Container();
              })
        ],
      ),
    );
  }

  Widget audioPlayWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: const ButtonStyle(
                shadowColor: MaterialStatePropertyAll(Colors.transparent)),
            onPressed: () {
              widget.msg.player.play();
            },
            child: Row(
              children: [
                const Icon(Icons.multitrack_audio_rounded),
                const Text(
                  "  语音",
                  style: TextStyle(fontSize: 16),
                ),
                ValueListenableBuilder(
                    valueListenable: widget.msg.audioIsPlaying,
                    builder: (context, value, child) {
                      if (value == 0) return const Text("加载中");
                      if (value == 1) return const Text("播放中");
                      if (value == 2) return const Text("已暂停");
                      if (value == 3) return const Text("播放完毕");
                      if (value == 4) return const Text("缓冲中");
                      if (value == -2) return const Text("加载失败");
                      return const Text("");
                    }),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
