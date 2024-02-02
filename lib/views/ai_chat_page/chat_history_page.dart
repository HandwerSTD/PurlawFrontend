import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/models/ai_chat/chat_message_model.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_history_viewmodel.dart';
import 'package:purlaw/views/ai_chat_page/ai_chat_page.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

import '../../common/provider/provider_widget.dart';
import '../../components/purlaw/chat_message_block.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: '对话历史', showBack: true).build(context),
      body: ChatHistoryPageBody(),
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
      builder: (context, model, child) => MultiStateWidget(state: model.state, builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: SettingsGroup(
              items: List.generate(model.sessionList.length, (index) {
                return SettingsItem(
                    onTap:(){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryChatDetailPage(list: model.sessionList[index].$2)));
                }, title: (model.sessionList[index].$1), icons: const TypIconData(0xE04A),);
              }),
            ),
          ),
        );
      })
    );
  }
}

class HistoryChatDetailPage extends StatelessWidget {
  final ListAIChatMessageModels list;
  const HistoryChatDetailPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(
        title: '对话详情',
            showBack: true
      ).build(context),
      body: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                  children: list.messages!
                      .map((e) => PurlawChatMessageBlock(msg: e))
                      .toList()),
            ),
          ),
        ],
      )
    );
  }
}


