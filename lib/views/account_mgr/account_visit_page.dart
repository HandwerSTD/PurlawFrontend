import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/account_mgr/account_visit_viewmodel.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';
import 'package:purlaw/views/community/private_message/private_message.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../common/provider/provider_widget.dart';

// Future openMyAccountPage(BuildContext context) {
//   bool logged =
//       Provider.of<MainViewModel>(context, listen: false).cookies.isNotEmpty;
//   if (logged)
//     return Navigator.push(
//         context, MaterialPageRoute(builder: (_) => MyAccountPage()));
//   return Navigator.push(context,
//       MaterialPageRoute(builder: (_) => AccountLoginPage(showBack: true)));
// }

class AccountVisitPage extends StatelessWidget {
  final String userId;
  const AccountVisitPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<AccountVisitViewModel>(
      model: AccountVisitViewModel(userId: userId),
      onReady: (model) {
        model.load();
      },
      builder: (context,model,_) => Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: (){
              // Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
              Navigator.push(context, MaterialPageRoute(builder: (_) => PrivateMessagePage(sendUser: model.userInfoModel)));
            }, icon: const Icon(EvaIcons.messageCircleOutline))
          ],
        ),
        body: MultiStateWidget(
          state: model.state,
          builder: (context) => AccountVisitPageBody(
            userInfo: model.userInfoModel,
          ),
        ),
      ),
    );
  }
}

class AccountVisitPageBody extends StatefulWidget {
  final UserInfoModel userInfo;
  const AccountVisitPageBody({required this.userInfo, super.key});

  @override
  State<AccountVisitPageBody> createState() => _AccountVisitPageBodyState();
}

class _AccountVisitPageBodyState extends State<AccountVisitPageBody>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  final List<TDTab> tabs = [const TDTab(text: 'Ta的视频',)];


  @override
  void initState() {
    controller = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    bool rBreak = (Responsive.checkWidth(width) == Responsive.lg);
    return Flex(
      direction: rBreak ? Axis.horizontal : Axis.vertical,
      children: [
        AccountPageUserInfoBoard(
            userInfoModel: widget.userInfo),
        Expanded(
          // width: rBreak ? 700 : null,
          child: Column(
            children: [
              PurlawPageTab(
                  controller: controller,
                  tabs: tabs
              ),
              Expanded(
                child: PurlawPageTab(
                  controller: controller,
                  children: [AccountPageVideoWaterfall(userId: widget.userInfo.uid)],
                ).buildView(context),
              ),
            ],
          ),
        )
      ],
    );
  }
}
