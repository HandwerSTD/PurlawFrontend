
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/components/purlaw/tabbar.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_page_viewmodel.dart';
import 'package:purlaw/viewmodels/community/short_video_list_viewmodel.dart';
import 'package:purlaw/viewmodels/main_page_viewmodel.dart';
import 'package:purlaw/views/account_mgr/my_account_page.dart';
import 'package:purlaw/views/ai_chat_page/ai_chat_page.dart';
import 'package:purlaw/views/ai_chat_page/chat_session_list_page.dart';
import 'package:purlaw/views/community/community_page.dart';
import 'package:purlaw/views/utilities/utilities_index_page.dart';

import '../common/utils/misc.dart';
import 'community/community_search_page.dart';


/// 程序首页的 UI，用脚手架搭建 AppBar 和三个 Tab
class MainPage extends StatelessWidget {
  static int tabIndex = 1;
  static Widget getTab(BuildContext context, int index) {
    if (index == 0) return const UtilitiesIndexPage().build(context);
    if (index == 1) return const AIChatPageBody().build(context);
    if (index == 2) return const CommunityPageBody();
    return Container();
  }

  static Widget leftButton(BuildContext context) => IconButton(
        onPressed: () {
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (_) => ChatHistoryPage()));
          Navigator.push(context, PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ChatSessionListPage(),
              barrierColor: Colors.black45,
              transitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder: (context, anim, secAnim, child) {
                return SlideTransition(position: anim.drive(Tween(
                    begin: const Offset(-1, 0),
                    end: Offset.zero
                ).chain(CurveTween(curve: Curves.ease))),child: child,);
              }
          ),).then((value) {
            if (value == true) {
              Provider.of<AIChatMsgListViewModel>(context, listen: false).switchToSessionMessages();
            }
          });
        },
        icon: const Icon(Icons.mark_chat_read_outlined),
      );
  static Widget rightButton(BuildContext context, {bool rBreak = false}) =>
      Container(
        // padding: EdgeInsets.only(left: (tabIndex == 2 && rBreak) ? 4 : 0),
        child: Row(
          children: [
            Visibility(
              visible: (tabIndex == 2 && rBreak),
              child: IconButton(
                onPressed: () {
                  JumpToSearchPage(context);
                },
                icon: const Icon(Icons.search),
              ),
            ),
            IconButton(
              onPressed: () {
                openMyAccountPage(context);
              },
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
      );

  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainPageViewModel>(
            create: (_) => MainPageViewModel()),
        ChangeNotifierProvider<AIChatMsgListViewModel>(
          create: (_) => AIChatMsgListViewModel(),
        ),
        ChangeNotifierProvider<ShortVideoListViewModel>(
          create: (_) => ShortVideoListViewModel(),
        )
      ],
      builder: (context, __) => Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          body: Builder(
            builder: (context) {
              final width = MediaQuery.of(context).size.width;
              final String screenType = Responsive.checkWidth(width);
              bool rBreak = (screenType == Responsive.lg);
              return (rBreak
                  ? const LargeMainPageBody()
                  : const NormalMainPageBody());
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
  PageController controller = PageController(initialPage: MainPage.tabIndex);

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
                  controller.animateToPage(0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutQuad);
                },
                tabText: '工具'),
            PurlawTabBarConfig(
                onTap: () {
                  controller.animateToPage(1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutQuad);
                },
                tabText: '对话'),
            PurlawTabBarConfig(
                onTap: () {
                  controller.animateToPage(2,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutQuad);
                },
                tabText: '社区')
          ],
          selectedTab: MainPage.tabIndex,
        ),
        Expanded(
          child: PageView(
            controller: controller,
            children: [
              MainPage.getTab(context, 0),
              MainPage.getTab(context, 1),
              MainPage.getTab(context, 2),
            ],
            onPageChanged: (index) {
              setState(() {
                MainPage.tabIndex = index;
              });
            },
          ),
        )
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
  PageController controller = PageController(initialPage: MainPage.tabIndex);

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<MainPageViewModel>(
      model: MainPageViewModel(),
      onReady: (model) {},
      builder: (context, model, child) => Container(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            PageView(
              controller: controller,
              children: [
                MainPage.getTab(context, 0),
                MainPage.getTab(context, 1),
                MainPage.getTab(context, 2),
              ],
              onPageChanged: (index) {
                setState(() {
                  MainPage.tabIndex = index;
                });
              },
            ),
            PurlawAppMainPageTabBar(
              leftButton: MainPage.leftButton(context),
              rightButton: MainPage.rightButton(context, rBreak: true),
              tabs: [
                PurlawTabBarConfig(
                    onTap: () {
                      controller.animateToPage(0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutQuad);
                    },
                    tabText: '工具'),
                PurlawTabBarConfig(
                    onTap: () {
                      controller.animateToPage(1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutQuad);
                    },
                    tabText: '对话'),
                PurlawTabBarConfig(
                    onTap: () {
                      controller.animateToPage(2,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutQuad);
                    },
                    tabText: '社区')
              ],
              selectedTab: MainPage.tabIndex,
            ),
          ],
        ),
      ),
    );
  }
}
