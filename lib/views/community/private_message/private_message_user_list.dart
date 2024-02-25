
import 'package:flutter/material.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/views/community/private_message/private_message.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../common/provider/provider_widget.dart';
import '../../../components/multi_state_widget.dart';
import '../../../models/account_mgr/user_info_model.dart';
import '../../../viewmodels/community/private_messsage/private_message_list_viewmodel.dart';
import '../../account_mgr/components/account_page_components.dart';

class PrivateMessageUserListPage extends StatelessWidget {
  const PrivateMessageUserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(
          title: '私信列表',
          showBack: true
      ).build(context),
      body: const PrivateMessageListPageBody(),
    );
  }
}


class PrivateMessageListPageBody extends StatelessWidget {
  const PrivateMessageListPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<PrivateMessageListViewModel>(
      model: PrivateMessageListViewModel(),
      onReady: (model) {
        model.load(getCookie(context, listen: false));
      },
      builder: (context, model, _) =>
          RefreshIndicator(
            onRefresh: () async {
              await model.load(getCookie(context, listen: false));
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: MultiStateWidget(
                      state: model.state,
                      builder: (context) =>
                          ListView(
                            children: List.generate(
                                model.userList.length,
                                    (index) =>
                                    Container(
                                      // padding: const EdgeInsets.only(left: 24, right: 24, top: 0),
                                      child: ListBlock(userInfo: model.userList[index], clearUnread: (){
                                        model.clearUnread(index);
                                      },),
                                    )),
                          ),
                      emptyWidget: const Center(child: Text("空空如也")),
                    )),
              ],
            ),
          ),
    );
  }
}

class ListBlock extends StatelessWidget {
  final (UserInfoModel, int) userInfo;
  final Function clearUnread;
  const ListBlock({super.key, required this.userInfo, required this.clearUnread});

  @override
  Widget build(BuildContext context) {
    UserInfoModel user = userInfo.$1;
    int count = userInfo.$2;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PrivateMessagePage(sendUser: user))).then((value) {
          clearUnread();
        });
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[400]!, width: 0.5))
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: UserAvatarLoader(
                    avatar: user.avatar,
                    size: 36,
                    radius: 18,
                  ),
                ),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.user,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    )),
                (count != 0 ? TDBadge(
                  TDBadgeType.message,
                  size: TDBadgeSize.large,
                  message: count.toString(),
                ) : Container())
              ],
            )
          ],
        ),
      ),
    );
  }
}
