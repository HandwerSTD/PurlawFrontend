import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  final ChatMessageModel msg;
  const PurlawChatMessageBlockViewOnly({required this.msg, super.key});

  @override
  Widget build(BuildContext context) {
    return chatMessageBlock(context, msg);
  }

  Widget chatMessageBlock(BuildContext context, ChatMessageModel msgData) {
    final width = MediaQuery.of(context).size.width;
    bool rBreak = (Responsive.checkWidth(width) == Responsive.lg);
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    Color foreground = (msgData.isMine
        ? Colors.white
        : (themeModel.dark ? Colors.white : Colors.black87));
    Color background = (msgData.isMine
        ? themeModel.colorModel.generalFillColor
        : (themeModel.dark ? Colors.black : Colors.white));
    double leftMargin = 24 + (msgData.isMine ? (rBreak ? width * 0.3 : 24) : 0);
    double rightMargin = 24 + (msgData.isMine ? 0 : (rBreak ? width * 0.3 : 0));
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
                  border: Border.all(
                      color: themeModel.colorModel.generalFillColorLight,
                      width: 1),
                  color: background,
                  boxShadow: [
                    const BoxShadow(color: Colors.black12, blurRadius: 5),
                    BoxShadow(
                        color: (themeModel.dark
                            ? Colors.grey[800]!.withOpacity(0.2)
                            : Colors.lightBlue[50]!.withOpacity(0.5)),
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

class PurlawChatMessageBlockForPM extends StatelessWidget {
  final PrivateChatMessageModel msg;
  const PurlawChatMessageBlockForPM({required this.msg, super.key});

  @override
  Widget build(BuildContext context) {
    return chatMessageBlock(context, msg);
  }

  Widget chatMessageBlock(
      BuildContext context, PrivateChatMessageModel msgData) {
    final width = MediaQuery.of(context).size.width;
    bool rBreak = (Responsive.checkWidth(width) == Responsive.lg);
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    Color foreground = (msgData.isMine
        ? Colors.white
        : (themeModel.dark ? Colors.white : Colors.black87));
    Color background = (msgData.isMine
        ? themeModel.colorModel.generalFillColor
        : (themeModel.dark ? Colors.black : Colors.white));
    double leftMargin = 24 + (msgData.isMine ? (rBreak ? width * 0.3 : 24) : 0);
    double rightMargin = 24 + (msgData.isMine ? 0 : (rBreak ? width * 0.3 : 0));
    // 总容器
    return Container(
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
                  border: Border.all(
                      color: themeModel.colorModel.generalFillColorLight,
                      width: 1),
                  color: background,
                  boxShadow: [
                    const BoxShadow(color: Colors.black12, blurRadius: 5),
                    BoxShadow(
                        color: (themeModel.dark
                            ? Colors.grey[800]!.withOpacity(0.2)
                            : Colors.lightBlue[50]!.withOpacity(0.5)),
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
                    (msgData.message == "" ? "思考中..." : msgData.message),
                    // softWrap: true,
                    style:
                        TextStyle(color: foreground, height: 1.5, fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      TimeUtils.formatDateTime(msgData.timestamp),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  )
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
  final bool overrideRadius;
  const PurlawChatMessageBlockWithAudio(
      {required this.msg, super.key, this.overrideRadius = false});

  @override
  State<PurlawChatMessageBlockWithAudio> createState() =>
      _PurlawChatMessageBlockWithAudioState();
}

class _PurlawChatMessageBlockWithAudioState
    extends State<PurlawChatMessageBlockWithAudio> {
  ValueNotifier<bool> showAudio = ValueNotifier(false);
  int totalLength = 0;

  @override
  void initState() {
    super.initState();
    widget.msg.player.durationStream.listen((event) {
      if (event == null) return;
      totalLength = event.inMilliseconds;
    });
    widget.msg.player.positionStream.listen((event) {});
    widget.msg.player.bufferedPositionStream.listen((event) {
      Log.d("Buffering to $event", tag: "Chat MessageBlock Audio");
    });
    widget.msg.player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace st) {
      Log.e(e, tag: "Chat MessageBlock Audio");
    });
    widget.msg.player.playerStateStream.listen((event) async {
      Log.d("listen: ${event.processingState}",
          tag: "Chat MessageBlock Audio PlayerState");
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

  Widget chatMessageBlock(
      BuildContext context, AIChatMessageModelWithAudio msgData) {
    final width = MediaQuery.of(context).size.width;
    bool rBreak = (Responsive.checkWidth(width) == Responsive.lg);
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    bool foregroundWhite =
        (msgData.isMine ? true : (themeModel.dark ? true : false));
    Color background = (msgData.isMine
        ? themeModel.colorModel.generalFillColor
        : (themeModel.dark ? Colors.black : Colors.white));
    double leftMargin = 24 + (msgData.isMine ? (rBreak ? width * 0.3 : 24) : 0);
    double rightMargin = 24 + (msgData.isMine ? 0 : (rBreak ? width * 0.3 : 0));
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
                      border: msgData.isMine
                          ? null
                          : Border.all(
                              color:
                                  themeModel.colorModel.generalFillColorLight,
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
                      borderRadius: (widget.overrideRadius
                          ? BorderRadius.circular(20)
                          : BorderRadius.only(
                              bottomLeft: const Radius.circular(20),
                              bottomRight: const Radius.circular(20),
                              topLeft: (msgData.isMine
                                  ? const Radius.circular(20)
                                  : const Radius.circular(6)),
                              topRight: (!msgData.isMine
                                  ? const Radius.circular(20)
                                  : const Radius.circular(6))))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: msgData.generateCompleted,
                          builder: (context, value, child) {
                            if (!value) {
                              return SelectableText(
                                // (msgData.sentences.isEmpty ? "思考中..." : msgData.getString()),
                                (msgData.showedText.isEmpty
                                    ? "思考中..."
                                    : msgData.showedText),
                                // softWrap: true,
                                style: TextStyle(
                                    color: foregroundWhite
                                        ? Colors.white
                                        : Colors.black87,
                                    height: 1.5,
                                    fontSize: 15),
                              );
                            }
                            return MarkdownBody(
                              data: msgData.showedText.isEmpty
                                  ? "思考中..."
                                  : msgData.showedText,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet.fromTheme(
                                  Theme.of(context).copyWith(
                                      textTheme: (!foregroundWhite
                                          ? Typography.blackCupertino.copyWith(
                                              bodyMedium: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15))
                                          : Typography.blackCupertino.copyWith(
                                              bodyMedium: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15))))),
                            );
                          }),
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
                                    if (value) return audioPlayWidget(width);
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
                    margin: EdgeInsets.only(right: rightMargin, bottom: 8),
                    height: 24,
                    width: 24,
                    radius: 12,
                    onClick: () async {
                      if (showAudio.value) {
                        widget.msg.player.stop();
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
                return Container(
                    // child: TDLoading(size: TDLoadingSize.large, icon: TDLoadingIcon.circle, iconColor: getThemeModel(context).colorModel.generalFillColor,)
                    );
              })
        ],
      ),
    );
  }

  Widget audioPlayWidget(double width) {
    bool rBreak = Responsive.checkWidth(width) == Responsive.lg;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<PlayerState>(
              stream: widget.msg.player.playerStateStream,
              builder: (context, snapshot) {
                final playingState = snapshot.data;
                final processingState = playingState?.processingState;
                final playing = playingState?.playing;
                var text = "";
                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  text = "加载中";
                } else if (processingState == ProcessingState.completed) {
                  text = "播放完成";
                } else if (playing == true) {
                  text = "播放中";
                } else {
                  text = "";
                }
                return ElevatedButton(
                  style: const ButtonStyle(
                      shadowColor:
                          MaterialStatePropertyAll(Colors.transparent)),
                  onPressed: () async {
                    if (processingState == ProcessingState.loading) return;
                    if (playing == true &&
                        processingState != ProcessingState.completed) {
                      widget.msg.player.pause();
                    } else {
                      if (processingState == ProcessingState.completed) {
                        await widget.msg.player.seek(Duration.zero, index: 0);
                      }
                      widget.msg.player.play();
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.multitrack_audio_rounded),
                      const Text(
                        "  语音",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(text)
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}
