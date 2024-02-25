class VideoCommentList {
  int? total;
  List<VideoCommentInfoModel>? result;

  VideoCommentList({this.total, this.result});

  VideoCommentList.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    if (json['result'] != null) {
      result = <VideoCommentInfoModel>[];
      json['result'].forEach((v) {
        result!.add(VideoCommentInfoModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VideoCommentInfoModel {
  String? content;
  String? author;
  String? authorId;
  double? timestamp;
  String? avatar;
  bool? verified;

  VideoCommentInfoModel(
      {this.content, this.author, this.authorId, this.timestamp, this.avatar, this.verified});

  VideoCommentInfoModel.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    author = json['author'];
    authorId = json['author_id'];
    timestamp = json['timestamp'];
    avatar = json['avatar'];
    verified = json['user_type'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['author'] = author;
    data['author_id'] = authorId;
    data['timestamp'] = timestamp;
    data['avatar'] = avatar;
    data['user_type'] = verified == true ? 1 : 0;
    return data;
  }
}
