import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/multi_state_widget.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'button.dart';

class PurlawWaterfallList extends StatefulWidget {
  final List<Widget> list;
  final ScrollController controller;
  final bool useTopPadding;
  final Future<void> Function() onPullRefresh;
  final NetworkLoadingState loadingState;
  final Widget? readyWidget;
  final double refresherOffset;
  const PurlawWaterfallList(
      {required this.list,
      required this.controller,
      this.useTopPadding = true,
      super.key,
      required this.onPullRefresh,
      required this.loadingState,
        this.refresherOffset = 0,
      this.readyWidget});

  @override
  State<PurlawWaterfallList> createState() => _PurlawWaterfallListState();
}

class _PurlawWaterfallListState extends State<PurlawWaterfallList> {
  bool errorRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      bool nsmBreak =
          (Responsive.checkWidth(constraints.maxWidth) != Responsive.sm);
      bool lgBreak =
          (Responsive.checkWidth(constraints.maxWidth) == Responsive.lg);
      var themeModel = Provider.of<ThemeViewModel>(context).themeModel;
      return RefreshIndicator(
        edgeOffset: widget.refresherOffset,
        onRefresh: widget.onPullRefresh,
        child: MultiStateWidget(
          state: widget.loadingState,
          builder: (_) => Container(
            padding: const EdgeInsets.only(left: 2, right: 2),
            width: Responsive.assignWidthMedium(constraints.maxWidth),
            child: WaterfallFlow.count(
              padding: (widget.useTopPadding
                  ? EdgeInsets.only(top: (lgBreak ? 84 : 64))
                  : null),
              crossAxisCount: (nsmBreak ? 4 : 2),
              controller: widget.controller,
              children: widget.list,
            ),
          ),
          readyWaitingWidget: widget.readyWidget,
          errorWidget: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("加载失败\n"),
                PurlawRRectButton(
                  height: 54,
                  width: 144,
                  radius: 12,
                  backgroundColor: themeModel.colorModel.generalFillColor,
                  onClick: () async {
                    setState(() {
                      errorRefreshing = true;
                    });
                    await widget.onPullRefresh();
                    setState(() {
                      errorRefreshing = false;
                    });
                  },
                  disabled: errorRefreshing,
                  disabledColor: themeModel.colorModel.generalFillColor,
                  child: Text(
                    (errorRefreshing ? "加载中" : "重新加载"),
                     style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
