import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/components/purlaw/button.dart';
import 'package:purlaw/components/purlaw/search_bar.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/community/short_video_play_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/account_login.dart';
import 'package:purlaw/views/account_mgr/account_visit_page.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';
import 'package:purlaw/views/account_mgr/my_account_page.dart';
import 'package:purlaw/views/community/community_page.dart';
import 'package:purlaw/views/community/community_search_page.dart';
import 'package:purlaw/views/community/short_video/short_video_comment_page.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../../common/utils/misc.dart';

class ShortVideoPlayPage extends StatefulWidget {
  final VideoInfoModel paramVideo;
  const ShortVideoPlayPage({required this.paramVideo, super.key});

  @override
  State<ShortVideoPlayPage> createState() => _ShortVideoPlayPageState();
}

class _ShortVideoPlayPageState extends State<ShortVideoPlayPage> {
  String cookie = "";

  @override
  void initState() {
    super.initState();
    var _ = eventBus.on<ShortVideoPlayBlockEventBus>().listen((event) {
      if (event.needNavigate) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AccountLoginPage(showBack: true)));
      }
    });
    _.resume();
  }

  @override
  Widget build(BuildContext context) {
    String cookie = Provider.of<MainViewModel>(context).cookies;
    // 这里应该会重新加载吧。。都监听了
    return ProviderWidget<ShortVideoPlayViewModel>(
      model: ShortVideoPlayViewModel.fromSingleVideo(widget.paramVideo),
      onReady: (model) {
        // load 10
        model.loadMoreVideo(cookie);
      },
      builder: (context, model, _) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0, //去除状态栏下的一条阴影
          toolbarHeight: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Container(
          // padding: EdgeInsets.only(top: 24),
          child: PageView.builder(
            controller: model.controller,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              if (index == model.videoList.result!.length - 1) {
                print("[ShortVideoPlay] Scrolled to end");
                model.loadMoreVideo(cookie);
              }
            },
            itemCount: model.videoList.result!.length,
            itemBuilder: (BuildContext context, int index) {
              return VideoPlayBlock(nowPlaying: model.videoList.result![index]);
            },
          ),
        ),
      ),
    );
  }
}

class ShortVideoPlayByList extends StatefulWidget {
  final VideoList videoList;
  final int videoIndex;
  final Function loadMoreVideo;
  const ShortVideoPlayByList(
      {required this.videoList,
      required this.videoIndex,
      required this.loadMoreVideo,
      super.key});

  @override
  State<ShortVideoPlayByList> createState() => _ShortVideoPlayByListState();
}

class _ShortVideoPlayByListState extends State<ShortVideoPlayByList> {
  late StreamSubscription _;

  @override
  void initState() {
    super.initState();
    _ = eventBus.on<ShortVideoPlayBlockEventBus>().listen((event) {
      if (event.needNavigate) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AccountLoginPage(showBack: true)));
      }
    });
    _.resume();
  }
  @override
  void dispose() {
    super.dispose();
    _.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String cookie = Provider.of<MainViewModel>(context).cookies;
    // 这里应该会重新加载吧。。都监听了
    return ProviderWidget<ShortVideoPlayByListViewModel>(
      model: ShortVideoPlayByListViewModel(
          videoList: widget.videoList,
          pageIndex: widget.videoIndex,
          loadMoreVideo: widget.loadMoreVideo),
      onReady: (model) {},
      builder: (context, model, _) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0, //去除状态栏下的一条阴影
          toolbarHeight: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Container(
          // padding: EdgeInsets.only(top: 24),
          child: PageView(
            controller: model.controller,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) async {
              if (index == model.videoList.result!.length - 1) {
                print("[ShortVideoPlay] Scrolled to end");
                model.loadMoreVideo(cookie);
              }
            },
            children: model.pageList,
          ),
        ),
      ),
    );
  }
}

class VideoPlayBlock extends StatefulWidget {
  final VideoInfoModel nowPlaying;
  const VideoPlayBlock({super.key, required this.nowPlaying});

