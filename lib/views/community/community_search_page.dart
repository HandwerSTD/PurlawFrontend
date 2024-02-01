import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/models/community/short_video_info_model.dart';
import 'package:purlaw/viewmodels/community/short_video_list_viewmodel.dart';
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
                icon: Icon(Icons.arrow_back),
                onPressed: (){ Navigator.pop(context); },
              ),
              title: SearchAppBar(
                height: 48,
                hintLabel: '搜索',
                onSubmitted: (value) {
                  model.searchVideo(cookie, value);
                },
                readOnly: false,
                onTap: () {},
              ),
              bottom: PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(),),
              toolbarHeight: 72,
            ),
            body: CommunitySearchPageBody(),
          );
        });
  }
}

class CommunitySearchPageBody extends StatefulWidget {
  const CommunitySearchPageBody({super.key});

  @override
  State<CommunitySearchPageBody> createState() =>
      _CommunitySearchPageBodyState();
}

class _CommunitySearchPageBodyState extends State<CommunitySearchPageBody> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ShortVideoSearchViewModel>(
        model: Provider.of<ShortVideoSearchViewModel>(context),
        onReady: (_) {},
        builder: (_, model, __) => MultiStateWidget(
              builder: (_) => PurlawWaterfallList(
                useTopPadding: false,
                  list: List.generate(model.videoList.result!.length, (index) {
                    return GridVideoBlock(
                      video: model.videoList.result![index],
                      indexInList: index,
                      videoList: model.videoList,
                      loadMore: model.loadMoreVideo,
                    );
                  }),
                  controller: controller),
              state: model.state,
          readyWaitingWidget: Container()
            ));
  }
}
