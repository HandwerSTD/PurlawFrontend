import 'dart:convert';
import 'dart:io';

import 'package:fake_http_client/fake_http_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/utils/database/kvstore.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:purlaw/viewmodels/account_mgr/account_register_viewmodel.dart';

void main() {
  group("Register tests", () {
    setUp(() async {
      HttpOverrides.global = MyHttpOverrides();
      PathProviderPlatform.instance = FakePathProviderPlatform();
      await KVBox.setupLocator();
    });
    test("Register success", () async {
      final viewModel = AccountRegisterViewModel();
      viewModel.nameCtrl = TextEditingController(text: "success");
      viewModel.passwdCtrl = TextEditingController(text: "66666666");
      viewModel.mailCtrl = TextEditingController(text: "test@example.com");
      viewModel.agreeStatement = true;
      var result = await viewModel.registerNewAccount();
      expect(result, (true, "注册成功，请登录"));
    });
    test("Register failed", () async {
      final viewModel = AccountRegisterViewModel();
      viewModel.nameCtrl = TextEditingController(text: "failed");
      viewModel.passwdCtrl = TextEditingController(text: "66666666");
      viewModel.mailCtrl = TextEditingController(text: "test@example.com");
      viewModel.agreeStatement = true;
      var result = await viewModel.registerNewAccount();
      expect(result, (false, "test"));
    });
    test("Login field incomplete", () async {
      final viewModel = AccountRegisterViewModel();
      viewModel.passwdCtrl = TextEditingController(text: "66666666");
      var result = await viewModel.registerNewAccount();
      expect(result, (false, "填写信息不完整"));
    });
    test("Login field fake mail", () async {
      final viewModel = AccountRegisterViewModel();
      viewModel.nameCtrl = TextEditingController(text: "66666666");
      viewModel.passwdCtrl = TextEditingController(text: "66666666");
      viewModel.mailCtrl = TextEditingController(text: "66666666@");
      viewModel.agreeStatement = true;
      var result = await viewModel.registerNewAccount();
      expect(result, (false, "邮箱格式不正确"));
    });
    test("Login field agreement not accepted", () async {
      final viewModel = AccountRegisterViewModel();
      viewModel.nameCtrl = TextEditingController(text: "231");
      viewModel.passwdCtrl = TextEditingController(text: "666");
      viewModel.mailCtrl = TextEditingController(text: "test@example.com");
      var result = await viewModel.registerNewAccount();
      expect(result.$2.contains("请"), true);
    });
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient((request, client) {
      if (request.uri.path.contains(API.userRegister.api)) {
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
