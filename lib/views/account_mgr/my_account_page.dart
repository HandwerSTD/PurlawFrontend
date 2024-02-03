import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/account_login.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';
import 'package:purlaw/views/ai_chat_page/chat_history_page.dart';
import 'package:purlaw/views/community/short_video/short_video_upload_page.dart';
import 'package:purlaw/views/settings/SettingsPage.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../common/utils/misc.dart';

Future openMyAccountPage(BuildContext context) {
  bool logged =
      Provider.of<MainViewModel>(context, listen: false).cookies.isNotEmpty;
  if (logged) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (_) => const MyAccountPage()));
  }
  return Navigator.push(context,
      MaterialPageRoute(builder: (_) => const AccountLoginPage(showBack: true)));
}
void checkAndLoginIfNot(BuildContext context) {
  bool logged =
      Provider.of<MainViewModel>(context, listen: false).cookies.isNotEmpty;
  if (!logged) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AccountLoginPage(showBack: true)));
  }
}

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  late MyUserInfoModel userInfoModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Provider.of<ThemeViewModel>(context, listen: false).switchDarkMode();
          }, icon: const Icon(Icons.sunny)),
          IconButton(onPressed: (){
            TDToast.showText("刷新中", context: context);
            Provider.of<MainViewModel>(context, listen: false).refreshCookies(toast: true);
          }, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          }, icon: const Icon(Icons.settings))
        ],
      ),
      body: MyAccountPageBody(
        userInfo: Provider.of<MainViewModel>(context).myUserInfoModel,
      ),
    );
  }
}

class MyAccountPageBody extends StatefulWidget {
  final MyUserInfoModel userInfo;
  const MyAccountPageBody({required this.userInfo, super.key});

  @override
  State<MyAccountPageBody> createState() => _MyAccountPageBodyState();
}

class _MyAccountPageBodyState extends State<MyAccountPageBody>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  final List<TDTab> tabs = [const TDTab(text: '我的历史',), const TDTab(text: '我的视频',), const TDTab(text: '社区收藏',)];


  @override
  void initState() {
    controller = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool rBreak = (Responsive.checkWidth(constraints.maxWidth) == Responsive.lg);
        return Flex(
          direction: rBreak ? Axis.horizontal : Axis.vertical,
          children: [
            AccountPageUserInfoBoard(
                userInfoModel: widget.userInfo.toGeneralModel()),
            Expanded(
              child: Column(
                children: [
                  PurlawPageTab(
                      controller: controller,
                      tabs: tabs
                  ),
                  Expanded(
                    child: PurlawPageTab(
                      controller: controller,
                      children: [
                        const ChatHistoryPageBody(),
                        MyAccountVideoListBody(uid: widget.userInfo.uid),
                        const AccountPageFavoriteVideoWaterfall()
                      ],
                    ).buildView(context),
                  ),
                ],
              ),
            )
          ],
        );
      }
    );
  }
}

class MyAccountVideoListBody extends StatelessWidget {
  final String uid;
  const MyAccountVideoListBody({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        AccountPageVideoWaterfall(userId: uid),
        Container(
          margin: const EdgeInsets.only(bottom: 48, right: 36),
          child: FloatingActionButton.extended(
              label: const Text("上传视频"),
              icon: const Icon(Icons.add),
              backgroundColor: Provider.of<ThemeViewModel>(context).themeModel.colorModel.generalFillColor,
              foregroundColor: Colors.white,
              onPressed: (){
                ImagePicker()
                    .pickVideo(source: ImageSource.gallery)
                    .then((selectVideo) {
                  if (selectVideo == null) return;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ShortVideoUpload(selectedFile: selectVideo)));
                });
              }),
        )
      ],
    );
  }
}