  @override
  State<VideoPlayBlock> createState() => _VideoPlayBlockState();
}

class _VideoPlayBlockState extends State<VideoPlayBlock> {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ShortVideoPlayBlockViewModel>(
      model: ShortVideoPlayBlockViewModel(
          nowPlaying: widget.nowPlaying, context: context),
      onReady: (model) {
        model.cookie =
            Provider.of<MainViewModel>(context, listen: false).cookies;
        model.load();
      },
      builder: (context, model, _) => Stack(
        alignment: Alignment.topLeft,
        children: [
          Column(
            children: [
              Flexible(
                  child: GestureDetector(
                onTap: () {
                  if (!model.loaded) return;
                  if (model.videoController.isPlaying) {
                    model.pauseVideo();
                  } else {
                    model.resumeVideo();
                  }
                },
                onDoubleTap: () {
                  if (!model.loaded) return;
                  model.switchVideoLike();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                            child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              child: model.loaded
                                  ? Chewie(
                                      controller: model.videoController,
                                    )
                                  : const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                            ),
                            bottomWidget(widget.nowPlaying, context),
                          ],
                        )),
                      ],
                    ),
                    pauseIcon(model)
                  ],
                ),
              ))
            ],
          ),
          topBackButton()
        ],
      ),
    );
  }

  Widget pauseIcon(ShortVideoPlayBlockViewModel model) {
    return ValueListenableBuilder(
        valueListenable: model.videoPlayerController,
        builder: (context, value, child) {
          if (model.loaded && value.isBuffering)
            return CircularProgressIndicator();
          return Icon(
            Icons.play_arrow,
            color: ((!model.loaded || (model.loaded && value.isPlaying))
                ? Colors.transparent
                : Colors.white54),
            shadows: ((!model.loaded || (model.loaded && value.isPlaying))
                ? []
                : kElevationToShadow[6]),
            size: 60,
          );
        });
  }

  Widget topBackButton() {
    var appBarHeight = 56.0;
    return Container(
      height: appBarHeight,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 6),
      decoration: const BoxDecoration(
          // color: Colors.black12
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.transparent])),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  Widget bottomWidget(VideoInfoModel video, BuildContext context) {
    var model = Provider.of<ShortVideoPlayBlockViewModel>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
            child: Container(
          padding: EdgeInsets.only(bottom: 36, left: 4, right: 4),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment(0, 0.5),
                  colors: [Colors.black54, Colors.transparent])),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 18, right: 8, top: 0, bottom: 12),
                          child: GestureDetector(
                            onDoubleTap: () {
                              print("[ShortVideoPlay] test for double tap");
                            },
                            onTap: () {
                              if (!model.loaded) return;
                              print("[ShortVideoPlay] open desc");
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 24,
                                              right: 24,
                                              top: 24,
                                              bottom: 0),
                                          child: Text(
                                            video.title!,
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 4),
                                          child: Text(
                                            TimeUtils.formatDateTime(
                                                video.timestamp!.toInt()),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              left: 24, right: 24),
                                          child: Divider(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 24, right: 24, bottom: 24),
                                          child: Text(
                                            video.description!,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        )
                                      ],
                                    );
                                  });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                authorInfo(context, video),
                                Text(
                                  video.title!,
                                  style: TextStyle(
                                      shadows: kElevationToShadow[3],
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                )
                              ],
                            ),
                          ))),
                  bottomFAB(context, video)
                ],
              ),
              // LinearProgressIndicator()
              Row(
                children: [
                  Expanded(
                    child: VideoProgressIndicator(model.videoPlayerController,
                        allowScrubbing: true),
                  ),
                  ValueListenableBuilder(
                      valueListenable: model.videoPlayerController,
                      builder: (context, value, child) {
                        return Text(
                          "  ${TimeUtils.getDurationTimeString(value.position, value.duration)}",
                          style: TextStyle(color: Colors.white),
                        );
                      })
                ],
              )
            ],
          ),
        ))
      ],
    );
  }

  Widget authorInfo(BuildContext context, VideoInfoModel video) {
    var model = Provider.of<ShortVideoPlayBlockViewModel>(context);
    return GestureDetector(
      onTap: () {
        if (!model.loaded) return;
        model.pauseVideo();
        Navigator.push(context, MaterialPageRoute(builder: (_) => AccountVisitPage(userId: video.authorId!)));
        // todo: pause & jump
      },
      child: Container(
        margin: EdgeInsets.only(left: 0, top: 4, bottom: 12),
        child: Row(
          children: [
            UserAvatarLoader(
              avatar: video.avatar!,
              size: 48,
              radius: 24,
            ),
            Padding(
              padding: EdgeInsets.only(left: 12, top: 2),
              child: Text(
                video.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomFAB(BuildContext context, VideoInfoModel video) {
    var model = Provider.of<ShortVideoPlayBlockViewModel>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        bottomFABSingle(
            icon:
                (video.meLiked == 1 ? Icons.thumb_up : Icons.thumb_up_outlined),
            onPressed: () {
              print("switchVideoLike");
              if (getCookie(context, listen: false).isEmpty) {
                TDToast.showText('请先登录', context: context);
                Future.delayed(Duration(seconds: 1)).then((value) {
                  checkAndLoginIfNot(context);
                });
                return;
              }
              model.switchVideoLike();
            }),
        bottomFABSingle(
            icon: Icons.comment,
            onPressed: () {
              if (!model.loaded) return;
              model.pauseVideo();
              Navigator.push(context, MaterialPageRoute(builder: (_) => ShortVideoCommentPage(video: video)));
            }),
        bottomFABSingle(
            icon: Icons.share,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("暂未开放"),
                duration: Duration(milliseconds: 1000),
              ));
            }),
      ],
    );
  }

  Widget bottomFABSingle(
      {required IconData icon, required Function onPressed}) {
    return Container(
      height: 52,
      width: 52,
      margin: const EdgeInsets.all(12),
      child: IconButton(
        onPressed: () {
          onPressed();
        },
        icon: Icon(
          icon,
          size: 36,
          shadows: [fabBoxShadow],
          color: Colors.white,
        ),
      ),
    );
  }
}

final BoxShadow fabBoxShadow = BoxShadow(
    color: Colors.black,
    offset: Offset.fromDirection(1, 1),
    spreadRadius: 3,
    blurRadius: 5);

// 烂活，已经没用了
// class ShortVideoRefreshPage extends StatelessWidget {
//   const ShortVideoRefreshPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff212121),
//       appBar: AppBar(
//         backgroundColor: Color(0xff212121),
//         foregroundColor: Colors.white,
//       ),
//       body: Container(
//         alignment: Alignment.center,
//         child: Container(
//           margin: EdgeInsets.only(bottom: 48),
//           height: 180,
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Text("视频", style: TextStyle(fontSize: 24),),
//               PurlawRRectButton(
//                   backgroundColor: Provider.of<ThemeViewModel>(context)
//                       .themeModel
//                       .colorModel
//                       .generalFillColor,
//                   width: 144,
//                   height: 54,
//                   radius: 12,
//                   child: const Text(
//                     "刷新视频",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   onClick: () {
//                     String cookie =
//                         Provider.of<MainViewModel>(context, listen: false)
//                             .cookies;
//                     var model = Provider.of<ShortVideoPlayViewModel>(context,
//                         listen: false);
//                     model.videoList.result!.clear();
//                     // model.pageList.removeRange(1, model.pageList.length);
//                     model.loadMoreVideo(cookie).then((value) {
//                       model.controller.nextPage(
//                           duration: Duration(milliseconds: 700),
//                           curve: Curves.ease);
//                     });
//                   }),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "或者  ",
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                   SizedBox(
//                     width: 300,
//                     child: SearchAppBar(
//                         hintLabel: "搜索",
//                         onSubmitted: (val) {},
//                         readOnly: true,
//                         onTap: () {
//                           JumpToSearchPage(context);
//                         }),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
