// useless because just_audio platform channel doesn't work properly

import 'dart:convert';
import 'dart:io';

import 'package:fake_http_client/fake_http_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grock/grock.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/common/utils/database/kvstore.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_page_viewmodel.dart';

void main() {
  group("Chat Page ViewModel tests", () {
    setUp(() async {
      HttpOverrides.global = MyHttpOverrides();
      PathProviderPlatform.instance = FakePathProviderPlatform();
      await KVBox.setupLocator();
    });
    testWidgets("Append Session", (tester) async {
      final m = AIChatMsgListViewModel();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => m)
        ],
        child: Builder(builder: (context) {
          return MaterialApp(
              title: "紫藤法道",
              navigatorKey: Grock.navigationKey, // added line
              scaffoldMessengerKey: Grock.scaffoldMessengerKey, // added line
              home: Consumer<AIChatMsgListViewModel>(
                builder: (context, model, child) {
                  return Column(
                    children: [
                      SizedBox(height: 10, child: ListView(controller: model.scrollController,)),
                      ElevatedButton(
                        key: Key("testBtn"),
                          onPressed: () async {
                        model.controller = TextEditingController(text: "success");
                        DatabaseUtil.storeLastAIChatSession("123");
                        tester.runAsync(() async {
                          await model.submitNewMessage("123", callback: (){
                            expect(model.messageModels.messages.last.showedText, testText);
                          });
                        });
                      }, child: Text("testButton")),
                      Text(key: Key("testTxt"),
                      model.messageModels.messages.lastOrNull?.showedText ?? "")
                    ],
                  );
                },
              )
          );
        }),
      ));

      final button = find.byKey(Key("testBtn"));
      await tester.tap(button);
      await tester.pumpAndSettle();
    });
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient((request, client) {
      if (request.uri.path.contains(API.chatAppendSession.api)) {
        return FakeHttpResponse(
          body: jsonEncode({
            "status": request.bodyText.contains("success") ? "success" : "fail",
            "message": "test"
          })
        );
      }
      if (request.uri.path.contains(API.chatFlushSession.api)) {
        if (count + 5 >= testText.length) {
          int _c = count; count = 0;
          return FakeHttpResponse(
              body: jsonEncode({
                "status": "success",
                "data": "${testText.substring(_c)}<EOF>"
              })
          );
        }
        int _c = count; count += 5;
        return FakeHttpResponse(
            body: jsonEncode({
              "status": "success",
              "message": testText.substring(_c, count)
            }));
      }
      if (request.uri.path.contains(API.userRecommendLawyer.api)) {
        return FakeHttpResponse(
          body: jsonEncode({
            "status": "success",
            "result": []
          })
        );
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

int count = 0;
const String testText =
"""
As of Flutter 3.19.0, Flutter supports deploying apps the following combinations of hardware architectures and operating system versions。 These combinations are called platforms。

Flutter supports platforms in three tiers:

Supported: The Flutter team tests these platforms on every commit。
Best effort: The Flutter team intends to support these platforms through coding practices。 The team tests these platforms on an ad-hoc basis。
Unsupported: The Flutter team doesn’t test or support these platforms。
Based on these tiers, Flutter supports deploying to the following platforms。
""";