
/// 服务器 API 合集
enum API {
  videoFile("/video/"),
  videoUpload("/api/video/upload_video"),
  videoSearch("/api/video/search"),
  videoInfo("/api/video/info"),
  videoCover("/api/cover/"),
  videoLikeIt("/api/video/like"),
  videoIsLiked("/api/video/is_like"),
  videoRecommended("/api/video/random"),

  commentSubmit("/api/comment/commit_comment"),
  commentList("/api/comment/list_comment"),

  userRegister("/api/user/register"),
  userLogin("/api/user/login"),
  userInfo("/api/user/info"),
  userSearch("/api/user/search"),
  userAvatar("/api/avatar/"),
  userUploadAvatar("/api/user/upload_avatar"),
  userListVideo("/api/video/list_video"),

  chatCreateSession("/api/chat/create_session"),
  chatFlushSession("/api/chat/flush_session"),
  chatRequestVoice("/api/voice/request_voice");

  const API(this.api);
  final String api;
}

/// 全局常量
class Constants {
  /// 视频分页，单页数量
  static const videosPerPage = 10;

  /// 评论区分页，单页数量
  static const commentsPerPage = 20;

  /// 生成对话的第一句输出
  static const firstOutput = "您好，我是您的专属 AI 律师顾问紫小藤！我可以提供各种信息，或者回答一些法律问题。有什么问题想问的？";
}