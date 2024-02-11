import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:purlaw/common/utils/log_utils.dart';

import '../../components/purlaw/chat_message_block.dart';
import '../../components/third_party/modified_just_audio.dart';

/// 单条对话的信息，适用于 AI 对话
class ListAIChatMessageModels {
  List<AIChatMessageModel>? messages;

  ListAIChatMessageModels({this.messages});

  ListAIChatMessageModels.fromJson(Map<String, dynamic> json) {
    if (json['AIChatMessageModel'] != null) {
      messages = <AIChatMessageModel>[];
      json['AIChatMessageModel'].forEach((v) {
        messages!.add(AIChatMessageModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (messages != null) {
      data['AIChatMessageModel'] =
          messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AIChatMessageModel {
  String message = "";
  bool isMine = false;
  bool isFirst = false;

  AIChatMessageModel({this.message = "", this.isMine = false, this.isFirst = false});

  AIChatMessageModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    isMine = json['isMine'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['isMine'] = isMine;
    return data;
  }

  Future<void> append(String msg, Function refresh) async {
    for (int i = 0; i < msg.length; ++i) {
      await Future.delayed(const Duration(milliseconds: 50)).then((value) {
        message += msg[i];
        refresh();
      });
    }
  }
}

class ListAIChatMessageModelsWithAudio {
  late List<AIChatMessageModelWithAudio> messages;

  ListAIChatMessageModelsWithAudio({required this.messages});

  ListAIChatMessageModelsWithAudio.fromDb(ListAIChatMessageModels model) {
    messages = [];
    messages.addAll(model.messages!.map((e) => AIChatMessageModelWithAudio.fromFull(
      e.message, e.isMine, first: e.isFirst
    )));
  }
  ListAIChatMessageModels export() {
    ListAIChatMessageModels result = ListAIChatMessageModels(messages: []);
    result.messages!.addAll(messages.map((e) {
      var message = "";
      for (var it in e.sentences) {
        message += it;
      }
      return AIChatMessageModel(message: message, isFirst: e.isFirst, isMine: e.isMine);
    }));
    return result;
  }
}

class AIChatMessageModelWithAudio {
  List<String> sentences = [];
  String showedText = "";
  List<bool> sentenceCompleted = [];
  bool isMine = false;
  bool isFirst = false;
  ValueNotifier<bool> generateCompleted = ValueNotifier(false);
  AudioPlayer player = AudioPlayer();
  final playlist = ConcatenatingAudioSource(children: []);

  AIChatMessageModelWithAudio();

  Future<void> animatedAdd(String msg, Function refresh) async {
    for (var ch in msg.split('')) {
      await Future.delayed(Duration(milliseconds: 50));
      showedText += ch;
      refresh();
    }
  }

  AIChatMessageModelWithAudio.fromFull(String msg, bool mine, {bool first = false}) {
    sentences.add(msg);
    isMine = mine;
    isFirst = first;
  }

  Future<void> append(String msg, bool completed, Function refresh, Function(String, int) submit) async {
    if (sentences.isEmpty || sentenceCompleted.last) {
      // await animatedAdd(msg, refresh);
      sentences.add(msg);
      refresh();
      sentenceCompleted.add(completed);
      if (completed) {
        // submit to request
        sentences.last += '。';
        submit(sentences.last, sentences.length);
        Log.d("Submit to request ${sentences.length}: ${sentences.last}", tag: "Chat Model Append");
      }
      refresh();
      return;
    }
    // await animatedAdd(msg, refresh);
    sentences.last += (msg);
    refresh();
    sentenceCompleted.last = completed;
    if (completed) {
      // submit to request
      sentences.last += '。';
      submit(sentences.last, sentences.length);
      Log.d("Submit to request ${sentences.length}: ${sentences.last}", tag: "Chat Model Append");
    }
    refresh();
  }

  String getString() {
    var result = "";
    for (var str in sentences) {
      result += str;
    }
    return result;
  }
}
