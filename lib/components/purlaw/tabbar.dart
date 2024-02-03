import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/components/third_party/modified_td_bottom_tab_bar.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../common/utils/misc.dart';
import '../../models/theme_model.dart';

class PurlawTabBarConfig extends TDBottomTabBarTabConfig {
  PurlawTabBarConfig({required super.onTap, required super.tabText});
}

class PurlawAppMainPageTabBar extends StatefulWidget {
  static const double avoidancePadding = 96;

  final Widget leftButton;
  final Widget rightButton;
  final List<PurlawTabBarConfig> tabs;
  final int selectedTab;
  const PurlawAppMainPageTabBar(
      {required this.leftButton,
      required this.rightButton,
      required this.tabs,
      required this.selectedTab,
      super.key});

  @override
  State<PurlawAppMainPageTabBar> createState() =>
      _PurlawAppMainPageTabBarState();
}

class _PurlawAppMainPageTabBarState extends State<PurlawAppMainPageTabBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    // Color bg = themeModel.themeData.colorScheme.background;
    return LayoutBuilder(
      builder: (_, constraints) {
        String screenType = Responsive.checkWidth(constraints.maxWidth);
        // Log.i("[DEBUG] screenType = $screenType");
        bool rBreak = screenType == Responsive.lg;
        Color bg = (rBreak
            ? themeModel.colorModel.secondarySurfaceColor
            : Colors.transparent);
        return Container(
          height: 64,
          width: constraints.maxWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          margin: EdgeInsets.only(top: (rBreak ? 16 : 0), left: (rBreak ? 16 : 0), right: (rBreak ? 16 : 0)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              fabShell(widget.leftButton, rBreak),
              SizedBox(
                  width: (rBreak ? 400 : 220),
                  child: (rBreak
                      ? _capsuleTabBar(context, bg)
                      : _fixedTabBar(context, bg))),
              fabShell(widget.rightButton, rBreak)
            ],
          ),
        );
      },
    );
  }

  Widget _fixedTabBar(BuildContext context, Color bg) {
    return Container(
      child: ModifiedTDBottomTabBar(
        TDBottomTabBarBasicType.text,
        useVerticalDivider: false,
        navigationTabs: widget.tabs,
        showTopBorder: false,
        backgroundColor: bg,
        selectedTab: widget.selectedTab,
      ),
    );
  }

  Widget _capsuleTabBar(BuildContext context, Color bg) {
    return SizedBox(
      width: Responsive.smallDp,
      child: ModifiedTDBottomTabBar(TDBottomTabBarBasicType.text,
          componentType: TDBottomTabBarComponentType.label,
          outlineType: TDBottomTabBarOutlineType.capsule,
          useVerticalDivider: true,
          navigationTabs: widget.tabs,
          backgroundColor: bg,
          selectedTab: widget.selectedTab),
    );
  }

  Widget fabShell(Widget child, bool rb) {
    final themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: (rb ? TDTheme.defaultData().shadowsTop : null),
          color: (rb
              ? themeModel.colorModel.secondarySurfaceColor
              : Colors.transparent)),
      child: child,
    );
  }
}

class PurlawPageTab extends StatelessWidget {
  final List<TDTab>? tabs;
  final TabController controller;
  final List<Widget>? children;
  const PurlawPageTab(
      {this.tabs, required this.controller, this.children, super.key});

  @override
  Widget build(BuildContext context) {
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    return TDTabBar(
      tabs: tabs!,
      controller: controller,
      backgroundColor: themeModel.themeData.colorScheme.background,
      indicatorColor: (themeModel.dark ? themeModel.colorModel.generalFillColorLight : themeModel.colorModel.generalFillColor),
      labelColor: (themeModel.dark ? themeModel.colorModel.generalFillColorLight : themeModel.colorModel.generalFillColor),
      unselectedLabelColor: Colors.grey,
      showIndicator: true,
    );
  }

  Widget buildView(BuildContext context) {
    return TDTabBarView(controller: controller,children: children!,);
  }
}
