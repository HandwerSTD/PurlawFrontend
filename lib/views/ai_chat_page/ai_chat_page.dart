
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/ai_chat_page/chat_page_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/utilities/document_scan/ai_document_recognition.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

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
                RecommendedActionButton(title: '清除对话', onClick: (){
                  model.clearMessage();
                }, show: (!model.replying && model.messageModels.messages.length > 1), ),
                RecommendedActionButton(title: '保存并清除对话', onClick: (){
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
                          showBottomToolSheet(context, lgBreak, themeModel);
                        },
                        icon: Icon(
                          Icons.camera_alt_outlined,
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
                          if (!model.replying) {
                            bool refreshed = getMainViewModel(context, listen: false).myUserInfoModel.cookie.isNotEmpty;
                            if (!refreshed) {
                              TDToast.showText("请先刷新用户信息", context: context);
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

  void showBottomToolSheet(
      BuildContext context, bool lgBreak, ThemeModel themeModel) {
    Navigator.push(
        context,
        TDSlidePopupRoute(
            slideTransitionFrom: (lgBreak
                ? SlideTransitionFrom.center
                : SlideTransitionFrom.bottom),
            barrierLabel: '选择操作',
            builder: (context) {
              Widget child = Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: themeModel.themeData.colorScheme.background),
                height: 200,
                width: 400,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 0,
                      height: 36,
                    ),
                    TDButton(
                      icon: Icons.keyboard_voice,
                      text: '语音输入',
                      size: TDButtonSize.large,
                      type: TDButtonType.fill,
                      shape: TDButtonShape.filled,
                      style: TDButtonStyle(
                          backgroundColor:
                              themeModel.themeData.colorScheme.background,
                          textColor:
                              themeModel.themeData.colorScheme.onBackground,
                          frameColor: Colors.grey[200],
                          frameWidth: 1),
                    ),
                    const SizedBox(
                      width: 0,
                      height: 12,
                    ),
                    TDButton(
                      icon: Icons.document_scanner,
                      text: '文档扫描',
                      size: TDButtonSize.large,
                      type: TDButtonType.outline,
                      shape: TDButtonShape.filled,
                      style: TDButtonStyle(
                          backgroundColor:
                              themeModel.themeData.colorScheme.background,
                          textColor:
                              themeModel.themeData.colorScheme.onBackground,
                          frameColor: Colors.grey[200],
                          frameWidth: 1),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AIDocumentRecognition()));
                      },
                    )
                  ],
                ),
              );

              if (lgBreak) {
                return Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(24)),
                  child: TDPopupCenterPanel(
                      radius: 24,
                      backgroundColor:
                          themeModel.themeData.colorScheme.background,
                      closeClick: () {
                        Navigator.pop(context);
                      },
                      child: child),
                );
              } else {
                return TDPopupBottomDisplayPanel(
                    backgroundColor:
                        themeModel.themeData.colorScheme.background,
                    titleColor: themeModel.themeData.colorScheme.onBackground,
                    title: '选择操作',
                    closeClick: () {
                      Navigator.pop(context);
                    },
                    child: child);
              }
            }));
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


