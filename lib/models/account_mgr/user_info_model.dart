class UserInfoModel {
  String avatar;
  String uid;
  String user;
  String desc;
  bool verified;

  UserInfoModel({required this.avatar, required this.uid, required this.user, required this.desc, required this.verified});

  static UserInfoModel fromJson(Map<String, dynamic> json) {
    var avatar = json['avatar'];
    var uid = json['uid'];
    var user = json['user'];
    var desc = json['user_info'];
    bool verified = json['user_type'] == 1;
    return UserInfoModel(avatar: avatar, uid: uid, user: user, desc: desc, verified: verified);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['uid'] = uid;
    data['user'] = user;
    data['user_info'] = desc;
    data['user_type'] = (verified ? 1 : 0);
    return data;
  }
}

class MyUserInfoModel {
  String avatar;
  String uid;
  String user;
  String cookie;
  String desc;
  bool verified;

  MyUserInfoModel({required this.avatar, required this.uid, required this.user, required this.cookie, required this.desc, required this.verified});

  static MyUserInfoModel fromJson(Map<String, dynamic> json, String cookie) {
    var avatar = json['avatar'];
    var uid = json['uid'];
    var user = json['user'];
    var desc = json['user_info'];
    bool verified = json['user_type'] == 1;
    return MyUserInfoModel(avatar: avatar, uid: uid, user: user, cookie: cookie, desc: desc, verified: verified);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['uid'] = uid;
    data['user'] = user;
    data['user_info'] = desc;
    data['user_type'] = (verified ? 1 : 0);
    return data;
  }

  bool valid() {
    return avatar.isNotEmpty && uid.isNotEmpty && user.isNotEmpty && cookie.isNotEmpty;
  }

  UserInfoModel toGeneralModel() {
    return UserInfoModel(avatar: avatar, uid: uid, user: user, desc: desc, verified: verified);
  }
}
