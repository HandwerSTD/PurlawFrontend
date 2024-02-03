class UserInfoModel {
  String avatar;
  String uid;
  String user;

  UserInfoModel({required this.avatar, required this.uid, required this.user});

  static UserInfoModel fromJson(Map<String, dynamic> json) {
    var avatar = json['avatar'];
    var uid = json['uid'];
    var user = json['user'];
    return UserInfoModel(avatar: avatar, uid: uid, user: user);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['uid'] = uid;
    data['user'] = user;
    return data;
  }
}

class MyUserInfoModel {
  String avatar;
  String uid;
  String user;
  String cookie;

  MyUserInfoModel({required this.avatar, required this.uid, required this.user, required this.cookie});

  static MyUserInfoModel fromJson(Map<String, dynamic> json, String cookie) {
    var avatar = json['avatar'];
    var uid = json['uid'];
    var user = json['user'];
    return MyUserInfoModel(avatar: avatar, uid: uid, user: user, cookie: cookie);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['uid'] = uid;
    data['user'] = user;
    return data;
  }

  bool valid() {
    return avatar.isNotEmpty && uid.isNotEmpty && user.isNotEmpty && cookie.isNotEmpty;
  }

  UserInfoModel toGeneralModel() {
    return UserInfoModel(avatar: avatar, uid: uid, user: user);
  }
}
