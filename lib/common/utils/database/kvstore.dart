import 'package:hive_flutter/hive_flutter.dart';

class KVBox {
  static const defaultBox = "myBox";
  static const historyChats = "historyChatBox";

  static Future setupLocator() async {
    await Hive.initFlutter();
    await Hive.openBox(defaultBox);
    await Hive.openLazyBox(historyChats);
  }
  static void insert(String key, String value, {String useBox = KVBox.defaultBox}) {
    var box = Hive.box(useBox);
    box.put(key, value);
  }
  static String query(String key, {String useBox = KVBox.defaultBox}) {
    var box = Hive.box(useBox);
    return box.get(key, defaultValue: "");
  }
}