import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/viewmodels/community/short_video_search_viewmodel.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/views/community/community_page.dart';

import '../../components/purlaw/search_bar.dart';

void JumpToSearchPage(BuildContext context) {
  Navigator.push(
      context, MaterialPageRoute(builder: (_) => const CommunitySearchPage()));
}

class CommunitySearchPage extends StatelessWidget {
  final String? paramSearch;
  const CommunitySearchPage({this.paramSearch, super.key});

  @override
  Widget build(BuildContext context) {
    var cookie = Provider.of<MainViewModel>(context).cookies;
    return ProviderWidget<ShortVideoSearchViewModel>(
        model: ShortVideoSearchViewModel(),
        onReady: (model) {
          if (paramSearch != null) {
            model.searchVideo(cookie, paramSearch!);
          }
        },
        builder: (context, model, __) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: (){ Navigator.pop(context); },
              ),
              title: SearchAppBar(
                key: const Key('community_search_bar'),
                height: 48,
                hintLabel: '搜索',
                onSubmitted: (value) {
                  model.searchVideo(cookie, value);
                },
                readOnly: false,
                onTap: () {},
              ),
              bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(),),
              toolbarHeight: 72,
            ),
            body: PurlawWaterfallList(
              useTopPadding: false,
              list: List.generate((model.videoList.result?.length) ?? 0, (index) {
                return GridVideoBlock(
                  video: model.videoList.result![index],
                  indexInList: index,
                  videoList: model.videoList,
                  loadMore: model.loadMoreVideo,
                );
              }),
              controller: model.controller, onPullRefresh: () async {
              await model.searchVideo(getCookie(context, listen: false), model.text);
            }, loadingState: model.state, readyWidget: Container(),),
          );
        });
  }
}
