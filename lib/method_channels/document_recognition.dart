import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/method_channels/method_channels.dart';

class DocumentRecognition {
  static Future<List<String>> getResult(XFile file) async {
    final res = await callJavaFunction('documentRecognition', {
      'filename': file.path,
      'ocrModelPath': OCRModelCopyFilesUtils.localPath.absolute.path
    });
    List<String> result = [];
    for (var v in res) {
      result.add(v!.toString());
    }
    return result;
  }
}