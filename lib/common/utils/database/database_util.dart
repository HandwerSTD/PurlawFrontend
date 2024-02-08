import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:purlaw/common/utils/database/kvstore.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';

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

  static void storeLastAIChatMsg(String result) {
    KVBox.insert(DatabaseConst.aiChatMsg, result);
  }
  static String getLastAIChatMsg() => KVBox.query(DatabaseConst.aiChatMsg);

  static String getServerAddress() => KVBox.query(DatabaseConst.serverAddress);
  static void storeServerAddress(String server) {
    KVBox.insert(DatabaseConst.serverAddress, server);
  }
  static bool get getAutoAudioPlay => KVBox.query(DatabaseConst.autoAudioPlay) == DatabaseConst.dbTrue;
}

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
  static const String aiChatMsg = "AI_CHAT_MSG";

  // Debug Settings
  static const String serverAddress = "SERVER_ADDRESS";
}