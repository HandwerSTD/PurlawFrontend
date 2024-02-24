
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_page_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/ai_chat_page/chat_page_voice_recognition.dart';

/// AI 对话界面的主体
class AIChatPageBody extends StatelessWidget {
  const AIChatPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: const AIChatPageMessageList().build(context),
          ),
          const Flexible(flex: 0, child: AIChatPageFooter())
        ],
      ),
    );
  }
}

class AIChatPageMessageList extends StatelessWidget {
  const AIChatPageMessageList({super.key});

  @override
  Widget build(BuildContext context) {
    AIChatMsgListViewModel model = Provider.of<AIChatMsgListViewModel>(context);
    return Column(
      children: [
        Flexible(
          child: SingleChildScrollView(
            controller: model.scrollController,
            child: Column(
                children: model.messageModels.messages
                    .map((e) => PurlawChatMessageBlockWithAudio(msg: e,))
                    .toList()),
          ),
        ),
      ],
    );
  }
}

class AIChatPageFooter extends StatefulWidget {
  const AIChatPageFooter({super.key});

  @override
  State<AIChatPageFooter> createState() => _AIChatPageFooterState();
}

class _AIChatPageFooterState extends State<AIChatPageFooter> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AIChatMsgListViewModel>(
      builder: (context, model, _) => LayoutBuilder(builder: (_, constraint) {
        String screenType = Responsive.checkWidth(constraint.maxWidth);
        ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
        Color onPrimaryContainer = themeModel.themeData.colorScheme.onBackground;
        Color onPrimary = themeModel.themeData.colorScheme.background;
        bool lgBreak = (screenType == 'lg');

        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RecommendedActions(buttons: [
                RecommendedActionButton(title: '停止对话', onClick: (){
                  model.manuallyBreak();
                }, show: model.replying,),
                RecommendedActionButton(title: '清屏', onClick: (){
                  model.clearMessage();
                }, show: (!model.replying && model.messageModels.messages.length > 1), ),
                RecommendedActionButton(title: '保存并清屏', onClick: (){
                  model.saveMessage();
                }, show: (!model.replying && model.messageModels.messages.length > 1), )
              ],),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius:
                        (lgBreak ? BorderRadius.circular(12) : BorderRadius.zero),
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
                    left: 12, right: 18, top: 2 + (lgBreak ? 2 : 0), bottom: 4),
                margin: (lgBreak ? const EdgeInsets.only(bottom: 4) : null),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () {
                          // showBottomToolSheet(context, lgBreak, themeModel);
                          // Navigator.push(context, PageRouteBuilder(
                          //     pageBuilder: (_, __, ___) => ChatPageVoiceRecognition(),
                          //     transitionDuration: const Duration(milliseconds: 400),
                          //     reverseTransitionDuration: const Duration(milliseconds: 400),
                          //     transitionsBuilder: (context, anim, secAnim, child) {
                          //       return SlideTransition(position: anim.drive(Tween(
                          //           begin: const Offset(0, 1),
                          //           end: Offset.zero
                          //       ).chain(CurveTween(curve: Curves.linearToEaseOut))),child: child,);
                          //     }
                          // ),);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPageVoiceRecognition()));
                        },
                        icon: Icon(
                          Icons.mic_rounded,
                          color: onPrimaryContainer,
                        )),
                    Expanded(
                      child: PurlawChatTextField(
                          hint: (getCookie(context).isEmpty ? '登录后可用' : (model.replying ? '生成中' : '说点什么吧')),
                          focusNode: model.focusNode,
                          readOnly: (getCookie(context).isEmpty ? true : model.replying),
                          borderRadius: (lgBreak ? 12 : null),
                          controller: model.controller),
                    ),
                    PurlawRRectButton(
                        radius: 10,
                        backgroundColor: themeModel.colorModel.generalFillColor,
                        onClick: () {
                          // if (model.controller.text.isEmpty) return;
                          if (!model.replying) {
                            bool refreshed = getMainViewModel(context, listen: false).myUserInfoModel.cookie.isNotEmpty;
                            if (!refreshed) {
                              Log.d("User not refreshed", tag: "AI Chat Page");
                              showToast("请先刷新用户信息", toastType: ToastType.warning);
                              return;
                            }
                            model.submitNewMessage(
                                Provider.of<MainViewModel>(context, listen: false)
                                    .cookies);
                          }
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

class RecommendedActions extends StatelessWidget {
  final List<RecommendedActionButton> buttons;
  const RecommendedActions({required this.buttons, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: buttons,
          ),
        )
      ],
    );
  }
}

class RecommendedActionButton extends StatelessWidget {
  final String title;
  final Function onClick;
  final bool show;
  final int isHeadOrTail;
  const RecommendedActionButton({required this.title, required this.onClick, required this.show, this.isHeadOrTail = 0, super.key});

  @override
  Widget build(BuildContext context) {
    return Visibility(visible: show,child: PurlawRRectButton(
      margin: EdgeInsets.only(left: 8 + (isHeadOrTail == -1 ? 8 : 0), top: 8, bottom: 8, right: 8 + (isHeadOrTail == 1 ? 8 : 0)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: Provider.of<ThemeViewModel>(context).themeModel.colorModel.generalFillColorLight.withOpacity(0.2), width: null, onClick: onClick, radius: 18,
      child: Text(title),),);
  }
}


