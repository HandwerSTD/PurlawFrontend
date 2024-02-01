class VideoCommentList {
  int? total;
  List<VideoCommentInfoModel>? result;

  VideoCommentList({this.total, this.result});

  VideoCommentList.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    if (json['result'] != null) {
      result = <VideoCommentInfoModel>[];
      json['result'].forEach((v) {
        result!.add(new VideoCommentInfoModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
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

  VideoCommentInfoModel(
      {this.content, this.author, this.authorId, this.timestamp, this.avatar});

  VideoCommentInfoModel.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    author = json['author'];
    authorId = json['author_id'];
    timestamp = json['timestamp'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['author'] = this.author;
    data['author_id'] = this.authorId;
    data['timestamp'] = this.timestamp;
    data['avatar'] = this.avatar;
    return data;
  }
}
