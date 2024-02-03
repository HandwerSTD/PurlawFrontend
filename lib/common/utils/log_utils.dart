import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class Log {
  static bool printLog = true;
  static bool showLog = true;
  static String logs = "";
  static Logger logger = Logger(
    printer: PrettyPrinter(
      stackTraceBeginIndex: 1,
      methodCount: 3
    )
  );

  static void switchLogger() {
    showLog = !showLog;
  }
  static void append(message) {
    if (!showLog) return;
    logs += '$message\n';
  }
  static void i(message, {String? tag}) {
    message = "${tag??""}$message";
    if (!printLog) return;
    logger.i(message);
    append(message);
  }
  static void d(message, {String? tag}) {
    message = "${tag??""}$message";
    if (!printLog) return;
    logger.d(message);
    append(message);
  }
  static void e(message, {Object? error, String? tag}) {
    message = "[${tag??""}]$message";
    if (!printLog) return;
    logger.e(message, error: error);
    append(message); append(error);
  }
}

class LoggerPage extends StatelessWidget {
  const LoggerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(child: Text(Log.logs))
            ],
          )
        ],
      ),
    );
  }
}
