import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:purlaw/common/utils/database/kvstore.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';

/// 数据库结构：{ key: value }
class DatabaseUtil {
  static bool isFirstOpen() {
    return KVBox.query(DatabaseConst.firstOpen).isEmpty;
  }
  static void setFirstOpen() {
    KVBox.insert(DatabaseConst.firstOpen, DatabaseConst.dbTrue);
    KVBox.insert(DatabaseConst.themeColor, "0");
    KVBox.insert(DatabaseConst.autoAudioPlay, DatabaseConst.dbFalse);
    storeServerAddress("http://100.86.9.47:5000");
  }

  static void updateThemeIndex(int color) {
    KVBox.insert(DatabaseConst.themeColor, color.toString());
  }
  static int getThemeIndex() => int.parse(KVBox.query(DatabaseConst.themeColor));

  static void storeCookie(String cookie) {
    KVBox.insert(DatabaseConst.userCookie, cookie);
  }
  static String getCookie() => KVBox.query(DatabaseConst.userCookie);
  static void storeUserNamePasswd(String name, String passwd) {
    KVBox.insert(DatabaseConst.userLoginName, name);
    KVBox.insert(DatabaseConst.userPasswdSha1, passwd);
  }
  static (String, String) getUserNamePasswd() => (KVBox.query(DatabaseConst.userLoginName), KVBox.query(DatabaseConst.userPasswdSha1));

  static void storeLastAIChatSession(String sid) {
    KVBox.insert(DatabaseConst.lastChatSession, sid);
  }
  static String getLastAIChatSession() => KVBox.query(DatabaseConst.lastChatSession);

  static String getServerAddress() => KVBox.query(DatabaseConst.serverAddress);
  static void storeServerAddress(String server) {
    KVBox.insert(DatabaseConst.serverAddress, server);
  }
  static bool get getAutoAudioPlay => KVBox.query(DatabaseConst.autoAudioPlay) == DatabaseConst.dbTrue;
}

/// 数据库结构：{ timestamp: data }
class HistoryDatabaseUtil {
  static Future<void> clearHistory() async {
    var box = await Hive.openLazyBox(KVBox.historyChats);
    await box.clear();
  }
  static void storeHistory(String value) async {
    var box = await Hive.openLazyBox(KVBox.historyChats);
    box.put(TimeUtils.timestamp, value);
    box.flush();
  }
  static Future<List<(int, String)>> listHistory() async {
    var box = await Hive.openLazyBox(KVBox.historyChats);
    var result = <(int, String)>[];
    for (var key in box.keys) {
      result.add((key, await box.get(key)));
    }
    return result;
  }
  static Future<void> deleteHistory(int value) async {
    var box = await Hive.openLazyBox(KVBox.historyChats);
    await box.delete(value);
  }
}

/// 数据库结构：
///
/// favoriteVideosIndex = { uid: "true" / "" }
///
/// favoriteVideos = { uid: data }
class FavoriteDatabaseUtil {
  static Future<LazyBox> getBox() {
    return Hive.openLazyBox(KVBox.favoriteVideos);
  }
  static void storeFavorite(VideoInfoModel video, bool toState) async {
    var box = await getBox();
    KVBox.insert(video.uid!, (toState ? DatabaseConst.dbTrue : ""), useBox: KVBox.favoriteVideosIndex);
    if (!toState) {
      // delete
      box.delete(video.uid!);
    } else {
      // add
      box.put(video.uid!, jsonEncode(video.toJson()));
    }
  }
  static Future<List<String>> listFavorite() async {
    var box = await getBox();
    var result = <String>[];
    for (var key in box.keys) {
      result.add((await box.get(key)));
    }
    return result;
  }
  static bool getIsFavorite(String uid) {
    return KVBox.query(uid, useBox: KVBox.favoriteVideosIndex).isNotEmpty;
  }
}

