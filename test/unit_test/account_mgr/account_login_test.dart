import 'dart:convert';
import 'dart:io';

import 'package:fake_http_client/fake_http_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:purlaw/common/utils/database/kvstore.dart';
import 'package:purlaw/viewmodels/account_mgr/account_login_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group("Login tests", () {
    setUp(() async {
      HttpOverrides.global = MyHttpOverrides();
      PathProviderPlatform.instance = FakePathProviderPlatform();
      await KVBox.setupLocator();
    });
    test("Login success", () async {
      AccountLoginViewModel viewModel = AccountLoginViewModel();
      viewModel.nameCtrl = TextEditingController(text: "success");
      viewModel.passwdCtrl = TextEditingController(text: "666");
      var result = await viewModel.loginUser();
      expect(result, "success");
    });
    test("Login failed", () async {
      AccountLoginViewModel viewModel = AccountLoginViewModel();
      viewModel.nameCtrl = TextEditingController(text: "failed");
      viewModel.passwdCtrl = TextEditingController(text: "666");
      var result = await viewModel.loginUser();
      expect(result, "test");
    });
    test("Login field incomplete", () async {
      AccountLoginViewModel viewModel = AccountLoginViewModel();
      viewModel.nameCtrl = TextEditingController(text: "");
      viewModel.passwdCtrl = TextEditingController(text: "666");
      var result = await viewModel.loginUser();
      expect(result, "用户名或密码不完整");
    });
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient((request, client) {
      if (request.uri.path.contains(API.userInfo.api)) {
        return FakeHttpResponse(
            body: jsonEncode({
          'message': '获取成功',
          'result': {
            'avatar': '5c6143a45cdd81ccc1dc36d0f4a762cd5ae6ada9',
            'uid': '656f2c18eddbc27b127192e2',
            'user': 'user',
            'user_type': 1,
            'user_info': '111, 1231'
          },
          'status': 'success'
        }));
      }
      if (request.uri.path.contains(API.userLogin.api)) {
        return FakeHttpResponse(
            headers: {"set-cookie": "123"},
            body: jsonEncode({
              "status":
                  (request.bodyText.contains("success") ? "success" : "fail"),
              "message": "test"
            }));
      }
      return FakeHttpResponse();
    });
  }
}

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return '.';
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return '.';
  }

  @override
  Future<String?> getTemporaryPath() async {
    return '.';
  }
}
