import 'package:flutter/material.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/community/community_page.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../local_example/local_example_video_category.dart';
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
                    return GridVideoBlock(video: videoList[categoryId][index], indexInList: index, videoList: VideoList(result: videoList[categoryId]), loadMore: (cookie){},);
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