/// 数据库结构：
///
/// sessionListsIndex = { sid: name }
///
/// sessionLists = { sid: data }
class SessionListDatabaseUtil {
  static Future<LazyBox> getBox() {
    return Hive.openLazyBox(KVBox.sessionLists);
  }
  static void add(String name, String sid) {
    KVBox.insert(sid, name, useBox: KVBox.sessionListsIndex);
  }
  static void storeSessionList(List<(String, String)> res) async {
    await clear();
    for (var item in res) {
      Hive.box(KVBox.sessionListsIndex).put(item.$1, item.$2);
    }
    Log.i("sessionList stored", tag: "SessionList DatabaseUtil");
  }
  static Future<void> storeHistoryBySid(String sid, String val) async {
    var box = await getBox();
    await box.put(sid, val);
    Log.i("SID $sid saved.", tag: "SessionList DatabaseUtil");
  }
  /// 返回格式：(sid, name)
  static Future<List<(String, String)>> getList() async {
    var result = <(String, String)>[];
    var indexBox = Hive.box(KVBox.sessionListsIndex);
    for (var sid in indexBox.keys) {
      result.add((sid, indexBox.get(sid)));
    }
    return result;
  }
  /// 返回 json 格式的纯文本
  static Future<String> getHistoryBySid(String sid) async {
    var box = await getBox();
    return await box.get(sid, defaultValue: "");
  }
  static Future<void> delete(String sid) async {
    var box = await getBox();
    await box.delete(sid);
    await Hive.box(KVBox.sessionListsIndex).delete(sid);
  }
  static Future<void> clear() async {
    await (await getBox()).clear();
    await Hive.box(KVBox.sessionListsIndex).clear();
  }
}

// 暂时用不着
// /// 数据库结构
// ///
// /// privateMessageList = { uid: name }
// ///
// /// privateMessageData = { uid: data }
// class PrivateMessageDatabaseUtil {
//   static Future<LazyBox> getBox() {
//     return Hive.openLazyBox(KVBox.privateMessageData);
//   }
//   static void addNewPM(String uid, String name) {
//     KVBox.insert(uid, name, useBox: KVBox.privateMessageList);
//   }
//   static void storePMList(List<(String, String)> res) async {
//     await clear();
//     for (var item in res) {
//       Hive.box(KVBox.privateMessageList).put(item.$1, item.$2);
//     }
//     Log.i("privateMessageList stored (refresh)", tag: "PrivateMessage DatabaseUtil");
//   }
//   static Future<void> storePMByUid(String uid, String val) async {
//     var box = await getBox();
//     await box.put(uid, val);
//     Log.i("UID $uid saved.", tag: "PrivateMessage DatabaseUtil");
//   }
//   /// 返回格式：(uid, name)
//   static Future<List<(String, String)>> getList() async {
//     var result = <(String, String)>[];
//     var indexBox = Hive.box(KVBox.privateMessageList);
//     for (var sid in indexBox.keys) {
//       result.add((sid, indexBox.get(sid)));
//     }
//     return result;
//   }
//   /// 返回 json 格式的纯文本
//   static Future<String> getHistoryByUid(String uid) async {
//     var box = await getBox();
//     return await box.get(uid, defaultValue: "");
//   }
//   static Future<void> delete(String uid) async {
//     var box = await getBox();
//     await box.delete(uid);
//     await Hive.box(KVBox.privateMessageList).delete(uid);
//   }
//   static Future<void> clear() async {
//     await (await getBox()).clear();
//     await Hive.box(KVBox.privateMessageList).clear();
//   }
// }

class DatabaseConst {
  // Basic consts
  static const String dbTrue = "true";
  static const String dbFalse = "false";

  // Preferences
  static const String firstOpen = "IS_FIRST_OPEN";
  static const String themeColor = "THEME_COLOR";
  static const String autoAudioPlay = "AUTO_AUDIO_PLAY";

  // User login info
  static const String userCookie = "USER_COOKIE";
  static const String userLoginName = "USER_LOGIN_NAME";
  static const String userPasswdSha1 = "USER_PASSWD";

  // AI Chat
  static const String lastChatSession = "AI_CHAT_MSG";

  // Debug Settings
  static const String serverAddress = "SERVER_ADDRESS";
}