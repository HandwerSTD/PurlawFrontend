import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/components/purlaw/tabbar.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_page_viewmodel.dart';
import 'package:purlaw/viewmodels/community/short_video_list_viewmodel.dart';
import 'package:purlaw/viewmodels/main_page_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/account_login.dart';
import 'package:purlaw/views/account_mgr/my_account_page.dart';
import 'package:purlaw/views/ai_chat_page/ai_chat_page.dart';
import 'package:purlaw/views/community/community_page.dart';
import 'package:purlaw/views/utilities/utilities_index_page.dart';

import '../common/utils/misc.dart';
import 'community/community_search_page.dart';

/// 程序首页的 UI，用脚手架搭建 AppBar 和三个 Tab
class MainPage extends StatelessWidget {
  static int tabIndex = 1;
  static Widget getTab(BuildContext context, int index) {
    if (index == 0) return UtilitiesIndexPage().build(context);
    if (index == 1) return AIChatPageBody().build(context);
    if (index == 2) return CommunityPageBody();
    return Container();
  }

  static Widget leftButton(BuildContext context) => IconButton(
    onPressed: () {
      // Navigator.push(context, MaterialPageRoute(builder: (_) => MyAccountPage()));
      Provider.of<ThemeViewModel>(context, listen: false).switchDarkMode();
    },
    icon: Icon(Icons.mark_chat_read_outlined),
  );
  static Widget rightButton(BuildContext context, {bool rBreak = false}) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: (tabIndex == 2 && rBreak) ? 4 : 0),
        child: Row(
          children: [
            Visibility(visible: (tabIndex == 2 && rBreak),
              child: IconButton(
              onPressed: () {
                JumpToSearchPage(context);
              },
              icon: Icon(Icons.search),
            ),),
            IconButton(
                onPressed: () {
            openMyAccountPage(context);
                },
                icon: Icon(Icons.person_outline),
              ),
          ],
        ),
      );
  
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainPageViewModel>(create: (_) => MainPageViewModel()),
        ChangeNotifierProvider<AIChatMsgListViewModel>(create: (_) => AIChatMsgListViewModel(context: _),),
        ChangeNotifierProvider<ShortVideoListViewModel>(create: (_) => ShortVideoListViewModel(context: _),)
      ],
      builder: (_, __) => Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          body: Builder(
            builder: (context) {
              final width = MediaQuery.of(context).size.width;
              final String screenType = Responsive.checkWidth(width);
              bool rBreak = (screenType == Responsive.lg);
              return (rBreak ? LargeMainPageBody() : NormalMainPageBody());
            },
          )),
    );
  }
}

class NormalMainPageBody extends StatefulWidget {
  const NormalMainPageBody({super.key});

  @override
  State<NormalMainPageBody> createState() => _NormalMainPageBodyState();
}

class _NormalMainPageBodyState extends State<NormalMainPageBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PurlawAppMainPageTabBar(
          leftButton: MainPage.leftButton(context),
          rightButton: MainPage.rightButton(context),
          tabs: [
            PurlawTabBarConfig(
                onTap: () {
                  setState(() {
                    MainPage.tabIndex = 0;
                  });
                },
                tabText: '工具'),
            PurlawTabBarConfig(
                onTap: () {
                  setState(() {
                    MainPage.tabIndex = 1;
                  });
                },
                tabText: '对话'),
            PurlawTabBarConfig(
                onTap: () {
                  setState(() {
                    MainPage.tabIndex = 2;
                  });
                },
                tabText: '社区')
          ], selectedTab: MainPage.tabIndex,
        ),
        Expanded(child: MainPage.getTab(context, MainPage.tabIndex))
      ],
    );
  }
}

class LargeMainPageBody extends StatefulWidget {
  const LargeMainPageBody({super.key});

  @override
  State<LargeMainPageBody> createState() => _LargeMainPageBodyState();
}

class _LargeMainPageBodyState extends State<LargeMainPageBody> {
  @override
  Widget build(BuildContext context) {
    // TODO: 调布局
    return ProviderWidget<MainPageViewModel>(
      model: MainPageViewModel(),
      onReady: (model) {},
      builder: (context, model, child) => Container(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              // 给悬浮 Tab 留出空间
              // padding: EdgeInsets.only(top: 96),
                child: MainPage.getTab(context, MainPage.tabIndex)),
            PurlawAppMainPageTabBar(
              leftButton: MainPage.leftButton(context),
              rightButton: MainPage.rightButton(context, rBreak: true),
              tabs: [
                PurlawTabBarConfig(
                    onTap: () {
                      setState(() {
                        MainPage.tabIndex = 0;
                      });
                    },
                    tabText: '工具'),
                PurlawTabBarConfig(
                    onTap: () {
                      setState(() {
                        MainPage.tabIndex = 1;
                      });
                    },
                    tabText: '对话'),
                PurlawTabBarConfig(
                    onTap: () {
                      setState(() {
                        MainPage.tabIndex = 2;
                      });
                    },
                    tabText: '社区')
              ], selectedTab: MainPage.tabIndex,
            ),
          ],
        ),
      ),
    );
  }
}
