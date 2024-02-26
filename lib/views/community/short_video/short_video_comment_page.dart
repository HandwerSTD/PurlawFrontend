import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/models/community/short_video_comment_model.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/community/short_video_comment_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/views/ai_chat_page/ai_chat_page.dart';
import '../../../common/provider/provider_widget.dart';
import '../../../common/utils/misc.dart';
import '../../../components/purlaw/button.dart';
import '../../../components/purlaw/expandable_text.dart';
import '../../../components/purlaw/text_field.dart';

class ShortVideoCommentPage extends StatelessWidget {
  final VideoInfoModel video;
  const ShortVideoCommentPage({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("评论"),
      ),
      body: ShortVideoCommentList(
        video: video,
      ),
    );
  }
}

class ShortVideoCommentList extends StatefulWidget {
  final VideoInfoModel video;
  const ShortVideoCommentList({super.key, required this.video});

  @override
  State<ShortVideoCommentList> createState() => _ShortVideoCommentListState();
}

class _ShortVideoCommentListState extends State<ShortVideoCommentList> {
  static const tag = "ShortVideo Comment";
  ScrollController controller = ScrollController();
  Function()? loadMore;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        Log.d(tag: tag, "Scrolled to end, loading data");
        // 到底部加载新内容
        if (loadMore != null) loadMore!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ShortVideoCommentViewModel>(
      model: ShortVideoCommentViewModel(
          cid: widget.video.commentsId!),
      onReady: (model) {
        model.load();
        loadMore = model.loadMoreComments;
      },
      builder: (context, model, _) => RefreshIndicator(
        onRefresh: () async {
          await model.load();
        },
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: MultiStateWidget(
                    state: model.state,
                    builder: (context) => Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        ListView(
                                      controller: controller,
                                      children: List.generate(
                          model.videoCommentList.result!.length,
                          (index) => CommentBlock(
                              comment: model.videoCommentList.result![index])),
                        ),
                        const OpenAIChatFloatingDialogButton()
                      ],
                    ),
                    emptyWidget: const Center(child: Text("空空如也")),
                  )),
              bottomSendMsgButton(context)
            ],
          ),
      ),
    );
  }

  Widget bottomSendMsgButton(BuildContext context) {
    var model = Provider.of<ShortVideoCommentViewModel>(context);
    return Container(
      padding: const EdgeInsets.only(left: 13, right: 12, bottom: 12, top: 8),
      decoration:
          const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: PurlawChatTextField(
              hint: (getCookie(context).isEmpty ? '登录后可发送评论' : '说点什么吧'),
              focusNode: model.focusNode,
              controller: model.controller,
              readOnly: getCookie(context).isEmpty,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 24),
            child: PurlawRRectButton(
                radius: 10,
                backgroundColor: Provider.of<ThemeViewModel>(context)
                    .themeModel
                    .colorModel
                    .generalFillColor,
                onClick: () {
                  model.submitComment(
                      Provider.of<MainViewModel>(context, listen: false)
                          .cookies);
                },
                child: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                )),
          )
        ],
      ),
    );
  }
}

class CommentBlock extends StatelessWidget {
  final VideoCommentInfoModel comment;
  const CommentBlock({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[400]!, width: 0.5))
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 18, top: 12, bottom: 24),
                child: UserAvatarLoader(
                  verified: comment.verified ?? false,
                  avatar: comment.avatar!,
                  size: 36,
                  radius: 18,
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      comment.author!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  ExpandableText(
                    text: comment.content!,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    expand: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      TimeUtils.formatDateTime(comment.timestamp!.toInt()),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                ],
              ))
            ],
          )
        ],
      ),
    );
  }
}
