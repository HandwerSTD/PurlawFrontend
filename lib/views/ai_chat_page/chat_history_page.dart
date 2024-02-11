import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/models/ai_chat/chat_message_model.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_history_viewmodel.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

import '../../common/provider/provider_widget.dart';
import '../../common/utils/database/database_util.dart';
import '../../components/purlaw/chat_message_block.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: '对话历史', showBack: true).build(context),
      body: const ChatHistoryPageBody(),
    );
  }
}

class ChatHistoryPageBody extends StatelessWidget {
  const ChatHistoryPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ChatHistoryViewModel>(
        model: ChatHistoryViewModel(),
        onReady: (model) {
          model.load();
        },
        builder: (context, model, child) => MultiStateWidget(
            state: model.state,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: SettingsGroup(
                    items: List.generate(model.sessionList.length, (index) {
                      return SettingsItem(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => HistoryChatDetailPage(
                                      list: model.sessionList[index].$2, ts: model.sessionList[index].$1,))).then((value) {
                                        if (value == true) {
                                          model.changeState(NetworkLoadingState.LOADING);
                                          model.load();
                                        }
                          });
                        },
                        title:
                            (model.sessionList[index].$2.messages![1].message),
                        subtitle: (TimeUtils.formatDateTime(model.sessionList[index].$1)),
                        icons: const TypIconData(0xE04A),
                        titleMaxLine: 2,
                      );
                    }),
                  ),
                ),
              );
            }));
  }
}

class HistoryChatDetailPage extends StatefulWidget {
  final int ts;
  final ListAIChatMessageModels list;
  const HistoryChatDetailPage({super.key, required this.list, required this.ts});

  @override
  State<HistoryChatDetailPage> createState() => _HistoryChatDetailPageState();
}

class _HistoryChatDetailPageState extends State<HistoryChatDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('对话详情'), centerTitle: true,
          actions: [
            IconButton(onPressed: (){
              showDialog(context: context, builder: setDeletePermanently).then((value) {
                if (value == true) {
                  Navigator.pop(context, true);
                }
              });
            }, icon: const Icon(Icons.delete_forever_rounded))
          ],
        ),
        body: Column(
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                    children: widget.list.messages!
                        .map((e) => PurlawChatMessageBlockViewOnly(msg: e))
                        .toList()),
              ),
            ),
          ],
        ));
  }

  Dialog setDeletePermanently(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("确定要删除吗？"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text("取消")),
                TextButton(
                    onPressed: () {
                      HistoryDatabaseUtil.deleteHistory(widget.ts);
                      Navigator.pop(context, true);
                    },
                    child: const Text("确定"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
