class VideoList {
  List<VideoInfoModel>? result;

  VideoList({this.result});

  VideoList.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <VideoInfoModel>[];
      json['result'].forEach((v) {
        result!.add(new VideoInfoModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VideoInfoModel {
  String? uid;
  String? title;
  String? description;
  String? author;
  String? authorId;
  int? like;
  int meLiked = -1; // -1: undefined; 0: false; 1 : true
  String? tags;
  String? commentsId;
  String? sha1;
  String? coverSha1;
  double? coverRatio;
  double? timestamp;
  String? avatar;

  VideoInfoModel(
      {this.uid,
        this.title,
        this.description,
        this.author,
        this.authorId,
        this.like,
        this.tags,
        this.commentsId,
        this.sha1,
        this.coverSha1,
        this.timestamp,
        this.avatar});

  VideoInfoModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    title = json['title'];
    description = json['description'];
    author = json['author'];
    authorId = json['author_id'];
    like = json['like'];
    tags = json['tags'];
    commentsId = json['comments_id'];
    sha1 = json['sha1'];
    coverSha1 = json['cover_sha1'];
    timestamp = json['timestamp'];
    avatar = json['avatar'];
    coverRatio = json['cover_height'] / json['cover_width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['title'] = this.title;
    data['description'] = this.description;
    data['author'] = this.author;
    data['author_id'] = this.authorId;
    data['like'] = this.like;
    data['tags'] = this.tags;
    data['comments_id'] = this.commentsId;
    data['sha1'] = this.sha1;
    data['cover_sha1'] = this.coverSha1;
    data['timestamp'] = this.timestamp;
    data['avatar'] = this.avatar;
    return data;
  }
}
