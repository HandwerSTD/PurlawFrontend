import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 导航栏默认高度
const double _kDefaultTabBarHeight = 56;
/// 展开项弹窗 单个item默认宽度为按钮宽度-20
const double _kDefaultMenuItemWidthShrink = 20;

class ModifiedTDBottomTabBar extends StatefulWidget {
  ModifiedTDBottomTabBar(
      this.basicType, {
        Key? key,
        this.componentType = TDBottomTabBarComponentType.label,
        this.outlineType = TDBottomTabBarOutlineType.filled,
        required this.navigationTabs,
        this.barHeight = _kDefaultTabBarHeight,
        this.useVerticalDivider,
        this.dividerHeight,
        this.dividerThickness,
        this.backgroundColor,
        this.dividerColor,
        required this.selectedTab,
        this.showTopBorder = true,
        this.topBorder,
        this.useSafeArea = true,
      })  : assert(() {
    if (navigationTabs.isEmpty) {
      throw FlutterError(
          '[TDBottomTabBar] please set at least one tab!');
    }
    if (basicType == TDBottomTabBarBasicType.text) {
      for (final item in navigationTabs) {
        if (item.tabText == null) {
          throw FlutterError(
              '[TDBottomTabBar] type is TDBottomBarType.text, but not set text.');
        }
      }
    }
    if (basicType == TDBottomTabBarBasicType.icon) {
      for (final item in navigationTabs) {
        if (item.iconTypeConfig == null) {
          throw FlutterError(
              '[TDBottomTabBar] type is TDBottomBarType.icon,'
                  'but has no iconTypeConfig instance.');
        }
      }
    }
    if (basicType == TDBottomTabBarBasicType.iconText) {
      for (final item in navigationTabs) {
        if (item.iconTextTypeConfig == null) {
          throw FlutterError(
              '[TDBottomTabBar] type is TDBottomBarType.iconText,'
                  'but has no iconTextConfig instance.');
        }
      }
    }
    return true;
  }()),
        super(key: key);

  int selectedTab;
  
  /// 基本样式（纯文本、纯图标、图标+文本）
  final TDBottomTabBarBasicType basicType;

  /// 选项样式 默认label
  final TDBottomTabBarComponentType? componentType;

  /// 标签栏样式 默认filled
  final TDBottomTabBarOutlineType? outlineType;

  /// tabs配置
  final List<TDBottomTabBarTabConfig> navigationTabs;

  /// tab高度
  final double? barHeight;

  /// 是否使用竖线分隔(如果选项样式为label则强制为false)
  final bool? useVerticalDivider;

  /// 分割线高度（可选）
  final double? dividerHeight;

  /// 分割线厚度（可选）
  final double? dividerThickness;

  /// 分割线颜色（可选）
  final Color? dividerColor;

  final Color? backgroundColor;

  /// 是否展示bar上边线（设置为true 但是topBorder样式未设置，则使用默认值,非胶囊型才生效）
  final bool? showTopBorder;

  /// 上边线样式
  final BorderSide? topBorder;

  /// 使用安全区域
  final bool useSafeArea;

  @override
  State<ModifiedTDBottomTabBar> createState() => _ModifiedTDBottomTabBarState();
}

class _ModifiedTDBottomTabBarState extends State<ModifiedTDBottomTabBar> {

