import 'package:flutter/material.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/community/community_page.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../models/community/short_video_info_model.dart';

class CommunityCategoryPage extends StatelessWidget {
  final int categoryId;
  final String title;
  final String subtitle;
  final List<Color> gradientColor;
  const CommunityCategoryPage({super.key, required this.categoryId, required this.title, required this.subtitle, required this.gradientColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool break4 =
          (constraints.maxWidth > 800), break3 = (constraints.maxWidth > 500);
          return Container(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  collapsedHeight: 70,
                  expandedHeight: 230,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColor, begin: const Alignment(-1.5, 0)),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))
                      ),
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: getThemeModel(context).themeData.colorScheme.onBackground, fontSize: 20),),
                        Text(subtitle, style: TextStyle(color: getThemeModel(context).themeData.colorScheme.onBackground, fontSize: 12),)
                      ],
                    ),
                  ),
                  stretch: true,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 12,),
                ),
                SliverWaterfallFlow(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return GridVideoBlock(video: videoList[categoryId][index]);
                  }, childCount: videoList[categoryId].length),
                  gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (break4 ? 4 : (break3 ? 3 : 2)),
                ))
              ],
            ),
          );
        }
      ),
    );
  }
}

final testVideo = VideoInfoModel(
    uid: "65f0009ca21f65c0585d7ece",
    title: "长视频测试",
    description: "233",
    author: "futz12",
    authorId: "65eff60080e1e8bf03e05729",
    like: 1,
    tags: "测试",
    commentsId: "65f0009ca21f65c0585d7ecd",
    sha1: "1f07bc836fd2e475e4b1b286e1ca7d3add0f4228",
    coverSha1: "1917d99b0f4dc457581b4af2f030eee02c0d12af",
    timestamp: 1710227612.4492388,
    avatar: "0434f4e8c89df3a5f5cc56b823cf2b031b56dd84", coverRatio: 0.5625);

List<List<VideoInfoModel>> videoList = [
  List.generate(20, (index) => testVideo),
  List.generate(20, (index) => testVideo),
  List.generate(20, (index) => testVideo),
];

