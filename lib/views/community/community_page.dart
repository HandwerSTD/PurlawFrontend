import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/components/purlaw/search_bar.dart';
import 'package:purlaw/components/purlaw/waterfall_list.dart';
import 'package:purlaw/components/third_party/image_loader.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/community/short_video_list_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';
import 'package:purlaw/views/account_mgr/my_account_page.dart';
import 'package:purlaw/views/community/community_category_page.dart';
import 'package:purlaw/views/community/community_search_page.dart';
import 'package:purlaw/views/community/private_message/private_message_user_list.dart';
import 'package:purlaw/views/community/short_video/short_video_play_page.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

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
          // margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          child: Stack(alignment: Alignment.topCenter, children: [
            CustomPurlawWaterfallList(
              leading: const RecommendedCategory(),
              refresherOffset: 40,
              controller: controller,
              list:
                  List.generate((model.videoList.result?.length) ?? 0, (index) {
                return GridVideoBlock(video: model.videoList.result![index]);
              }),
              onPullRefresh: () async {
                await model.fetchVideoList(getCookie(context, listen: false));
              },
              loadingState: model.state,
            ),
            Visibility(
              visible: (Responsive.checkWidth(constraints.maxWidth) !=
                  Responsive.lg),
              child: Row(
                children: [
                  Expanded(
                    child: SearchAppBar(
                      height: 48,
                      hintLabel: '搜索',
                      onSubmitted: (val) {},
                      readOnly: true,
                      onTap: () {
                        JumpToSearchPage(context);
                      },
                    ),
                  ),
                  fabShell(IconButton(
                      onPressed: () {
                        if (checkAndLoginIfNot(context)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const PrivateMessageUserListPage()));
                        }
                      },
                      padding: const EdgeInsets.only(bottom: 2),
                      icon: Icon(
                        EvaIcons.messageCircleOutline,
                        size: 22,
                        color: Theme.of(context).colorScheme.primary,
                      )))
                ],
              ),
            ),
          ])),
    );
  }

  Widget fabShell(Widget child) {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 8),
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: (TDTheme.defaultData().shadowsTop),
          color: getThemeModel(context).dark ? Colors.black : Theme.of(context).scaffoldBackgroundColor),
      child: child,
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
              // print(jsonEncode(video.toJson()));
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
          child: Container(
            margin: const EdgeInsets.only(top: 2, bottom: 4, left: 3, right: 3),
            decoration: BoxDecoration(
                border: (getThemeModel(context).dark
                    ? null
                    : Border.all(width: 0.1, color: Colors.grey[400]!)),
                borderRadius: BorderRadius.circular(4)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      getThemeModel(context).dark ? Colors.black : Colors.white,
                ),
                padding:
                    const EdgeInsets.only(top: 0, bottom: 8, left: 0, right: 0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 0, bottom: 12),
                            child: ImageLoader(
                              width: width,
                              height: (video.coverRatio! * width),
                              url: HttpGet.getApi(API.videoCover.api) +
                                  video.coverSha1!,
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
                            style:
                                const TextStyle(fontSize: 13, letterSpacing: 0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  UserAvatarLoader(
                                      verified: false,
                                      avatar: video.avatar!,
                                      size: 18,
                                      radius: 9),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 6, right: 1),
                                    child: Text(
                                      video.author!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                // crossAxisAlignment: en,
                                children: [
                                  const Icon(
                                    size: 16,
                                    EvaIcons.heartOutline,
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
                    );
                  }
                ),
              ),
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
                CupertinoPageRoute(
                    builder: (_) => ShortVideoPlayPage(paramVideo: video)));
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 5, bottom: 12),
                    child: ImageLoader(
                        width: 180,
                        height: (video.coverRatio! * 180),
                        url: HttpGet.getApi(API.videoCover.api) +
                            video.coverSha1!,
                        loadingWidget: Container(
                          width: 180,
                          alignment: Alignment.center,
                          color: Colors.grey.withOpacity(0.5),
                          child: const TDLoading(
                            icon: TDLoadingIcon.circle,
                            size: TDLoadingSize.large,
                          ),
                        ))),
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
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          UserAvatarLoader(
                              verified: false,
                              avatar: video.avatar!,
                              size: 18,
                              radius: 9),
                          Padding(
                            padding: const EdgeInsets.only(left: 6, right: 1),
                            child: Text(
                              video.author!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      Row(
                        // crossAxisAlignment: en,
                        children: [
                          const Icon(
                            EvaIcons.heartOutline,
                            size: 16,
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

class RecommendedCategory extends StatelessWidget {
  const RecommendedCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 12,
        ),
        const Text(
          "   精选分区",
          style: TextStyle(fontSize: 20),
        ),
        Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 28),
          child: ListView(
            padding: const EdgeInsets.only(left: 12, top: 12, bottom: 4),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityCategoryPage(categoryId: 0, title: '时讯', subtitle: '最新讯息', gradientColor: [
                    getThemeModel(_).dark ? Colors.blueGrey : Colors.white, Colors.blue
                  ],)));
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(left: 2),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.only(topRight: Radius.circular(12)),
                        image: DecorationImage(
                            image: Image.asset(
                          "assets/video_category/category1.png",
                          width: 100,
                        ).image)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityCategoryPage(categoryId: 1, title: '普法', subtitle: '专家讲解', gradientColor: [
                    getThemeModel(_).dark ? Colors.blueGrey: Colors.white, Colors.cyanAccent
                  ],)));
                  },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(left: 18),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.only(topRight: Radius.circular(12)),
                        image: DecorationImage(
                            image: Image.asset(
                          "assets/video_category/category2.png",
                          width: 100,
                        ).image)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityCategoryPage(categoryId: 2, title: '名案', subtitle: '经典案例', gradientColor: [
                    getThemeModel(_).dark ? Colors.green : Colors.white, Colors.greenAccent
                  ])));
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(left: 18, right: 16),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.only(topRight: Radius.circular(12)),
                        image: DecorationImage(
                            image: Image.asset(
                          "assets/video_category/category3.png",
                          width: 100,
                        ).image)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Text(
          "   热门推荐",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }
}
