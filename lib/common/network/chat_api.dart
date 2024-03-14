import 'dart:convert';
import 'dart:isolate';

import 'package:grock/grock.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/log_utils.dart';

import '../constants/constants.dart';

class ChatNetworkRequest {


  static Isolate? isolate;

  static Future<void> submitNewMessage(
      String session, String text, String cookie, Future<void> Function(String dt, String cookie) append, Function callback) async {
    var response = jsonDecode(await HttpGet.post(
        API.chatAppendSession.api,
        HttpGet.jsonHeadersCookie(cookie),
        ({"sid": session, "content": text})).timeout(const Duration(seconds: 10)));
    Log.i(response);
    if (response["status"] != "success") {
      if (response["message"].toString().contains('sid')) {
        throw Exception("session error");
      }
      throw Exception(response["message"]);
    }
    await Future.delayed(500.milliseconds); // 等待服务器刷新延迟
    await isolateFlushSession(append,
        session: session, cookie: cookie, callback: callback);
  }

  static Future isolateFlushSession(Future<void> Function(String dt, String cookie) append,
      {required String session,
      required String cookie,
      required Function callback}) async {
    final response = ReceivePort();
    isolate = await Isolate.spawn(flushSession, response.sendPort);
    bool start = true;
    response.listen((message) async {
      if (message is String) {
        if (message.endsWith("<H_EOF>")) {
          // 到达结尾
          message = message.replaceAll("<H_EOF>", "");
          await append(message, cookie);
          Log.i("[ChatAPI] Isolate killed");
          isolate?.kill(priority: Isolate.immediate);
          callback();
        } else if (message.startsWith("<H_ERR>")) {
          // 出现错误
          Log.e("[ChatAPI] Isolate killed due to error");
          isolate?.kill(priority: Isolate.immediate);
          throw Exception(message.replaceAll("<H_ERR>", ""));
        } else {
          if (start && message.startsWith('\n')) {
            message = message.replaceAll('\n', '');
            start = false;
          }
          await append(message, cookie);
        }
      }
      if (message is SendPort) {
        Log.i("[ChatAPI] sendPort got");
        try {
          message.send({"cookie": cookie, "session": session, "address": HttpGet.baseUrl});
        } on Exception catch (e) {
          Log.e("Send message failed", error: e, tag: "Chat API");
        }
      }
    });
  }

  static void flushSession(SendPort sp) {
    ReceivePort receivePort = ReceivePort();
    sp.send(receivePort.sendPort);
    String cookie = "", session = "";
    receivePort.listen((message) async {
      cookie = message["cookie"];
      session = message["session"];
      HttpGet.switchBaseUrl(message["address"]);
      Log.d("Received message from Main $session", tag: "ChatAPI");
      try {
        while (true) {
          await Future.delayed(3000.milliseconds);
          var chatRes = jsonDecode(await HttpGet.post(API.chatFlushSession.api,
              HttpGet.jsonHeadersCookie(cookie), {"sid": session}));
          Log.i(chatRes);
          if (chatRes["status"] != "success") {
            throw Exception(chatRes["message"]);
          }
          if ((chatRes["data"] as String).endsWith("<EOF>")) {
            // 最后一条信息
            sp.send((chatRes["data"].toString().replaceAll("<EOF>", "")));
            break;
          }
          sp.send((chatRes["data"].toString()));
        }
      } catch (err) {
        Log.e(tag:"ChatAPI", err);
        sp.send("<H_ERR>err: $err");
      } finally {
        sp.send("<H_EOF>");
      }
    });
  }
}
