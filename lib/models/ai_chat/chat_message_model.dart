import 'dart:typed_data';

import 'package:flutter/material.dart';

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
  Uint8List? audio;
  bool isMine = false;
  bool isFirst = false;
  ValueNotifier<bool> generateCompleted = ValueNotifier(false);
  ValueNotifier<int> audioIsPlaying = ValueNotifier(-1);

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
      await Future.delayed(const Duration(milliseconds: 100)).then((value) {
        message += msg[i];
        refresh();
      });
    }
  }
}
