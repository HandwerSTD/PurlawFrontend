import 'dart:convert';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:async/async.dart';

import '../../models/ai_chat/chat_message_model.dart';

class PurlawChatMessageBlock extends StatefulWidget {
  final AIChatMessageModel msg;
  const PurlawChatMessageBlock({required this.msg, super.key});

  @override
  State<PurlawChatMessageBlock> createState() => _PurlawChatMessageBlockState();
}

class _PurlawChatMessageBlockState extends State<PurlawChatMessageBlock> {
  AudioPlayer audioPlayer = AudioPlayer();
  CancelableOperation? audioFuture;
  ValueNotifier<int> playedProgress = ValueNotifier(-1);
  ValueNotifier<bool> showAudio = ValueNotifier(false);
  int totalLength = 0;

  @override
  void initState() {
    super.initState();
    widget.msg.audioIsPlaying.value = -1;
    audioPlayer.onPlayerComplete.listen((event) {
      widget.msg.audioIsPlaying.value = 3;
      audioPlayer.seek(Duration.zero);
    });
    audioPlayer.onPositionChanged.listen((event) {
      playedProgress.value = event.inSeconds;
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    audioFuture?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return chatMessageBlock(context, widget.msg, audioPlayer);
  }

  Widget chatMessageBlock(BuildContext context, AIChatMessageModel msgData,
      AudioPlayer audioPlayer) {
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
                        BoxShadow(color: Colors.black12, blurRadius: 5),
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
                        (msgData.message == "" ? "思考中..." : msgData.message),
                        // softWrap: true,
                        style: TextStyle(
                            color: foreground, height: 1.5, fontSize: 15),
                      ),
                      if (!msgData.isMine)
                        {
                          Padding(
                            padding: EdgeInsets.only(top: 4),
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
                    margin: EdgeInsets.only(right: 16, bottom: 8),
                    height: 24,
                    width: 24,
                    radius: 12,
                    onClick: () {
                      if (showAudio.value) {
                        audioFuture?.cancel();
                        audioPlayer.stop();
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
              playAudio();
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
                      if (value == 0) return Text("加载中");
                      if (value == 1) return Text("播放中");
                      if (value == 2) return Text("已暂停");
                      if (value == 3) return Text("播放完毕");
                      if (value == -2) return Text("加载失败");
                      return Text("");
                    }),
              ],
            ),
          ),
          ValueListenableBuilder(
              valueListenable: playedProgress,
              builder: (context, progress, child) {
                if (progress == -1) return Container();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ProgressBar(
                          progress: Duration(seconds: progress),
                          total: Duration(seconds: totalLength),
                          onSeek: (dur) {
                            audioPlayer.seek(dur);
                          },
                          timeLabelTextStyle: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(height: 2.1),
                          thumbRadius: 8,
                          thumbGlowRadius: 16,
                        ),
                      ),
                      // Text("  " + TimeUtils.getDurationTimeString(Duration(seconds: progress), Duration(seconds: totalLength)))
                    ],
                  ),
                );
              })
        ],
      ),
    );
  }

  void playAudio() async {
    // network loading
    if (widget.msg.audioIsPlaying.value == 0) return;
    try {
      // first load
      if (widget.msg.audioIsPlaying.value == -1 ||
          widget.msg.audioIsPlaying.value == -2) {
        widget.msg.audioIsPlaying.value = 0;
        try {
          if (widget.msg.audio == null) {
            // load from network

            audioFuture = CancelableOperation.fromFuture(
                HttpGet.postGetBodyBytes(
                    API.chatRequestVoice.api,
                    HttpGet.jsonHeadersCookie(
                        getCookie(context, listen: false)),
                    {"voice_text": widget.msg.message}), onCancel: () {
              print("[Network] canceled");
            });
            var response = await audioFuture?.valueOrCancellation(null);
            if (response == null) return;
            print("[DEBUG] voice got");
            try {
              var failedBody = Utf8Decoder().convert(response);
              // failed
              print(failedBody);
            } catch (e) {
              // success
              widget.msg.audio = response;
              await audioPlayer.setSource(BytesSource(widget.msg.audio!));
              totalLength = (await audioPlayer.getDuration())!.inSeconds;
              audioPlayer.play(BytesSource(widget.msg.audio!));
              widget.msg.audioIsPlaying.value = 1;
            }
          } else {
            // load from local
            await audioPlayer.setSource(BytesSource(widget.msg.audio!));
            totalLength = (await audioPlayer.getDuration())!.inSeconds;
            audioPlayer.play(BytesSource(widget.msg.audio!));
            widget.msg.audioIsPlaying.value = 1;
          }
          return;
        } catch (e) {
          print(e);
          widget.msg.audioIsPlaying.value = -2;
        }
      }
      // playing
      if (widget.msg.audioIsPlaying.value == 1) {
        widget.msg.audioIsPlaying.value = 2;
        audioPlayer.pause();
        return;
      }
      // paused
      if (widget.msg.audioIsPlaying.value == 2) {
        widget.msg.audioIsPlaying.value = 1;
        audioPlayer.resume();
        return;
      }
      // completed
      if (widget.msg.audioIsPlaying.value == 3) {
        widget.msg.audioIsPlaying.value = 1;
        audioPlayer.play(BytesSource(widget.msg.audio!));
      }
    } on Exception catch (e) {
      print(e);
      if (context.mounted) {
        TDToast.showText("播放失败", context: context);
      }
    }
  }
}
