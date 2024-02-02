import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:purlaw/models/account_mgr/user_info_model.dart';

import '../constants/constants.dart';
import '../utils/database/database_util.dart';

/// 对 HTTP 网络请求的二次封装
class HttpGet {
  static String baseUrl = "http://100.86.9.47:5000";
  static int HTTP_OK = 200;

  static switchBaseUrl(String newUrl) {
    baseUrl = newUrl;
  }

  static String getApi(String api) => (baseUrl + api);
  static const jsonHeaders = {"content-type": "application/json"};
  static jsonHeadersCookie(String cookie) =>
      {"content-type": "application/json", "cookie": cookie};

  static Future<String> get(String api, Map<String, String> headers) async {
    var response = await http.get(Uri.parse(getApi(api)), headers: headers);
    if (response.statusCode != HTTP_OK)
      throw HttpException(response.statusCode.toString());
    return const Utf8Decoder().convert(response.bodyBytes);
  }

  static Future<(String, String?)> postGetCookie(String api,
      Map<String, String> headers, Map<String, dynamic> body) async {
    var response = await http.post(Uri.parse(getApi(api)),
        headers: headers, body: jsonEncode(body)).timeout(Duration(seconds: 10));
    if (response.statusCode != HTTP_OK)
      throw HttpException(response.statusCode.toString());
    return (
      const Utf8Decoder().convert(response.bodyBytes),
      response.headers["set-cookie"]
    );
  }

  static Future<String> post(String api, Map<String, String> headers,
      Map<String, dynamic> body) async {
    var response = await http.post(Uri.parse(getApi(api)),
        headers: headers, body: jsonEncode(body)).timeout(Duration(seconds: 10));
    if (response.statusCode != HTTP_OK)
      throw HttpException(response.statusCode.toString());
    return const Utf8Decoder().convert(response.bodyBytes);
  }
  static Future<Uint8List> postGetBodyBytes(String api, Map<String, String> headers,
      Map<String, dynamic> body) async {
    print("getting bytes");
    var response = await http.post(Uri.parse(getApi(api)),
        headers: headers, body: jsonEncode(body));
    if (response.statusCode != HTTP_OK)
      throw HttpException(response.statusCode.toString());
    return (response.bodyBytes);
  }
}

/// 部分常用网络请求数据封装
class NetworkRequest {
  static Future<MyUserInfoModel> getUserInfoWhenLogin(
      String user, String cookie) async {
    var response = jsonDecode(await HttpGet.post(
        API.userInfo.api, HttpGet.jsonHeaders, {'user': user}));
    // print(response);
    if (!(response["status"] as String).startsWith("success"))
      throw Exception(response["message"]);
    return MyUserInfoModel.fromJson((response["result"]), cookie);
  }

  static Future<String> refreshCookies(String username, String passwd) async {
    (String, String?) httpResult = await HttpGet.postGetCookie(
        API.userLogin.api,
        HttpGet.jsonHeaders,
        {"user": username, "password": passwd});
    var response = jsonDecode(httpResult.$1);
    print(response);

    if (!response["status"].startsWith("success")) {
      print("login failed");
      throw Exception(response["message"]);
    }

    // 获取 cookie，存入数据库
    int index = (httpResult.$2)!.indexOf(';');
    var setCookie =
        (index == -1 ? (httpResult.$2)! : (httpResult.$2)!.substring(0, index));
    DatabaseUtil.storeCookie(setCookie);
    return setCookie;
  }
}
