import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:purlaw/common/utils/misc.dart';

class Log {
  static bool saveLog = true;
  static bool printLog = true;
  static String logs = "";
  static Logger logger = Logger(
    printer: PrettyPrinter(
      stackTraceBeginIndex: 1,
      methodCount: 3
    )
  );

  static void switchLogger() {
    printLog = !printLog;
    logs += ("\n-----------Logger turned to $printLog at ${TimeUtils.formatDateTime(TimeUtils.timestamp)}------------\n");
  }
  static void switchSaver() {
    saveLog = !saveLog;
    logs += ("\n-----------Switched to $saveLog at ${TimeUtils.formatDateTime(TimeUtils.timestamp)}------------\n");
  }
  static void append(message) {
    if (!saveLog) return;
    logs += '${TimeUtils.formatDateTime(TimeUtils.timestamp)}\n$message\n';
  }
  static void i(message, {String? tag}) {
    message = "[${tag??""}] $message";
    if (!printLog) return;
    logger.i(message);
    append(message);
  }
  static void d(message, {String? tag}) {
    message = "[${tag??""}] $message";
    if (!printLog) return;
    logger.d(message);
    append(message);
  }
  static void e(message, {Object? error, String? tag}) {
    message = "[${tag??""}] $message";
    if (!printLog) return;
    logger.e(message, error: error);
    append(message); append(error);
  }
}


class LoggerPage extends StatefulWidget {
  const LoggerPage({super.key});

  @override
  State<LoggerPage> createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("日志"),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              Log.switchSaver();
            });
          }, icon: const Icon(Icons.switch_camera_outlined)),
          IconButton(onPressed: (){
            setState(() {
              Log.switchLogger();
            });
          }, icon: const Icon(Icons.closed_caption_disabled_outlined))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(child: SelectableText(Log.logs, style: const TextStyle(
                  fontFamily: 'Monospace'
                ),))
              ],
            )
          ],
        ),
      ),
    );
  }
}