  @override
  Widget build(BuildContext context) {
    var isCapsuleOutlineType =
        widget.outlineType == TDBottomTabBarOutlineType.capsule;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        /// -2 是为了增加边框
        var maxWidth =
            double.parse(constraints.biggest.width.toStringAsFixed(1)) - 2;

        /// 胶囊样式 比正常样式宽度要小32
        if (isCapsuleOutlineType) {
          maxWidth -= 32;
        }
        var itemWidth = maxWidth / widget.navigationTabs.length;

        Widget result = Container(
            height: widget.barHeight ?? _kDefaultTabBarHeight,
            alignment: Alignment.center,
            margin: isCapsuleOutlineType
                ? const EdgeInsets.symmetric(horizontal: 16)
                : null,
            decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius:
                isCapsuleOutlineType ? BorderRadius.circular(56) : null,
                border: widget.showTopBorder! && !isCapsuleOutlineType
                    ? Border(
                    top: widget.topBorder ??
                        BorderSide(
                            color: TDTheme.of(context).grayColor3,
                            width: 0.5))
                    : null,
                boxShadow: isCapsuleOutlineType
                    ? TDTheme.of(context).shadowsTop
                    : null),
            child: Stack(alignment: Alignment.center, children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                  List.generate(widget.navigationTabs.length, (index) {
                    return _item(index, itemWidth);
                  })),
              _verticalDivider(),
            ]));
        if(widget.useSafeArea){
          result = SafeArea(child: result);
        }
        return result;
      },
    );
  }

  void _onTap(int index) {
    setState(() {
      if (widget.selectedTab != index) {
        widget.selectedTab = index;
        widget.navigationTabs[index].onTap?.call();
      }
    });
  }

  Widget _item(int index, double itemWidth) {
    var tabItemConfig = widget.navigationTabs[index];
    return Container(
        height: widget.barHeight ?? _kDefaultTabBarHeight,
        width: itemWidth,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: ModifiedTDBottomTabBarItemWithBadge(
          basicType: widget.basicType,
          componentType:
          widget.componentType ?? TDBottomTabBarComponentType.label,
          outlineType: widget.outlineType ?? TDBottomTabBarOutlineType.filled,
          itemConfig: tabItemConfig,
          isSelected: index == widget.selectedTab,
          itemHeight: widget.barHeight ?? _kDefaultTabBarHeight,
          itemWidth: itemWidth,
          tabsLength: widget.navigationTabs.length,
          onTap: () {
            _onTap(index);
          },
        ));
  }

  Widget _verticalDivider() {
    if (widget.componentType == TDBottomTabBarComponentType.label) {}
    return Visibility(
      visible: widget.componentType != TDBottomTabBarComponentType.label &&
          (widget.useVerticalDivider ?? false),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.navigationTabs.length - 1, (index) {
          return SizedBox(
            width: widget.dividerThickness ?? 0.5,
            height: widget.dividerHeight ?? 32,
            child: VerticalDivider(
              color: widget.dividerColor ?? TDTheme.of(context).grayColor3,
              thickness: widget.dividerThickness ?? 0.5,
            ),
          );
        }),
      ),
    );
  }
}


class ModifiedTDBottomTabBarItemWithBadge extends StatelessWidget {
  const ModifiedTDBottomTabBarItemWithBadge(
      {Key? key,
        required this.basicType,
        required this.componentType,
        required this.outlineType,
        required this.itemConfig,
        required this.isSelected,
        required this.itemHeight,
        required this.itemWidth,
        required this.onTap,
        required this.tabsLength})
      : super(key: key);

  /// tab基本类型
  final TDBottomTabBarBasicType basicType;

  /// tab选中背景类型
  final TDBottomTabBarComponentType componentType;

  //
  final TDBottomTabBarOutlineType outlineType;

  /// 单个tab的属性配置
  final TDBottomTabBarTabConfig itemConfig;

  /// 选中状态
  final bool isSelected;

  /// tab高度
  final double itemHeight;

  /// tab宽度
  final double itemWidth;

  /// 点击事件
  final GestureTapCallback onTap;

  /// tab总个数
  final int tabsLength;

