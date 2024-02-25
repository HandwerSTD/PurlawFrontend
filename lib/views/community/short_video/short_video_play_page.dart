import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/components/third_party/modified_video_progress.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/community/short_video_play_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/account_login.dart';
import 'package:purlaw/views/account_mgr/account_visit_page.dart';
import 'package:purlaw/views/account_mgr/components/account_page_components.dart';
import 'package:purlaw/views/account_mgr/my_account_page.dart';
import 'package:purlaw/views/community/short_video/short_video_comment_page.dart';
import 'package:video_player/video_player.dart';
import '../../../common/utils/misc.dart';
import 'package:purlaw/common/utils/log_utils.dart';

import '../../../components/third_party/prompt.dart';

const tag = "ShortVideo PlayPage";
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
      model: ShortVideoPlayViewModel.fromSingleVideo(widget.paramVideo, context),
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
        body: PageView.builder(
          controller: model.controller,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            if (index == model.videoList.result!.length - 1) {
              Log.d(tag: tag, "[ShortVideoPlay] Scrolled to end");
              model.loadMoreVideo(cookie);
            }
          },
          itemCount: model.videoList.result!.length,
          itemBuilder: (BuildContext context, int index) {
            return VideoPlayBlock(nowPlaying: model.videoList.result![index]);
          },
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
                Log.i(tag: tag, "[ShortVideoPlay] Scrolled to end");
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
  bool favorite = false;

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ShortVideoPlayBlockViewModel>(
      model: ShortVideoPlayBlockViewModel(
          nowPlaying: widget.nowPlaying),
      onReady: (model) {
        favorite = FavoriteDatabaseUtil.getIsFavorite(model.nowPlaying.uid!);
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
                              padding: const EdgeInsets.all(2),
                              child: Builder(builder: (context) {
                                if (model.loadError) {
                                  return Icon(
                                  Icons.error_outline_rounded,
                                  color: (Colors.white.withOpacity(0.8)),
                                  shadows: (kElevationToShadow[6]),
                                  size: 72,
                                );
                                }
                                return model.loaded
                                    ? Chewie(
                                  controller: model.videoController,
                                )
                                    : const CircularProgressIndicator(
                                  color: Colors.white,
                                );
                              }),
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
          if (model.loaded && value.isBuffering) {
            return const CircularProgressIndicator();
          }
          return Icon(
            Icons.play_arrow_rounded,
            color: ((!model.loaded || (model.loaded && value.isPlaying))
                ? Colors.transparent
                : Colors.white.withOpacity(0.8)),
            shadows: ((!model.loaded || (model.loaded && value.isPlaying))
                ? []
                : kElevationToShadow[6]),
            size: 72,
          );
        });
  }

  Widget topBackButton() {
    var appBarHeight = 56.0;
    return Container(
      height: appBarHeight,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(left: 6),
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
          padding: const EdgeInsets.only(bottom: 36, left: 4, right: 4),
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
                              Log.d(tag: tag, "test for double tap");
                            },
                            onTap: () {
                              // if (!model.loaded) return;
                              Log.d(tag: tag, "open desc");
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: getThemeModel(context).themeData.scaffoldBackgroundColor,
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 24,  top: 12, right: 24),

                                            child: Row(
                                              children: [
                                                UserAvatarLoader(
                                                  verified: false,
                                                  avatar: video.avatar!,
                                                  size: 40,
                                                  radius: 20,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 12, top: 2),
                                                  child: Text(
                                                    video.author!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Theme.of(context).colorScheme.onBackground,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 24,
                                                right: 24,
                                                top: 12,
                                                bottom: 0),
                                            child: Text(
                                              video.title!,
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 4),
                                            child: Text(
                                              "${
                                                TimeUtils.formatDateTime(
                                                    video.timestamp!.toInt())
                                              }\n标签：${video.tags}",
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
                                      ),
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
                                      fontSize: 14,
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
                    child: ModifiedVideoProgressIndicator(model.videoPlayerController,
                        allowScrubbing: true, colors: VideoProgressColors(
                        playedColor: getThemeModel(context).colorModel.generalFillColorLight,
                        bufferedColor: Colors.grey
                      ),),
                  ),
                  ValueListenableBuilder(
                      valueListenable: model.videoPlayerController,
                      builder: (context, value, child) {
                        return Text(
                          "  ${TimeUtils.getDurationTimeString(value.position, value.duration)}",
                          style: const TextStyle(color: Colors.white),
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
        // if (!model.loaded) return;
        // model.pauseVideo();
        if (model.loaded) {
          model.pauseVideo();
        } else {
          model.autoPlay = false;
        }
        Navigator.push(context, PageRouteBuilder(
            pageBuilder: (_, __, ___) => AccountVisitPage(userId: video.authorId!),
          transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, anim, secAnim, child) {
          return SlideTransition(position: anim.drive(Tween(
            begin: const Offset(0, 1),
            end: Offset.zero
          ).chain(CurveTween(curve: Curves.linearToEaseOut))),child: child,);
          }
        ),).then((value) {
          model.autoPlay = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 0, top: 4, bottom: 12),
        child: Row(
          children: [
            UserAvatarLoader(
              verified: false,
              avatar: video.avatar!,
              size: 40,
              radius: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text(
                video.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14,
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
          color: (video.meLiked != 1 ? Colors.white : getThemeModel(context).colorModel.generalFillColorBright),
            icon:
                (Icons.thumb_up_rounded),
            onPressed: () {
              Log.i(tag: tag, "switchVideoLike");
              if (getCookie(context, listen: false).isEmpty) {
                showToast("请先登录", toastType: ToastType.warning);
                Future.delayed(const Duration(seconds: 1)).then((value) {
                  checkAndLoginIfNot(context);
                });
                return;
              }
              model.switchVideoLike();
            }),
        bottomFABSingle(
          color: Colors.white.withOpacity(0.9),
            icon: Icons.comment_rounded,
            onPressed: () {
              // if (!model.loaded) return;
              // model.pauseVideo();
              if (model.loaded) {
                model.pauseVideo();
              } else {
                model.autoPlay = false;
              }
              Navigator.push(context, CupertinoPageRoute(builder: (_) => ShortVideoCommentPage(video: video))).then((value) {
                model.autoPlay = true;
              });
            }),
        bottomFABSingle(
          showOverlay: false,
            color: (!favorite ? Colors.white : getThemeModel(context).colorModel.generalFillColor),
          iconSize: 50,
            margin: const EdgeInsets.only(top: 6, bottom: 12, right: 12),
            icon: (Icons.star_rounded),
            onPressed: () {
              // if (!model.loaded) return;
              FavoriteDatabaseUtil.storeFavorite(model.nowPlaying, !favorite);
              setState(() {
                favorite = !favorite;
              });
            }),
        bottomFABSingle(
          color: Colors.white,
            icon: Icons.share_rounded,
            margin: const EdgeInsets.only(top: 12, bottom: 36, right: 12, left: 12),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("暂未开放"),
                duration: Duration(milliseconds: 1000),
              ));
            }),
      ],
    );
  }

  Widget bottomFABSingle(
      {required IconData icon, required Function onPressed, double iconSize = 40, EdgeInsetsGeometry? margin, required Color color, bool showOverlay = true}) {
    return Container(
      height: 52,
      width: 52,
      margin: (margin?? const EdgeInsets.all(12)),
      child: IconButton(
        style: (showOverlay ? null : const ButtonStyle(
          overlayColor: MaterialStatePropertyAll(Colors.transparent)
        )),
        onPressed: () {
          onPressed();
        },
        icon: Icon(
          icon,
          size: iconSize,
          shadows: [fabBoxShadow],
          color: color.withOpacity(0.85),
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
