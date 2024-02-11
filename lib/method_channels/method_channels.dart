import 'package:flutter/services.dart';

import '../common/utils/log_utils.dart';

// 定义一个常量作为channel名称
const platform = MethodChannel('com.tianzhu.purlaw/channel');

// 调用Java函数并传递参数
Future<String> callJavaFunction(String methodName, Map<String, dynamic> parameter) async {
  try {
    // 发送消息到原生平台
    final result = await platform.invokeMethod(methodName, parameter);
    return result;
  } catch (e) {
    Log.e("Error calling function: $e", tag: "Method Channel");
    return "Error";
  }
}