  @override
  Widget build(BuildContext context) {
    var popUpButtonConfig = itemConfig.popUpButtonConfig;
    var badgeConfig = itemConfig.badgeConfig;
    var isInOrOutCapsule = componentType == TDBottomTabBarComponentType.label ||
        outlineType == TDBottomTabBarOutlineType.capsule;
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap.call();
        if (itemConfig.popUpButtonConfig != null) {
          Navigator.push(
              context,
              PopRoute(
                child: PopupDialog(
                  itemWidth - _kDefaultMenuItemWidthShrink,
                  btnContext: context,
                  config: popUpButtonConfig!.popUpDialogConfig,
                  items: popUpButtonConfig.items,
                  onClickMenu: (value) {
                    popUpButtonConfig.onChanged(value);
                  },
                ),
              ));
        }
      },
      child: Container(
        height: itemHeight,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Visibility(
                visible: componentType == TDBottomTabBarComponentType.label &&
                    isSelected,
                child: Container(
                  /// 设计稿上 tab个数大于3时，左右边距为8，小于等于3时，左右边距为12
                  width: itemWidth - (tabsLength > 3 ? 16 : 24),
                  height: basicType == TDBottomTabBarBasicType.text ||
                      basicType == TDBottomTabBarBasicType.expansionPanel
                      ? 32 : null,
                  decoration: BoxDecoration(
                      // color: TDTheme.of(context).brandColor1,
                    // color: themeModel.themeData.colorScheme.primaryContainer.withOpacity(0.5),
                    color: themeModel.colorModel.generalFillColorLight.withOpacity(0.2),
                      borderRadius:
                      const BorderRadius.all(Radius.circular(24))),
                )),
            Container(
                padding: EdgeInsets.only(
                    top: isInOrOutCapsule ? 3.0 : 2.0,
                    bottom: isInOrOutCapsule ? 1.0 : 0.0),
                child: _constructItem(context, badgeConfig, isInOrOutCapsule)),

            /// )
          ],
        ),
      ),
    );
  }

  Widget _badge(BadgeConfig? badgeConfig) {
    if (badgeConfig?.showBage ?? false) {
      if (badgeConfig?.tdBadge != null) {
        return badgeConfig!.tdBadge!;
      }
    }
    return Container();
  }

  Widget _constructItem(
      BuildContext context, BadgeConfig? badgeConfig, bool isInOrOutCapsule) {
    Widget child = Container();
    if (basicType == TDBottomTabBarBasicType.text) {
      child = _textItem(context, itemConfig.tabText!, isSelected,
          TDTheme.of(context).fontTitleMedium!);
    }
    if (basicType == TDBottomTabBarBasicType.expansionPanel) {
      if (itemConfig.popUpButtonConfig != null) {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TDIcons.view_list,
              size: 16.0,
              color: isSelected
                  ? TDTheme.of(context).brandNormalColor
                  : TDTheme.of(context).fontGyColor1,
            ),
            const SizedBox(width: 5),
            _textItem(context, itemConfig.tabText!, isSelected,
                TDTheme.of(context).fontTitleMedium!)
          ],
        );
      } else {
        child = _textItem(context, itemConfig.tabText!, isSelected,
            TDTheme.of(context).fontTitleMedium!);
      }
    }
    if (basicType == TDBottomTabBarBasicType.icon) {
      var selectedIcon = itemConfig.iconTypeConfig!.selectedIcon;
      var unSelectedIcon = itemConfig.iconTypeConfig!.unselectedIcon;
      if (itemConfig.iconTypeConfig!.useDefaultIcon ?? false) {
        /// selectedIcon = const TabIcon(isSelected: true, isPureIcon: true);
        selectedIcon = Icon(
          TDIcons.app,
          size: 24,
          color: TDTheme.of(context).brandNormalColor,
        );
        unSelectedIcon = Icon(
          TDIcons.app,
          size: 24,
          color: TDTheme.of(context).fontGyColor1,
        );
      }
      child = isSelected ? selectedIcon! : unSelectedIcon!;
    }

    if (basicType == TDBottomTabBarBasicType.iconText) {
      var selectedIcon = itemConfig.iconTextTypeConfig!.selectedIcon;
      var unSelectedIcon = itemConfig.iconTextTypeConfig!.unselectedIcon;
      if (itemConfig.iconTextTypeConfig!.useDefaultIcon ?? false) {
        var size = 24.0;
        if (isInOrOutCapsule) {
          size = 20.0;
        }
        selectedIcon = Icon(
          TDIcons.app,
          size: size,
          color: TDTheme.of(context).brandNormalColor,
        );
        unSelectedIcon = Icon(
          TDIcons.app,
          size: size,
          color: TDTheme.of(context).fontGyColor1,
        );
      }
      child = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isSelected ? selectedIcon! : unSelectedIcon!,
          _textItem(
            context,
            itemConfig.iconTextTypeConfig!.tabText,
            isSelected,
            TDTheme.of(context).fontBodyExtraSmall!,
          )
        ],
      );
    }

    var top = badgeConfig?.badgeTopOffset ?? -2;
    var right = badgeConfig?.badgeRightOffset ?? -10;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Visibility(
            visible: badgeConfig?.showBage ?? false,
            child:
            Positioned(top: top, right: right, child: _badge(badgeConfig))),
      ],
    );
  }

  Widget _textItem(
      BuildContext context, String text, bool isSelected, Font font) {
    ThemeData themeData = Provider.of<ThemeViewModel>(context).themeModel.themeData;
    return TDText(
      text,
      font: font,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      textColor: isSelected
          ? themeData.colorScheme.primary.withOpacity(0.7)
          : themeData.colorScheme.onSecondaryContainer,
      forceVerticalCenter: true,
    );
  }
}