import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/cache_utils.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/common/utils/database/kvstore.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/components/third_party/image_loader.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/ai_chat_page/chat_history_page.dart';
import 'package:purlaw/views/main_page.dart';
import 'package:purlaw/views/oobe/oobe.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:purlaw/common/utils/log_utils.dart';

void main() {
  runApp(const MyApp());
}

final EventBus eventBus = EventBus();
/// 程序入口
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/rounded_app_icon.png"), context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel(MediaQuery.of(context).platformBrightness == Brightness.dark)),
        ChangeNotifierProvider(create: (_) => MainViewModel())
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
            title: "紫藤法道",
            theme: Provider.of<ThemeViewModel>(context).themeModel.themeData,
            home: const ProgramEntry());
      }),
    );
  }
}

/// 用户界面入口，加载设置
class ProgramEntry extends StatefulWidget {
  const ProgramEntry({super.key});

  @override
  State<ProgramEntry> createState() => _ProgramEntryState();
}

class _ProgramEntryState extends State<ProgramEntry> {
  late StreamSubscription _sub;
  Future<void> initStateAsync() async {
    await KVBox.setupLocator();
  }

  @override
  void initState() {
    super.initState();
    _sub = eventBus.on<MainViewModelEventBus>().listen((event) {
      TDToast.showText(event.toast, context: context);
    });
    _sub.resume();
    // 需要异步加载的功能，比如 KVBox，写在 initStateAsync 里
    initStateAsync().then((_) {
      // 首次使用应用引导
      if (DatabaseUtil.isFirstOpen()) {
        DatabaseUtil.setFirstOpen();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const OOBE(),
                settings: const RouteSettings(name: '/home')));
      }

      // 获取主题色
      final themeColor = DatabaseUtil.getThemeIndex();
      Log.i(tag: "Main", "read theme color = $themeColor");
      Provider.of<ThemeViewModel>(context, listen: false)
          .setThemeColor(themeColor, update: false);
      if ((MediaQuery.of(context).platformBrightness == Brightness.dark) != Provider.of<ThemeViewModel>(context, listen: false).themeModel.dark) {
        Provider.of<ThemeViewModel>(context, listen: false).switchDarkMode();
      }

      // 清空上次的对话信息
      DatabaseUtil.storeLastAIChatMsg("");

      // 重置服务器设置
      HttpGet.switchBaseUrl(DatabaseUtil.getServerAddress());

      // 获取并刷新 Cookies
      final String cookie = DatabaseUtil.getCookie();
      Provider.of<MainViewModel>(context, listen: false).cookies = cookie;
      if (cookie.isNotEmpty) {
        ("[DEBUG] cookie detected, refreshing");
        Provider.of<MainViewModel>(context, listen: false).refreshCookies();
      }
      getMainViewModel(context, listen: false).autoAudioPlay = DatabaseUtil.getAutoAudioPlay;

      Provider.of<MainViewModel>(context, listen: false)
          .changeState(NetworkLoadingState.CONTENT);
    });
    Log.i(tag: "Main", "main inited");
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MultiStateWidget(
      state: Provider.of<MainViewModel>(context).state,
      builder: (BuildContext context) => const MainPage(),
      loadingWidget: const Scaffold(
        // backgroundColor: Color(0xff5550A6),
        body: Center(
          child: AppIconImage(),
        ),
      ),
    );
  }
}
