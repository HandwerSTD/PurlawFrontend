import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/components/third_party/image_loader.dart';
import 'package:purlaw/models/account_mgr/user_info_model.dart';
import 'package:purlaw/viewmodels/account_mgr/account_video_list_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';

import '../../../common/constants.dart';
import '../../community/community_page.dart';

class AccountPageUserInfoBoard extends StatelessWidget {
  final UserInfoModel userInfoModel;
  const AccountPageUserInfoBoard({required this.userInfoModel, super.key});

  @override
  Widget build(BuildContext context) {
    // final themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    return Container(
      alignment: Alignment.center,
      height: 180,
      width: 300,
      child: Column(
        children: [
          UserAvatarLoader(avatar: userInfoModel.avatar, size: 108, radius: 54),
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 18),
            child: Text(
              userInfoModel.user,
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}

class UserAvatarLoader extends StatelessWidget {
  final String avatar;
  final double size;
  final double radius;
  const UserAvatarLoader({required this.avatar, required this.size, required this.radius, super.key});

  @override
  Widget build(BuildContext context) {
    return ImageLoader(
      url: HttpGet.getApi(API.userAvatar.api) + avatar,
      width: size,
      height: size,
      borderRadius: radius,
      errorWidget: Icon(Icons.account_circle_rounded, size: size * 0.8, color: Colors.grey,),
      loadingWidget: Icon(Icons.account_circle_rounded, size: size * 0.8, color: Colors.grey,),
    );
  }
}


class AccountPageVideoWaterfall extends StatefulWidget {
  final String userId;
  const AccountPageVideoWaterfall({required this.userId, super.key});

  @override
  State<AccountPageVideoWaterfall> createState() => _AccountPageVideoWaterfallState();
}

class _AccountPageVideoWaterfallState extends State<AccountPageVideoWaterfall> {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<AccountVideoListViewModel>(
      model: AccountVideoListViewModel(userId: widget.userId, context: context),
      onReady: (model){
        model.load();
      },
      builder: (context, model, _) {
        return MultiStateWidget(
          state: model.state,
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
        );
      },
    );
  }
}



