import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';

import '../../models/ai_chat/chat_message_model.dart';

class PurlawChatMessageBlock extends StatelessWidget {
  final AIChatMessageModel msg;
  const PurlawChatMessageBlock({required this.msg, super.key});

  @override
  Widget build(BuildContext context) {
    return chatMessageBlock(context, msg);
  }

  Widget chatMessageBlock(BuildContext context, AIChatMessageModel msgData) {
    bool rBreak = (Responsive.checkWidth(MediaQuery.of(context).size.width) ==
        Responsive.lg);
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    Color foreground = (msgData.isMine
        ? Colors.white
        : (themeModel.dark ? Colors.white : Colors.black87));
    Color background = (msgData.isMine
        ? themeModel.colorModel.generalFillColor
        : (themeModel.dark ? Colors.black : Colors.white));
    double leftMargin = 24 + (msgData.isMine ? (rBreak ? 500 : 24) : 0);
    double rightMargin = 24 + (msgData.isMine ? 0 : (rBreak ? 500 : 0));
    // 总容器
    return Container(
      margin: EdgeInsets.only(
          top: (msgData.isFirst && rBreak)
              ? PurlawAppMainPageTabBar.avoidancePadding
              : 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            (msgData.isMine ? MainAxisAlignment.end : MainAxisAlignment.start),
        children: [
          Flexible(
            // 文字容器
            child: Container(
              margin: EdgeInsets.only(
                  left: leftMargin, right: rightMargin, top: 12, bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border:
                      Border.all(color: themeModel.colorModel.generalFillColorLight, width: 1),
                  color: background,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                    BoxShadow(
                        color: (themeModel.dark
                                ? Colors.grey[800]!.withOpacity(0.2)
                                : Colors.lightBlue[50]!.withOpacity(0.5)),
                        blurRadius: (themeModel.dark ? 20 : 30),
                      spreadRadius: 5,
                      offset: const Offset(0, 10)
                    )
                  ],
                  borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                      topLeft: (msgData.isMine
                          ? const Radius.circular(20)
                          : const Radius.circular(0)),
                      topRight: (!msgData.isMine
                          ? const Radius.circular(20)
                          : const Radius.circular(0)))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    (msgData.message == "" ? "思考中..." : msgData.message),
                    // softWrap: true,
                    style:
                        TextStyle(color: foreground, height: 1.5, fontSize: 15),
                  ),
                  if (!msgData.isMine)
                    {
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "对话由 AI 大模型生成，仅供参考",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      )
                    }.first
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
