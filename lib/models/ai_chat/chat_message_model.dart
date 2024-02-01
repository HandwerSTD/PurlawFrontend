/// 单条对话的信息，适用于 AI 对话
class ListAIChatMessageModels {
  List<AIChatMessageModel>? messages;

  ListAIChatMessageModels({this.messages});

  ListAIChatMessageModels.fromJson(Map<String, dynamic> json) {
    if (json['AIChatMessageModel'] != null) {
      messages = <AIChatMessageModel>[];
      json['AIChatMessageModel'].forEach((v) {
        messages!.add(new AIChatMessageModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.messages != null) {
      data['AIChatMessageModel'] =
          this.messages!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['isMine'] = this.isMine;
    return data;
  }

  Future<void> append(String msg, Function refresh) async {
    for (int i = 0; i < msg.length; ++i) {
      await Future.delayed(Duration(milliseconds: 100)).then((value) {
        message += msg[i];
        refresh();
      });
    }
  }
}
