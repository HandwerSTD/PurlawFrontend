import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/method_channels/method_channels.dart';

const speechMessageChannel = EventChannel('com.tianzhu.purlaw/message');

class SpeechToTextUtil {
  static Future<String> getResult({required String filename}) async {
    final result = await callJavaFunction('speechToText', {
      'filename': filename,
      'modelPath': ModelCopyFilesUtils.localPath.absolute.path
    });
    return result;
  }
  static Stream getStream() {
    return speechMessageChannel.receiveBroadcastStream();
  }
}
