import 'package:purlaw/common/utils/database/kvstore.dart';

class DatabaseUtil {
  static bool isFirstOpen() {
    return KVBox.query(DatabaseConst.firstOpen).isEmpty;
  }
  static void setFirstOpen() {
    KVBox.insert(DatabaseConst.firstOpen, DatabaseConst.dbTrue);
    KVBox.insert(DatabaseConst.themeColor, "#ca80ba");
    storeServerAddress("http://100.86.9.47:5000");
  }

  static void updateThemeColor(String color) {
    KVBox.insert(DatabaseConst.themeColor, color);
  }
  static String getThemeColor() => KVBox.query(DatabaseConst.themeColor);

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
}

class DatabaseConst {
  // Basic consts
  static const String dbTrue = "true";
  static const String dbFalse = "false";

  // Preferences
  static const String firstOpen = "IS_FIRST_OPEN";
  static const String themeColor = "THEME_COLOR";

  // User login info
  static const String userCookie = "USER_COOKIE";
  static const String userLoginName = "USER_LOGIN_NAME";
  static const String userPasswdSha1 = "USER_PASSWD";

  // AI Chat
  static const String aiChatMsg = "AI_CHAT_MSG";

  // Debug Settings
  static const String serverAddress = "SERVER_ADDRESS";
}