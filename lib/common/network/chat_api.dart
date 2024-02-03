import 'dart:convert';
import 'dart:isolate';

import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/log_utils.dart';

import '../constants/constants.dart';

class ChatNetworkRequest {


  static late Isolate isolate;

  static Future<void> submitNewMessage(
      String text, String cookie, Function(String dt) append) async {
    var response = jsonDecode(await HttpGet.post(
        API.chatCreateSession.api,
        HttpGet.jsonHeadersCookie(cookie),
        ({"type": "ask", "data": text})).timeout(const Duration(seconds: 10)));
    Log.i(response);
    String session = response["session_id"];
    Log.i(session);
    await isolateFlushSession(append,
        session: session, cookie: cookie, callback: () {});
  }

  static Future isolateFlushSession(Function(String dt) append,
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
          message = message.replaceAll("<EOF>", "");
          await append(message);
          Log.i("[ChatAPI] Isolate killed");
          isolate.kill(priority: Isolate.immediate);
          callback();
        } else if (message.startsWith("<H_ERR>")) {
          // 出现错误
          Log.i("[ChatAPI] Isolate killed due to error");
          isolate.kill(priority: Isolate.immediate);
          throw Exception(message.replaceAll("<H_ERR>", ""));
        } else {
          if (start && message.startsWith('\n')) {
            message = message.replaceAll('\n', '');
            start = false;
          }
          await append(message);
        }
      }
      if (message is SendPort) {
        Log.i("[ChatAPI] sendPort got");
        message.send({"cookie": cookie, "session": session});
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
      try {
        while (true) {
          // var value = await http
          //     .post(Uri.parse(serverAddress + API.chatFlushSession.api),
          //     headers: jsonHeadersWithCookie(cookie),
          //     body: jsonEncode({"session_id": session}));
          // var chatRes = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
          var chatRes = jsonDecode(await HttpGet.post(API.chatFlushSession.api,
              HttpGet.jsonHeadersCookie(cookie), {"session_id": session}));
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
        sp.send("<H_ERR>$err");
      } finally {
        sp.send("<H_EOF>");
      }
    });
  }
}
