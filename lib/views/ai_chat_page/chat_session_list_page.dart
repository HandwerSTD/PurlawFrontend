import 'dart:async';

import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/components/purlaw/dialogs.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_session_list_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

import '../../common/provider/provider_widget.dart';

class ChatSessionListPage extends StatelessWidget {
  const ChatSessionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatSessionListPageBody();
  }
}

class ChatSessionListPageBody extends StatefulWidget {
  const ChatSessionListPageBody({super.key});

  @override
  State<ChatSessionListPageBody> createState() =>
      _ChatSessionListPageBodyState();
}

class _ChatSessionListPageBodyState extends State<ChatSessionListPageBody> {
  late StreamSubscription _;

  @override
  void initState() {
    super.initState();
    _ = eventBus.on<ChatSessionListEventBus>().listen((event) {
      if (event.needNavigate) {
        Navigator.pop(context, true);
      }
    });
    _.resume();
  }

  @override
  void dispose() {
    _.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ChatSessionListViewModel>(
      model: ChatSessionListViewModel(context: context),
      onReady: (model) {
        model.load();
      },
      builder: (context, model, child) => Scaffold(
          appBar: AppBar(
            title: const Text("会话列表"),
            centerTitle: true,
            actions: [
              Visibility(
                visible: !model.editing,
                child: IconButton(
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        pageBuilder: (BuildContext buildContext,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return PurlawAlertDialog(
                              title: '下载会话列表',
                              content: '从网络下载会话列表，成功后会清除本地会话列表的对话数据，是否确定？',
                              rightBtnTitle: '确定',
                              acceptAction: () {
                                bool refreshed = getMainViewModel(context, listen: false).myUserInfoModel.cookie.isNotEmpty;
                                if (!refreshed) {
                                  TDToast.showText("请先刷新用户信息", context: context);
                                  return;
                                }
                                model.fetchSessionsFromNetwork(
                                    getCookie(context, listen: false));
                              });
                        },
                      );
                    },
                    icon: const Icon(Icons.download)),
              ),
              IconButton(
                  onPressed: () {
                    model.switchDeleting();
                  },
                  icon:
                      Icon((model.editing ? Icons.edit : Icons.edit_outlined)))
            ],
          ),
          body: Stack(
            alignment: Alignment.bottomRight,
            children: [
              MultiStateWidget(
                  state: model.state,
                  builder: (context) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: SettingsGroup(
                              items: List.generate(model.sessionList.length,
                                  (index) {
                                Widget trailing = (model.editing
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          getThemeModel(context)
                                                              .colorModel
                                                              .generalFillColor)),
                                              onPressed: () {
                                                showGeneralDialog(
                                                  context: context,
                                                  pageBuilder: (buildContext,
                                                      animation,
                                                      secondaryAnimation) {
                                                    return PurlawInputDialog(
                                                        title: '编辑会话标题',
                                                        defaultText: model.sessionList[index].$2,
                                                        onSubmitted: (val) {
                                                          if (val.isNotEmpty) {
                                                            model
                                                                .changeSessionName(
                                                                    index, val);
                                                          }
                                                        });
                                                  },
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.edit_note_rounded,
                                                color: Colors.white,
                                              )),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          IconButton(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.redAccent)),
                                              onPressed: () {
                                                showGeneralDialog(
                                                  context: context,
                                                  pageBuilder: (BuildContext
                                                          buildContext,
                                                      Animation<double>
                                                          animation,
                                                      Animation<double>
                                                          secondaryAnimation) {
                                                    return PurlawAlertDialog(
                                                        title: '删除会话',
                                                        content:
                                                            '确定要删除会话？此操作不可逆。',
                                                        rightBtnTitle: '确定',
                                                        acceptAction: () {
                                                          bool refreshed = getMainViewModel(context, listen: false).myUserInfoModel.cookie.isNotEmpty;
                                                          if (!refreshed) {
                                                            TDToast.showText("请先刷新用户信息", context: context);
                                                            return;
                                                          }
                                                          model.deleteEntry(index, getCookie(context, listen: false));
                                                        });
                                                  },
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.delete_forever,
                                                color: Colors.white,
                                              )),
                                        ],
                                      )
                                    : Radio(
                                        value: index,
                                        groupValue: model.chosenRadio,
                                        onChanged: (val) {},
                                      ));

                                return SettingsItem(
                                    onTap: () {
                                      model.useSession(index);
                                    },
                                    title: (model.sessionList[index].$2),
                                    subtitle: "点击切换到会话记忆",
                                    icons: const TypIconData(0xE033),
                                    titleMaxLine: 2,
                                    trailing: trailing);
                              }),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              Visibility(
                visible: !model.editing,
                child: Padding(
                  padding: const EdgeInsets.only(right: 36, bottom: 48),
                  child: {
                    FloatingActionButton.extended(
                        label: const Text("新建会话"),
                        icon: const Icon(Icons.add),
                        backgroundColor:
                            getThemeModel(context).colorModel.generalFillColor,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          bool refreshed = getMainViewModel(context, listen: false).myUserInfoModel.cookie.isNotEmpty;
                          if (!refreshed) {
                            TDToast.showText("请先刷新用户信息", context: context);
                            return;
                          }
                          model.createNewSession(
                              getCookie(context, listen: false));
                        })
                  }.first,
                ),
              )
            ],
          )),
    );
  }
}
