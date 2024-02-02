import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/components/purlaw/search_bar.dart';
import 'package:purlaw/components/third_party/image_loader.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/community/short_video_list_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';
import 'package:purlaw/views/community/community_search_page.dart';
import 'package:purlaw/views/community/short_video/short_video_play_page.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class CommunityPageBody extends StatefulWidget {
  const CommunityPageBody({super.key});

  @override
  State<CommunityPageBody> createState() => _CommunityPageBodyState();
}

class _CommunityPageBodyState extends State<CommunityPageBody> {
  late ShortVideoListViewModel model;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        model.loadMoreVideo(
            Provider.of<MainViewModel>(context, listen: false).cookies);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    model = Provider.of<ShortVideoListViewModel>(context);
    if (model.state == NetworkLoadingState.LOADING &&
        (model.videoList.result == null || model.videoList.result!.isEmpty)) {
      model.fetchVideoList(Provider.of<MainViewModel>(context).cookies);
    } else {
      if (model.state == NetworkLoadingState.LOADING) {
        model.state = NetworkLoadingState.CONTENT;
      }
    }
    return LayoutBuilder(
      builder: (_, constraints) => Container(
          alignment: Alignment.center,
          child: Stack(alignment: Alignment.topCenter, children: [
            PurlawWaterfallList(
              refresherOffset: 40,
              controller: controller,
              list: List.generate((model.videoList.result?.length) ?? 0, (index) {
                return GridVideoBlock(video: model.videoList.result![index]);
              }), onPullRefresh: () async {
                await model.fetchVideoList(getCookie(context, listen: false));
            }, loadingState: model.state,
            ),
            Visibility(
              visible: (Responsive.checkWidth(constraints.maxWidth) !=
                  Responsive.lg),
              child: SearchAppBar(
                hintLabel: '搜索',
                onSubmitted: (val) {},
                readOnly: true,
                onTap: () {
                  JumpToSearchPage(context);
                },
              ),
            ),
          ])),
    );
  }
}

class GridVideoBlock extends StatelessWidget {
  final VideoInfoModel video;
  final int? indexInList;
  final Function? loadMore;
  final VideoList? videoList;

  const GridVideoBlock({
    super.key,
    required this.video,
    this.indexInList,
    this.loadMore,
    this.videoList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (indexInList == null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ShortVideoPlayPage(paramVideo: video)));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ShortVideoPlayByList(
                          videoList: videoList!,
                          videoIndex: indexInList!,
                          loadMoreVideo: loadMore!)));
            }
          },
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 12, left: 4, right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 5, bottom: 12),
                    child: ImageLoader(
                      width: 180,
                      height: (video.coverRatio! * 180),
                      url:
                          HttpGet.getApi(API.videoCover.api) + video.coverSha1!,
                      loadingWidget: Container(
                        width: 180,
                        alignment: Alignment.center,
                        color: Colors.grey.withOpacity(0.3),
                        child: const TDLoading(
                          icon: TDLoadingIcon.circle,
                          size: TDLoadingSize.large,
                        ),
                      ),
                    )),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 6),
                  child: Text(
                    video.title!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, letterSpacing: 0.1),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          UserAvatarLoader(
                              avatar: video.avatar!, size: 18, radius: 9),
                          Padding(
                            padding: EdgeInsets.only(left: 6, right: 1),
                            child: Text(
                              video.author!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      Row(
                        // crossAxisAlignment: en,
                        children: [
                          const Icon(
                            size: 16,
                            TypIconData(0xE087),
                            // color: Color(0xbb000000),
                          ),
                          Text(" ${video.like!}")
                        ],
                      )
                    ],
                  ),
                ),
                // Divider()
              ],
            ),
          ),
        )
      ],
    );
  }

  static Widget buildWithIndex(
      BuildContext context, VideoInfoModel video, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShortVideoPlayPage(paramVideo: video)));
          },
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 5, bottom: 12),
                    child: ImageLoader(
                      width: 180,
                      height: (video.coverRatio! * 180),
                      url:
                          HttpGet.getApi(API.videoCover.api) + video.coverSha1!,
                        loadingWidget: Container(
                          width: 180,
                          alignment: Alignment.center,
                          color: Colors.grey.withOpacity(0.5),
                          child: const TDLoading(
                            icon: TDLoadingIcon.circle,
                            size: TDLoadingSize.large,
                          ),
                        )
                    )),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 6),
                  child: Text(
                    video.title!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, letterSpacing: 0.1),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          UserAvatarLoader(
                              avatar: video.avatar!, size: 18, radius: 9),
                          Padding(
                            padding: EdgeInsets.only(left: 6, right: 1),
                            child: Text(
                              video.author!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      Row(
                        // crossAxisAlignment: en,
                        children: [
                          const Icon(
                            size: 16,
                            TypIconData(0xE087),
                            // color: Color(0xbb000000),
                          ),
                          Text(" ${video.like!}")
                        ],
                      )
                    ],
                  ),
                ),
                // Divider()
              ],
            ),
          ),
        )
      ],
    );
  }
}
