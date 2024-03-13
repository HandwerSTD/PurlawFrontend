import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/community/private_messsage/private_message_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';

import '../../../common/provider/provider_widget.dart';

class PrivateMessagePage extends StatelessWidget {
  final UserInfoModel sendUser;
  const PrivateMessagePage({super.key, required this.sendUser});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<PrivateMessageViewModel>(
      model: PrivateMessageViewModel(sendUser: sendUser),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 8,
              title: Row(
                children: [
                  UserAvatarLoader(avatar: sendUser.avatar, size: 40, radius: 20, verified: sendUser.verified, margin: EdgeInsets.only(right: 12),),
                  Text(sendUser.user, style: TextStyle(fontSize: 18),)
                ],
              ),
          ),
          body: const PrivateMessagePageBody(),
        );
      },
      onReady: (model) {
        model.load(getCookie(context, listen: false));
      },
    );
  }
}


class PrivateMessagePageBody extends StatelessWidget {
  const PrivateMessagePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: const PrivateMessageChatList().build(context),
          ),
          const Flexible(flex: 0, child: PrivateMessageChatFooter())
        ],
      ),
    );
  }
}

class PrivateMessageChatList extends StatelessWidget {
  const PrivateMessageChatList({super.key});

  @override
  Widget build(BuildContext context) {
    PrivateMessageViewModel model = Provider.of<PrivateMessageViewModel>(context);
    return Column(
      children: [
        Flexible(
          child: SingleChildScrollView(
            controller: model.scrollController,
            child: Column(
                children: model.messages
                    .map((e) => PurlawChatMessageBlockForPM(
                          msg: e,
                        ))
                    .toList()),
          ),
        ),
      ],
    );
  }
}

class PrivateMessageChatFooter extends StatefulWidget {
  const PrivateMessageChatFooter({super.key});

  @override
  State<PrivateMessageChatFooter> createState() => _PrivateMessageChatFooterState();
}

class _PrivateMessageChatFooterState extends State<PrivateMessageChatFooter> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PrivateMessageViewModel>(
      builder: (context, model, _) => LayoutBuilder(builder: (_, constraint) {
        String screenType = Responsive.checkWidth(constraint.maxWidth);
        ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
        Color onPrimary = themeModel.themeData.colorScheme.background;
        bool lgBreak = (screenType == 'lg');

        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: (lgBreak
                        ? BorderRadius.circular(12)
                        : BorderRadius.zero),
                    border: (lgBreak
                        ? Border.all(
                            color: themeModel.colorModel.chatInputDividerColor,
                            width: 1.5)
                        : Border(
                            top: BorderSide(
                                color:
                                    themeModel.colorModel.chatInputDividerColor,
                                width: 1.5)))),
                width: Responsive.assignWidthMedium(constraint.maxWidth),
                padding: EdgeInsets.only(
                    left: 24, right: 18, top: 6 + (lgBreak ? 2 : 0), bottom: 4),
                margin: (lgBreak ? const EdgeInsets.only(bottom: 4) : null),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: PurlawChatTextField(
                          hint: (getCookie(context).isEmpty
                              ? '登录后可用'
                              : ('说点什么吧')),
                          focusNode: model.focusNode,
                          readOnly: (getCookie(context).isEmpty),
                          borderRadius: (lgBreak ? 12 : null),
                          controller: model.controller),
                    ),
                    PurlawRRectButton(
                        radius: 10,
                        backgroundColor: themeModel.colorModel.generalFillColor,
                        onClick: () {
                          if (model.controller.text.isEmpty) return;
                          bool refreshed =
                              getMainViewModel(context, listen: false)
                                  .myUserInfoModel
                                  .cookie
                                  .isNotEmpty;
                          if (!refreshed) {
                            Log.d("User not refreshed", tag: "PrivateMessage");
                            showToast("请先刷新用户信息",
                                toastType: ToastType.warning);
                            return;
                          }
                          model.sendMessage(Provider.of<MainViewModel>(
                              context,
                              listen: false)
                              .cookies);
                        },
                        child: Icon(
                          Icons.send,
                          color: onPrimary,
                          size: 20,
                        ))
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
